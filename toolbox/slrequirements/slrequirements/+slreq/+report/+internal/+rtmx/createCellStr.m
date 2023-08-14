function cellStr=createCellStr(tagStr,contentStr,varargin)
    attStr='';
    for index=1:2:length(varargin)
        attStr=sprintf('%s %s="%s"',attStr,varargin{index},varargin{index+1});
    end

    switch tagStr



    case 'span'
        cellStr=sprintf('<%s%s>%s</%s>',tagStr,attStr,contentStr,tagStr);
    otherwise



        cellStr=sprintf('<%s%s>\n%s\n</%s>\n',tagStr,attStr,contentStr,tagStr);

    end


end

