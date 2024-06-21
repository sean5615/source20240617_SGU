<%/*
----------------------------------------------------------------------------------
File Name		: scd016m_01m1.jsp
Author			: barry
Description		: 彙總名次 - 處理邏輯頁面
Modification Log	:

Vers		Date       	By            	Notes
--------------	--------------	--------------	----------------------------------
0.0.1		096/07/18	barry    	Code Generate Create
0.0.2		096/11/08	poto    	可以重複寫入排名
----------------------------------------------------------------------------------
*/%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="MS950"%>
<%@include file="/utility/header.jsp"%> 
<%@include file="/utility/modulepageinit.jsp"%>  
<%!

public String getASYS120(DBManager dbManager, Hashtable requestMap, HttpSession session, MyLogger logger) throws Exception
{
	Connection	conn	=	dbManager.getConnection(AUTCONNECT.mapConnect("REG", session));
	StringBuffer	sql	=	new StringBuffer();	
	DBResult rs = null;
    rs = dbManager.getSimpleResultSet(conn);
    rs.open();
	
	String AYEAR =  Utility.dbStr(requestMap.get("AYEAR"));
	String SMS =  Utility.dbStr(requestMap.get("SMS"));
	String SCD_TAKE_CRD =  Utility.dbStr(requestMap.get("SCD_TAKE_CRD"));
	String SCD_TAKE_CRS =  Utility.dbStr(requestMap.get("SCD_TAKE_CRS"));
	String SCD_AVG_MARK =  Utility.dbStr(requestMap.get("SCD_AVG_MARK"));
	
	sql.append("SELECT MIN(AVG_MARK) AS AVG_MARK \n");
	sql.append("FROM ( \n");
	sql.append("    SELECT a.AVG_MARK \n");
	sql.append("    FROM SCDT008 a  \n");
	sql.append("	JOIN STUT003 c ON a.STNO=c.STNO AND c.ASYS='1' \n");	
	sql.append("    WHERE 1=1 \n");
	//sql.append("	AND NVL((SELECT STTYPE FROM STUT004 WHERE a.AYEAR = AYEAR AND a.SMS = SMS AND a.STNO = STNO ),c.STTYPE) = '1' \n");
	sql.append("	AND a.AYEAR='"+AYEAR+"' AND a.SMS='"+SMS+"' AND a.TAKE_CRD>="+SCD_TAKE_CRD+" AND a.AVG_MARK>="+SCD_AVG_MARK+" \n");
	sql.append("	AND	 (SELECT COUNT(1) FROM SCDT004 WHERE  a.AYEAR = AYEAR AND a.SMS = SMS AND a.STNO = STNO ) >="+SCD_TAKE_CRS+"  \n");
	sql.append("	ORDER BY AVG_MARK DESC  \n");
	sql.append(") WHERE ROWNUM<=20 \n");
		
	
	rs.executeQuery(sql.toString());
	String AVG_MARK="0";
	if(rs.next())
		AVG_MARK = rs.getString("AVG_MARK");
	if(AVG_MARK.equals(""))	
		AVG_MARK = "0";
	return AVG_MARK;
}

public String getASYS203(DBManager dbManager, Hashtable requestMap, HttpSession session, MyLogger logger) throws Exception
{
	Connection	conn	=	dbManager.getConnection(AUTCONNECT.mapConnect("REG", session));
	StringBuffer	sql	=	new StringBuffer();	
	DBResult rs = null;
    rs = dbManager.getSimpleResultSet(conn);
    rs.open();
	
	String AYEAR =  Utility.dbStr(requestMap.get("AYEAR"));
	String SMS =  Utility.dbStr(requestMap.get("SMS"));
	String SCD_TAKE_CRD =  Utility.dbStr(requestMap.get("SCD_TAKE_CRD"));
	String SCD_TAKE_CRS =  Utility.dbStr(requestMap.get("SCD_TAKE_CRS"));
	String SCD_AVG_MARK =  Utility.dbStr(requestMap.get("SCD_AVG_MARK"));
	
	sql.append("SELECT MIN(AVG_MARK) AS AVG_MARK \n");
	sql.append("FROM ( \n");
	sql.append("    SELECT a.AVG_MARK \n");
	sql.append("    FROM SCDT008 a  \n");
	sql.append("	JOIN STUT003 c ON a.STNO=c.STNO AND c.ASYS='2' \n");	
	sql.append("    WHERE 1=1 \n");	
	sql.append("	AND a.AYEAR='"+AYEAR+"' AND a.SMS='"+SMS+"' AND a.TAKE_CRD>="+SCD_TAKE_CRD+" AND a.AVG_MARK>="+SCD_AVG_MARK+" \n");
	sql.append("	AND	 (SELECT COUNT(1) FROM SCDT004 WHERE  a.AYEAR = AYEAR AND a.SMS = SMS AND a.STNO = STNO ) >="+SCD_TAKE_CRS+"  \n");
	sql.append("	ORDER BY AVG_MARK DESC  \n");
	sql.append(") WHERE ROWNUM<=3 \n");
	rs.executeQuery(sql.toString());
	String AVG_MARK="0";
	if(rs.next())
		AVG_MARK = rs.getString("AVG_MARK");
	if(AVG_MARK.equals(""))	
		AVG_MARK = "0";		
	return AVG_MARK;
}

/** rank */
public void doRank(JspWriter out, DBManager dbManager, Hashtable requestMap, HttpSession session, MyLogger logger) throws Exception
{
	Connection	conn	=	dbManager.getConnection(AUTCONNECT.mapConnect("REG", session));
	StringBuffer	sql	=	new StringBuffer();	
	
	DBAccess rs = new DBAccess(conn, logger);
	
	try
	{
		String ASYS	=	(String)session.getAttribute("ASYS");		
		String AYEAR =  Utility.dbStr(requestMap.get("AYEAR"));
		String SMS =  Utility.dbStr(requestMap.get("SMS"));
		String SCD_TAKE_CRD =  Utility.dbStr(requestMap.get("SCD_TAKE_CRD"));
		String SCD_TAKE_CRS =  Utility.dbStr(requestMap.get("SCD_TAKE_CRS"));
		String SCD_AVG_MARK =  Utility.dbStr(requestMap.get("SCD_AVG_MARK"));
		String KIND =  Utility.dbStr(requestMap.get("KIND"));
		try{
			rs.execute("DELETE FROM SCDT021 WHERE AYEAR = '"+AYEAR+"' AND SMS = '"+SMS+"' AND KIND = '"+KIND+"'");
			dbManager.commit();
		}catch (Exception ex){	
			dbManager.rollback();
			out.println(DataToJson.faileJson("砍檔失敗!!"));
		}
		
		
		if("1".equals(KIND)){
			//新增空大全校前20名資料  //20140523 Maggie 馬祖服務處併台北中心彙總
			System.out.println("新增空大全校前20名資料");
			if(sql.length() > 0)
				sql.delete(0, sql.length());
			sql.append(
				"INSERT INTO SCDT021(AYEAR, SMS, STNO, KIND, RANK, CENTER_CODE, ASYS) \n" +
				"SELECT AYEAR, SMS, STNO, '1' AS KIND, LPAD(ROWNUM,2,0) AS RANK, decode(CENTER_CODE, '14', '02', CENTER_CODE) as CENTER_CODE, ASYS \n" +
				"FROM ( \n" +
				"SELECT a.AYEAR, a.SMS, a.STNO, a.CENTER_CODE, b.ASYS \n" +
				"FROM SCDT008 a \n" +
				"JOIN STUT003 b ON a.STNO=b.STNO AND b.ASYS='1' \n" +
				"WHERE AVG_MARK>="+getASYS120(dbManager, requestMap, session, logger)+" \n" +
				"AND a.AYEAR='"+AYEAR+"' AND a.SMS='"+SMS+"' AND a.TAKE_CRD>="+SCD_TAKE_CRD+" AND a.AVG_MARK>="+SCD_AVG_MARK+" \n" +
				"AND (SELECT COUNT(1) FROM SCDT004 WHERE AYEAR=a.AYEAR AND SMS=a.SMS AND STNO=a.STNO)>="+SCD_TAKE_CRS+" \n" +
				"ORDER BY a.AVG_MARK DESC, a.STNO \n" +
				") "
			);			
			try{
				rs.execute(sql.toString());
				dbManager.commit();
			}catch (Exception ex){	
				dbManager.rollback();
				out.println(DataToJson.faileJson("空大全校前20名資料，產生失敗!!"));
			}
					
			//新增空專全校前3名資料    //20140523 Maggie 馬祖服務處併台北中心彙總
			System.out.println("新增空專全校前3名資料");
			if(sql.length() > 0)
				sql.delete(0, sql.length());
			sql.append(
				"INSERT INTO SCDT021(AYEAR, SMS, STNO, KIND, RANK, CENTER_CODE, ASYS) \n" +
				"SELECT AYEAR, SMS, STNO, '1' AS KIND, LPAD(ROWNUM,2,0) AS RANK, decode(CENTER_CODE, '14', '02', CENTER_CODE) as CENTER_CODE, ASYS \n" +
				"FROM ( \n" +
				"SELECT a.AYEAR, a.SMS, a.STNO, a.CENTER_CODE, b.ASYS \n" +
				"FROM SCDT008 a \n" +
				"JOIN STUT003 b ON a.STNO=b.STNO AND b.ASYS='2' \n" +
				"WHERE AVG_MARK>="+getASYS203(dbManager, requestMap, session, logger)+" \n" +
				"AND a.AYEAR='"+AYEAR+"' AND a.SMS='"+SMS+"' AND a.TAKE_CRD>="+SCD_TAKE_CRD+" AND a.AVG_MARK>="+SCD_AVG_MARK+" \n" +
				"AND (SELECT COUNT(*) FROM SCDT004 WHERE AYEAR=a.AYEAR AND SMS=a.SMS AND STNO=a.STNO)>="+SCD_TAKE_CRS+" \n" +
				"ORDER BY a.AVG_MARK DESC, a.STNO \n" +
				") "
			);			
			try{
				rs.execute(sql.toString());
				dbManager.commit();
			}catch (Exception ex){	
				dbManager.rollback();
				out.println(DataToJson.faileJson("空專全校前3名資料，產生失敗!!"));
			}
			
			System.out.println("222222222222222");
			if(sql.length() > 0)
			sql.delete(0, sql.length());
			sql.append(
				"UPDATE SCDT021 a \n" +
				"SET RANK=( \n" +
				"	   SELECT MIN(b.RANK) \n" +
				"	   FROM SCDT021 b \n" + 
				"	   JOIN SCDT008 c ON b.AYEAR=c.AYEAR AND b.SMS=c.SMS AND b.STNO=c.STNO \n" + 
				"	   WHERE b.AYEAR='"+AYEAR+"' AND b.SMS='"+SMS+"' AND b.KIND='1' AND b.ASYS=a.ASYS \n" +
				"	   AND c.AVG_MARK=(SELECT AVG_MARK FROM SCDT008 WHERE AYEAR=a.AYEAR AND SMS=a.SMS AND STNO=a.STNO) \n" + 
				") \n" +
				"WHERE a.AYEAR='"+AYEAR+"' AND a.SMS='"+SMS+"' AND a.KIND='1'"
				);		
			System.out.println("3333333333333");
			try{
				rs.execute(sql.toString());
				dbManager.commit();
				out.println(DataToJson.faileJson("全校前20名資料，成功產生!!"));
				System.out.println("3333333333333ok");
			}catch (Exception ex){	
				dbManager.rollback();
				out.println(DataToJson.faileJson("更新名次失敗!!"));
			}			

		}else if("2".equals(KIND)){
		//新增空大各指導中心第一名  //20140523 Maggie 馬祖服務處併台北中心彙總
			System.out.println("新增空大各指導中心第一名");
			if(sql.length() > 0)
				sql.delete(0, sql.length());
			sql.append(
				"INSERT INTO SCDT021(AYEAR, SMS, STNO, KIND, RANK, CENTER_CODE, ASYS) \n" +
				"SELECT a.AYEAR, a.SMS, a.STNO, '2' AS KIND, '01' AS RANK, decode(a.CENTER_CODE, '14', '02', a.CENTER_CODE) as CENTER_CODE, c.ASYS \n" +
				"FROM SCDT008 a \n" +
				"JOIN ( \n" +
				"	   SELECT decode(a.CENTER_CODE, '14', '02', a.CENTER_CODE) as CENTER_CODE, MAX(a.AVG_MARK) AS AVG_MARK \n" +
				"	   FROM SCDT008 a \n" +
				"      JOIN STUT003 b on a.stno = b.stno and b.asys = '1' \n" +
				"	   WHERE a.AYEAR='"+AYEAR+"' AND a.SMS='"+SMS+"' \n" +
				"	   AND a.TAKE_CRD>="+SCD_TAKE_CRD+" AND a.AVG_MARK>="+SCD_AVG_MARK+" \n" +
				"	   AND (SELECT COUNT(*) FROM SCDT004 WHERE AYEAR=a.AYEAR AND SMS=a.SMS AND STNO=a.STNO)>="+SCD_TAKE_CRS+" \n" +
				"	   GROUP BY decode(a.CENTER_CODE, '14', '02', a.CENTER_CODE) \n" +
				") b ON a.AVG_MARK=b.AVG_MARK AND decode(a.CENTER_CODE, '14', '02', a.CENTER_CODE)=b.CENTER_CODE \n" +
				"JOIN STUT003 c ON a.STNO=c.STNO AND c.ASYS='1' \n" +
				"WHERE a.AYEAR='"+AYEAR+"' AND a.SMS='"+SMS+"' \n" +
				//"AND NVL((SELECT STTYPE FROM STUT004 WHERE a.AYEAR = AYEAR AND a.SMS = SMS AND a.STNO = STNO ),c.STTYPE) = '1' \n" +
				"AND a.TAKE_CRD>="+SCD_TAKE_CRD+" AND a.AVG_MARK>="+SCD_AVG_MARK+" \n" +
				"AND (SELECT COUNT(*) FROM SCDT004 WHERE AYEAR=a.AYEAR AND SMS=a.SMS AND STNO=a.STNO)>="+SCD_TAKE_CRS+" \n" +
				"ORDER BY decode(a.CENTER_CODE, '14', '02', a.CENTER_CODE)"
			);			
			try{
				rs.execute(sql.toString());
				dbManager.commit();
			}catch (Exception ex){	
				dbManager.rollback();
				out.println(DataToJson.faileJson("空大各指導中心第一名，產生失敗!!"));
			}
			
			//新增空專各指導中心第一名  //20140523 Maggie 馬祖服務處併台北中心彙總
			if(sql.length() > 0)
				sql.delete(0, sql.length());
			sql.append(
				"INSERT INTO SCDT021(AYEAR, SMS, STNO, KIND, RANK, CENTER_CODE, ASYS) \n" +
				"SELECT a.AYEAR, a.SMS, a.STNO, '2' AS KIND, '01' AS RANK, decode(a.CENTER_CODE, '14', '02', a.CENTER_CODE) as CENTER_CODE, c.ASYS \n" +
				"FROM SCDT008 a \n" +
				"JOIN ( \n" +
				"	   SELECT decode(a.CENTER_CODE, '14', '02', a.CENTER_CODE) as CENTER_CODE, MAX(a.AVG_MARK) AS AVG_MARK \n" +
				"	   FROM SCDT008 a \n" +
				"      JOIN STUT003 b on a.stno = b.stno and b.asys = '2' \n" +
				"	   WHERE a.AYEAR='"+AYEAR+"' AND a.SMS='"+SMS+"' \n" +
				"	   AND a.TAKE_CRD>="+SCD_TAKE_CRD+"  \n" +
				"	   AND (SELECT COUNT(*) FROM SCDT004 WHERE AYEAR=a.AYEAR AND SMS=a.SMS AND STNO=a.STNO)>="+SCD_TAKE_CRS+" \n" +
				"	   GROUP BY decode(a.CENTER_CODE, '14', '02', a.CENTER_CODE) \n" +
				") b ON a.AVG_MARK=b.AVG_MARK AND decode(a.CENTER_CODE, '14', '02', a.CENTER_CODE)= b.CENTER_CODE \n" +
				"JOIN STUT003 c ON a.STNO=c.STNO AND c.ASYS='2' \n" +
				"WHERE a.AYEAR='"+AYEAR+"' AND a.SMS='"+SMS+"' \n" +
				"AND a.TAKE_CRD>="+SCD_TAKE_CRD+"  \n" +
				"AND (SELECT COUNT(*) FROM SCDT004 WHERE AYEAR=a.AYEAR AND SMS=a.SMS AND STNO=a.STNO)>="+SCD_TAKE_CRS+" \n" +
				"ORDER BY decode(a.CENTER_CODE, '14', '02', a.CENTER_CODE)"
			);			

			try{
				rs.execute(sql.toString());				
				dbManager.commit();
				out.println(DataToJson.faileJson("各指導中心第一名，成功產生!!"));
			}catch (Exception ex){	
				dbManager.rollback();
				out.println(DataToJson.faileJson("空專各指導中心第一名，產生失敗!!"));
			}
		}else if("4".equals(KIND)){	
			//新增各中心各科第一名							
			if(sql.length() > 0)
				sql.delete(0, sql.length());
			try{
				rs.execute(doGetCenterCrsnoStno(requestMap));				
				dbManager.commit();
				out.println(DataToJson.successJson ("各中心各科第一名，成功產生!!"));
			}catch (Exception ex){	
				dbManager.rollback();
				out.println(DataToJson.faileJson("各中心各科第一名，產生失敗!!"));
			}			
		}			
	}
	catch (Exception ex)
	{
		/** Rollback Transaction */
		dbManager.rollback();

		throw ex;
	}
	finally
	{
		dbManager.close();
	}
}
//新增各中心各科第一名 kind 4
public String doGetCenterCrsnoStnoOld(DBManager dbManager,Connection conn,Hashtable requestMap) throws Exception
{    
	StringBuffer sql = new StringBuffer();		
    try
    {				
		String AYEAR =  Utility.dbStr(requestMap.get("AYEAR"));
		String SMS =  Utility.dbStr(requestMap.get("SMS"));
		String SCD_AVG_MARK =  Utility.dbStr(requestMap.get("SCD_AVG_MARK"));		
		//sql.append("INSERT INTO SCDT021(AYEAR, SMS, STNO, KIND, RANK, CENTER_CODE, CRSNO, ASYS) \n");
		sql.append("SELECT a.AYEAR, a.SMS, a.STNO, '4' AS KIND, '01' AS RANK, decode(c.CENTER_CODE, '14', '02', c.CENTER_CODE) as CENTER_CODE, a.CRSNO, decode(length(STNO),'7','2','1') AS ASYS  \n");
		sql.append("FROM SCDT004 a  \n");
		sql.append("JOIN (  \n");
		sql.append("	 SELECT decode(b.CENTER_CODE, '14', '02', b.CENTER_CODE), a.CRSNO, MAX(a.CRSNO_SMSGPA) AS CRSNO_SMSGPA  \n");
		sql.append("	 FROM SCDT004 a  \n");
		sql.append("	 JOIN SCDT008 b ON a.AYEAR=b.AYEAR AND a.SMS=b.SMS AND a.STNO=b.STNO  \n");
		sql.append("	 WHERE 1=1 \n");
		sql.append("	 AND a.AYEAR='"+AYEAR+"' AND a.SMS='"+SMS+"' AND a.CRSNO_SMSGPA>="+SCD_AVG_MARK+" \n");
		sql.append("	 AND SUBSTR(a.STNO,1,LENGTH(A.STNO)) LIKE '%' \n");
		//sql.append("	 AND b.CENTER_CODE = '02' \n");
		sql.append("	 GROUP BY decode(b.CENTER_CODE, '14', '02', b.CENTER_CODE), a.CRSNO  \n");
		sql.append(") b ON a.AYEAR='"+AYEAR+"' AND a.SMS='"+SMS+"' AND a.CRSNO=b.CRSNO AND a.CRSNO_SMSGPA=b.CRSNO_SMSGPA \n");
		sql.append("JOIN SCDT008 c on  a.AYEAR=c.AYEAR AND a.SMS=c.SMS AND a.STNO=c.STNO and b.CENTER_CODE=decode(c.CENTER_CODE, '14', '02', c.CENTER_CODE) \n");
		sql.append("WHERE a.AYEAR='"+AYEAR+"' AND a.SMS='"+SMS+"' AND a.CRSNO_SMSGPA>="+SCD_AVG_MARK+" \n");
		//sql.append("AND b.CENTER_CODE = '02' \n");
		sql.append("AND SUBSTR(a.STNO,1,LENGTH(A.STNO)) LIKE '%' \n");

		
	    DBResult rs  = dbManager.getSimpleResultSet(conn);
	    rs.open();	
		rs.executeQuery(sql.toString());
		PreparedStatement pstmt = conn.prepareStatement("INSERT INTO SCDT021(ASYS,AYEAR, SMS, STNO, KIND, RANK, CENTER_CODE, CRSNO ) VALUES (?,?,?,?,?,?,?,?)");
		for(int i=1;rs.next();i++){
			System.out.println("i="+i);
			pstmt.setString(1,rs.getString("ASYS"));
			pstmt.setString(2,rs.getString("AYEAR"));
			pstmt.setString(3,rs.getString("SMS"));
			pstmt.setString(4,rs.getString("STNO"));
			pstmt.setString(5,rs.getString("KIND"));
			pstmt.setString(6,rs.getString("RANK"));
			pstmt.setString(7,rs.getString("CENTER_CODE"));
			pstmt.setString(8,rs.getString("CRSNO"));	
			pstmt.addBatch();
			if(i%500==0){
				pstmt.executeBatch();
			}
		}
		pstmt.executeBatch();
		rs.close();
    }
    catch (Exception ex)
    {
        throw ex;
    }finally
    {
     
    }
    return sql.toString();
}


//新增各中心各科第一名 kind 4
public String doGetCenterCrsnoStno(Hashtable requestMap) throws Exception
{    
	String AYEAR =  Utility.dbStr(requestMap.get("AYEAR"));
	String SMS =  Utility.dbStr(requestMap.get("SMS"));
	String SCD_AVG_MARK =  Utility.dbStr(requestMap.get("SCD_AVG_MARK"));		
	
	StringBuffer sql = new StringBuffer();	
	sql.append("INSERT INTO SCDT021(AYEAR, SMS, STNO, KIND, RANK, CENTER_CODE, CRSNO, ASYS) \n");
	sql.append("select \n");
	sql.append("a.AYEAR, a.SMS, a.STNO, '4' AS KIND, '01' AS RANK, decode(b.CENTER_CODE, '14', '02', b.CENTER_CODE) as CENTER_CODE, a.CRSNO,decode(length(a.STNO),'7','2','1') AS ASYS   \n");
	sql.append("FROM SCDT004 a   \n");
	sql.append("JOIN SCDT008 b on  a.AYEAR=b.AYEAR AND a.SMS=b.SMS AND a.STNO=b.STNO  \n");
	sql.append("WHERE a.AYEAR='"+AYEAR+"' AND a.SMS='"+SMS+"'   \n");
	sql.append("AND (decode(b.CENTER_CODE, '14', '02', b.CENTER_CODE), a.CRSNO, a.CRSNO_SMSGPA ) in  \n");
	sql.append("(   \n");
	sql.append("   SELECT decode(b.CENTER_CODE, '14', '02', b.CENTER_CODE) as CENTER_CODE, a.CRSNO, MAX(a.CRSNO_SMSGPA) AS CRSNO_SMSGPA   \n");
	sql.append("   FROM SCDT004 a   \n");
	sql.append("   JOIN SCDT008 b ON a.AYEAR=b.AYEAR AND a.SMS=b.SMS AND a.STNO=b.STNO   \n");
	sql.append("   WHERE 1=1  \n");
	sql.append("   AND a.AYEAR='"+AYEAR+"' AND a.SMS='"+SMS+"' AND a.CRSNO_SMSGPA>="+SCD_AVG_MARK+" \n");
	sql.append("   GROUP BY decode(b.CENTER_CODE, '14', '02', b.CENTER_CODE), a.CRSNO   \n");
	sql.append(") ");
	
	return sql.toString();
}


%>