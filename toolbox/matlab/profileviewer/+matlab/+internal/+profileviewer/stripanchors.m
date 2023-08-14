function str=stripanchors(str)















    str=regexprep(str,'<a.*?>','');
    str=regexprep(str,'</a>','');
    str=regexprep(str,'<form.*?</form>','');
    disabledLinkText=message('MATLAB:profiler:LinksDisabled');
    str=strrep(str,'<body>',['<body bgcolor="#F8F8F8"><strong>',disabledLinkText.getString(),'</strong><p>']);

    web('-new','-noaddressbox',['text://',str]);