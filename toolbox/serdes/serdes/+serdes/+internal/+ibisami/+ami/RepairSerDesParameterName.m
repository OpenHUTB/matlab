function repairedName=RepairSerDesParameterName(nodeName)







    cNodeName=char(nodeName);
    if numel(cNodeName)>0
        firstChar=cNodeName(1);
        if firstChar=='-'
            cNodeName(1)='m';
        elseif firstChar=='+'
            cNodeName(1)='p';
        elseif firstChar>='0'&&firstChar<='9'
            cNodeName=['p',cNodeName];
        end
    end
    repairedName=string(cNodeName);
end

