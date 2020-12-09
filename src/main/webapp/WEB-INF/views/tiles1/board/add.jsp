<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<% String ctxPath = request.getContextPath(); %>    

<style type="text/css">

   table, th, td, input, textarea {border: solid gray 1px;}
   
   #table {border-collapse: collapse;
          width: 900px;
          }
   #table th, #table td{padding: 5px;}
   #table th{width: 120px; background-color: #DDDDDD;}
   #table td{width: 860px;}
   .long {width: 470px;}
   .short {width: 120px;}

</style>

<script type="text/javascript">
   	$(document).ready(function(){

   		// 쓰기 버튼
   		$("button#btnWrite").click(function() {
			
	   		// 글내용 유효성 검사(스마트에디터 사용 안 할시)
	        var contentVal = $("textarea#content").val().trim();
	        if(contentVal == "") {
	        	alert("글내용을 입력하세요!!");
	        	return;
	        }
	           
			// 글암호 유효성 검사
	        var pwVal = $("input#pw").val().trim();
	       	if(pwVal == "") {
	        	alert("글암호를 입력하세요!!");
	            return;
	        }
	           
	        // 폼(form) 을 전송(submit)
	        var frm = document.addFrm;
	        frm.method = "POST";
	        frm.action = "<%= ctxPath%>/addEnd.action";
			frm.submit();     
   		
		});
	   
   	});// end of $(document).ready(function(){})----------------
   
</script>

<div style="padding-left: 10%;">
   <h1>글쓰기</h1>

 <%-- <form name="addFrm"> --%>
 <%-- === #149. 파일첨부하기 === 
 	    먼저 위의 <form name="addFrm">을 주석처리 한 이후에 아래와 같이 해야 한다.
 	  enctype="multipart/form-data" 를 해주어야만 파일첨부가 되어진다. --%>  
 <form name="addFrm" enctype="multipart/form-data">  
      <table id="table">
         <tr>
            <th>성명</th>
            <td>
               <input type="hidden" name="fk_userid" value="${sessionScope.loginuser.userid}" />
               <input type="text" name="name" value="${sessionScope.loginuser.name}" class="short" readonly />       
            </td>
         </tr>
         <tr>
            <th>제목</th>
            <td>
               <input type="text" name="subject" id="subject" class="long" />       
            </td>
         </tr>
         <tr>
            <th>내용</th>
            <td>
               <textarea rows="10" cols="100" style="width: 95%; height: 412px;" name="content" id="content"></textarea>       
            </td>
         </tr>
         
         <%-- === #150. 파일첨부 타입 추가하기 === --%> 
         <tr>
            <th>파일첨부</th>
            <td>
               <input type="file" name="attach" />       
            </td>
         </tr>
         
         
         <tr>
            <th>글암호</th>
            <td>
               <input type="password" name="pw" id="pw" class="short" />       
            </td>
         </tr>
      </table>
      
      <!-- === #143. 답변글쓰기가 추가된 경우  === -->
      <input type="hidden" name="fk_seq" value="${fk_seq}" />
      <input type="hidden" name="groupno" value="${groupno}" />
      <input type="hidden" name="depthno" value="${depthno}" />
      
      <div style="margin: 20px;">
         <button type="button" id="btnWrite">쓰기</button>
         <button type="button" onclick="javascript:history.back()">취소</button>
      </div>
         
   </form>
   
</div>