define(DATE,esyscmd(date +"%d %b %Y"))dnl
define(YEAR,esyscmd(date +"%Y"))dnl
define(`forloop',`pushdef(`$1', `$2')_forloop(`$1', `$2', `$3', `$4')popdef(`$1')')dnl
define(`_forloop',`$4`'ifelse($1, `$3', ,`define(`$1', incr($1))_forloop(`$1', `$2', `$3', `$4')')')dnl
define(BEGINHEAD,
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html><head>
include(_copyright.html)
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>TITLE</title>
)dnl
define(ENDHEAD,
</head>
)dnl
define(_NBSPX,<img width="$1" height="$2" src="1x1t.gif">)
define(BEGINBODY,
<body>
<table border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2">
      <!-- BANNER -->
      <table width="100%" border="0" cellspacing="0" cellpadding="0" class="toc">
	<tr>
	  <td><img width="10" height="10" src="bordertl.gif"></td>
	  <td><img width="100" height="10" src="bordert.gif"></td>
	  <td><img width="10" height="10" src="bordert.gif"></td>
	  <td style="background-image:url(bordert.gif);">_NBSPX(1,1)</td>
	  <td><img width="152" height="10" src="bordert.gif"></td>
	  <td><img width="30" height="10" src="bordert.gif"></td>
	  <td><img width="10" height="10" src="bordertr.gif"></td>
	</tr>
	<tr>
	  <td><img width="10" height="30" src="borderl.gif"></td>
	  <td><img width="100" height="30" src="cornert.gif"></td>
	  <td style="background-image:url(ribbingv.gif);">_NBSPX(10,30)</td>
	  <td style="background-image:url(ribbingv.gif);">
	    <span style="line-height: 1px;">forloop(`i',1,100,`&nbsp; ')</span>
	  </td>
	  <td><img width="152" height="30" src="ggcov_banner4t.gif" alt="ggcov"></td>
	  <td style="background-image:url(ribbingv.gif);">_NBSPX(30,30)</td>
	  <td><img width="10" height="30" src="borderr.gif"></td>
	</tr>
	<tr>
	  <td><img width="10" height="10" src="borderl.gif"></td>
	  <td><img width="100" height="10" src="cornerm.gif"></td>
	  <td><img width="10" height="10" src="borderitl.gif"></td>
	  <td style="background-image:url(borderb.gif);">_NBSPX(1,1)</td>
	  <td><img width="152" height="10" src="ggcov_banner4b.gif"></td>
	  <td><img width="30" height="10" src="borderb.gif"></td>
	  <td><img width="10" height="10" src="borderbr.gif"></td>
	</tr>
      </table>
    </td>
  </tr>
  <tr>
    <td valign="top">
      <!-- TOC -->
include(toc.html.in)
    </td>
    <td valign="top">
      <table width="100%" cellspacing="0" cellpadding="10">
        <tr>
	  <td>
	    <!-- MAIN BODY -->
	    <h1>TITLE</h1>
)dnl
define(ENDBODY,
	  </td>
	</tr>
      </table>
    </td>
  </tr>
</table>
<!-- <HR NOSHADE SIZE=4> -->
<br><br>
<center>
<p class="small">
Last updated: DATE.<br>
&copy; 2001 Greg Banks. All Rights Reserved.<br>
Ant theme clipart from <a href="http://www.arttoday.com/">ArtToday.com</a>
</p>
</center>
</body></html>
)dnl
define(EMAILME,
$1 <a href="mailto:gnb@alphalink.com.au?Subject=ggcov">gnb@alphalink.com.au</a>
)dnl
dnl Usage: THUMBNAIL(some/dir/fred,gif,width,height,[alternate text])
define(THUMBNAIL,
<a href="$1.$2"><img src="$1_t.$2" width="$3" height="$4" alt="$5" border=0></a>
)dnl
dnl Usage: BEGINDOWNLOAD ( DOWNLOAD(description,filename) )* ENDDOWNLOAD
define(BEGINDOWNLOAD,
<table>
)dnl
define(ENDDOWNLOAD,
</table>
)dnl
define(DOWNLOAD,
`  <tr>
    <td valign=top><b>$1</b></td>
    <td>
      <a href="$2">$2</a><br>
      esyscmd(find . .. ../.. -maxdepth 1 -name $2 -exec ls -l \{\} \;| head -1 | awk {print`\$'5}) bytes<br>
      MD5 esyscmd(find . .. ../.. -maxdepth 1 -name $2 -exec md5sum \{\} \;| head -1 | awk {print`\$'1})
    </td>
  </tr>'
)dnl
