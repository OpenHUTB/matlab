function[success]=loadConfiguration(this,filename)



    PerfTools.Tracer.logMATLABData('MAGroup','Load Configuration',true);

    success=false;%#ok<NASGU>

    am=Advisor.Manager.getInstance;
    if slfeature('MACEConfigurationValidation')
        enableConfigurationValidation=true;
    else
        enableConfigurationValidation=false;
    end

    if~isfield(am.slCustomizationDataStructure,'checkCellArray')
        am.loadslCustomization;
    end
    CheckIDMap=am.slCustomizationDataStructure.CheckIDMap;
    checkCellArray=am.slCustomizationDataStructure.checkCellArray;
    isLoadingFromJSON=false;
    persistent configuration;

    try
        [~,~,ext]=fileparts(filename);
        if isempty(ext)
            filename=[filename,'.mat'];
        end
        if~exist(filename,'file')
            success=false;
            PerfTools.Tracer.logMATLABData('MAGroup','Load Configuration',false);
            return;
        end


        if isa(this.ConfigUIWindow,'DAStudio.Explorer')
            this.ConfigUIWindow.setStatusMessage(DAStudio.message('Simulink:tools:MALoadingConfiguration',filename));
            if this.EdittimeViewMode

                modeladvisorprivate('modeladvisorutil2','SelectFilterView',DAStudio.message('ModelAdvisor:engine:FullView'));
                this.Toolbar.viewComboBoxWidget.selectItem(0);
                drawnow;
            end
        end


        if~isempty(configuration)
            ta=configuration.ConfigUICellArray;
            if~isempty(ta)&&~isstruct(ta{1})
                for j=1:length(ta)
                    if isvalid(ta{j})&&isa(ta{j},'ModelAdvisor.ConfigUI')
                        ta{j}.ParentObj=[];
                        ta{j}.MAObj=[];
                    end
                end
            end
            configuration=[];
        end


        if strcmp(ext,'.json')
            jsonString=fileread(filename);
        else
            load(filename);%#ok<LOAD>
        end

        if exist('jsonString','var')
            [configuration,this.ConfigFileOptions]=convertConfigurationFromJSON(jsonString);
            isLoadingFromJSON=true;
        end

        if isempty(configuration.ConfigUIRoot)||isempty(configuration.ConfigUICellArray)
            error(message('ModelAdvisor:engine:CmdAPIConfigurationParamInValid',filename));
        end

        NeedSupportLib=this.IsLibrary&&modeladvisorprivate('modeladvisorutil2','FeatureControl','SupportLibrary');


        if modeladvisorprivate('modeladvisorutil2','FeatureControl','CompressedMACEFormat')
            if~isfield(configuration,'ReducedTree')
                if isa(configuration.ConfigUIRoot,'ModelAdvisor.ConfigUI')&&~isempty(configuration.ConfigUIRoot.ChildrenObj)&&ischar(configuration.ConfigUIRoot.ChildrenObj{1})

                    fastlookup=containers.Map;
                    for i=1:length(configuration.ConfigUICellArray)
                        fastlookup(configuration.ConfigUICellArray{i}.ID)=i;
                    end
                    for i=1:length(configuration.ConfigUIRoot.ChildrenObj)
                        configuration.ConfigUIRoot.ChildrenObj{i}=fastlookup(configuration.ConfigUIRoot.ChildrenObj{i});
                    end
                    for i=1:length(configuration.ConfigUICellArray)
                        for j=1:length(configuration.ConfigUICellArray{i}.ChildrenObj)
                            configuration.ConfigUICellArray{i}.ChildrenObj{j}=fastlookup(configuration.ConfigUICellArray{i}.ChildrenObj{j});
                        end
                    end
                end
                [configuration.ConfigUIRoot,configuration.ConfigUICellArray]=modeladvisorprivate('modeladvisorutil2','TrimUnusedTrees',configuration.ConfigUIRoot,configuration.ConfigUICellArray);
            end
        end



        cuicellarrary=[{configuration.ConfigUIRoot},configuration.ConfigUICellArray];
        for i=1:length(cuicellarrary)
            cuicellarrary{i}.MAObj=this;

            if isnumeric(cuicellarrary{i}.ParentObj)

                cuicellarrary{i}.ParentObj=cuicellarrary{cuicellarrary{i}.ParentObj+1};

                if~isLoadingFromJSON
                    cuicellarrary{i}.ParentObj.addChildren(cuicellarrary{i});
                end
                for k=1:length(cuicellarrary{i}.ParentObj.ChildrenObj)
                    if isnumeric(cuicellarrary{i}.ParentObj.ChildrenObj{k})&&(cuicellarrary{i}.ParentObj.ChildrenObj{k}==cuicellarrary{i}.Index)
                        cuicellarrary{i}.ParentObj.ChildrenObj{k}=cuicellarrary{i};
                        break;
                    end
                end
            end




            if~isempty(cuicellarrary{i}.MAC)
                if CheckIDMap.isKey(cuicellarrary{i}.MAC)
                    matchCheckIndex=CheckIDMap(cuicellarrary{i}.MAC);
                    correspondingCheckObj=checkCellArray{matchCheckIndex};
                    cuicellarrary{i}.MACIndex=correspondingCheckObj.Index;
                    foundMatch=true;
                else

                    foundMatch=false;
                    newID=ModelAdvisor.convertCheckID(cuicellarrary{i}.MAC);
                    if am.slCustomizationDataStructure.CheckIDMap.isKey(newID)
                        modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',cuicellarrary{i}.MAC,newID);
                        matchCheckIndex=am.slCustomizationDataStructure.CheckIDMap(newID);
                        correspondingCheckObj=am.slCustomizationDataStructure.checkCellArray{matchCheckIndex};
                        if~isempty(correspondingCheckObj)
                            cuicellarrary{i}.MACIndex=correspondingCheckObj.Index;
                            foundMatch=true;
                        end
                    end
                    if~foundMatch
                        cuicellarrary{i}.MACIndex=-1;

                        if~(isfield(this.ConfigFileOptions,'SuppressWarnOnMALoadConfigMissCorrespondCheck')&&this.ConfigFileOptions.SuppressWarnOnMALoadConfigMissCorrespondCheck)&&~enableConfigurationValidation
                            MSLDiagnostic('Simulink:tools:MALoadConfigMissCorrespondCheck',cuicellarrary{i}.MAC,cuicellarrary{i}.DisplayName,filename).reportAsWarning;
                        end
                    end
                end

                if foundMatch&&~isempty(cuicellarrary{i}.InputParameters)
                    if~loc_verify_inputparam(cuicellarrary{i}.InputParameters,correspondingCheckObj.InputParameters)
                        if strncmp(correspondingCheckObj.ID,'mathworks.maab.',15)&&loc_verify_inputparam(cuicellarrary{i}.InputParameters,skip_MAAB_find_system_inputparam(correspondingCheckObj.InputParameters))

                            cuicellarrary{i}.InputParameters=[cuicellarrary{i}.InputParameters,modeladvisorprivate('modeladvisorutil2','DeepCopy',get_MAAB_find_system_inputparam(correspondingCheckObj.InputParameters))];
                        elseif~isempty(correspondingCheckObj.loadOutofdateInputParametersCallback)

                            status=correspondingCheckObj.loadOutofdateInputParametersCallback(cuicellarrary{i});
                            if~status
                                cuicellarrary{i}.MACIndex=-2;
                                if~enableConfigurationValidation
                                    MSLDiagnostic('ModelAdvisor:engine:InputParamMismatchInConfigFile',cuicellarrary{i}.MAC,cuicellarrary{i}.DisplayName,filename).reportAsWarning;
                                end
                            end
                        else
                            cuicellarrary{i}.MACIndex=-2;
                            if~enableConfigurationValidation
                                MSLDiagnostic('ModelAdvisor:engine:InputParamMismatchInConfigFile',cuicellarrary{i}.MAC,cuicellarrary{i}.DisplayName,filename).reportAsWarning;
                            end
                        end
                    end
                end
                if NeedSupportLib&&~isempty(correspondingCheckObj)
                    if~correspondingCheckObj.SupportLibrary&&~modeladvisorprivate('modeladvisorutil2','FeatureControl','ForceRunOnLibrary')
                        cuicellarrary{i}.Selected=false;
                        cuicellarrary{i}.Enable=false;
                    end
                end
            end

        end


        ta=this.ConfigUICellArray;
        if~isempty(ta)&&~isstruct(ta{1})
            for j=1:length(ta)
                if isa(ta{j},'ModelAdvisor.ConfigUI')
                    ta{j}.ParentObj=[];
                    ta{j}.MAObj=[];
                end
            end
        end


        this.ConfigUIRoot=cuicellarrary{1};
        if length(cuicellarrary)>1
            this.ConfigUICellArray=cuicellarrary(2:end);
        else
            this.ConfigUICellArray={};
        end

        this.lookForDeprecatedChecks(true);


        this.ConfigUIDirty=false;


        this.ConfigFilePath=filename;


        if strcmp(ext,'.mat')
            checkList=[{configuration.ConfigUIRoot},configuration.ConfigUICellArray];
            ModelAdvisorWebUI.interface.ValidationCheckRegistration.getInstance.registerChecks(checkList);
        end


        if isa(this.ConfigUIWindow,'DAStudio.Explorer')
            this.ConfigUIWindow.setStatusMessage('');
            Simulink.ModelAdvisor.openConfigUI;
        end

        modeladvisorprivate('modeladvisorutil2','ShowConfigurationOnStatusBar',this);
        modeladvisorprivate('modeladvisorutil2','UpdateConfigUIWindowTitle',this);
        ModelAdvisor.ConfigUI.stackoperation('init');
        success=true;

    catch E


        disp(E.message);
        rethrow(E);
    end
    PerfTools.Tracer.logMATLABData('MAGroup','Load Configuration',false);

    function verified=loc_verify_inputparam(InputParameters1,InputParameters2)
        if length(InputParameters1)==length(InputParameters2)
            verified=true;
            for i=1:length(InputParameters1)
                if~strcmp(InputParameters1{i}.Type,InputParameters2{i}.Type)
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

            function OutputParameters=get_MAAB_find_system_inputparam(InputParameters)
                OutputParameters={};
                followlinkParam=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
                lookundermaskParam=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
                find_systemParamNames={followlinkParam.Name,lookundermaskParam.Name};
                for i=1:length(InputParameters)
                    if ismember(InputParameters{i}.Name,find_systemParamNames)
                        OutputParameters{end+1}=InputParameters{i};%#ok<AGROW>
                    end
                end

                function[configuration,ConfigFileOptions]=convertConfigurationFromJSON(jsonString)
                    configuration.ReducedTree=true;














                    jsonStruct=jsondecode(jsonString);

                    ConfigFileOptions={};
                    if isstruct(jsonStruct)&&isfield(jsonStruct,'SimulinkVersion')
                        for i=1:numel(jsonStruct.Options)
                            ConfigFileOptions.(jsonStruct.Options(i).name)=jsonStruct.Options(i).value;
                        end
                        jsonStruct=jsonStruct.Tree;
                    end

                    if~iscell(jsonStruct)
                        jsonStruct=num2cell(jsonStruct);
                    end
                    checkList=jsonStruct;

                    for i=1:numel(checkList)
                        if~isempty(checkList{i}.InputParameters)
                            if~iscell(checkList{i}.InputParameters)
                                checkList{i}.InputParameters=num2cell(checkList{i}.InputParameters);
                            end
                            for j=1:numel(checkList{i}.InputParameters)
                                checkList{i}.InputParameters{j}.Value=checkList{i}.InputParameters{j}.value;
                            end
                        end
                    end
                    maObj=Simulink.ModelAdvisor;

                    checkList=maObj.assignMACIndex(checkList);
                    checkList=ModelAdvisorWebUI.interface.updateDisplayIcons(checkList);

                    ModelAdvisorWebUI.interface.ValidationCheckRegistration.getInstance.registerChecks(checkList);
                    for i=1:numel(jsonStruct)
                        jsonStruct{i}.ParentObj={};
                        jsonStruct{i}.ChildrenObj={};
                    end
                    jsonidFastLookup=containers.Map;
                    for i=1:numel(jsonStruct)
                        jsonidFastLookup(jsonStruct{i}.id)=i;
                    end
                    for i=1:numel(jsonStruct)
                        if~isempty(jsonStruct{i}.parent)
                            if jsonidFastLookup.isKey(jsonStruct{i}.parent)
                                parentIndex=jsonidFastLookup(jsonStruct{i}.parent);
                                jsonStruct{i}.ParentObj=parentIndex-1;

                                jsonStruct{parentIndex}.ChildrenObj{end+1}.ID=jsonStruct{i}.id;
                            end
                        end
                    end

                    ConfigUICellArray=cell(1,numel(jsonStruct));
                    jsonHasSeverityInfo=false;
                    if isfield(jsonStruct{1},'Severity')
                        jsonHasSeverityInfo=true;
                    end
                    for i=1:numel(jsonStruct)

                        ConfigUICellArray{i}.ID=jsonStruct{i}.id;
                        if isfield(jsonStruct{i},'enable')
                            ConfigUICellArray{i}.Enable=jsonStruct{i}.enable;
                        end
                        ConfigUICellArray{i}.DisplayName=jsonStruct{i}.label;
                        if isfield(jsonStruct{i},'CSHParameters')
                            ConfigUICellArray{i}.CSHParameters=jsonStruct{i}.CSHParameters;
                        else
                            ConfigUICellArray{i}.CSHParameters=[];
                        end
                        ConfigUICellArray{i}.OriginalNodeID=jsonStruct{i}.originalnodeid;
                        ConfigUICellArray{i}.Selected=jsonStruct{i}.check;
                        ConfigUICellArray{i}.MAC=jsonStruct{i}.checkid;
                        ConfigUICellArray{i}.ParentObj=jsonStruct{i}.ParentObj;
                        ConfigUICellArray{i}.ChildrenObj=jsonStruct{i}.ChildrenObj;
                        ConfigUICellArray{i}.iscompile=jsonStruct{i}.iscompile;
                        ConfigUICellArray{i}.iconUri=jsonStruct{i}.iconUri;
                        ConfigUICellArray{i}.InputParameters={};
                        for j=1:numel(jsonStruct{i}.InputParameters)


                            ip.Name=jsonStruct{i}.InputParameters(j).name;
                            ip.Value=jsonStruct{i}.InputParameters(j).value;
                            ip.Enable=jsonStruct{i}.InputParameters(j).isenable;
                            ip.Entries=jsonStruct{i}.InputParameters(j).entries;
                            ip.Type=jsonStruct{i}.InputParameters(j).type;
                            ip.Visible=jsonStruct{i}.InputParameters(j).visible;

                            if~isempty(ip.Value)
                                switch ip.Type
                                case{'BlockType','BlockTypeWithParameter'}

                                    ip.Value=struct2cell(ip.Value)';
                                end
                            end
                            ConfigUICellArray{i}.InputParameters{end+1}=ip;
                        end
                        if isempty(jsonStruct{i}.checkid)
                            ConfigUICellArray{i}.Type='Group';
                        else
                            ConfigUICellArray{i}.Type='Task';
                            ConfigUICellArray{i}.Severity='';
                            if jsonHasSeverityInfo&&~isempty(jsonStruct{i}.Severity)
                                ConfigUICellArray{i}.Severity=jsonStruct{i}.Severity;
                            end
                        end
                        if isempty(jsonStruct{i}.ParentObj)||(jsonStruct{i}.ParentObj==0)
                            ConfigUICellArray{i}.Published=true;
                        else
                            ConfigUICellArray{i}.Published=false;
                        end
                        ConfigUICellArray{i}.Index=i-1;
                    end

                    configuration.ConfigUIRoot=ConfigUICellArray{1};
                    configuration.ConfigUIRoot.ShowCheckbox=false;

                    configuration.ConfigUICellArray=ConfigUICellArray(2:end);
