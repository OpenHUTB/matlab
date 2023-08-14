function LinkStr=autoblksMdlHyperlink(Object,MaxLength,DispStr)















    if nargin<2
        MaxLength=[];
    end
    if nargin<3
        DispStr='';
    end
    Type=get_param(Object,'Type');
    if strcmp(Type,'block')||strcmp(Type,'block_diagram')
        SysName=getfullname(Object);
        if isempty(DispStr)
            DispStr=SysName;
        end
    else
        SysName=Object;
    end

    if isempty(MaxLength)
        MaxLength=inf;
    end


    if length(DispStr)>MaxLength
        DispStr=[v(1:MaxLength),'...'];
    end
    SysName=strrep(SysName,newline,' ');
    DispStr=strrep(DispStr,newline,' ');
    if strcmp(Type,'block_diagram')
        LinkStr=sprintf('<a href="matlab:open_system(''%s'')">%s</a>',SysName,DispStr);
    elseif ishandle(SysName)
        LinkStr=sprintf('<a href="matlab:hilite_system(%1.20d, ''find'')">%s</a>',SysName,DispStr);
    else
        LinkStr=sprintf('<a href="matlab:hilite_system(''%s'', ''find'')">%s</a>',SysName,DispStr);
    end