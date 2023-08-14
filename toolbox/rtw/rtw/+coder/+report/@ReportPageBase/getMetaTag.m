function out=getMetaTag(rpt)
    encoding=rpt.getEncoding;
    if~isempty(encoding)
        out=['<meta http-equiv="Content-Type" content="text/html; charset=',encoding,'" />'];
    else
        out='';
    end
end
