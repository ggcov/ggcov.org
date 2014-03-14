define(DATE,esyscmd(date +"%d %b %Y"))dnl
define(YEAR,esyscmd(date +"%Y"))dnl
define(`forloop',`pushdef(`$1', `$2')_forloop(`$1', `$2', `$3', `$4')popdef(`$1')')dnl
define(`_forloop',`$4`'ifelse($1, `$3', ,`define(`$1', incr($1))_forloop(`$1', `$2', `$3', `$4')')')dnl
define(_TITLE,`ggcov'ifdef(`TITLE',` - 'TITLE))
define(BEGINHEAD,
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html><head>
<!-- Copyright (c) include(_copyright.txt) -->
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>_TITLE</title>
<link REL="SHORTCUT ICON" HREF="favicon.ico">
<LINK href="ggcov.css" rel="stylesheet" type="text/css">
)dnl
define(ENDHEAD,
</head>
)dnl
define(_NBSPX,<img width="$1" height="$2" src="1x1t.gif" alt="">)
define(BEGINBODY,`
<body>

<table width="100%" border="0" cellspacing="0" cellpadding="5">
  <tr style="background:#afafcf;">
    <td colspan="2" valign="top" class="logo">_TITLE</td>
  </tr>
  <tr>
    <td align="center" valign="top" width="1">
      <!-- TOC -->
include(toc.html.in)
    </td>
    <td style="background:#ffffff;" valign="top" align="left">
      <!-- MAIN BODY -->
')dnl
define(ENDBODY,
    </td>
  </tr>
</table>
<!-- <HR NOSHADE SIZE=4> -->
<br><br>
<center>
<p class="small">Updated: DATE. Copyright &copy; include(_copyright.txt).</p>
<p>
      <!-- HTML copied from http://validator.w3.org/ 20061202 -->
      <!-- and added border="0" -->
      <a href="http://validator.w3.org/check?uri=referer"><img
      src="http://www.w3.org/Icons/valid-html40" border="0"
      alt="Valid HTML 4.0 Transitional" height="31" width="88"></a>
</p>
</center>
</body></html>
)dnl
define(EMAILME,
$1 <a href="mailto:gnb@users.sourceforge.com?Subject=ggcov">gnb@users.sourceforge.com</a>
)dnl
dnl Usage: THUMBNAIL(some/dir/fred,gif,width,height,[alternate text])
define(THUMBNAIL,
<a href="$1.$2"><img src="$1_t.$2" width="$3" height="$4" alt="$5" border=0></a>
)dnl
define(GGCOV,<span class="program">ggcov</span>)
define(TGGCOV,<span class="program">tggcov</span>)
define(GGCOV_WEB,<span class="program">ggcov-web</span>)
