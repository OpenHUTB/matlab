function keywords = getkeywordlist
%

%   Copyright 2020-2021 The MathWorks, Inc.

    fullPath      = fileparts( mfilename('fullpath') );
    xml           = PLCCoder.PLCUtils.parseXMLDoc([fullPath,filesep,'plcopenkeywords.xml']);
    list          = xml.getElementsByTagName('name');
    keywords = cell(list.getLength,1);
    for index = 1:list.getLength
        item                 = list.item(index-1);
        keywords{index} = char( item.getTextContent );
    end
    keywords = unique(keywords);
end

% LocalWords:  plcopenkeywords
