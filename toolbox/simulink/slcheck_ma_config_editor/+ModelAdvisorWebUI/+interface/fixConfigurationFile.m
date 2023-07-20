function result=fixConfigurationFile()





    filename=ModelAdvisorWebUI.interface.ValidationCheckRegistration.getInstance.getCompleteFileName;
    am=Advisor.Manager.getInstance;
    if~isfield(am.slCustomizationDataStructure,'checkCellArray')
        am.loadslCustomization;
    end
    CheckIDMap=am.slCustomizationDataStructure.CheckIDMap;
    checkCellArray=am.slCustomizationDataStructure.checkCellArray;
    updatedIPChecks=[];
    deletedChecks=[];
    updatedIDChecks=[];

    [~,~,ext]=fileparts(filename);
    if strcmpi(ext,'.json')
        result=fixJSONConfig(filename,CheckIDMap,checkCellArray);
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

                    cuicellarrary{i}.MACIndex=-1;

                    if~isempty(cuicellarrary{i}.ParentObj)
                        newChildrenObj={};
                        for j=1:length(cuicellarrary{i}.ParentObj.ChildrenObj)
                            if~strcmp(cuicellarrary{i}.ParentObj.ChildrenObj{j}.ID,cuicellarrary{i}.ID)
                                newChildrenObj{end+1}=cuicellarrary{i}.ParentObj.ChildrenObj{j};%#ok<AGROW>
                            end
                        end
                        cuicellarrary{i}.ParentObj.ChildrenObj=newChildrenObj;
                        deletedChecks{end+1}=cuicellarrary{i}.displayName;

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

                        cuicellarrary{i}.InputParameters=correspondingCheckObj.InputParameters;
                        cuicellarrary{i}.MACIndex=correspondingCheckObj.Index;
                        updatedIPChecks{end+1}=cuicellarrary{i}.displayName;
                        needFix=true;
                    end
                end
            end
        end
    end

    if needFix
        newConfigUICellArray={};
        for i=1:numel(cuicellarrary)
            newConfigUICellArray{end+1}=cuicellarrary{i};%#ok<AGROW>
            if~isempty(cuicellarrary{i}.MAC)
                if~isempty(ModelAdvisor.convertCheckID(cuicellarrary{i}.MAC))

                    updatedIDChecks{end+1}=cuicellarrary{i}.displayName;
                    newConfigUICellArray{end}.MAC=ModelAdvisor.convertCheckID(cuicellarrary{i}.MAC);
                end
            end
        end
        maObj=Simulink.ModelAdvisor;
        maObj.ConfigUICellArray=configuration.ConfigUICellArray;
        maObj.ConfigUIRoot=configuration.ConfigUIRoot;
        maObj.ConfigFilePath=filename;
        jsonString=Advisor.Utils.exportJSON(maObj,'MACE');
        resultStruct=struct('updatedIPChecks',{updatedIPChecks},'deletedChecks',{deletedChecks},'updatedIDChecks',{updatedIDChecks},'val',jsonString);
        result=resultStruct;
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

                function result=fixJSONConfig(filename,CheckIDMap,checkCellArray)
                    updatedIPChecks=[];
                    deletedChecks=[];
                    updatedIDChecks=[];
                    needFix=false;
                    config=jsondecode(fileread(filename));
                    checkList=config.Tree;
                    if~iscell(checkList)
                        checkList=num2cell(checkList);
                    end
                    for i=1:length(checkList)
                        if~isempty(checkList{i}.checkid)
                            if CheckIDMap.isKey(checkList{i}.checkid)
                                matchCheckIndex=CheckIDMap(checkList{i}.checkid);
                                correspondingCheckObj=checkCellArray{matchCheckIndex};
                                foundMatch=true;
                            else

                                foundMatch=false;
                                newID=ModelAdvisor.convertCheckID(checkList{i}.checkid);
                                if CheckIDMap.isKey(newID)
                                    matchCheckIndex=CheckIDMap(newID);
                                    correspondingCheckObj=checkCellArray{matchCheckIndex};
                                    if~isempty(correspondingCheckObj)
                                        foundMatch=true;
                                    end
                                end
                                if~foundMatch
                                    needFix=true;

                                    checkList{i}.checkid=-1;
                                    deletedChecks{end+1}=checkList{i}.label;
                                end
                            end

                            if foundMatch&&~isempty(checkList{i}.InputParameters)
                                if~loc_verify_inputparam(num2cell(checkList{i}.InputParameters),correspondingCheckObj.InputParameters)
                                    if~(strncmp(correspondingCheckObj.ID,'mathworks.maab.',15)&&loc_verify_inputparam(num2cell(checkList{i}.InputParameters),skip_MAAB_find_system_inputparam(correspondingCheckObj.InputParameters)))

                                        checkList{i}.InputParameters=loc_converIpToJSON(correspondingCheckObj.InputParameters);
                                        updatedIPChecks{end+1}=checkList{i}.label;
                                        needFix=true;
                                    end
                                end
                            end
                        end
                    end

                    if needFix
                        newTree={};
                        for i=1:numel(checkList)
                            if checkList{i}.checkid==-1

                            elseif isempty(checkList{i}.checkid)
                                checkList{i}.checkid=NaN;
                                checkList{i}.iconUri='../../../../toolbox/simulink/simulink/modeladvisor/resources/folder_16.png';
                                newTree{end+1}=checkList{i};%#ok<AGROW>
                            else
                                newTree{end+1}=checkList{i};%#ok<AGROW>
                                if~isempty(checkList{i}.checkid)
                                    if~isempty(ModelAdvisor.convertCheckID(checkList{i}.checkid))

                                        newTree{end}.checkid=ModelAdvisor.convertCheckID(checkList{i}.checkid);
                                        updatedIDChecks{end+1}=newTree{end}.label;
                                    end
                                end
                            end
                        end

                        config.Tree=newTree;
                        config.Tree{1}.parent=NaN;
                        config.Tree{1}.iconUri='../../../../toolbox/simulink/simulink/modeladvisor/resources/mace.png';
                        jsonString=jsonencode(config);
                        resultStruct=struct('updatedIPChecks',{updatedIPChecks},'deletedChecks',{deletedChecks},'updatedIDChecks',{updatedIDChecks},'val',jsonString);
                        result=resultStruct;
                    end