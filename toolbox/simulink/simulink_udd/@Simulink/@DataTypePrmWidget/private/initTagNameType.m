function curItem=initTagNameType(varargin)





















    assert(nargin==3||nargin==4,...
    ['Number of arguments of function initTagNameType has to be '...
    ,'between 3 and 4.']);

    tag=varargin{1};
    if nargin==3
        name=varargin{2};
        type=varargin{3};
    else
        tag2=varargin{2};
        if ischar(tag)
            assert(ischar(tag2));
            tag=[tag,'|',tag2];
        end
        name=varargin{3};
        type=varargin{4};
    end

    if ischar(tag)
        curItem.Tag=tag;
    end

    if~ischar(name)||isempty(name)
        curItem.Name='';
    else
        curItem.Name=DAStudio.message(['Simulink:dialog:',name]);
    end

    curItem.Type=type;



