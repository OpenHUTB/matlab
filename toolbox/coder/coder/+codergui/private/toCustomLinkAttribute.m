function html=toCustomLinkAttribute(linkType,fileArg,varargin)





    linkType=validatestring(linkType,{'matlabFunction','cFunction','file'});
    locationArgIndex=3;

    switch linkType
    case 'matlabFunction'
        assert(isnumeric(fileArg));
        data.functionId=fileArg;
    case 'cFunction'
        narginchk(3,4);
        assert(ischar(fileArg)&&ischar(varargin{1}));
        data.cFunctionName=varargin{1};
        data.file=escapeStr(cleanStr(fileArg));
        locationArgIndex=locationArgIndex+1;
    case 'file'
        assert(ischar(fileArg));
        data.file=escapeStr(cleanStr(fileArg));
    otherwise
        assert(false);
    end

    if nargin>=locationArgIndex
        locationArg=varargin{locationArgIndex-2};
        assert(isnumeric(locationArg));
        if numel(locationArg)>1

            data.start=locationArg(1);
            data.end=locationArg(2);
        else
            data.line=locationArg;
        end
    end

    html=['data-linktarget=''',jsonencode(data),''''];
end

function escaped=escapeStr(str)
    escaped=strrep(strrep(str,'''','&apos;'),'&','&amp;');
end

function cleaned=cleanStr(str)

    cleaned=fullfile(str);
end