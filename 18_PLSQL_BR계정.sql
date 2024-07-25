/*
    < PL/SQL >
    1. Procedure Language extension to SQL
    2. 오라클내에 내장되어 있는 절차적 언어
    3. 변수의 정의, 조건/반복처리 등을 지원하여 BLOCK구조로 다수의 SQL문을 한번에 실행시킬 수 있음
    4. 구조
       1) 선언부    : DECLARE로 시작, 변수 및 상수를 선언 및 초기화 가능
       2) 실행부    : BEGIN로 시작, 필수로 작성, SQL문 또는 제어문(조건/반복) 등의 로직을 기술 
       3) 예외처리부: EXCEPTION으로 시작, 예외발생시 실행할 구문을 미리 정의
*/

-- 화면에 문구 출력

--> 출력결과를 보기위해서 SERVEROUTPUT 옵션을 ON으로 설정
SET SERVEROUTPUT ON;

BEGIN
    -- System.out.println("구문"); -- 자바
    DBMS_OUTPUT.PUT_LINE('HELLO ORACLE');
END;
/

/*
    1. DECLARE 선언부
       변수 및 상수 선언 공간 (초기화도 가능)
       일반타입변수, 레퍼런스타입변수, ROW타입변수
    
    1_1) 일반타입 변수 선언 및 초기화
         [표현법] 변수명 [CONSTANT] 데이터타입 [:= 값];
*/
DECLARE
    EID NUMBER;
    ENAME VARCHAR2(20);
    PI CONSTANT NUMBER := 3.14;
BEGIN
    --EID := 800;
    --ENAME := '홍길동';
    
    EID := &번호;
    ENAME := '&이름';
    
    DBMS_OUTPUT.PUT_LINE('EID : ' || EID);
    DBMS_OUTPUT.PUT_LINE('ENAME : ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('PI : ' || PI);
END;
/

/*
    1_2) 레퍼런스 타입 변수 선언 및 초기화
         특정 테이블의 특정 컬럼의 데이터타입을 참조해서 동일하게 지정
         [표현법] 변수명 테이블명.컬럼명%TYPE;
*/
DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
BEGIN
    --EID := '300';
    --ENAME := '강보람';
    --SAL := 3000000;
    
    -- 사번이 200번인 사원의 사번, 이름, 급여 조회해서 각 변수에 대입
    SELECT EMP_ID, EMP_NAME, SALARY
      INTO EID, ENAME, SAL
      FROM EMPLOYEE
     --WHERE EMP_ID = '200';
     WHERE EMP_ID = '&사번';
    
    DBMS_OUTPUT.PUT_LINE('EID: ' || EID);
    DBMS_OUTPUT.PUT_LINE('ENAME: ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('SAL: ' || SAL);
END;
/

/*
    레퍼런스타입변수로 EID, ENAME, JCODE, SAL, DTITLE을 선언하고 
    각 자료형을 EMPLOYEE(EMP_ID, EMP_NAME, JOB_CODE, SALARY), DEPARTMENT(DEPT_TITLE)로 참조
    
    사용자가 입력한 사번의 사원 조회
    사번, 사원명, 직급코드, 급여, 부서명을 조회한 후 각 변수에 담아 출력 
*/
DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    JCODE EMPLOYEE.JOB_CODE%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
    DTITLE DEPARTMENT.DEPT_TITLE%TYPE;
BEGIN
    SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY, DEPT_TITLE
      INTO EID, ENAME, JCODE, SAL, DTITLE
      FROM EMPLOYEE
      JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
     WHERE EMP_ID = '&사번';
     
    DBMS_OUTPUT.PUT_LINE(EID || ', ' || ENAME || ', ' || JCODE || ', ' || SAL || ', ' || DTITLE);
END;
/

/*
    1_3) ROW타입 변수 선언
         테이블의 한 행에 대한 모든 컬럼값을 한꺼번에 담을 수 있는 변수 
         [표현법] 변수명 테이블명%ROWTYPE;
*/
DECLARE
    E EMPLOYEE%ROWTYPE;
BEGIN
    SELECT *
      INTO E
      FROM EMPLOYEE
     WHERE EMP_ID = '&사번';
     
    DBMS_OUTPUT.PUT_LINE('사원명: ' || E.EMP_NAME);
    DBMS_OUTPUT.PUT_LINE('급여: ' || E.SALARY);
    DBMS_OUTPUT.PUT_LINE('보너스: ' || NVL(E.BONUS,0));
END;
/

-----------------------------------------------------------------------------

/*
    2. BEGIN 실행부
       실행할 SQL문, 제어문(조건문/반복문) 등의 로직 기술 가능
    
    2_1) 조건문(IF)
    
    [표현법]
    IF 조건식1
        THEN 실행내용1
    [ELSIF 조건식2
        THEN 실행내용2]
    ...
    [ELSE 실행내용N]
    END IF;
*/

-- 사번 입력받은 후 해당 사원의 사번, 이름, 급여, 보너스율(%) 출력
-- 단, 보너스를 받지 않는 사원은 보너스율 출력전 '보너스를 지급받지 않는 사원입니다' 출력
DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    SAL EMPLOYEE.SALARY%TYPE;
    BONUS EMPLOYEE.BONUS%TYPE;
BEGIN
    SELECT EMP_ID, EMP_NAME, SALARY, NVL(BONUS, 0)
      INTO EID, ENAME, SAL, BONUS
      FROM EMPLOYEE
     WHERE EMP_ID = '&사번';
     
    DBMS_OUTPUT.PUT_LINE('사번: ' || EID);
    DBMS_OUTPUT.PUT_LINE('이름: ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('급여: ' || SAL || '원');
    
    IF BONUS = 0
        THEN DBMS_OUTPUT.PUT_LINE('보너스를 지급받지 않는 사원입니다');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('보너스율: ' || BONUS*100 || '%');
    END IF;    
END;
/

/*
    레퍼런스타입변수 (EID, ENAME, DTITLE, NCODE) 선언 
    일반타입변수 (TEAM 문자타입) 선언    => '국내팀' 또는 '해외팀' 대입 예정
    
    사용자가 입력한 사번의 사원을 조회
    사번, 이름, 부서명, 근무국가코드 조회후 레퍼런스타입변수에 대입
    이때 NCODE값이 'KO'일 경우 TEAM변수에 '국내팀' 대입
                  그게아닐경우 TEAM변수에 '해외팀' 대입
                    
    결과 출력 (사번, 이름, 부서명, 소속)
*/
DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
    DTITLE DEPARTMENT.DEPT_TITLE%TYPE;
    NCODE LOCATION.NATIONAL_CODE%TYPE;
    TEAM VARCHAR2(10);
BEGIN
    SELECT EMP_ID, EMP_NAME, DEPT_TITLE, NATIONAL_CODE
      INTO EID, ENAME, DTITLE, NCODE
      FROM EMPLOYEE
      JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
      JOIN LOCATION ON (LOCATION_ID = LOCAL_CODE)
     WHERE EMP_ID = '&사번';
     
    IF NCODE = 'KO'
        THEN TEAM := '국내팀';
    ELSE 
        TEAM := '해외팀';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('사번: ' || EID);
    DBMS_OUTPUT.PUT_LINE('이름: ' || ENAME);
    DBMS_OUTPUT.PUT_LINE('부서: ' || DTITLE);
    DBMS_OUTPUT.PUT_LINE('소속: ' || TEAM);
END;
/

/*
    사용자에게 입력받은 사번의 사원의 급여를 조회해서 SAL변수에 대입
    급여가 500만 이상이면 '고급'
    급여가 300만 이상이면 '중급'
    급여가 300만 미만이면 '초급'
    
    '해당 사원의 급여등급은 XX입니다'
*/
DECLARE
    SAL EMPLOYEE.SALARY%TYPE;
    GRADE VARCHAR2(10);
BEGIN
    SELECT SALARY
      INTO SAL
      FROM EMPLOYEE
     WHERE EMP_ID = '&사번';
     
    IF SAL >= 5000000 THEN GRADE := '고급';
    ELSIF SAL >= 3000000 THEN GRADE := '중급';
    ELSE GRADE := '초급';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('해당 사원의 급여 등급은 ' || GRADE || '입니다');
END;
/

/*
    2_2) 조건문 (CASE WHEN THEN)
    
    [표현법]
    CASE 비교대상자
        WHEN 비교값1 THEN 결과값1
        WHEN 비교값2 THEN 결과값2
        ...
        ELSE 결과값N
    END;
*/
DECLARE
    EMP EMPLOYEE%ROWTYPE;
    GEN CHAR(6);
BEGIN
    SELECT *
      INTO EMP
      FROM EMPLOYEE
     WHERE EMP_ID = '&사번';
     
    GEN := CASE SUBSTR(EMP.EMP_NO, 8, 1)
            WHEN '1' THEN '남자'
            WHEN '2' THEN '여자'
            WHEN '3' THEN '남자'
            WHEN '4' THEN '여자'
           END;
           
    DBMS_OUTPUT.PUT_LINE(GEN || '입니다');
END;
/

/*
    2_3) 반복문 (BASIC LOOP)
    
    [표현법]
    LOOP
        반복적으로 실행할 구문;
        
        * 반복문을 빠져나갈수 있는 구문
    END LOOP;
    
    * 반복문 빠져나가는 구문 (2가지)
    1) IF 조건식 THEN EXIT; END IF;
    2) EXIT WHEN 조건식;
*/

-- 1~5까지 순차적으로 1씩 증가하는 값을 출력
DECLARE
    I NUMBER := 1;
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE(I);
        I := I + 1;
        
        EXIT WHEN I = 6;
    END LOOP;
END;
/

/*
    2_4) 반복문 (FOR LOOP)
    
    [표현법]
    FOR 변수 IN [REVERSE] 초기값..최종값
    LOOP
        반복적으로 실행할 구문;
    END LOOP;
*/
BEGIN
    FOR I IN /*REVERSE*/ 1..5
    LOOP
        DBMS_OUTPUT.PUT_LINE(I);
    END LOOP;
    
END;
/

DROP TABLE TEST;
CREATE TABLE TEST(
    TNO NUMBER PRIMARY KEY,
    TDATE DATE
);

CREATE SEQUENCE SEQ_TNO
    MAXVALUE 1000
    NOCYCLE
    NOCACHE;

BEGIN
    FOR I IN 1..100
    LOOP
        INSERT INTO TEST(TNO, TDATE) VALUES(SEQ_TNO.NEXTVAL, SYSDATE-I);
    END LOOP;
END;
/

SELECT * FROM TEST;

/*
    2_5) 반복문 (WHILE LOOP)
    
    [표현법]
    WHILE 반복문이수행될조건
    LOOP
        반복적으로 실행할 구문;
    END LOOP;
*/
DECLARE
    I NUMBER := 1;
BEGIN
    WHILE I < 6
    LOOP
        DBMS_OUTPUT.PUT_LINE(I);
        I := I + 1;
    END LOOP;
    
END;
/

-------------------------------------------------------------------------------

/*
    3. 예외처리부
    
    [표현법]
    EXCEPTION
        WHEN 예외명1 THEN 예외처리구문1;
        WHEN 예외명2 THEN 예외처리구문2;
        ...
        WHEN OTHERS THEN 예외처리구문N;
    
    * 시스템예외 (미리 정의해둔 예외)
      ㄴ NO_DATA_FOUND : SELECT한 결과가 한 행도 없을 경우
      ㄴ TOO_MANY_ROWS : SELECT한 결과가 여러행일 경우 
      ㄴ ZERO_DIVIDE   : 0으로 나눌 때
      ㄴ DUP_VAL_ON_INDEX : UNIQUE 제약조건에 위배되었을 경우
      ....
        
*/
-- 사용자가 입력한 수로 나눈셈 연산한 결과 출력
DECLARE
    RESULT NUMBER;
BEGIN
    RESULT := 10 / &숫자;
    DBMS_OUTPUT.PUT_LINE('결과: ' || RESULT);
EXCEPTION
    WHEN ZERO_DIVIDE THEN DBMS_OUTPUT.PUT_LINE('나누기 연산시 0으로 나눌 수 없습니다');
END;
/

-- UNIQUE 제약조건 위배
BEGIN
    UPDATE EMPLOYEE
       SET EMP_ID = '&변경할사번'
     WHERE EMP_NAME = '노옹철';
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN DBMS_OUTPUT.PUT_LINE('이미 존재하는 사번입니다');
END;
/

DECLARE
    EID EMPLOYEE.EMP_ID%TYPE;
    ENAME EMPLOYEE.EMP_NAME%TYPE;
BEGIN
    SELECT EMP_ID, EMP_NAME
      INTO EID, ENAME
      FROM EMPLOYEE
     WHERE MANAGER_ID = '&사수사번';
     
    DBMS_OUTPUT.PUT_LINE('사번: ' || EID);
    DBMS_OUTPUT.PUT_LINE('이름: ' || ENAME);
EXCEPTION
    WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('너무 많은 행이 조회되었습니다');
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('조회 결과가 없습니다');
END;
/








