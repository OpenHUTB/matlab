function objectName=getObjectName(this,obj,objectType)







    if iscell(obj)
        obj=obj{1};
    end

    if isa(obj,'Simulink.Annotation')
        objectName=obj.PlainText;

    elseif isa(obj,'Simulink.Object')
        objectName=obj.Name;

    elseif isa(obj,'Simulink.VariableUsage')
        objectName=obj.Name;

    elseif(ischar(obj)||ishandle(obj))
        if strcmp(get_param(obj,'Type'),'annotation')
            objectName=getObjectName(this,get_param(obj,'Object'));
        else
            objectName=get_param(obj,'Name');
        end

    else
        error(message('Simulink:rptgen_sl:InvalidSimulinkObject'));
    end

    if isempty(objectName)

        try
            portNum=get_param(obj,'PortNumber');
            parentName=strrep(get_param(get_param(obj,'Parent'),'Name'),...
            char(10),' ');
            objectName=sprintf('%s<%i>',parentName,portNum);
        catch me %#ok
            objectName=rptgen.toString(obj);
        end
    else
        if((nargin<3)||isempty(objectType))
            objectType=this.getObjectType(obj);
        end

        if strncmpi(objectType,'a',1)
            objectName=getFirstLine(objectName);
        else
            objectName=strrep(objectName,char(10),' ');
        end
    end


    function objectName=getFirstLine(objectName)


        crIdx=find(objectName==char(10));
        if~isempty(crIdx)
            if(crIdx(1)==length(objectName))
                objectName=objectName(1:crIdx(1)-1);
            else
                objectName=[objectName(1:crIdx(1)-1),'...'];
            end
        end
        objectName=rptgen.truncateString(objectName,'',32);
