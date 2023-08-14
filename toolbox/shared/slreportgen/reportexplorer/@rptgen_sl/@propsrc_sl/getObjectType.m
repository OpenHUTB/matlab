function objectType=getObjectType(~,obj)





    if~exist('obj','var')
        obj=[];
    end

    if isempty(obj)
        objectType='Model';

    elseif isa(obj,'Simulink.ConfigSet')
        objectType='ConfigSet';

    elseif isa(obj,'Simulink.VariableUsage')
        objectType='Simulink Workspace Variable';

    else
        objectType=locResolveSimulinkType(obj);
    end


    function objectType=locResolveSimulinkType(obj)

        if isa(obj,'Simulink.Object')
            type=get(obj,'Type');
        else
            type=get_param(obj,'Type');
        end

        switch(type)
        case 'block_diagram'
            objectType='Model';

        case 'block'
            objectType=locResolveBlockType(obj);

        case 'annotation'
            objectType='Annotation';

        otherwise
            objectType='Signal';
        end


        function objectType=locResolveBlockType(obj)

            objectType='Block';
            try
                if isa(obj,'Simulink.Object')
                    blockType=obj.BlockType;
                    blockFullName=obj.getFullName();
                else
                    blockType=get_param(obj,'BlockType');
                    blockFullName=getfullname(obj);
                end
                blockFullName=strrep(blockFullName,char(10),' ');

            catch ME %#ok
                blockType='';
            end

            adSL=rptgen_sl.appdata_sl;
            sysList=adSL.ReportedSystemList;

            if(strcmp(blockType,'SubSystem')&&ismember(blockFullName,sysList))
                objectType='System';
            end

