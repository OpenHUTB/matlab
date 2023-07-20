function out=getTemplateKeywords





    out=containers.Map('KeyType','char','ValueType','char');
    files=which('+simscape/+template/ssc_template_keywords.xml','-all');



    for i=length(files):-1:1
        out=lParseFile(files{i},out);
    end

end

function map=lParseFile(filename,map)


    try
        xDoc=parseFile(matlab.io.xml.dom.Parser,filename);
        keywords=xDoc.getElementsByTagName('Entry');
        for i=0:keywords.getLength-1
            map=lParseKeyword(keywords.item(i),map,filename);
        end
    catch ME
        pm_warning('physmod:simscape:templates:newfile:FailedToParseXML',...
        filename,ME.message);
    end

end

function map=lParseKeyword(keyword,map,filename)

    xKey=keyword.getElementsByTagName('Keyword');
    xValue=keyword.getElementsByTagName('Template');
    if xKey.getLength~=1||xValue.getLength~=1
        pm_error('physmod:simscape:templates:newfile:KeyLengthNotOne');
    end

    key=char(xKey.item(0).item(0).getData);
    value=char(xValue.item(0).item(0).getData);
    if~isvarname(key)
        pm_error('physmod:simscape:templates:newfile:InvalidMatlabId',key);
    end

    if map.isKey(key)
        pm_warning('physmod:simscape:templates:newfile:KeywordOverride',...
        key,filename,value);
    end
    map(key)=value;
end