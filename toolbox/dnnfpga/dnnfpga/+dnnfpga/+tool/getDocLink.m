function docLink=getDocLink(anchorID,msg,spID)


    if nargin<3
        spID='';
    end

    if isa(msg,'message')
        msg=msg.getString;
    end

    href=sprintf('matlab:dnnfpga.tool.helpView(''%s'', ''%s'');',anchorID,spID);
    docLink="<a href="""+href+""">"+msg+"</a>";
end