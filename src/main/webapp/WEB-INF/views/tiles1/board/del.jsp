<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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
      
	   	// 완료버튼 
	   	$("button#btnDelete").click(function() {
		
       		// 글암호 유효성 검사
    	   	var pwVal = $("#pw").val().trim();
       		if(pwVal == "") {
          		alert("글암호를 입력하세요!!");
        		return;
       		}
	   	
       		// 폼(form)을 전송(submit)
       		var frm = document.delFrm;
       		frm.method = "POST";
       		frm.action = "<%= ctxPath%>/delEnd.action";
       		frm.submit();
       		
	   	});
            
   });// end of $(document).ready(function(){})----------------
   
</script>

<div style="padding-left: 10%;">
   <h1>글삭제</h1>

   <form name="delFrm">
      <table id="table">

         <tr>
            <th>글암호</th>
            <td>
               <input type="password" name="pw" id="pw" class="short" />       
               <input type="hidden" name="seq" value="${seq}" />       
            </td>
         </tr>
      </table>
      
      <div style="margin: 20px;">
         <button type="button" id="btnDelete">완료</button>
         <button type="button" onclick="javascript:history.back()">취소</button>
      </div>
      <c:set var="gobackURL2" value='${ fn:replace(gobackURL, "&" ," ") }' />
	  <input type="hidden" name="gobackURL" value='${ fn:replace(gobackURL, "&" ," ") }'/>
   </form>
   
</div>