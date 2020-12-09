<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
	String ctxPath = request.getContextPath();
		// /board
%>

<style>

p#mytitle {
	font-size: 16pt;
	margin: 20px;
}

span#storename {
	color: red;
	font-weight: bold;
}
</style>

<p id="mytitle">
	안녕하세요? <span id="storename">SIST 쇼핑</span> 입니다.
</p>

<div class="container"> <!-- container에 관하여는 이미 위의 부트스트랩  링크에 설정이 되어있으므로 새로운 클래스 mycontainer를 부여하여 설정한다. -->
  <div style="width: 70%; margin: 0 auto;">
   <div id="myCarousel" class="carousel slide" data-ride="carousel">
    <!-- Indicators -->
    <ol class="carousel-indicators">
    <%-- 
      <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
      <li data-target="#myCarousel" data-slide-to="1"></li>
      <li data-target="#myCarousel" data-slide-to="2"></li> 
    --%>
		<c:forEach items="${imgfilenameList}" varStatus="status">
			<c:if test="${status.index == 0}">
				<li data-target="#myCarousel" data-slide-to="${status.index}" class="active"></li>
			</c:if>
			<c:if test="${status.index > 0}">
				<li data-target="#myCarousel" data-slide-to="${status.index}"></li>
			</c:if>
		</c:forEach>

    </ol>
	<div class="carousel-inner">
	    <c:forEach var="filename" items="${imgfilenameList}" varStatus="status">
			<c:if test="${status.index == 0}">
				<div class="item active">
        		<img src="<%= ctxPath%>/resources/images/${filename}" style="width:100%;">
      			</div>
			</c:if>
			<c:if test="${status.index > 0}">
				<div class="item">
        		<img src="<%= ctxPath%>/resources/images/${filename}" style="width:100%;">
      			</div>
			</c:if>
		</c:forEach>
    </div>

    <!-- Left and right controls -->
    <a class="left carousel-control" href="#myCarousel" data-slide="prev">
      <span class="glyphicon glyphicon-chevron-left"></span>
      <span class="sr-only">Previous</span>
    </a>
    <a class="right carousel-control" href="#myCarousel" data-slide="next">
      <span class="glyphicon glyphicon-chevron-right"></span>
      <span class="sr-only">Next</span>
    </a>
  </div>
</div>
</div>