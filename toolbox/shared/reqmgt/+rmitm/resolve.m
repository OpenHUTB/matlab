function[testSuite,id,ext]=resolve(varargin)

    source=varargin{1};

    if any(source=='|')
        [srcName,remainder]=strtok(source,'|');
        id=remainder(2:end);
    else
        srcName=source;
        if nargin>1&&ischar(varargin{2})
            id=varargin{2};
        else
            id='';
        end
    end

    testSuite=rmitm.getFilePath(srcName);
    if nargout==3
        [~,~,ext]=fileparts(testSuite);
    else
        ext='';
    end
end


