function checkContent(exception,condition,content,varargin)
    if~isempty(content)&&~isvector(content)
        throw(createValidatorException('mlreportgen:report:validators:mustBeList'));
    end
    if ischar(content)
        content=string(content);
    end
    if iscell(content)
        len=length(content);
        for i=1:len
            checkContent(exception,condition,content{i});
        end
    else
        if numel(content)>1
            len=length(content);
            for i=1:len
                checkContent(exception,condition,content(i),varargin{:});
            end
        else
            if~condition(content,varargin{:})
                throw(createValidatorException(exception,varargin{:}));
            end
        end
    end
