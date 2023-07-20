function out=getCommaSeparatedStringFromCellstr(c,format)
















    if~iscellstr(c)
        throwAsCaller(MException(message('SimBiology:Internal:NOT_CELLSTR')));
    end
    if~exist('format','var')
        format='%s';
    end
    switch numel(c)
    case 0
        out='';
    case 1

        out=sprintf(format,c{1});
    case 2

        out=sprintf([format,' and ',format],c{:});
    otherwise

        out=[sprintf([format,', '],c{1:end-1}),...
        sprintf(['and ',format],c{end})];
    end
