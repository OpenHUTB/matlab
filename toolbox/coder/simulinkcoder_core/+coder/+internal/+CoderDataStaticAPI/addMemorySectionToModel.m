function addMemorySectionToModel(sourceDD,varargin)














    import coder.internal.CoderDataStaticAPI.*;


    nameIdx=find(ismember(varargin,'Name'));
    if isempty(nameIdx)
        error('Name is a required property');
    else
        msName=varargin{nameIdx+1};
    end


    validProperties={'Name','Comment','PreStatement','PostStatement','StatementsSurround'};
    for idx=1:2:length(varargin)
        if~any(ismember(validProperties,varargin{idx}))
            error([varargin{idx},' is an invalid property name. ',...
            'Valid names are Name, Comment, PreStatement, PostStatement, StatementsSurround']);
        end
    end


    hlp=getHelper();
    dd=hlp.openDD(sourceDD);
    ms=hlp.createEntry(dd,'MemorySection',msName);


    for idx=1:2:length(varargin)
        if isequal(varargin{idx},'Name')
            continue;
        end
        hlp.setProp(ms,varargin{idx},varargin{idx+1});
    end
end
