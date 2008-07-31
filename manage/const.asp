﻿<%
dim UserTrueIP
UserTrueIP = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
	If UserTrueIP = "" Then UserTrueIP = Request.ServerVariables("REMOTE_ADDR")

Sub showpage(language,format,sfilename,totalnumber,MaxPerPage,ShowTotal,ShowAllPages,strUnit,CurrentPage)
	dim zh,en,str
	zh="共,首页,上一页,下一页,尾页,页次：,页,页,转到："
	en="Total,First,Previous,Next,Last,Page:,&nbsp;,Page,Turn To:"
	if language="en" then
		str=split(en,",")
	else
		str=split(zh,",")
	end if
	dim n, i,strTemp,strUrl
	if totalnumber mod MaxPerPage=0 then
		n= totalnumber \ MaxPerPage
	else
		n= totalnumber \ MaxPerPage+1
	end if
	strTemp="<table width='100%'>"
	'strTemp=strTemp &  "<tr><td height='1' colspan='2' bgcolor='#4D8BEB'></td></tr>"
	strTemp=strTemp &  "<tr align='right'><td>"
	if ShowTotal=true then 
		strTemp=strTemp&str(0)&" <b>" & totalnumber & "</b> " & strUnit & "&nbsp;&nbsp;"
	end if
	strUrl=JoinChar(sfilename)
	if CurrentPage<2 then
			strTemp=strTemp & str(1)&"&nbsp;"&str(2)&"&nbsp;"
	else
			strTemp=strTemp & "<a href='" & strUrl & "page=1'>"&str(1)&"</a>&nbsp;"
			strTemp=strTemp & "<a href='" & strUrl & "page=" & (CurrentPage-1) & "'>"&str(2)&"</a>&nbsp;"
	end if
	if n-CurrentPage<1 then
			strTemp=strTemp&str(3)&"&nbsp;"&str(4)
	else
			strTemp=strTemp & "<a href='" & strUrl & "page=" & (CurrentPage+1) & "'>"&str(3)&"</a>&nbsp;"
			strTemp=strTemp & "<a href='" & strUrl & "page=" & n & "'>"&str(4)&"</a>"
	end if
	strTemp=strTemp & "&nbsp;"&str(5)&"<strong><font color=red>" & CurrentPage & "</font>/" & n & "</strong>"&str(6)
	strTemp=strTemp & "&nbsp;<b>"&MaxPerPage&"</b>"&strUnit&"/"&str(7)
	if ShowAllPages=True then
		strTemp=strTemp & "&nbsp;"&str(8)&"<select name='page' size='1' onchange=""javascript:window.location='" & strUrl & "page=" & "'+this.options[this.selectedIndex].value;"">"   
		for i = 1 to n   
			strTemp=strTemp & "<option value='" & i & "'"
			if cint(CurrentPage)=cint(i) then strTemp=strTemp & " selected "
			strTemp=strTemp & ">"&i&"</option>"   
		next
		strTemp=strTemp & "</select>"
	end if
	strTemp=strTemp & "</td></tr></table>"
	response.write strTemp
end sub
function JoinChar(strUrl)
	if strUrl="" then
		JoinChar=""
		exit function
	end if
	if InStr(strUrl,"?")<len(strUrl) then 
		if InStr(strUrl,"?")>0 then
			if InStr(strUrl,"&")<len(strUrl) then 
				JoinChar=strUrl & "&"
			else
				JoinChar=strUrl
			end if
		else
			JoinChar=strUrl & "?"
		end if
	else
		JoinChar=strUrl
	end if
end function


Sub header()
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="keywords" content="CMP,Cenfun">
<meta name="description" content="Design By Cenfun.com">
<title><%=sitename%></title>
<link rel="stylesheet" type="text/css" href="images/main.css" />
<script type="text/javascript" src="images/main.js"></script>
</head>
<body>
<%
end sub

sub menu()
If Session(CookieName & "_flag")<>"" then
end if
%>
<div id="menu"><a href="manage.asp">播放器管理</a> | <a href="user.asp">管理密码修改</a> | <a href="login.asp?action=out">退出</a></div>
<%
end sub


Sub Cenfun_suc(url)
%>
<br />
<table cellpadding="3" cellspacing="1" align="center" class="tableBorder" style="width:75%">
  <tr align="center">
    <th height="25">成功信息</th>
  </tr>
  <tr>
    <td class="cmsRow"><%=SucMsg%></td>
  </tr>
  <tr>
    <td class="cmsRow"><%if url<>"" then%>
      <meta http-equiv="Refresh" content="3;URL=<%=url%>" />
      <li><b><span id="timeout">3</span>秒钟后自动返回...</b>
        <script type="text/javascript">
	function countDown(secs){
		document.getElementById('timeout').innerHTML=secs;
		if(--secs>0){
			setTimeout("countDown("+secs+")",1000);
		}
	}
	countDown(3);
    </script>
        <%end if%>
      </li></td>
  </tr>
  <tr>
    <td colspan="2" align="center" class="cmsRow">&lt;&lt;<a href="<%=Request.ServerVariables("HTTP_REFERER")%>">返回上一页</a></td>
  </tr>
</table>
<%
End Sub

Sub Cenfun_error()
%>
<br />
<table cellpadding="3" cellspacing="1" align="center" class="tableBorder" style="width:75%">
  <tr align="center">
    <th height="25" colspan="2">错误信息</th>
  </tr>
  <tr>
    <td class="cmsRow" colspan="2">&nbsp;&nbsp;<strong>您在后台操作的时候发生错误,下面是可能的错误信息</strong></td>
  </tr>
  <tr>
    <td class="cmsRow" colspan="2" style="color:#0000ff"><%=ErrMsg%></td>
  </tr>
  <tr>
    <td class="cmsRow" colspan="2"><li>请仔细阅读相关帮助文件，确保您有相应的操作权限，或者点击<a href="login.asp"><strong>重新登录</strong></a>!</li></td>
  </tr>
  <tr>
    <td class="cmsRow" valign="middle" colspan="2" align="center"><a href="javascript:history.go(-1)">&lt;&lt; 返回上一页</a></td>
  </tr>
</table>
<%
	footer()
	response.End()
End Sub

Sub footer()
%>
<div id="footer">Copyright &copy; <a href="<%=siteurl%>" target="_blank"><%=sitename%></a>. All Rights Reserved.</div>
<%
response.Write("</body></html>")
End Sub
%>