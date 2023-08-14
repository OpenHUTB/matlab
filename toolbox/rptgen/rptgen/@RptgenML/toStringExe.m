function[s,newDataType]=toStringExe(v,dataType)






    if(nargin<2)
        dataType=class(v);
    end

    switch dataType
    case{'bool','LOGICAL'}
        if v
            s='true';
        else
            s='false';
        end
        newDataType='bool';

    case{'double','int32','NUMBER'}
        s=sprintf('[%s]',num2str(v));
        newDataType='double';

    case{'string','STRING','RGParsedString','ustring'}
        s=['''',strrep(rptgen.toString(v,0),'''',''''''),''''];
        newDataType='ustring';

    case{'string vector','CELL'};
        s='{';
        for i=1:length(v)
            s=[s,'''',strrep(rptgen.toString(v{i},0),'''',''''''),''', '];
        end
        s=[s,'}'];
        newDataType='string vector';

    case 'RGComponentOrParsedString'
        if ischar(v)
            s=['''',strrep(rptgen.toString(v,0),'''',''''''),''''];
        else
            s='[]';
        end
        newDataType='MATLAB array';

    case 'real point'
        s=rptgen.toString(v);
        newDataType='MATLAB array';

    otherwise
        s='[]';
        newDataType='MATLAB array';

        if(~strcmpi(dataType,'MATLAB array'))
            warning(message('rptgen:RptgenML:stringToExecutableConversionWarning'));
        end
    end

