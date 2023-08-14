function dtlist = getprefixlist
%

%   Copyright 2020-2021 The MathWorks, Inc.

    fullPath      = fileparts( mfilename('fullpath') );
    xml           = PLCCoder.PLCUtils.parseXMLDoc([fullPath,filesep,'plcopenkeywords.xml']);
    list          = xml.getElementsByTagName('dt');
    elements = cell(list.getLength,1);
    for index = 1:list.getLength
        item                 = list.item(index-1);
        elements{index} = char( item.getTextContent );
    end
    elements = unique(elements);
    elements = cellfun(@(x) strsplit(x,'-'),elements,'UniformOutput',false);
    dtlist.dt = cellfun(@(x) x{1},elements,'UniformOutput',false);
    dtlist.pf = cellfun(@(x) x{2},elements,'UniformOutput',false);
end

% LocalWords:  plcopenkeywords
