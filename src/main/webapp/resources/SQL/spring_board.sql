----- **** 스프링 게시판 **** -----

show user;

create table spring_test
(no         number
,name       varchar2(100)
,writeday   date default sysdate
);

select *
from spring_test;

delete from spring_test;
commit;
drop table spring_test1 purge;

select * from tab;


-----------------------------------------------------------------------------------------
SHOW USER;
-- USER이(가) "HR"입니다.

select employee_id, first_name || ' ' || last_name AS ename,
       nvl( (salary + salary*commission_pct)*12 ,  salary*12) AS yearpay,
       case when substr(jubun,7,1) in ('1','3') then '남' else '여' end AS gender,
       extract(year from sysdate) - ( case when substr(jubun,7,1) in('1','2') then 1900 else 2000 end + to_number(substr(jubun,1,2)) ) + 1 AS age        
from employees
order by 1;


select * from tab;

select * 
from tbl_main_image;

select *
from tbl_member
where employee_id = ?;

select *
from tbl_loginhistory;


SELECT userid, name, email, mobile, postcode, address, detailaddress, extraaddress, gender 
     , birthyyyy, birthmm, birthdd, coin, point, registerday, pwdchangegap 
     , nvl(lastlogingap, TRUNC( months_between(sysdate, registerday) ) ) AS lastlogingap 
FROM 
( 
SELECT userid, name, email, mobile, postcode, address, detailaddress, extraaddress, gender 
          , substr(birthday, 1, 4) AS birthyyyy, substr(birthday, 6, 2) AS birthmm, substr(birthday, 9) AS birthdd 
          , coin, point, to_char(registerday, 'yyyy-mm-dd') AS registerday 
          , TRUNC( months_between(sysdate, lastpwdchangedate) ) AS pwdchangegap 
FROM tbl_member 
WHERE status=1 AND  userid = 'sist' AND pwd = 'asfasf'  
) M ;
CROSS JOIN 
( 
SELECT TRUNC( months_between(sysdate, MAX(logindate)) ) AS lastlogingap 
FROM tbl_loginhistory 
WHERE fk_userid = 'sist'  
) H;


    ------- **** 게시판(답변글쓰기가 없고, 파일첨부도 없는) 글쓰기 **** -------
desc tbl_member;

create table tbl_board
(seq         number                not null    -- 글번호
,fk_userid   varchar2(20)          not null    -- 사용자ID
,name        varchar2(20)          not null    -- 글쓴이 
,subject     Nvarchar2(200)        not null    -- 글제목
,content     Nvarchar2(2000)       not null    -- 글내용   -- clob (최대 4GB까지 허용) 
,pw          varchar2(20)          not null    -- 글암호
,readCount   number default 0      not null    -- 글조회수
,regDate     date default sysdate  not null    -- 글쓴시간
,status      number(1) default 1   not null    -- 글삭제여부   1:사용가능한 글,  0:삭제된글
,constraint PK_tbl_board_seq primary key(seq)
,constraint FK_tbl_board_fk_userid foreign key(fk_userid) references tbl_member(userid)
,constraint CK_tbl_board_status check( status in(0,1) )
);

create sequence boardSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

select *
from tbl_board
order by seq desc;

select previousseq, previoussubject
     , seq, fk_userid, name, subject, content, readCount
     , regDate, nextseq, nextsubject
from
(
    select lag(seq, 1) over(order by seq desc) AS previousseq
         , lag(subject, 1) over(order by seq desc) AS previoussubject
         , seq, fk_userid, name, subject, content, readCount
         , to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') AS regDate
         , lead(seq, 1) over(order by seq desc) AS nextseq
         , lead(subject, 1) over(order by seq desc) AS nextsubject
    from tbl_board
    where status = 1
)V
where V.seq = 2;


------------------------------------------------------------------------
   ----- **** 댓글 게시판 **** -----

/* 
  댓글쓰기(tblComment 테이블)를 성공하면 원게시물(tblBoard 테이블)에
  댓글의 갯수(1씩 증가)를 알려주는 컬럼 commentCount 을 추가하겠다. 
*/
drop table tbl_board purge;

create table tbl_board
(seq           number                not null    -- 글번호
,fk_userid     varchar2(20)          not null    -- 사용자ID
,name          varchar2(20)          not null    -- 글쓴이 
,subject       Nvarchar2(200)        not null    -- 글제목
,content       Nvarchar2(2000)       not null    -- 글내용   -- clob (최대 4GB까지 허용) 
,pw            varchar2(20)          not null    -- 글암호
,readCount     number default 0      not null    -- 글조회수
,regDate       date default sysdate  not null    -- 글쓴시간
,status        number(1) default 1   not null    -- 글삭제여부   1:사용가능한 글,  0:삭제된글
,commentCount  number default 0  not null  -- 댓글의 갯수
,constraint PK_tbl_board_seq primary key(seq)
,constraint FK_tbl_board_fk_userid foreign key(fk_userid) references tbl_member(userid)
,constraint CK_tbl_board_status check( status in(0,1) )
);

drop sequence boardSeq;

create sequence boardSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;


----- **** 댓글 테이블 생성 **** -----
create table tbl_comment
(seq           number               not null   -- 댓글번호
,fk_userid     varchar2(20)         not null   -- 사용자ID
,name          varchar2(20)         not null   -- 성명
,content       varchar2(1000)       not null   -- 댓글내용
,regDate       date default sysdate not null   -- 작성일자
,parentSeq     number               not null   -- 원게시물 글번호
,status        number(1) default 1  not null   -- 글삭제여부
                                               -- 1 : 사용가능한 글,  0 : 삭제된 글
                                               -- 댓글은 원글이 삭제되면 자동적으로 삭제되어야 한다.
,constraint PK_tbl_comment_seq primary key(seq)
,constraint FK_tbl_comment_userid foreign key(fk_userid) references tbl_member(userid)
,constraint FK_tbl_comment_parentSeq foreign key(parentSeq) references tbl_board(seq) on delete cascade
,constraint CK_tbl_comment_status check( status in(1,0) ) 
);

create sequence commentSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

select *
from tbl_comment
order by seq desc;


--- 회원들이 게시판에 글쓰기를 하면 글작성 1건당 POINT를 100점을 준다.
--- 회원들이 게시판에서 댓글쓰기를 하면 댓글작성 1건당 POINT를 50점을 준다.
--- 그런데 POINT는 300을 초과할 수 없다.

-- tbl_member 테이블에 POINT 컬럼에 check 제약을 추가한다.

alter table tbl_member
add constraint CK_tbl_member_point check( point between 0 and 300 );

update tbl_member set point = 301
where userid = 'leess';

select *
from tbl_comment
order by seq desc;

select *
from tbl_board
order by seq desc;

select *
from tbl_member
where userid = 'leess';


update tbl_member set point = 300
where userid = 'eomjh';

commit;

select *
from tbl_board
order by seq desc;


insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'luckkog', '권오윤', '나는 권오윤이다', '나는 권오윤이라고 해', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'sist', '쌍용이', '나는 쌍용', '나 쌍용아파트 살아', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'eomjh', '엄정화', '너 순신이니?', '엄정화는 나야', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'luckkog', '권오윤', 'hi!!', 'I am...', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'luckkog', '권오윤', '우리집', '우리집으로 다들 놀러와', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'sist', '쌍용이', 'JAVA', 'I LO~~~~~~VE JAVA', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'luckkog', '권오윤', 'project 끝낸 사람~?', 'very gooda~', '1234', default, default, default);

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status)
values(boardSeq.nextval, 'sist', '쌍용이', '야 C언어', '맞짱뜨자', '1234', default, default, default);

commit;


select seq, fk_userid, name, subject  
     , readcount, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate
     , commentCount
from tbl_board
where status = 1 and lower(subject) like '%' || lower('jA') || '%'
order by seq desc;
        
        
select subject
from tbl_board
where status = 1 and lower(subject) like '%' || lower('jA') || '%'   
order by seq desc;
  
  
select seq, fk_userid, name, subject, readCount, regDate, commentCount  
from
(      
select row_number() over(order by seq desc) as rno,
        seq, fk_userid, name, subject, readCount,
        to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate,
        commentCount
from tbl_board
where status = 1
-- and lower(subject) like '%' || lower('이') || '%'
) V
where rno between 1 and 10;

-------------------------------------------------
desc tbl_comment;

insert into tbl_comment(seq, fk_userid, name, content, parentseq)
values(commentSeq.nextval, 'sist', '쌍용이', '나다 임마', 3);

insert into tbl_comment(seq, fk_userid, name, content, parentseq)
values(commentSeq.nextval, 'sist', '쌍용이', '너다 임마', 3);

insert into tbl_comment(seq, fk_userid, name, content, parentseq)
values(commentSeq.nextval, 'sist', '쌍용이', '우리다 임마', 3);

insert into tbl_comment(seq, fk_userid, name, content, parentseq)
values(commentSeq.nextval, 'sist', '쌍용이', '그들이다 임마', 3);

insert into tbl_comment(seq, fk_userid, name, content, parentseq)
values(commentSeq.nextval, 'sist', '쌍용이', '나냐 임마', 3);

insert into tbl_comment(seq, fk_userid, name, content, parentseq)
values(commentSeq.nextval, 'sist', '쌍용이', '너냐 임마', 3);

insert into tbl_comment(seq, fk_userid, name, content, parentseq)
values(commentSeq.nextval, 'sist', '쌍용이', '우리냐 임마', 3);

insert into tbl_comment(seq, fk_userid, name, content, parentseq)
values(commentSeq.nextval, 'sist', '쌍용이', '그들이냐 임마', 3);

commit;

select *
from tbl_comment
order by seq desc;

select name, content, regDate
from 
(
    select row_number() over(order by seq desc) as rno, name, content, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate
    from tbl_comment
    where status = 1 and parentSeq = 3
)V
where rno between 1 and 5; -- 댓글의 1페이지

select name, content, regDate
from 
(
    select row_number() over(order by seq desc) as rno, name, content, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate
    from tbl_comment
    where status = 1 and parentSeq = 3
)V
where rno between 6 and 10; -- 댓글의 2페이지

select name, content, regDate
from 
(
    select row_number() over(order by seq desc) as rno, name, content, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate
    from tbl_comment
    where status = 1 and parentSeq = 3
)V
where rno between 11 and 15; -- 댓글의 3페이지

select name, content, regDate
from 
(
    select row_number() over(order by seq desc) as rno, name, content, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate
    from tbl_comment
    where status = 1 and parentSeq = 3
)V
where rno between 16 and 20; -- 댓글의 4페이지


update tbl_board set commentcount = 2
where seq = 12;

update tbl_board set commentcount = 23
where seq = 3;


select *
from tbl_board
order by seq desc;

-----------------------------------------------------------------------------------------------------------
            ------ ****** 댓글 및 답변글 및 파일첨부가 있는 게시판 ****** ------
drop table tbl_comment purge;
drop sequence commentSeq;
drop table tbl_board purge;
drop sequence boardSeq;

create table tbl_board
(seq           number                not null    -- 글번호
,fk_userid     varchar2(20)          not null    -- 사용자ID
,name          varchar2(20)          not null    -- 글쓴이 
,subject       Nvarchar2(200)        not null    -- 글제목
,content       Nvarchar2(2000)       not null    -- 글내용   -- clob (최대 4GB까지 허용) 
,pw            varchar2(20)          not null    -- 글암호
,readCount     number default 0      not null    -- 글조회수
,regDate       date default sysdate  not null    -- 글쓴시간
,status        number(1) default 1   not null    -- 글삭제여부   1:사용가능한 글,  0:삭제된글
,commentCount  number default 0  not null  -- 댓글의 개수

,groupno        number                not null   -- 답변글쓰기에 있어서 그룹번호 
                                                 -- 원글(부모글)과 답변글은 동일한 groupno 를 가진다.
                                                 -- 답변글이 아닌 원글(부모글)인 경우 groupno 의 값은 groupno 컬럼의 최대값(max)+1 로 한다.

,fk_seq         number default 0      not null   -- fk_seq 컬럼은 절대로 foreign key가 아니다.!!!!!!
                                                 -- fk_seq 컬럼은 자신의 글(답변글)에 있어서 
                                                 -- 원글(부모글)이 누구인지에 대한 정보값이다.
                                                 -- 답변글쓰기에 있어서 답변글이라면 fk_seq 컬럼의 값은 
                                                 -- 원글(부모글)의 seq 컬럼의 값을 가지게 되며,
                                                 -- 답변글이 아닌 원글일 경우 0 을 가지도록 한다.

,depthno        number default 0       not null  -- 답변글쓰기에 있어서 답변글 이라면
                                                 -- 원글(부모글)의 depthno + 1 을 가지게 되며,
                                                 -- 답변글이 아닌 원글일 경우 0 을 가지도록 한다.

,fileName       varchar2(255)                    -- WAS(톰캣)에 저장될 파일명(20201208092715353243254235235234.png) --> 날짜시간나노초                                       
,orgFilename    varchar2(255)                    -- 진짜 파일명(강아지.png)  // 사용자가 파일을 업로드 하거나 파일을 다운로드 할때 사용되어지는 파일명 
,fileSize       number                           -- 파일크기  

,constraint PK_tbl_board_seq primary key(seq)
,constraint FK_tbl_board_fk_userid foreign key(fk_userid) references tbl_member(userid)
,constraint CK_tbl_board_status check( status in(0,1) )
);

create sequence boardSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;



----- **** 댓글 테이블 생성 **** -----
create table tbl_comment
(seq           number               not null   -- 댓글번호
,fk_userid     varchar2(20)         not null   -- 사용자ID
,name          varchar2(20)         not null   -- 성명
,content       varchar2(1000)       not null   -- 댓글내용
,regDate       date default sysdate not null   -- 작성일자
,parentSeq     number               not null   -- 원게시물 글번호
,status        number(1) default 1  not null   -- 글삭제여부
                                               -- 1 : 사용가능한 글,  0 : 삭제된 글
                                               -- 댓글은 원글이 삭제되면 자동적으로 삭제되어야 한다.
,constraint PK_tbl_comment_seq primary key(seq)
,constraint FK_tbl_comment_userid foreign key(fk_userid) references tbl_member(userid)
,constraint FK_tbl_comment_parentSeq foreign key(parentSeq) references tbl_board(seq) on delete cascade
,constraint CK_tbl_comment_status check( status in(1,0) ) 
);

create sequence commentSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

desc tbl_board;

-- 프로시저 생성
begin
    for i in 1..100 loop
        insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status, groupno)
        values(boardSeq.nextval, 'leess', '이순신', '이순신입니다'||i, '안녕하세요~ 입짧은 이순신'|| i ||'입니다아~압', '1234', default, default, default, i);
    end loop;
end;


delete from tbl_board;

begin
    for i in 101..200 loop
        insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status, groupno)
        values(boardSeq.nextval, 'eomjh', '엄정화', '엄정화입니다'||i, '안녕하세요~ 입안짧은 엄정화'|| i ||'입니다아~압', '1234', default, default, default, i);
    end loop;
end;

commit;

select *
from tbl_board
order by seq desc;


---- **** 답변글쓰기는 일반회원은 불가하고 직원(관리자)들만 답변글쓰기가 가능하도록 한다 **** ----
select * 
from tbl_member;

-- *** tbl_member 테이블에 gradelevel 이라는 컬럼을 추가한다. *** -- 
alter table tbl_member add gradelevel number default 1; 

-- *** 직원(관리자)들에게는 gradelevel 컬럼의 값을 10으로 부여한다. gradelevel 컬럼의 값이 10인 직원들만 답변글쓰기가 가능하다. *** --
update tbl_member set gradelevel = 10
where userid in('admin', 'luckkog');

commit;

--- *** 글번호 197에 대한 답변글쓰기를 한다면 아래와 같이 insert를 해야 한다.
select *
from tbl_board
where seq = 197;

insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status, groupno, fk_seq, depthno)
values(boardSeq.nextval, 'admin', '관리자', '글번호 197에 대한 답변글입니다.', '답변내용입니다. 행복하세요~~', '1234', default, default, default, 197, 197, 1);

commit;

---- *** 답변글이 있을시 글목록 보여주기 *** ----
select *
from tbl_board
order by seq desc;

--- 계층형 쿼리
select seq, fk_userid, name, subject, readCount, regDate, commentCount,
       groupno, fk_seq, depthno
from
(
    select rownum AS rno
         , seq, fk_userid, name, subject, readCount,regDate, commentCount
         , groupno, fk_seq, depthno
    from
    (      
        select seq, fk_userid, name, subject, readCount,
               to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate,
               commentCount, 
               groupno, fk_seq, depthno
        from tbl_board
        where status = 1
        start with fk_seq = 0 
        connect by prior seq = fk_seq   --- connect by prior 다음에 나오는 컬럼 seq은 start with 되어지는 행의 컬럼이다.
                                        --- fk_seq 는 start with 되어지는 행이 아닌 다른행에 존재하는 컬럼이다.
        order siblings by groupno desc, seq asc --- groupno 에 대해서 내림차순으로 나타나는데 groupno가 같은 행들은 붙어서 나온다.
        -- order siblings by를 사용하는 이유는 그냥 정렬(order by)하면 계층구조가 깨진다. 
        -- 그래서 계층구조를 그대로 유지하면서 동일한 groupno를 가진 행끼리 정렬을 하려면 siblings를 써야만 한다.  
    ) V
) T
where rno between 1 and 10;

update tbl_member set point = 0
where userid in('admin', 'luckkog');

commit;


--- *** tbl_member 테이블에 존재하는 제약조건 조회하기 *** ---
select *
from user_constraints
where table_name = 'TBL_MEMBER';

alter table tbl_member
drop constraint CK_TBL_MEMBER_POINT;

select *
from tbl_board
order by seq desc;



