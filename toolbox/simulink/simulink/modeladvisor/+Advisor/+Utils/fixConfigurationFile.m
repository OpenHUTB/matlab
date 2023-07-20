function fixConfigurationFile(filename)










    am=Advisor.Manager.getInstance;
    if~isfield(am.slCustomizationDataStructure,'checkCellArray')
        am.loadslCustomization;
    end
    CheckIDMap=am.slCustomizationDataStructure.CheckIDMap;
    checkCellArray=am.slCustomizationDataStructure.checkCellArray;

    [~,~,ext]=fileparts(filename);
    if strcmpi(ext,'.json')
        fixJSONConfig(filename,CheckIDMap,checkCellArray);
        return;
    end

    load(filename);
    cuicellarrary=[{configuration.ConfigUIRoot},configuration.ConfigUICellArray];
    needFix=false;

    for i=1:length(cuicellarrary)
        if~isempty(cuicellarrary{i}.ParentObj)



            cuicellarrary{i}.ParentObj=cuicellarrary{cuicellarrary{i}.ParentObj+1};

        end
        for j=1:numel(cuicellarrary{i}.ChildrenObj)
            cuicellarrary{i}.ChildrenObj{j}=cuicellarrary{cuicellarrary{i}.ChildrenObj{j}+1};
        end
    end
    for i=1:length(cuicellarrary)
        if~isempty(cuicellarrary{i}.MAC)
            if CheckIDMap.isKey(cuicellarrary{i}.MAC)
                matchCheckIndex=CheckIDMap(cuicellarrary{i}.MAC);
                correspondingCheckObj=checkCellArray{matchCheckIndex};

                foundMatch=true;
            else

                foundMatch=false;
                newID=ModelAdvisor.convertCheckID(cuicellarrary{i}.MAC);
                if CheckIDMap.isKey(newID)
                    modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',cuicellarrary{i}.MAC,newID);
                    matchCheckIndex=CheckIDMap(newID);
                    correspondingCheckObj=checkCellArray{matchCheckIndex};
                    if~isempty(correspondingCheckObj)

                        foundMatch=true;
                    end
                end
                if~foundMatch
                    needFix=true;
                    disp(DAStudio.message('Simulink:tools:MALoadConfigMissCorrespondCheck',cuicellarrary{i}.MAC,cuicellarrary{i}.DisplayName,filename));
                    disp('    ###### will remove above obselete check ######');
                    cuicellarrary{i}.MACIndex=-1;

                    if~isempty(cuicellarrary{i}.ParentObj)
                        newChildrenObj={};
                        for j=1:length(cuicellarrary{i}.ParentObj.ChildrenObj)
                            if~strcmp(cuicellarrary{i}.ParentObj.ChildrenObj{j}.ID,cuicellarrary{i}.ID)
                                newChildrenObj{end+1}=cuicellarrary{i}.ParentObj.ChildrenObj{j};%#ok<AGROW>
                            end
                        end
                        cuicellarrary{i}.ParentObj.ChildrenObj=newChildrenObj;
                    end
                end
            end

            if foundMatch&&(cuicellarrary{i}.MACIndex==-1)
                cuicellarrary{i}.MACIndex=12345;
            end

            if foundMatch&&~isempty(cuicellarrary{i}.InputParameters)
                if~loc_verify_inputparam(cuicellarrary{i}.InputParameters,correspondingCheckObj.InputParameters)
                    if strncmp(correspondingCheckObj.ID,'mathworks.maab.',15)&&loc_verify_inputparam(cuicellarrary{i}.InputParameters,skip_MAAB_find_system_inputparam(correspondingCheckObj.InputParameters))


                    else

                        disp(DAStudio.message('ModelAdvisor:engine:InputParamMismatchInConfigFile',cuicellarrary{i}.MAC,cuicellarrary{i}.DisplayName,filename));
                        disp('    ###### will update input parameter for the above check ######');
                        cuicellarrary{i}.InputParameters=correspondingCheckObj.InputParameters;
                        needFix=true;
                    end
                end
            end
        end
    end

    if needFix
        newConfigUICellArray={};
        for i=1:numel(cuicellarrary)
            if~isempty(cuicellarrary{i}.MAC)&&(cuicellarrary{i}.MACIndex==-1)
            else
                newConfigUICellArray{end+1}=cuicellarrary{i};%#ok<AGROW>
                if~isempty(cuicellarrary{i}.MAC)
                    if~isempty(ModelAdvisor.convertCheckID(cuicellarrary{i}.MAC))
                        disp(['    ###### replace old check ID ',cuicellarrary{i}.MAC,' with new ID ',ModelAdvisor.convertCheckID(cuicellarrary{i}.MAC),' for node ',cuicellarrary{i}.ID]);
                        newConfigUICellArray{end}.MAC=ModelAdvisor.convertCheckID(cuicellarrary{i}.MAC);
                    end
                end
            end
        end
        idMap=containers.Map;
        for i=1:length(newConfigUICellArray)
            idMap(newConfigUICellArray{i}.ID)=i-1;
        end
        for i=1:length(newConfigUICellArray)
            newConfigUICellArray{i}.Index=i-1;
            if~isempty(newConfigUICellArray{i}.ParentObj)
                newConfigUICellArray{i}.ParentObj=idMap(newConfigUICellArray{i}.ParentObj.ID);
            end
            for j=1:numel(newConfigUICellArray{i}.ChildrenObj)
                newConfigUICellArray{i}.ChildrenObj{j}=idMap(newConfigUICellArray{i}.ChildrenObj{j}.ID);
            end
        end

        configuration.ConfigUICellArray=newConfigUICellArray(2:end);
        [path,name,ext]=fileparts(filename);
        newfilename=[path,name,'fix',ext];
        disp('################################################');
        disp(['###### fixed configuration is saved as ',newfilename]);
        disp('################################################');
        save(newfilename,'configuration');
    end

    function verified=loc_verify_inputparam(InputParameters1,InputParameters2)
        if length(InputParameters1)==length(InputParameters2)
            verified=true;
            for i=1:length(InputParameters1)
                if~strcmp(InputParameters1{i}.type,InputParameters2{i}.type)
                    verified=false;
                    break;
                end
            end
        else
            verified=false;
        end

        function OutputParameters=skip_MAAB_find_system_inputparam(InputParameters)
            OutputParameters={};
            followlinkParam=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
            lookundermaskParam=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
            find_systemParamNames={followlinkParam.Name,lookundermaskParam.Name};
            for i=1:length(InputParameters)
                if~ismember(InputParameters{i}.Name,find_systemParamNames)
                    OutputParameters{end+1}=InputParameters{i};%#ok<AGROW>
                end
            end

            function InputParameters=loc_converIpToJSON(IpCheck)
                InputParameters=struct('name','',...
                'index',0,...
                'type','',...
                'visible','',...
                'entries','',...
                'value','',...
                'rowspan1','',...
                'rowspan2','',...
                'colspan1','',...
                'colspan2','',...
                'isenable',true);

                for i=1:length(IpCheck)
                    outIp.name=IpCheck{i}.Name;
                    outIp.index=i;
                    outIp.isenable=IpCheck{i}.Enable;
                    outIp.type=IpCheck{i}.Type;
                    outIp.visible=IpCheck{i}.Visible;

                    if~isempty(IpCheck{i}.RowSpan)
                        outIp.rowspan1=IpCheck{i}.RowSpan(1);
                        outIp.rowspan2=IpCheck{i}.RowSpan(2);
                    else
                        outIp.rowspan1=i;
                        outIp.rowspan2=i;
                    end

                    if~isempty(IpCheck{i}.ColSpan)
                        outIp.colspan1=IpCheck{i}.ColSpan(1);
                        outIp.colspan2=IpCheck{i}.ColSpan(2);
                    else
                        outIp.colspan1=1;
                        outIp.colspan2=1;
                    end

                    switch IpCheck{i}.Type
                    case 'BlockType'
                        ValueElement=[];
                        for j=1:length(IpCheck{i}.Value)
                            if isempty(IpCheck{i}.Value{j})
                                continue;
                            end
                            ValueElement(j).name=IpCheck{i}.Value{j,1};
                            ValueElement(j).masktype=IpCheck{i}.Value{j,2};
                        end
                        outIp.entries=IpCheck{i}.Entries;
                        outIp.value=ValueElement;
                    case 'BlockTypeWithParameter'
                        ValueElement=[];
                        for j=1:length(IpCheck{i}.Value)
                            if isempty(IpCheck{i}.Value{j})
                                continue;
                            end
                            ValueElement(j).name=IpCheck{i}.Value{j,1};
                            ValueElement(j).masktype=IpCheck{i}.Value{j,2};
                            ValueElement(j).blocktypeparameters=IpCheck{i}.Value{j,3};
                        end
                        outIp.entries=IpCheck{i}.Entries;
                        outIp.value=ValueElement;
                    case 'PushButton'
                        outIp.entries=[];
                        outIp.value=IpCheck{i}.value;
                    otherwise
                        outIp.entries=IpCheck{i}.Entries;
                        outIp.value=IpCheck{i}.value;
                    end
                    InputParameters(i)=outIp;
                end



                function fixJSONConfig(filename,CheckIDMap,checkCellArray)
                    needFix=false;
                    config=jsondecode(fileread(filename));
                    for i=1:length(config.Tree)
                        if~isempty(config.Tree{i}.checkid)
                            if CheckIDMap.isKey(config.Tree{i}.checkid)
                                matchCheckIndex=CheckIDMap(config.Tree{i}.checkid);
                                correspondingCheckObj=checkCellArray{matchCheckIndex};
                                foundMatch=true;
                            else

                                foundMatch=false;
                                newID=ModelAdvisor.convertCheckID(config.Tree{i}.checkid);
                                if CheckIDMap.isKey(newID)
                                    matchCheckIndex=CheckIDMap(newID);
                                    correspondingCheckObj=checkCellArray{matchCheckIndex};
                                    if~isempty(correspondingCheckObj)
                                        foundMatch=true;
                                    end
                                end
                                if~foundMatch
                                    needFix=true;
                                    disp(DAStudio.message('Simulink:tools:MALoadConfigMissCorrespondCheck',config.Tree{i}.checkid,config.Tree{i}.label,filename));
                                    disp('    ###### will remove above obselete check ######');
                                    config.Tree{i}.checkid=-1;
                                end
                            end

                            if foundMatch&&~isempty(config.Tree{i}.InputParameters)
                                if~loc_verify_inputparam(num2cell(config.Tree{i}.InputParameters),correspondingCheckObj.InputParameters)
                                    if~(strncmp(correspondingCheckObj.ID,'mathworks.maab.',15)&&loc_verify_inputparam(num2cell(config.Tree{i}.InputParameters),skip_MAAB_find_system_inputparam(correspondingCheckObj.InputParameters)))
                                        disp(DAStudio.message('ModelAdvisor:engine:InputParamMismatchInConfigFile',config.Tree{i}.checkid,config.Tree{i}.label,filename));
                                        disp('    ###### will update input parameter for the above check ######');
                                        config.Tree{i}.InputParameters=loc_converIpToJSON(correspondingCheckObj.InputParameters);
                                        needFix=true;
                                    end
                                end
                            end
                        end
                    end

                    if needFix
                        newTree={};
                        for i=1:numel(config.Tree)
                            if config.Tree{i}.checkid==-1

                            elseif isempty(config.Tree{i}.checkid)
                                config.Tree{i}.checkid=NaN;
                                newTree{end+1}=config.Tree{i};%#ok<AGROW>
                            else
                                newTree{end+1}=config.Tree{i};%#ok<AGROW>
                                if~isempty(config.Tree{i}.checkid)
                                    if~isempty(ModelAdvisor.convertCheckID(config.Tree{i}.checkid))
                                        disp(['    ###### replace old check ID ',config.Tree{i}.checkid,' with new ID ',ModelAdvisor.convertCheckID(config.Tree{i}.checkid),' for node ',config.Tree{i}.id]);
                                        newTree{end}.checkid=ModelAdvisor.convertCheckID(config.Tree{i}.checkid);
                                    end
                                end
                            end
                        end

                        config.Tree=newTree;
                        config.Tree{1}.parent=NaN;
                        [path,name,ext]=fileparts(filename);
                        newfilename=[path,name,'fix',ext];
                        disp('################################################');
                        disp(['###### fixed configuration is saved as ',newfilename]);
                        disp('################################################');
                        fid=fopen(newfilename,'wt','n','UTF-8');
                        fwrite(fid,jsonencode(config,'PrettyPrint',true),'char');
                        fclose(fid);
                    end