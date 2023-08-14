






function reservedNames=getReservedNames()
    import matlab.io.xml.dom.*
    fullPath=fileparts(mfilename('fullpath'));
    xml=parseFile(Parser,[fullPath,filesep,'reservedNames.xml']);
    list=xml.getElementsByTagName('name');
    reservedNames=cell(list.getLength,1);
    for index=1:list.getLength
        item=list.item(index-1);
        reservedNames{index}=char(item.getTextContent);
    end
    reservedNames=unique(reservedNames);
end


