function text=getXMLNodeTextContent(node)
    if(node.hasChildNodes())
        text=strtrim(char(node.getFirstChild().getTextContent()));
    else
        text='';
    end
end