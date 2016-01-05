<%@ page language="java" contentType="text/html; charset=UTF-8"
 import="java.util.*, 
blackboard.platform.session.*, 
blackboard.data.user.*, 
blackboard.persist.*,
blackboard.persist.BbPersistenceManager,
blackboard.platform.persistence.PersistenceService,
blackboard.platform.persistence.PersistenceServiceFactory,
blackboard.persist.user.*,
blackboard.data.course.*,
blackboard.persist.course.*,
blackboard.data.gradebook.Lineitem.*,
blackboard.persist.gradebook.LineitemDbPersister"
 pageEncoding="UTF-8"%> 
 <%@ page import="Labs.Labs" %>
 <%@ page import="Labs.GradeLogistics" %>
 
 <%@ taglib uri="/bbUI" prefix="bbUI" %> 
 <%@ taglib uri="/bbData" prefix="bbData"%> 
 <%@ taglib uri="/bbNG" prefix="bbNG"%>
 <%@ taglib prefix="ng" uri="/bbNG" %>
 
<%@ page import="blackboard.data.gradebook.Lineitem" %>
<%@ page import="blackboard.persist.gradebook.LineitemDbPersister" %>

 <%@ taglib uri="/bbUI" prefix="bbUI" %> 
 <%@ taglib uri="/bbData" prefix="bbData"%> 
 <%@ taglib uri="/bbNG" prefix="bbNG"%>
 <bbNG:learningSystemPage 
	title="Welcome To Blackboard Building Block Development - Course Information"
	ctxId="ctx">

	<bbNG:pageHeader>
		<bbNG:breadcrumbBar environment="COURSE"
			navItem="course_plugin_manage" >
				<bbNG:breadcrumb title="Home" href="welcome.jsp?course_id=${ctx.courseId.externalString}" />
			<bbNG:breadcrumb> Welcome Page </bbNG:breadcrumb>
		</bbNG:breadcrumbBar>
		<bbNG:pageTitleBar>
			Welcome to to Chem 109 Choose one of the labs below.
		</bbNG:pageTitleBar>
	</bbNG:pageHeader>


<p>
<% 
 BbList allMembershipsList =
 sessionCourseMembershipLoader.loadByCourseId( courseId, null, true ); 
 Collections.sort(allMembershipsList, cmSortByFamilyName); 
 
 Comparator cmSortByUsername = new Comparator() {
	 public int compare(Object o1, Object o2) {
	 CourseMembership cm1 = (CourseMembership) o1;
	 CourseMembership cm2 = (CourseMembership) o2;
	 String s1 = (String)((User)cm1.getUser()).getUserName();
	 String s2 = (String)((User)cm2.getUser()).getUserName();
	 return s1.toLowerCase().compareTo(s2.toLowerCase());
	 }
	};

	Comparator cmSortByFamilyName = new Comparator() {
	 public int compare(Object o1, Object o2) {
	 CourseMembership cm1 = (CourseMembership) o1;
	 CourseMembership cm2 = (CourseMembership) o2;
	 String s1 = (String)((User)cm1.getUser()).getFamilyName();
	 String s2 = (String)((User)cm2.getUser()).getFamilyName();
	 int compare = s1.toLowerCase().compareTo(s2.toLowerCase());
	 if( compare == 0 ) {
	 s1 = (String)((User)cm1.getUser()).getGivenName();
	 s2 = (String)((User)cm2.getUser()).getGivenName();
	 compare = s1.toLowerCase().compareTo(s2.toLowerCase());
	 }
	 return compare;
	 }
	};

	Comparator cmSortByRole = new Comparator() {
	 public int compare(Object o1, Object o2) {
	 CourseMembership cm1 = (CourseMembership) o1;
	 CourseMembership cm2 = (CourseMembership) o2;
	 String s1 = getRoleString( "COURSE", (CourseMembership.Role)cm1.getRole() );
	 String s2 = getRoleString( "COURSE", (CourseMembership.Role)cm2.getRole() );
	 int compare = s1.toLowerCase().compareTo(s2.toLowerCase());
	 if ( compare == 0 ) {
	 s1 = (String)((User)cm1.getUser()).getFamilyName();
	 s2 = (String)((User)cm2.getUser()).getFamilyName();
	 compare = s1.toLowerCase().compareTo(s2.toLowerCase());
	 if( compare == 0 ) {
	 s1 = (String)((User)cm1.getUser()).getGivenName();
	 s2 = (String)((User)cm2.getUser()).getGivenName();

	 compare = s1.toLowerCase().compareTo(s2.toLowerCase());
	 }
	 }
	 return compare;
	 }
	};

	Comparator cmSortByEmailAddress = new Comparator() {
	 public int compare(Object o1, Object o2) {
	 CourseMembership cm1 = (CourseMembership) o1;
	 CourseMembership cm2 = (CourseMembership) o2;
	 String s1 = (String)((User)cm1.getUser()).getEmailAddress();
	 String s2 = (String)((User)cm1.getUser()).getEmailAddress();
	 return s1.toLowerCase().compareTo(s2.toLowerCase());
	 }
	}; 
%>


<bbUI:list>
collection="<%= allMembershipsList %>"
collectionLabel="Users"
objectId="cm"
className="CourseMembership">
<bbUI:listElement width="10"></bbUI:listElement>

<bbUI:listElement
	label="Name"
	name="Name"
comparator="<%= cmSortByFamilyName %>">
	<%= cm.getUser().getGivenName() %> <%= cm.getUser().getFamilyName() %>
</bbUI:listElement>

<bbUI:listElement
	label="Username"
	name="Username"
	comparator="<%= cmSortByUsername %>">
	<%= cm.getUser().getUserName() %>
</bbUI:listElement>

<bbUI:listElement
	label="Email"
	name="Email"
	comparator="<%= cmSortByEmailAddress %>">
	<%= cm.getUser().getEmailAddress() %> 
</bbUI:listElement>

<bbUI:listElement
	label="Role"
	name="Role"
	comparator="<%= cmSortByRole %>">
	<%= getRoleString( "COURSE", cm.getRole() ) %>
</bbUI:listElement>

</bbUI:list>

</p> 
	
	
	
  
<% 
	User u = ctx.getUser();;
	Course c = ctx.getCourse();
	// get the membership data to determine the User's Role
	CourseMembership crsMembership = null;
	CourseMembershipDbLoader crsMembershipLoader = null;
	PersistenceService bbPm = PersistenceServiceFactory.getInstance() ;
    BbPersistenceManager bpManager = bbPm.getDbPersistenceManager();
 
	String errMsg = null;
	crsMembershipLoader = (CourseMembershipDbLoader)bpManager.getLoader(CourseMembershipDbLoader.TYPE);
	
	try {
		crsMembership = crsMembershipLoader.loadByCourseAndUserId(c.getId(), u.getId());
	} catch (KeyNotFoundException e) {
			// There is no membership record.
			errMsg = "There is no membership record. Better check this out:" + e;
	} catch (PersistenceException pe) {
			// There is no membership record.
			errMsg = "An error occured while loading the User. Better check this out:" + pe;
	}
	CourseMembership.Role crsMembershipRole = crsMembership.getRole();
	String crsMembershipRoleStr = crsMembershipRole.toString();
	boolean roleInstructor = false;

	// start of the roster


	//This one needs to go behind the activate button
	if (crsMembershipRole == CourseMembership.Role.INSTRUCTOR)
	{
		roleInstructor = true;
		GradeLogistics gl = new GradeLogistics();
		gl.initGradeLogistics("yccs_chemistrylab1");
		gl.makeLineItem("yccs_chemistrylab1", 100, ctx);
			
	}
//This one will go behindthe lab submit button
	else if (crsMembershipRole == CourseMembership.Role.STUDENT)
	{
/*		GradeLogistics gl = new GradeLogistics();
		Lineitem l = gl.getLineItem("yccs_chemistrylab1", ctx.getCourseId());
		if (l != null)
			gl.addStudentAttempts(ctx, "yccs_chemistrylab1", l.getId());
		else
			out.println("This should not happen: cant find lineitem for this assignment");
*/
	}
%>
	<p>
	The User's Role is: <%=crsMembershipRoleStr%> </p>

     <script>
        function enableButton2() {
        	document.getElementById("button2").disabled = false;
        	out.println("<p> test try");
<%---		try{
         	    Lineitem assignment = new Lineitem();
        		out.println("<p> test try");
        	    assignment.setCourseId(ctx.getCourseId());
        	    assignment.setName("Lab 1");
        	    assignment.setPointsPossible(100);
        	    assignment.setType("Lab 1");
        	    assignment.setIsAvailable(true);
        	    assignment.setDateAdded();
        	    LineitemDbPersister linePersister = LineitemDbPersister.Default.getInstance();
        	    linePersister.persist(assignment);
        	    out.println("<p>check the gradecenter");
        		} 
        	  
        	  catch (Exception e) {
        	    out.println("<p>" + e.getClass().getSimpleName() + ": " + e.getMessage());
        	    out.println("<p>check the tomcat logfiles");
        	    e.printStackTrace();
        	  }
        ---%>	
        }
    </script>

<script>
		function callLab1 () {
			window.open("index.jsp") 
		//	window.open("create.jsp")
		
		}
	
</script>

 <form method="post" action="${pageContext.request.contextPath}/Labs" > 
    <input type="submit" name="Activate" id="button1" value="Activate"  onclick=enableButton2() />  
 </form>
 
<form method="post" action="index.jsp?course_id=${ctx.courseId.externalString}&user_id=${ctx.userId.externalString}"> 
    <input type="submit" id="button2" value="lab 1"/>
</form>

<br>
<form method="post" action="lab2.jsp?course_id=${ctx.courseId.externalString}&user_id=${ctx.userId.externalString}"> 
    <input type="submit" id="button3" value="lab 2"/>
</form>

<br>
<form method="post" action="lab3.jsp?course_id=${ctx.courseId.externalString}&user_id=${ctx.userId.externalString}"> 
    <input type="submit" id="button4" value="lab 3"/>
</form>
<br>
<br>
<br>
		<form action="welcome" method="post">
			<input type="submit" value="Lab n">
		</form>

	</html>

</bbNG:learningSystemPage>
Status API Training Shop Blog About Pricing
© 2016 GitHub, Inc. Terms Privacy Security Contact Help
