package com.spring.board.service;

import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;
import java.util.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.test.annotation.Rollback;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.spring.board.common.AES256;
import com.spring.board.common.FileManager;
import com.spring.board.model.*;

//=== #31. Service 선언 === 
//트랜잭션 처리를 담당하는곳 , 업무를 처리하는 곳, 비지니스(Business)단
@Service
public class BoardService implements InterBoardService {

	/*
	    주문
	  ==> 주문테이블 insert (DAO에 있는 insert 관련 method 호출)
	  ==> 제품테이블에 주문받은 제품의 개수는 주문량만큼 감소해야 한다. (DAO에 있는 제품 테이블에 update 관련 method 호출)
	  ==> 장바구니에서 주문을 한 경우라면 장바구니 비우기를 해야한다. (DAO에 있는 제품 테이블에 delete 관련 method 호출)
	  ==> 회원테이블에 포인트(마일리지)를 증가시켜주어야 한다. (DAO에 있는 회원 테이블에 update 관련 method 호출)
	    
	    위에서 호출된 4가지의 메소드가 모두 성공되었다면 commit 해주고
	  1개라도 실패하면 rollback 해준다. 이러한 트랜잭션 처리를 해주는 곳이 Service 단이다.
	 */
	
	// === #34. 의존객체 주입하기(DI: Dependency Injection) ===
	@Autowired
	private InterBoardDAO dao;
    // Type 에 따라 Spring 컨테이너가 알아서 bean 으로 등록된 com.spring.model.BoardDAO 의 bean 을  dao 에 주입시켜준다. 
	// 그러므로 dao 는 null 이 아니다.

	
	// === #45. 양방향 암호화 알고리즘인 AES256 를 사용하여 복호화 하기 위한 클래스 의존객체 주입하기(DI: Dependency Injection) === //
	@Autowired
	private AES256 aes;
	// Type 에 따라 Spring 컨테이너가 알아서 bean 으로 등록된 com.spring.common.AES256 의 bean 을 aes 에 주입시켜준다. 
	// 그러므로 aes 는 null 이 아니다
	// com.spring.common.AES256 의 bean은 /webapp/WEB-INF/spring/appServlet/servlet-context.xml 파일에서 bean으로 등록시켜주었음.
	
	@Autowired     // Type에 따라 알아서 Bean 을 주입해준다.
	private FileManager fileManager;
	
	// model단 (BoardDAO)에 존재하는 메소드( test_insert() )를 호출한다.
	@Override
	public int test_insert() {
		return dao.test_insert();
	}

	
	// model단 (BoardDAO)에 존재하는 메소드( test_select() )를 호출한다.
	@Override
	public List<TestVO> test_select() {
		List<TestVO> testvoList = dao.test_select();
		return testvoList;
	}

	
	// model단 (BoardDAO)에 존재하는 메소드( test_insert(Map<String, String> paraMap) )를 호출한다.
	@Override
	public int test_insert(Map<String, String> paraMap) {
		int n = dao.test_insert(paraMap);
		return n;
	}

	
	// model단 (BoardDAO)에 존재하는 메소드( test_insert(TestVO vo) )를 호출한다.
	@Override
	public int test_insert(TestVO vo) {
		int n = dao.test_insert(vo);
		return n;
	}
	
	
	// model단 (BoardDAO)에 존재하는 메소드( test_employees() )를 호출한다.
	@Override
	public List<Map<String, String>> test_employees() {
		List<Map<String, String>> empList = dao.test_employees();
		return empList;
	}
	
	
	// === #37. 메인 페이지용 이미지 파일을 가져오기 === //
	@Override
	public List<String> getImgfilenameList() {
		List<String> imgfilenameList = dao.getImgfilenameList();
		return imgfilenameList;
	}
	
	
	// === #42. 로그인 처리하기 === //
	@Override
	public MemberVO getLoginMember(Map<String, String> paraMap) {
		
		MemberVO loginuser = dao.getLoginMember(paraMap);
		
		// === #48. aes 의존객체를 사용하여 로그인 되어진 사용자(loginuser)의 이메일 값을 복호화 하도록 한다. ===
		//			또한 암호변경 메시지와 휴면처리 유무 메시지를 띄우도록 업무처리를 하도록 한다.
		if (loginuser != null && loginuser.getPwdchangegap() >= 3) {
			// 마지막으로 암호를 변경한 날짜가 현재시각으로부터 3개월이 지났으면 
			loginuser.setRequirePwdChange(true); // 로그인시 암호를 변경하라는 alert를 띄우도록 한다.
		}
		
		
		if (loginuser != null && loginuser.getLastlogingap() >= 12 ) {
			// 마지막으로 로그인한 날짜 시간이 현재시각으로부터 1년이 지났으면 휴면으로 지정
			loginuser.setIdle(1);
			
			// === tbl_member 테이블의 idle 컬럼의 값을 1로 변경 하기 === //
			int n = dao.updateIdle(paraMap.get("userid"));
		}
		
		if (loginuser != null) {
			String email = "";
			try {
				email = aes.decrypt(loginuser.getEmail());
			} catch (UnsupportedEncodingException | GeneralSecurityException e) {
				e.printStackTrace();
			} 
			loginuser.setEmail(email);
		}
		
		return loginuser;
	}
	
	
	// === #55. 글쓰기(파일첨부가 없는 글쓰기) === //
	@Override
	public int add(BoardVO boardvo) {
		
		// === #144. 글쓰기가 원글쓰기인지 아니면 답변글쓰기인지를 구분하여 
		// 			 tbl_board 테이블에 insert를 해주어야 한다.
		//			  원글쓰기라면 tbl_board 테이블의 groupno 컬럼의 값은 
		//			 groupno 컬럼의 최대값(max)+1로 해서 insert 해야 하고,
		//			  답변글쓰기라면 넘겨받은 값(boardvo)을 그대로 insert 해주어야 한다.
		
		// == 원글쓰기인지 답변글쓰기인지 구분하기
		if (boardvo.getFk_seq() == null || boardvo.getFk_seq().trim().isEmpty()) {
			// 원글쓰기라면 groupno 컬럼의 값은 groupno 컬럼의 최대값(max)+1로 해야 한다.
			int groupno = dao.getGroupnoMax() + 1;
			boardvo.setGroupno(String.valueOf(groupno));
		}
		
		int n = dao.add(boardvo);
		return n;
	}
	
	
	// === #59. 페이징 처리를 안한 검색어가 없는 전체 글목록 보여주기 === //
	@Override
	public List<BoardVO> boardListNoSearch() {
		List<BoardVO> boardList = dao.boardListNoSearch();
		return boardList;
	}
	
	
	// === #63. 글 1개를 보여주는 페이지 요청 === //
	// (먼저 로그인을 한 상태에서 다른 사람의 글을 조회할 경우에는 글조회수 컬럼의 값을 1 증가시켜야 한다.) 
	@Override
	public BoardVO getView(String seq, String login_userid) {
						// login_userid는 로그인을 한 상태라면 로그인한 사용자의 userid이고, 
						// 로그인을 하지 않은 상태라면 login_userid는 null이다.
		BoardVO boardvo = dao.getView(seq); // 글 1개 조회하기
		
		if ( login_userid != null && !boardvo.getFk_userid().equals(login_userid) ) {
			// 글 조회수 증가는 로그인을 한 상태에서 다른사람의 글을 읽을 때만 실행되도록 해야 한다.

			dao.setAddReadCount(seq); // 글 조회수 1증가 하기 
			boardvo = dao.getView(seq); // 글 1개 조회하기
		}
		return boardvo;
	}
	
	
	// === #70. 글조회수 증가는 없고 단순히 글1개 조회만을 해주는 것 === //
	@Override
	public BoardVO getViewWithNoAddCount(String seq) {
		BoardVO boardvo = dao.getView(seq); // 글 1개 조회하기
		return boardvo;
	}


	// === #73. 1개글 수정하기 === //
	@Override
	public int edit(BoardVO boardvo) {
		int n = dao.edit(boardvo);
		return n;
	}


	// === #78. 1개글 삭제하기 === //
	@Override
	public int del(Map<String, String> paraMap) {
		
		int n = dao.del(paraMap);

		/*	
		// === #165. 파일첨부가 된 글이라면 글 삭제시 먼저 첨부파일을 삭제해주어야 한다. === //
		if(n == 1) {
			
		    String fileName = paraMap.get("fileName");
		    String path = paraMap.get("path");
		      
		    if( fileName != null && !"".equals(fileName) ) {
		       try {
		           fileManager.doFileDelete(fileName, path);
		       } catch (Exception e) {   }
		    }
	    }
	      ///////////////////////////////////////////////////////////////////
		*/	
		return n;
	}


	// === #85. 댓글쓰기 (transaction 처리) === //
	// tbl_comment 테이블에 insert 된 다음에 
	// tbl_board 테이블에 commentCount 컬럼이 1증가(update) 하도록 요청한다.
	// 즉, 2개이상의 DML 처리를 해야하므로 Transaction 처리를 해야 한다.
	// >>>>> 트랜잭션처리를 해야할 메소드에 @Transactional 어노테이션을 설정하면 된다. 
	// rollbackFor={Throwable.class} 은 롤백을 해야할 범위를 말하는데 Throwable.class 은 error 및 exception 을 포함한 최상위 루트이다. 즉, 해당 메소드 실행시 발생하는 모든 error 및 exception 에 대해서 롤백을 하겠다는 말이다.
	@Override
	@Transactional(propagation=Propagation.REQUIRED, isolation=Isolation.READ_COMMITTED, rollbackFor= {Throwable.class})
	public int addComment(CommentVO commentvo) throws Throwable {
		
		int result = 0, n = 0, m = 0;
		
		n = dao.addComment(commentvo); // 댓글쓰기(tbl_comment 테이블에 insert)
		//  n <== 1
		
		if (n == 1) {
			m = dao.updateCommentCount(commentvo.getParentSeq()); // tbl_board 테이블에 commentCount 컬럼의 값을 1증가 (update)
		//  m <== 1	
		}
		
		if (m == 1) {
			Map<String, String> paraMap = new HashMap<>();
			paraMap.put("userid", commentvo.getFk_userid());
			paraMap.put("point", "50");
			
			result = dao.updateMemberPoint(paraMap); // tbl_member 테이블에 point 컬럼의 값을 50 증가(update)
		//  result <== 1
		}

		return result;
	}

	
	// === #91. 원게시글에 딸린 댓글들을 조회해오는 것 === //
	@Override
	public List<CommentVO> getCommentList(String parentSeq) {
		List<CommentVO> commentList = dao.getCommentList(parentSeq);
		return commentList;
	}
	
	
	// === #98. BoardAOP 클래스에 사용하는 것으로 특정 회원에게 특정 점수만큼 포인트를 증가하기 위한 것 === //
	@Override
	public void pointPlus(Map<String, String> paraMap) {
		dao.pointPlus(paraMap);
	}

	
	// === #103. 페이징 처리를 안한 검색어가 있는 전체 글목록 보여주기 === //
	@Override
	public List<BoardVO> boardListSearch(Map<String, String> paraMap) {
		List<BoardVO> boardList = dao.boardListSearch(paraMap);
		return boardList;
	}
	
	
	// === #109. 검색어 입력시 자동글 완성하기 4 === //
	@Override
	public List<String> wordSearchShow(Map<String, String> paraMap) {
		List<String> wordList = dao.wordSearchShow(paraMap);
		return wordList;
	}
	
	
	// === #115. 총 게시물 건수(totalCount) 구하기 - 검색이 있을때와 검색이 없을때로 나뉜다. === // 
	@Override
	public int getTotalCount(Map<String, String> paraMap) {
		int n = dao.getTotalCount(paraMap);
		return n;
	}
	
	
	// === #118. 페이징 처리한 글목록 가져오기(검색이 있든지, 검색이 없든지 모두 다 포함한 것) === // 
	@Override
	public List<BoardVO> boardListSearchWithPaging(Map<String, String> paraMap) {
		List<BoardVO> boardList = dao.boardListSearchWithPaging(paraMap);
		return boardList;
	}
	
	
	// === #129. 원게시물에 딸린 댓글들을 페이징처리해서 조회해오기(Ajax로 처리) === //
	@Override
	public List<CommentVO> getCommentListPaging(Map<String, String> paraMap) {
		List<CommentVO> commentList = dao.getCommentListPaging(paraMap);
		
		return commentList;
	}
	
	
	// === #133. 원게시물에 딸린 댓글 totalPage 알아오기(Ajax로 처리) === //
	@Override
	public int getCommentTotalCount(Map<String, String> paraMap) {
		int totalCount = dao.getCommentTotalCount(paraMap);
		return totalCount;
	}
	
	
	// === #157. 글쓰기(파일첨부가 있는 글쓰기) === //
	@Override
	public int add_withFile(BoardVO boardvo) {
		// 글쓰기가 원글쓰기인지 아니면 답변글쓰기인지를 구분하여 
		// tbl_board 테이블에 insert를 해주어야 한다.
		// 원글쓰기라면 tbl_board 테이블의 groupno 컬럼의 값은 
		// groupno 컬럼의 최대값(max)+1로 해서 insert 해야 하고,
		// 답변글쓰기라면 넘겨받은 값(boardvo)을 그대로 insert 해주어야 한다.
		
		// == 원글쓰기인지 답변글쓰기인지 구분하기
		if (boardvo.getFk_seq() == null || boardvo.getFk_seq().trim().isEmpty()) {
			// 원글쓰기라면 groupno 컬럼의 값은 groupno 컬럼의 최대값(max)+1로 해야 한다.
			int groupno = dao.getGroupnoMax() + 1;
			boardvo.setGroupno(String.valueOf(groupno));
		}
		
		int n = dao.add_withFile(boardvo); // 첨부파일이 있는 경우
		return n;
	}
	
	
	
	
	
	
}

