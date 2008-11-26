﻿<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<!--#include file="md5.asp"-->
<%
'检测用户是否登录
If not founduser Then
	

end if

Select Case Request.QueryString("action")
	Case "uploadlrc"
		uploadlrc()
	
	Case Else
		
 End Select


sub uploadlrc()
	Response.Charset = "utf-8"
	dim savepath,maxsize
	'歌词保存至lrc目录
	savepath = "lrc/"
	'最大歌词文件大小50K
	maxsize = 50000

	'0大小判断
	dim formsize,formdata
	formsize = Request.TotalBytes
	if formsize < 1 then
		Response.Write("uploadError{|}上传文件的大小为0")
		Response.End()
		exit sub
	end if
	'取得表单数据
	Dim formStream,tempStream
	Set formStream = Server.CreateObject("ADODB.Stream")
	Set tempStream = Server.CreateObject("ADODB.Stream")
	formStream.Type = 1
	formStream.Mode = 3
	formStream.Open
	formStream.Write Request.BinaryRead(formsize)
	formStream.Position = 0
	formdata = formStream.Read
	'Response.BinaryWrite(formdata)
	If Err Then 
		Err.Clear
		Response.Write("uploadError{|}创建ADODB.Stream出错")
		Response.End()
		Exit sub
	end if
	'超出大小跳出
	if maxsize>0 then
		if formsize>maxsize then
			Response.Write("uploadError{|}文件大小("&formsize&")超过限制" & maxsize)
			Response.End()
			exit sub
		end if
	end if
	'二进制换行分隔符
	dim bncrlf
	bncrlf=chrB(13) & chrB(10)
	'表单项分割符
	Dim PosBeg, PosEnd, boundary, boundaryPos, boundaryEnd
	'开始位置
    PosBeg = 1
    PosEnd = InstrB(PosBeg,formdata,bncrlf)
	'取得项分隔符
    boundary = MidB(formdata,PosBeg,PosEnd-PosBeg)
	'项分隔符位置
	boundaryPos = InstrB(PosBeg,formdata,boundary)
	boundaryEnd = InstrB(formsize-LenB(boundary)-LenB("--"),formdata,boundary)
	Do until (boundaryPos = boundaryEnd)
		'取得项信息位置
		PosBeg = boundaryPos+LenB(boundary)
        PosEnd = InstrB(PosBeg,formdata,bncrlf & bncrlf)
		'读取项信息字符
		tempStream.Type = 1
		tempStream.Mode = 3
		tempStream.Open
		formStream.Position = PosBeg
		formStream.CopyTo tempStream,PosEnd-PosBeg
		tempStream.Position = 0
		tempStream.Type = 2
		tempStream.CharSet = "utf-8"
		dim fileinfo
		fileinfo = tempStream.ReadText
		tempStream.Close
		'查找文件标识开始的位置
		dim fnBeg, fnEnd
		fnBeg = InStr(45,fileinfo,"filename=""",1)
		'如果是文件
		if fnBeg > 0 Then
            '取得文件名
			dim filename,fileurl
            fnBeg = fnBeg + 10
			fnEnd = InStr(fnBeg,fileinfo,""""&vbCrLf,1)
			filename = Trim(Mid(fileinfo,fnBeg,fnEnd-fnBeg))
			'过滤文件名中的路径
			filename = Mid(filename, InStrRev(filename,"\")+1)
			
			'扩展类型是否符合要求，仅保存txt和lrc类型
			dim ext
			ext = LCase(Right(filename, 4))
			if ext=".lrc" or ext=".txt" then
				'生成文件
				fileurl = savepath & filename
				'取得文件数据位置
				PosBeg = InstrB(PosEnd,formdata,bncrlf & bncrlf)+4
				PosEnd = InstrB(PosBeg,formdata,boundary)-2
				'保存文件数据
				tempStream.Type = 1
				tempStream.Mode = 3
				tempStream.Open
				tempStream.Position = 0
				formStream.Position = PosBeg-1
				formStream.CopyTo tempStream,PosEnd-PosBeg
				tempStream.SaveToFile Server.Mappath(fileurl),2
				tempStream.Close
				if Err then
					Err.clear
					'服务器已经存在此文件
					Response.Write("uploadError{|}写入文件失败，可能服务器已经存在此文件，请尝试更换文件名再上传")
					Response.End()
					exit sub
				else
				
					'保存新增路径到数据库
		
					'如果没有重复记录
					conn.execute("insert into cmp_lrc (src) values('"&filename&"')")
	
					Response.Write("uploadComplete{|}" & fileurl)
					Response.End()
				end if
				
			else
				Response.Write("uploadError{|}仅支持*lrc和.txt类型的文件")
				Response.End()
				exit sub
			end if
			
			'找到文件项退出循环
			Exit Do
        else
			'非文件项，跳转到下一个项分隔符位置
        	BoundaryPos = InstrB(boundaryPos+LenB(boundary),formdata,boundary)
		End If
	Loop
	Set tempStream = nothing
	formStream.Close
	Set formStream = nothing
end sub


%>