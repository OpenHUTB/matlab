function info=getParameterDialogInfo(hObj,isReset)





    if~isReset
        info=get_param(hObj.getConfigSet(),'DialogTemplateData');
        if~isempty(info)
            return
        end
    end

    evaluatedAttributes={'RowSpan','ColSpan',...
    'Alignment','DialogRefresh','DoNotStore',...
    'SaveValueAsString'};
    evaluatedAttributeTypes={'int16','int16',...
    'int8','logical','logical',...
    'logical'};

    info.ParameterGroups={};
    info.Parameters={};

    hardwareInfo=codertarget.targethardware.getHardwareConfiguration(hObj);
    if isempty(hardwareInfo)||isempty(hardwareInfo.ParameterInfoFile)
        return;
    end

    attributeInfo=codertarget.attributes.getTargetHardwareAttributes(hObj);
    if~isempty(attributeInfo)
        Tokens=attributeInfo.Tokens;
    else
        Tokens={};
    end
    defFile=codertarget.utils.replaceTokens(hObj,...
    hardwareInfo.ParameterInfoFile,Tokens,true);

    paramInfo=codertarget.Registry.manageInstance('get','parameters',defFile);
    info.Parameters=paramInfo.getParameters();
    info.ParameterGroups=paramInfo.getParameterGroups();

    if~isequal(length(info.ParameterGroups),length(info.Parameters))
        info.ParameterGroups={};

    end

    for i=1:length(info.ParameterGroups)
        row=0;
        for j=1:length(info.Parameters{i})
            fieldnames=fields(info.Parameters{i}{j});
            for k=1:numel(fieldnames)
                thisField=fieldnames{k};
                [doEvaluate,idx]=ismember(thisField,evaluatedAttributes);
                if doEvaluate
                    curVal=info.Parameters{i}{j}.(thisField);
                    try
                        fpadd=str2func(evaluatedAttributeTypes{idx});
                        try
                            val=fpadd(eval(curVal));
                        catch me
                            val=[];
                        end
                        if isequal(thisField,'RowSpan')&&isequal(val,[0,0])
                            row=row+1;
                            val=[row,row];
                        end
                        info.Parameters{i}{j}.(thisField)=val;
                    catch me %#ok<*NASGU>

                    end
                elseif isequal(thisField,'Entries')&&~isempty(info.Parameters{i}{j}.(thisField))
                    rawEntries=textscan(info.Parameters{i}{j}.(thisField),'%s','delimiter',';');
                    info.Parameters{i}{j}.(thisField)=rawEntries{1}';
                elseif isequal(thisField,'Entries')
                    info.Parameters{i}{j}.(thisField)={};
                end
            end
            if ischar(info.Parameters{i}{j}.Value)&&...
                ~isequal(info.Parameters{i}{j}.ValueType,'callback')&&...
                ~isequal(info.Parameters{i}{j}.SaveValueAsString,true)
                info.Parameters{i}{j}.Value=str2num(info.Parameters{i}{j}.Value);%#ok<ST2NM>
            end
        end
    end

    if~hObj.isHierarchyBuilding&&~hObj.isHierarchySimulating&&~isa(hObj,'Simulink.ConfigSetRef')
        set_param(hObj.getConfigSet(),'DialogTemplateData',info);
    end

end
