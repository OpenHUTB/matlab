function out=getAllChildTagNodes(obj)




    cNodes=obj.getChildNodes;
    out={};
    for i=1:cNodes.getLength
        if isa(cNodes.item(i-1),'matlab.io.xml.dom.Element')
            out{end+1}=cNodes.item(i-1);%#ok<*AGROW>
        end
    end
end
