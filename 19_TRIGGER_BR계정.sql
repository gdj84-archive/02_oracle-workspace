/*
    < TRIGGER 트리거 >
    1. 특정 테이블에 변경사항(이벤트) 발생시 묵시적으로 실행시킬 내용을 정의해둘 수 있는
       데이터베이스 객체
    2. PL/SQL 구문을 이용해서 생성
    3. 종류
       ㄴ SQL문 실행시기
          - BEFORE TRIGGER : 특정테이블에 이벤트가 발생되기 전에 트리거 실행
          - AFTER  TRIGGER : 특정테이블에 이벤트가 발생된 후에 트리거 실행 
       ㄴ SQL문에 영향을 받는 행수
          - STATEMENT TRIGGER : 이벤트가 발생한 SQL문에 대해 딱 한번만 트리거 실행 
          - ROW TRIGGER       : 이벤트가 발생된 행 수만큼 매번 트리거 실행 (FOR EACH ROW 옵션 기술)
                                ㄴ :OLD - BEFORE UPDATE (수정전 데이터), BEFORE DELETE (삭제전 데이터)
                                ㄴ :NEW - AFTER INSERT (추가된 데이터), AFTER UPDATE (수정후 데이터)
                                
    ex)
    1) 회원탈퇴시 회원테이블에 delete 이벤트 발생 이때 탈퇴회원테이블에 자동으로 insert 처리 
    2) 회원신고시 신고테이블에 insert 이벤트 발생 이때 일정수를 넘겼을 경우 회원테이블에 회원상태를 자동으로 블랙리스트로 update처리 
    3) 상품입출고시 입출고테이블에 insert 이벤트 발생 이때 상품테이블에 해당 상품의 재고수량을 자동으로 update처리
*/

/*
    1. 트리거 생성 
    
    [표현법]
    CREATE [OR REPLACE] TRIGGER 트리거명 
    BEFORE|AFTER  INSERT|UPDATE|DELETE  ON  테이블명        --> 이벤트 감지할 테이블 지정
    [FOR EACH ROW]                                          --> 행트리거로 지정
    [DECLARE
        변수선언;]
    BEGIN
        실행내용(위에 지정된 테이블에 이벤트 발생시 묵시적으로(자동으로) 실행할 구문)
    [EXCEPTION
        예외처리구문;]
    END;
    /
    
*/

-- EMPLOYEE 테이블에 새로운 행이 INSERT 될 때 자동으로 메세지 출력되는 트리거 정의
SET SERVEROUTPUT ON;

CREATE OR REPLACE TRIGGER TRG_01
AFTER INSERT ON EMPLOYEE
BEGIN
    DBMS_OUTPUT.PUT_LINE('신입사원님 환영합니다.');
END;
/

INSERT INTO EMPLOYEE(EMP_ID, EMP_NAME, EMP_NO, DEPT_CODE, JOB_CODE, HIRE_DATE)
VALUES(500, '이순신', '111111-2222222', 'D7', 'J7', SYSDATE);

INSERT INTO EMPLOYEE(EMP_ID, EMP_NAME, EMP_NO, DEPT_CODE, JOB_CODE, HIRE_DATE)
VALUES(501, '강개순', '111111-2222222', 'D7', 'J7', SYSDATE);


-- EMP_DEPT 테이블에 UPDATE 이벤트 발생시 자동으로 메세지 출력 
CREATE OR REPLACE TRIGGER TRG_02
AFTER UPDATE ON EMP_DEPT
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE(:NEW.EMP_NAME || '님의 정보가 수정되었습니다.');
END;
/

UPDATE EMP_DEPT
   SET DEPT_CODE = 'D2';


-------------------------------------------------------------------------------

-- * 상품 입고 및 출고 관련 예시 

-- 1) 상품에 대한 데이터를 보관할 테이블 생성 (TB_PRODUCT)
CREATE TABLE TB_PRODUCT(
    PCODE VARCHAR2(8)  PRIMARY KEY   -- 상품코드 (PRO_001, PRO_002, PRO_003, ..)
  , PNAME VARCHAR2(30) NOT NULL
  , BRAND VARCHAR2(30) NOT NULL
  , PRICE NUMBER       NULL
  , STOCK NUMBER DEFAULT 0 NOT NULL
);

-- 상품코드로 활용할 시퀀스 생성 (SEQ_PCODE)
CREATE SEQUENCE SEQ_PCODE
    NOCACHE;

-- 샘플데이터 추가 
INSERT
  INTO TB_PRODUCT(PCODE, PNAME, BRAND, PRICE)
VALUES ('PRO_' || LPAD(SEQ_PCODE.NEXTVAL, 3, '0'), '갤럭시20', '삼성', 1400000);

INSERT
  INTO TB_PRODUCT(PCODE, PNAME, BRAND, PRICE, STOCK)
VALUES ('PRO_' || LPAD(SEQ_PCODE.NEXTVAL, 3, '0'), '아이폰15PRO', '애플', 1500000, 10);

INSERT
  INTO TB_PRODUCT(PCODE, PNAME, BRAND, PRICE, STOCK)
VALUES ('PRO_' || LPAD(SEQ_PCODE.NEXTVAL, 3, '0'), '대륙폰', '샤오미', 800000, 20);

SELECT * FROM TB_PRODUCT; -- PRO_001, PRO_002, PRO_003

COMMIT;

-- 2) 상품 입출고 이력 테이블 생성 (TB_PRODETAIL)
CREATE TABLE TB_PRODETAIL(
    DCODE NUMBER        PRIMARY KEY
  , PCODE VARCHAR2(8)   REFERENCES TB_PRODUCT
  , PDATE DATE          NOT NULL
  , AMOUNT NUMBER       NOT NULL
  , STATUS CHAR(6)      CHECK(STATUS IN('입고', '출고'))
);

-- 이력번호로 활용할 시퀀스 생성 (SEQ_DCODE)
CREATE SEQUENCE SEQ_DCODE
    START WITH 10000
    NOCACHE;

/*
    * 입고 또는 출고 기능 
    1) 입출고이력 테이블 INSERT 
    2) 상품 테이블 재고수량 UPDATE 
*/

-- PRO_001 상품이 오늘날짜로 10개 입고
INSERT 
  INTO TB_PRODETAIL 
VALUES (SEQ_DCODE.NEXTVAL, 'PRO_001', SYSDATE, 10, '입고');

UPDATE TB_PRODUCT
   SET STOCK = STOCK + 10
 WHERE PCODE = 'PRO_001';

COMMIT;

-- PRO_002 상품이 오늘날짜로 5개 출고
INSERT
  INTO TB_PRODETAIL
VALUES (SEQ_DCODE.NEXTVAL, 'PRO_002', SYSDATE, 5, '출고');

UPDATE TB_PRODUCT
   SET STOCK = STOCK - 5
 WHERE PCODE = 'PRO_002';

COMMIT;

-- PRO_003 상품이 오늘날짜로 20개 입고
INSERT
  INTO TB_PRODETAIL
VALUES (SEQ_DCODE.NEXTVAL, 'PRO_003', SYSDATE, 20, '입고');

UPDATE TB_PRODUCT
   SET STOCK = STOCK - 20
 WHERE PCODE = 'PRO_003'; --> UPDATE 실패
 
ROLLBACK;

/*
    * 트리거 정의 
      TB_PRODETAIL 테이블에 INSERT 이벤트 발생 후 
      자동으로 TB_PRODUCT 테이블의 STOCK값을 UPDATE 해주는 
      
      - INSERT된 데이터의 STATUS값이 '입고' 일 경우
        UPDATE TB_PRODUCT
           SET STOCK = STOCK + INSERT된데이터의AMOUNT
         WHERE PCODE = INSERT된데이터의PCODE;
         
      - '출고'일 경우
        UPDATE TB_PRODUCT
           SET STOCK = STOCK - INSERT된데이터의AMOUNT
         WHERE PCODE = INSERT된데이터의PCODE;
*/
CREATE OR REPLACE TRIGGER TRG_03
AFTER INSERT ON TB_PRODETAIL 
FOR EACH ROW
BEGIN
    IF :NEW.STATUS = '입고'
        THEN
            UPDATE TB_PRODUCT
               SET STOCK = STOCK + :NEW.AMOUNT
             WHERE PCODE = :NEW.PCODE;
    ELSE
        UPDATE TB_PRODUCT
           SET STOCK = STOCK - :NEW.AMOUNT
         WHERE PCODE = :NEW.PCODE;
    END IF;
END;
/

-- PRO_003 상품이 오늘날짜로 7개 출고
INSERT
  INTO TB_PRODETAIL
VALUES (SEQ_DCODE.NEXTVAL, 'PRO_003', SYSDATE, 7, '출고');

-- PRO_001 상품이 오늘날짜로 100개 입고
INSERT
  INTO TB_PRODETAIL
VALUES (SEQ_DCODE.NEXTVAL, 'PRO_001', SYSDATE, 100, '입고');






