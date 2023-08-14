function contentStr=getDOMContentString(elems)










    if~iscell(elems)
        elems=num2cell(elems);
    end

    contentStr=getContentStringImpl(elems);

end

function str=getContentStringImpl(elems)


    nElems=numel(elems);
    str="";
    for k=1:nElems
        content=elems{k};
        if isa(content,"mlreportgen.dom.Text")


            str=strcat(str,string(content.Content));
        elseif isa(content,"mlreportgen.dom.Number")

            str=strcat(str,content.toString);
        elseif isa(content,"mlreportgen.dom.Element")&&~isempty(content.Children)

            str=strcat(str,getContentStringImpl(num2cell(content.Children)));
        elseif isstring(content)||ischar(content)
            str=strcat(str,content);
        end
    end
end
