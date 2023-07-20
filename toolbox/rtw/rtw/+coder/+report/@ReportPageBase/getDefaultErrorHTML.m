function out=getDefaultErrorHTML(title,msg,bodyOption)
    css='<LINK rel="stylesheet" type="text/css" href="rtwreport.css" />';
    imgname='hilite_warning.png';
    img=['<IMG src="',imgname,'" />'];
    out=['<HTML><HEAD><TITLE>',title,'</TITLE>',css,'<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />','</HEAD><BODY ',bodyOption,'>','<H1>',title,'</H1>','<P>',img,msg,'</P>','</BODY></HTML>'];
end
