classdef sfunctionbuilderModel<handle

    properties(SetAccess=protected)
USERDATA
    end


    properties(SetAccess=private)
    end


    methods

        function obj=sfunctionbuilderModel()
        end


        function SfunWizardData=addBlock(obj,block)
            block.AppData=addFields(block.AppData);
            block.AppData=renameDataTypes(block.AppData);
            block.AppData=removeEmptyPorts(block.AppData);
            SfunWizardData=block.AppData.SfunWizardData;

            if isempty(obj.USERDATA)
                obj.USERDATA=block;
            else
                idx=obj.findSFunctionBuilder(block.BlockHandle);
                if isempty(idx)
                    obj.USERDATA(end+1)=block;

                else
                    SfunWizardData=obj.USERDATA(idx).AppData.SfunWizardData;
                end
            end
        end


        function destroyModel(obj,blockHandle)
            idx=obj.findSFunctionBuilder(blockHandle);
            if~isempty(idx)
                obj.USERDATA(idx)=[];
            end
        end


        function idx=findSFunctionBuilder(obj,blockHandle)
            idx=[];
            if~isempty(obj.USERDATA)
                idx=find([obj.USERDATA.BlockHandle]==blockHandle);
            end
        end


        function registerView(obj,blockHandle,view)
            idx=obj.findSFunctionBuilder(blockHandle);
            if isfield(obj.USERDATA(idx),'views')&&~isempty(obj.USERDATA(idx).views)

                cmp=cellfun(@(x)strcmp(x.publishChannel,view.publishChannel),obj.USERDATA(idx).views);
                if~any(cmp)
                    obj.USERDATA(idx).views{end+1}=view;
                end
            else
                obj.USERDATA(idx).views={view};
            end
        end


        function unregisterView(obj,blockHandle,view)
            idx=obj.findSFunctionBuilder(blockHandle);
            if isfield(obj.USERDATA(idx),'views')&&~isempty(obj.USERDATA(idx).views)
                cmp=cellfun(@(x)strcmp(x.publishChannel,view.publishChannel),obj.USERDATA(idx).views);
                obj.USERDATA(idx).views(cmp)=[];
            end
        end


        function applicationData=refreshViews(obj,blockHandle,action,varargin)
            idx=obj.findSFunctionBuilder(blockHandle);
            views=obj.USERDATA(idx).views;
            applicationData=obj.getApplicationData(blockHandle);
            switch action
            case{'refresh toolstrip','refresh ports table','refresh parameter table','refresh settings'...
                ,'refresh editor','refresh library table'}
                data=obj.USERDATA(idx).AppData.SfunWizardData;
                for i=1:length(views)

                    if isa(views{i},'sfunctionbuilder.internal.sfunctionbuilderView')
                        views{i}.refresh(action,data);
                    end
                end

                if strcmp(action,'refresh ports table')
                    refreshIcon(blockHandle,data.InputPorts,data.OutputPorts)
                end
            case 'refresh title'
                newTitle=varargin{1};
                for i=1:length(views)


                    if isa(views{i},'sfunctionbuilder.internal.sfunctionbuilderView')
                        views{i}.refreshTitle(newTitle);
                    end
                end
            case{'invalid sfunction name','set source file overwritable','set sfunction tlc overwritable',...
                'refresh buildlog','refresh packagelog','fail to add port item','fail to update port table','fail to add lib path',...
                'fail to update library table','invalid setting','fail to read the file'}
                if nargin==4
                    actionMessageJS=varargin{1};
                elseif nargin==5
                    actionMessageJS=varargin{2};
                end
                actionMessageCLI=varargin{1};
                for i=1:length(views)

                    if isa(views{i},'sfunctionbuilder.internal.sfunctionbuilderView')
                        views{i}.refresh(action,actionMessageJS);
                    elseif strcmp(views{i}.publishChannel,'cli')
                        disp(strtrim(actionMessageCLI));

                        if strcmp(action,'set source file overwritable')
                            obj.setSourceFileOverwritable(blockHandle);
                            sfcnbuilder.doBuild_OverwriteTLC(blockHandle,applicationData);
                        end
                        if strcmp(action,'set sfunction tlc overwritable')
                            applicationData=sfcnbuilder.ComputeLangExtFromGUI(blockHandle,applicationData);
                            applicationData=sfcnbuilder.doFinish(blockHandle,applicationData);
                        end
                    end
                end

            case 'set unsaved change'
                if obj.isGUIOpen(blockHandle)
                    for i=1:length(views)
                        if isa(views{i},'sfunctionbuilder.internal.sfunctionbuilderView')
                            views{i}.setUnSavedFlag(varargin{1});
                        end
                    end
                elseif obj.isFromApi(blockHandle)
                    if varargin{1}
                        applicationData=obj.getApplicationData(blockHandle);
                        sfunctionName=applicationData.SfunWizardData.SfunName;

                        if~(strcmp(sfunctionName,'system')||isempty(sfunctionName))
                            verifySFunctionName(sfunctionName);
                            set_param(blockHandle,'FunctionName',sfunctionName);
                        end

                        set_param(blockHandle,'WizardData',applicationData.SfunWizardData);
                    end
                end
            otherwise
                assert(false,'unrecognized action');
            end
        end


        function appData=getApplicationData(obj,blockHandle)
            idx=obj.findSFunctionBuilder(blockHandle);
            appData=obj.USERDATA(idx).AppData;
        end


        function setApplicationData(obj,blockHandle,appData)
            idx=obj.findSFunctionBuilder(blockHandle);
            obj.USERDATA(idx).AppData=appData;
        end


        function updateSFunctionName(obj,blockHandle,name)
            idx=obj.findSFunctionBuilder(blockHandle);
            obj.USERDATA(idx).AppData.SfunWizardData.SfunName=name;

            try
                set_param(blockHandle,'SfunBuilderFcnName',name);
            catch

            end
            try
                set_param(blockHandle,'FunctionName',name);
            catch

            end
            obj.refreshViews(blockHandle,'refresh toolstrip');
            obj.refreshViews(blockHandle,'refresh editor');
            obj.refreshViews(blockHandle,'set unsaved change',true);
        end


        function updateCertificateName(obj,blockHandle,name)
            idx=obj.findSFunctionBuilder(blockHandle);
            obj.USERDATA(idx).AppData.SfunWizardData.CertificateName=name;
            obj.USERDATA(idx).AppData.SfunWizardData.SignPackage='1';
            obj.refreshViews(blockHandle,'refresh toolstrip');
            obj.refreshViews(blockHandle,'refresh editor');
        end


        function updateSFBWindowPostion(obj,blockHandle,type,position)
            wizardData=get_param(blockHandle,'WizardData');
            idx=obj.findSFunctionBuilder(blockHandle);
            if strcmp(type,'editorDialog')
                wizardData.EditorDialogPosition=position;
                obj.USERDATA(idx).AppData.SfunWizardData.EditorDialogPosition=position;
            elseif strcmp(type,'parameterDialog')
                wizardData.ParameterDialogPosition=position;
                obj.USERDATA(idx).AppData.SfunWizardData.ParameterDialogPosition=position;
            end
            set_param(blockHandle,'WizardData',wizardData);
        end


        function position=getSFBWindowPostion(obj,blockHandle,type)
            idx=obj.findSFunctionBuilder(blockHandle);
            position=[];
            if strcmp(type,'editorDialog')&&isfield(obj.USERDATA(idx).AppData.SfunWizardData,'EditorDialogPosition')
                position=obj.USERDATA(idx).AppData.SfunWizardData.EditorDialogPosition;
            elseif strcmp(type,'parameterDialog')&&isfield(obj.USERDATA(idx).AppData.SfunWizardData,'ParameterDialogPosition')
                position=obj.USERDATA(idx).AppData.SfunWizardData.ParameterDialogPosition;
            end
        end


        function updateSFunctionLanguage(obj,blockHandle,language)
            idx=obj.findSFunctionBuilder(blockHandle);
            obj.USERDATA(idx).AppData.SfunWizardData.LangExt=language;
            obj.refreshViews(blockHandle,'refresh toolstrip');
            obj.refreshViews(blockHandle,'set unsaved change',true);
        end


        function updateSFunctionBlockPath(obj,blockHandle,bpath)
            idx=obj.findSFunctionBuilder(blockHandle);
            if isempty(idx),return,end

            obj.USERDATA(idx).AppData.blockName=bpath;
            newTitle=['S-Function Builder: ',strrep(bpath,newline,' ')];
            obj.USERDATA(idx).AppData.DefaultTitle=newTitle;
            obj.refreshViews(blockHandle,'refresh title',newTitle);
        end


        function updateSFunctionBuildOption(obj,blockHandle,option)
            idx=obj.findSFunctionBuilder(blockHandle);
            switch option.optionName
            case 'ShowCompileSteps'
                obj.USERDATA(idx).AppData.SfunWizardData.ShowCompileSteps=num2str(option.optionSelected);
            case 'CreateDebuggableMEX'
                obj.USERDATA(idx).AppData.SfunWizardData.CreateDebugMex=num2str(option.optionSelected);
            case 'GenerateWrapperTLC'
                obj.USERDATA(idx).AppData.SfunWizardData.GenerateTLC=num2str(option.optionSelected);
            case 'SaveCodeOnly'
                obj.USERDATA(idx).AppData.SfunWizardData.SaveCodeOnly=num2str(option.optionSelected);
            case 'EnableSupportForCoverage'
                obj.USERDATA(idx).AppData.SfunWizardData.SupportCoverage=num2str(option.optionSelected);
            case 'EnableSupportForDesignVerifier'
                obj.USERDATA(idx).AppData.SfunWizardData.SupportSldv=num2str(option.optionSelected);
            otherwise
            end
            obj.refreshViews(blockHandle,'refresh toolstrip');
            obj.refreshViews(blockHandle,'set unsaved change',true);
        end


        function updateSFunctionPackageOption(obj,blockHandle,option)
            idx=obj.findSFunctionBuilder(blockHandle);
            switch option.optionName
            case 'SignPackage'
                obj.USERDATA(idx).AppData.SfunWizardData.SignPackage=num2str(option.optionSelected);
            case 'CustomBuildScript'
                obj.USERDATA(idx).AppData.SfunWizardData.CustomBuildScript=num2str(option.optionSelected);
            otherwise
            end
            obj.refreshViews(blockHandle,'refresh toolstrip');
        end


        function setSourceFileOverwritable(obj,blockHandle)
            idx=obj.findSFunctionBuilder(blockHandle);
            obj.USERDATA(idx).AppData.Overwritable='Yes';
        end


        function updateSFunctionSetting(obj,blockHandle,setting)
            idx=obj.findSFunctionBuilder(blockHandle);
            switch setting.name
            case 'NumberDiscreteStates'
                if~isnan(str2double(setting.value))
                    obj.USERDATA(idx).AppData.SfunWizardData.NumberOfDiscreteStates=setting.value;
                else
                    obj.refreshViews(blockHandle,'refresh settings');
                    ME=MSLException('Simulink:SFunctionBuilder:InvalidDiscreteStates');
                    throw(ME)
                end
            case 'DiscreteStatesIC'
                obj.USERDATA(idx).AppData.SfunWizardData.DiscreteStatesIC=setting.value;
            case 'NumberContinuousStates'
                if~isnan(str2double(setting.value))
                    obj.USERDATA(idx).AppData.SfunWizardData.NumberOfContinuousStates=setting.value;
                else
                    obj.refreshViews(blockHandle,'refresh settings');
                    ME=MSLException('Simulink:SFunctionBuilder:InvalidContinuousStates');
                    throw(ME)
                end
            case 'ContinuousStatesIC'
                obj.USERDATA(idx).AppData.SfunWizardData.ContinuousStatesIC=setting.value;
            case 'Majority'
                if ismember(setting.value,{'Row','Column','Any'})
                    obj.USERDATA(idx).AppData.SfunWizardData.Majority=setting.value;
                else
                    ME=MSLException('Simulink:SFunctionBuilder:InvalidMajority',setting.value);
                    throw(ME);
                end
            case 'SampleTime'
                if ismember(setting.value,{'Inherited','Continuous','Discrete'})
                    obj.USERDATA(idx).AppData.SfunWizardData.SampleMode=setting.value;





                else
                    ME=MSLException('Simulink:SFunctionBuilder:InvalidSampleMode',setting.value);
                    throw(ME);
                end
            case 'SampleTimeValue'


                obj.USERDATA(idx).AppData.SfunWizardData.SampleTime=setting.value;
            case 'NumberPWorks'


                obj.USERDATA(idx).AppData.SfunWizardData.NumberOfPWorks=setting.value;
            case 'UseSimStruct'
                obj.USERDATA(idx).AppData.SfunWizardData.UseSimStruct=num2str(setting.value);


                if(setting.value)
                    obj.USERDATA(idx).AppData.SfunWizardData.GenerateTLC='0';
                end
            case 'DirectFeedThrough'
                obj.USERDATA(idx).AppData.SfunWizardData.DirectFeedThrough=num2str(setting.value);
            case 'ForEach'
                obj.USERDATA(idx).AppData.SfunWizardData.SupportForEach=num2str(setting.value);
            case 'MultiThread'
                obj.USERDATA(idx).AppData.SfunWizardData.EnableMultiThread=num2str(setting.value);
            case 'CodeReuse'
                obj.USERDATA(idx).AppData.SfunWizardData.EnableCodeReuse=num2str(setting.value);
            otherwise
            end
            obj.refreshViews(blockHandle,'refresh settings');
            obj.refreshViews(blockHandle,'refresh editor');
            obj.refreshViews(blockHandle,'set unsaved change',true);
        end


        function updateParameterValue(obj,blockHandle,parameterName,value)
            blockHandleIndex=obj.findSFunctionBuilder(blockHandle);
            names=obj.USERDATA(blockHandleIndex).AppData.SfunWizardData.Parameters.Name;
            parameterIndex=strcmp(names,parameterName);
            if~isempty(parameterIndex)
                obj.USERDATA(blockHandleIndex).AppData.SfunWizardData.Parameters.Value{parameterIndex}=value;
                obj.refreshViews(blockHandle,'refresh parameter table');
            else
                ME=MSLException('Simulink:SFunctionBuilder:InvalidParameterName');
                throw(ME);
            end
            obj.refreshViews(blockHandle,'set unsaved change',true);
        end


        function output=addItemToPortTable(obj,blockHandle,item)
            idx=obj.findSFunctionBuilder(blockHandle);
            scope=item{2};
            switch scope
            case 'input'
                newPort=newInputPort(item,obj.USERDATA(idx).AppData.SfunWizardData);
                try
                    obj.USERDATA(idx).AppData.SfunWizardData.InputPorts=...
                    addNewPort(obj.USERDATA(idx).AppData.SfunWizardData.InputPorts,newPort);
                catch ME
                    obj.refreshViews(blockHandle,'refresh ports table');
                    throw(ME);
                end
                output=newPort;
            case 'output'
                newPort=newOutputPort(item,obj.USERDATA(idx).AppData.SfunWizardData);
                obj.USERDATA(idx).AppData.SfunWizardData.OutputPorts=...
                addNewPort(obj.USERDATA(idx).AppData.SfunWizardData.OutputPorts,newPort);
                output=newPort;
            case 'parameter'
                newPara=newParameter(item,obj.USERDATA(idx).AppData.SfunWizardData);
                obj.USERDATA(idx).AppData.SfunWizardData.Parameters=...
                addNewParameter(obj.USERDATA(idx).AppData.SfunWizardData.Parameters,newPara);
                output=newPara;
            end


            obj.refreshViews(blockHandle,'refresh ports table');
            obj.refreshViews(blockHandle,'refresh editor');
            obj.refreshViews(blockHandle,'set unsaved change',true);
        end


        function delItemFromPortTable(obj,blockHandle,names,scopes)
            idx=obj.findSFunctionBuilder(blockHandle);
            for i=1:length(names)
                name=names{i};
                scope=scopes{i};
                switch scope
                case 'input'
                    obj.USERDATA(idx).AppData.SfunWizardData.InputPorts=...
                    deleteItemByName(obj.USERDATA(idx).AppData.SfunWizardData.InputPorts,name);
                case 'output'
                    obj.USERDATA(idx).AppData.SfunWizardData.OutputPorts=...
                    deleteItemByName(obj.USERDATA(idx).AppData.SfunWizardData.OutputPorts,name);
                case 'parameter'
                    obj.USERDATA(idx).AppData.SfunWizardData.Parameters=...
                    deleteItemByName(obj.USERDATA(idx).AppData.SfunWizardData.Parameters,name);
                end
            end
            obj.refreshViews(blockHandle,'refresh ports table');
            obj.refreshViews(blockHandle,'refresh editor');
            obj.refreshViews(blockHandle,'set unsaved change',true);
        end


        function updateItemOfPortTable(obj,blockHandle,newItem,field,oldvalue)
            idx=obj.findSFunctionBuilder(blockHandle);
            switch field
            case 'name'
                try
                    obj.USERDATA(idx).AppData.SfunWizardData=...
                    updatePortName(obj.USERDATA(idx).AppData.SfunWizardData,newItem,oldvalue);
                catch ME
                    throw(ME);
                end
            case 'scope'
                try
                    obj.USERDATA(idx).AppData.SfunWizardData=...
                    updatePortScope(obj.USERDATA(idx).AppData.SfunWizardData,newItem,oldvalue);


                    obj.USERDATA(idx).AppData.SfunWizardData=...
                    updatePortDataType(obj.USERDATA(idx).AppData.SfunWizardData,newItem);
                    obj.USERDATA(idx).AppData.SfunWizardData=...
                    updatePortComplexity(obj.USERDATA(idx).AppData.SfunWizardData,newItem);
                catch ME
                    throw(ME);
                end
            case 'datatype'
                try
                    obj.USERDATA(idx).AppData.SfunWizardData=...
                    updatePortDataType(obj.USERDATA(idx).AppData.SfunWizardData,newItem);
                catch ME
                    throw(ME);
                end
            case{'dimension','dimensions'}
                try
                    obj.USERDATA(idx).AppData.SfunWizardData=...
                    updatePortDimension(obj.USERDATA(idx).AppData.SfunWizardData,newItem);
                catch ME
                    throw(ME);
                end
            case 'complexity'
                try
                    obj.USERDATA(idx).AppData.SfunWizardData=...
                    updatePortComplexity(obj.USERDATA(idx).AppData.SfunWizardData,newItem);
                catch ME
                    throw(ME);
                end

            end
            obj.refreshViews(blockHandle,'refresh ports table');
            obj.refreshViews(blockHandle,'refresh editor');
            obj.refreshViews(blockHandle,'set unsaved change',true);
        end


        function updateUserCode(obj,blockHandle,userCode,refreshGUI)
            blockIdx=obj.findSFunctionBuilder(blockHandle);

            if compareCode(obj.USERDATA(blockIdx).AppData.SfunWizardData.IncludeHeadersText,userCode.IncludeHeadersText)&&...
                compareCode(obj.USERDATA(blockIdx).AppData.SfunWizardData.ExternalDeclaration,userCode.ExternalDeclaration)&&...
                compareCode(obj.USERDATA(blockIdx).AppData.SfunWizardData.UserCodeTextmdlStart,userCode.UserCodeTextmdlStart)&&...
                compareCode(obj.USERDATA(blockIdx).AppData.SfunWizardData.UserCodeText,userCode.UserCodeText)&&...
                compareCode(obj.USERDATA(blockIdx).AppData.SfunWizardData.UserCodeTextmdlUpdate,userCode.UserCodeTextmdlUpdate)&&...
                compareCode(obj.USERDATA(blockIdx).AppData.SfunWizardData.UserCodeTextmdlDerivative,userCode.UserCodeTextmdlDerivative)&&...
                compareCode(obj.USERDATA(blockIdx).AppData.SfunWizardData.UserCodeTextmdlTerminate,userCode.UserCodeTextmdlTerminate)

            else
                obj.USERDATA(blockIdx).AppData.SfunWizardData.IncludeHeadersText=userCode.IncludeHeadersText;
                obj.USERDATA(blockIdx).AppData.SfunWizardData.ExternalDeclaration=userCode.ExternalDeclaration;
                obj.USERDATA(blockIdx).AppData.SfunWizardData.UserCodeTextmdlStart=userCode.UserCodeTextmdlStart;
                obj.USERDATA(blockIdx).AppData.SfunWizardData.UserCodeText=userCode.UserCodeText;
                obj.USERDATA(blockIdx).AppData.SfunWizardData.UserCodeTextmdlUpdate=userCode.UserCodeTextmdlUpdate;
                obj.USERDATA(blockIdx).AppData.SfunWizardData.UserCodeTextmdlDerivative=userCode.UserCodeTextmdlDerivative;
                obj.USERDATA(blockIdx).AppData.SfunWizardData.UserCodeTextmdlTerminate=userCode.UserCodeTextmdlTerminate;
                if(refreshGUI)
                    obj.refreshViews(blockHandle,'refresh editor');
                    obj.refreshViews(blockHandle,'set unsaved change',true);
                end
            end
        end


        function addItemToLibTable(obj,blockHandle,item)
            blockIdx=obj.findSFunctionBuilder(blockHandle);
            switch item.type
            case 'SRC_PATH'
                if isempty(item.value)
                    item.value=defaultLibItemValue(obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable.SrcPaths,item.type);
                end
                obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable.SrcPaths{end+1}=item.value;
            case 'LIB_PATH'
                if isempty(item.value)
                    item.value=defaultLibItemValue(obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable.LibPaths,item.type);
                end
                obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable.LibPaths{end+1}=item.value;
            case 'INC_PATH'
                if isempty(item.value)
                    item.value=defaultLibItemValue(obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable.IncPaths,item.type);
                end
                obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable.IncPaths{end+1}=item.value;
            case 'ENV_PATH'
                if isempty(item.value)
                    item.value=defaultLibItemValue(obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable.EnvPaths,item.type);
                end
                obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable.EnvPaths{end+1}=item.value;
            case 'ENTRY'
                if isempty(item.value)
                    item.value=defaultLibItemValue(obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable.Entries,item.type);
                end
                obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable.Entries{end+1}=item.value;
            end
            obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesText=combineLibraryItems(obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable);
            obj.refreshViews(blockHandle,'refresh library table');
            obj.refreshViews(blockHandle,'set unsaved change',true);
        end


        function delItemFromLibTable(obj,blockHandle,~,ranges)
            blockIdx=obj.findSFunctionBuilder(blockHandle);

            fieldsAndIndexesToDelete=getFieldsAndIndexesForRanges(obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable,ranges);
            for idx=1:numel(fieldsAndIndexesToDelete)
                obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable.(fieldsAndIndexesToDelete{idx}.field)(fieldsAndIndexesToDelete{idx}.indexes)=[];
            end
            obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesText=combineLibraryItems(obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable);
            obj.refreshViews(blockHandle,'refresh library table');
            obj.refreshViews(blockHandle,'set unsaved change',true);
        end

        function updateItemOfLibTable(obj,blockHandle,oldItem,field,newValue,index)
            blockIdx=obj.findSFunctionBuilder(blockHandle);
            switch field
            case 'type'
                obj.USERDATA(blockIdx).AppData.SfunWizardData=...
                updateLibTag(obj.USERDATA(blockIdx).AppData.SfunWizardData,oldItem,newValue,index);
            case 'value'
                obj.USERDATA(blockIdx).AppData.SfunWizardData=...
                updateLibValue(obj.USERDATA(blockIdx).AppData.SfunWizardData,oldItem,newValue,index);
            end
            obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesText=combineLibraryItems(obj.USERDATA(blockIdx).AppData.SfunWizardData.LibraryFilesTable);
            obj.refreshViews(blockHandle,'refresh library table');
            obj.refreshViews(blockHandle,'set unsaved change',true);
        end


        function isOpen=isGUIOpen(obj,blockHandle)
            idx=obj.findSFunctionBuilder(blockHandle);
            views=obj.USERDATA(idx).views;
            for i=1:length(views)
                if isa(views{i},'sfunctionbuilder.internal.sfunctionbuilderView')
                    try
                        isVisible=views{i}.cefObj.isVisible;
                        if isVisible
                            isOpen=true;
                            return
                        end
                    catch
                    end
                end
            end
            isOpen=false;
        end


        function isApi=isFromApi(obj,blockHandle)
            idx=obj.findSFunctionBuilder(blockHandle);
            views=obj.USERDATA(idx).views;
            for i=1:length(views)
                if strcmp(views{i}.publishChannel,'cli')
                    isApi=true;
                    return
                end
            end
            isApi=false;
        end

    end


    methods(Static)
        function sfunctionbuilderModel=getInstance()
            persistent localObj;
            if isempty(localObj)||~isvalid(localObj)
                localObj=sfunctionbuilder.internal.sfunctionbuilderModel();
            end
            sfunctionbuilderModel=localObj;
        end
    end

end


function fieldIndexList=getFieldsAndIndexesForRanges(libFilesTable,ranges)
    myFields={'SrcPaths','LibPaths','IncPaths','EnvPaths','Entries'};
    fieldIndexList=cell(1,numel(myFields));
    for idx=1:numel(myFields)
        fieldIndexList{idx}=struct('field',myFields{idx},'indexes',[]);
    end
    indexList=zeros(size(myFields));
    for idx=1:numel(myFields)
        indexList(idx)=numel(libFilesTable.(myFields{idx}));
    end
    cumIndexList=cumsum(indexList);

    for r=1:numel(ranges)
        indexesFromRanges=linspace(ranges(r).start,ranges(r).end,ranges(r).count);
        for idx=1:numel(myFields)
            if idx==1
                offsetVal=0;
            else
                offsetVal=cumIndexList(idx-1);
            end
            fieldIndexList{idx}.indexes=[fieldIndexList{idx}.indexes,(indexesFromRanges(indexesFromRanges<=cumIndexList(idx)&indexesFromRanges>offsetVal)-offsetVal)];
        end
    end


    for idx=numel(myFields):-1:1
        if isempty(fieldIndexList{idx}.indexes)
            fieldIndexList(idx)=[];
        end
    end
end




function appData=addFields(appData)

    defaultPort=getDefaultPort();
    portFields=fieldnames(defaultPort);

    defaultParameter=getDefaultParameter();
    parameterFields=fieldnames(defaultParameter);


    inputPort=appData.SfunWizardData.InputPorts;

    inputPortNum=nnz(inputPort.Name~="");

    if inputPortNum>0
        for i=1:numel(portFields)
            if~isfield(inputPort,portFields{i})||length(inputPort.(portFields{i}))~=inputPortNum
                field=cell(1,inputPortNum);
                field(:)=defaultPort.(portFields{i});
                inputPort.(portFields{i})=field;

            elseif any(strcmp(inputPort.(portFields{i}),''))&&~strcmp(portFields{i},'Busname')
                index=strcmp(inputPort.(portFields{i}),'');
                inputPort.(portFields{i})(index)=defaultPort.(portFields{i});
            end
        end
    end


    outputPort=appData.SfunWizardData.OutputPorts;
    outputPortNum=nnz(outputPort.Name~="");
    if outputPortNum>0
        for i=1:numel(portFields)
            if~isfield(outputPort,portFields{i})||length(outputPort.(portFields{i}))~=outputPortNum
                field=cell(1,outputPortNum);
                field(:)=defaultPort.(portFields{i});
                outputPort.(portFields{i})=field;
            elseif any(strcmp(outputPort.(portFields{i}),''))&&~strcmp(portFields{i},'Busname')
                index=strcmp(outputPort.(portFields{i}),'');
                outputPort.(portFields{i})(index)=defaultPort.(portFields{i});
            end
        end
    end


    parameters=appData.SfunWizardData.Parameters;
    parametersNum=nnz(parameters.Name~="");
    if parametersNum>0
        for i=1:numel(parameterFields)
            if~isfield(parameters,parameterFields{i})||length(parameters.(parameterFields{i}))~=parametersNum||any(strcmp(parameters.(parameterFields{i}),''))
                field=cell(1,parametersNum);
                field(:)=defaultParameter.(parameterFields{i});
                parameters.(parameterFields{i})=field;
            end
        end
    end


    appData.SfunWizardData.InputPorts=inputPort;
    appData.SfunWizardData.OutputPorts=outputPort;
    appData.SfunWizardData.Parameters=parameters;
end


function appData=renameDataTypes(appData)
    appData.SfunWizardData.InputPorts=renamePortDataTypes(appData.SfunWizardData.InputPorts);
    appData.SfunWizardData.OutputPorts=renamePortDataTypes(appData.SfunWizardData.OutputPorts);
    appData.SfunWizardData.Parameters=renameParameterDataTypes(appData.SfunWizardData.Parameters);
end



function appData=removeEmptyPorts(appData)
    appData.SfunWizardData.InputPorts=removeEmptyPort(appData.SfunWizardData.InputPorts);
    appData.SfunWizardData.OutputPorts=removeEmptyPort(appData.SfunWizardData.OutputPorts);
end

function port=removeEmptyPort(port)
    if(length(port.Name)==1&&strcmp(port.Name{1},'ALLOW_ZERO_PORTS'))
        f=fieldnames(port);
        for i=1:length(f)
            port.(f{i})(1)=[];
        end
    end
end


function ports=addNewPort(ports,newPort)
    if isempty(ports)
        ports=newPort;
        return
    end
    ipTemplate=getDefaultPort();
    f=fieldnames(newPort);
    for i=1:length(f)
        if~isfield(ports,f{i})
            ports.(f{i})=ipTemplate.(f{i});
        end
        ports.(f{i})=[ports.(f{i}),newPort.(f{i})];
    end
end


function parameters=addNewParameter(parameters,newParameter)

    if isempty(parameters.Name)||isempty(parameters.Name{1})
        parameters=newParameter;
        return
    end
    ipTemplate=getDefaultParameter();
    f=fieldnames(newParameter);
    for i=1:length(f)
        if~isfield(parameters,f{i})
            parameters.(f{i})=ipTemplate.(f{i});
        end
        parameters.(f{i})=[parameters.(f{i}),newParameter.(f{i})];
    end
end


function set=deleteItemByName(set,itemName)
    names=set.Name;
    index=strcmp(names,itemName);
    f=fieldnames(set);
    for i=1:length(f)
        set.(f{i})(index)=[];
    end
end

function ports=updatePortName(ports,newItem,oldvalue)
    newName=strtrim(newItem{1});
    oldName=oldvalue;

    if strcmp(newName,oldName)
        return
    end
    scope=newItem{2};
    switch scope
    case 'input'
        verifyPortName(newName,ports);
        idx=strcmp(ports.InputPorts.Name,oldName);
        ports.InputPorts.Name{idx}=newName;
    case 'output'
        verifyPortName(newName,ports);
        idx=strcmp(ports.OutputPorts.Name,oldName);
        ports.OutputPorts.Name{idx}=newName;
    case 'parameter'
        verifyPortName(newName,ports);
        idx=strcmp(ports.Parameters.Name,oldName);
        ports.Parameters.Name{idx}=newName;
    end
end


function ports=updatePortScope(ports,newItem,oldvalue)
    newScope=newItem{2};
    oldScope=oldvalue;
    if strcmp(newScope,oldScope)
        return
    end
    name=newItem{1};


    if isfield(name,'oldValue')
        name=name.oldValue;
    end


    switch oldScope
    case 'input'
        ports.InputPorts=deleteItemByName(ports.InputPorts,name);
    case 'output'
        ports.OutputPorts=deleteItemByName(ports.OutputPorts,name);
    case 'parameter'
        ports.Parameters=deleteItemByName(ports.Parameters,name);
    end


    switch newScope
    case 'input'
        newPort=newInputPort(newItem,ports);
        ports.InputPorts=addNewPort(ports.InputPorts,newPort);
    case 'output'
        newPort=newOutputPort(newItem,ports);
        ports.OutputPorts=addNewPort(ports.OutputPorts,newPort);
    case 'parameter'
        newPort=newParameter(newItem,ports);
        ports.Parameters=addNewParameter(ports.Parameters,newPort);
    end

end


function ports=updatePortDataType(ports,newItem)
    dataTypeFixdtBinary='Fixdt:binary';
    dataTypeFixdtSlopeAndBias='Fixdt:slope and bias';
    dataTypeBus='Bus';
    name=newItem{1};
    scope=newItem{2};
    datatype=newItem{3};
    s=datatype;


    if isfield(name,'oldValue')
        name=name.oldValue;
    end

    switch scope
    case 'input'
        idx=strcmp(ports.InputPorts.Name,name);
        if~any(idx)
            ME=MSLException('Simulink:SFunctionBuilder:PortNotExist');
            throw(ME);
        end

        if startsWith(datatype,dataTypeBus)

            s(1:length(dataTypeBus))='';

            p={':','(',')','<','>'};
            for i=1:length(p)
                s=strrep(s,p{i},'');
            end
            ports.InputPorts.Bus{idx}='on';
            ports.InputPorts.Busname{idx}=strtrim(s);

        elseif startsWith(datatype,dataTypeFixdtBinary)

            s(1:length(dataTypeFixdtBinary))='';

            p={'(',')'};
            for i=1:length(p)
                s=strrep(s,p{i},'');
            end
            values=str2num(s);
            ports.InputPorts.DataType{idx}='fixpt';
            ports.InputPorts.FixPointScalingType{idx}='0';
            ports.InputPorts.IsSigned{idx}=num2str(values(1));
            ports.InputPorts.WordLength{idx}=num2str(values(2));
            ports.InputPorts.FractionLength{idx}=num2str(values(3));
            ports.InputPorts.Bus{idx}='off';
            if values(2)>64

                DAStudio.error('Simulink:SFunctionBuilder:DatatypeLengthExceedsLimit');
            end

        elseif startsWith(datatype,dataTypeFixdtSlopeAndBias)

            s(1:length(dataTypeFixdtSlopeAndBias))='';

            p={'(',')'};
            for i=1:length(p)
                s=strrep(s,p{i},'');
            end
            values=str2num(s);
            ports.InputPorts.DataType{idx}='fixpt';
            ports.InputPorts.FixPointScalingType{idx}='1';
            ports.InputPorts.IsSigned{idx}=num2str(values(1));
            ports.InputPorts.WordLength{idx}=num2str(values(2));
            ports.InputPorts.Slope{idx}=num2str(values(3));
            ports.InputPorts.Bias{idx}=num2str(values(4));
            ports.InputPorts.Bus{idx}='off';

            if values(2)>64

                DAStudio.error('Simulink:SFunctionBuilder:DatatypeLengthExceedsLimit');
            end
        else
            ports.InputPorts.DataType{idx}=datatype;
            ports.InputPorts.Bus{idx}='off';
        end
        ports.InputPorts=renamePortDataTypes(ports.InputPorts);
    case 'output'
        idx=strcmp(ports.OutputPorts.Name,name);
        if~any(idx)
            ME=MSLException('Simulink:SFunctionBuilder:PortNotExist');
            throw(ME);
        end

        if startsWith(datatype,dataTypeBus)

            s(1:length(dataTypeBus))='';

            p={':','(',')','<','>'};
            for i=1:length(p)
                s=strrep(s,p{i},'');
            end
            ports.OutputPorts.Bus{idx}='on';
            ports.OutputPorts.Busname{idx}=strtrim(s);

        elseif startsWith(datatype,dataTypeFixdtBinary)

            s(1:length(dataTypeFixdtBinary))='';

            p={'(',')'};
            for i=1:length(p)
                s=strrep(s,p{i},'');
            end
            values=str2num(s);
            ports.OutputPorts.DataType{idx}='fixpt';
            ports.OutputPorts.FixPointScalingType{idx}='0';
            ports.OutputPorts.IsSigned{idx}=num2str(values(1));
            ports.OutputPorts.WordLength{idx}=num2str(values(2));
            ports.OutputPorts.FractionLength{idx}=num2str(values(3));
            ports.OutputPorts.Bus{idx}='off';

            if values(2)>64

                DAStudio.error('Simulink:SFunctionBuilder:DatatypeLengthExceedsLimit');
            end

        elseif startsWith(datatype,dataTypeFixdtSlopeAndBias)

            s(1:length(dataTypeFixdtSlopeAndBias))='';

            p={'(',')'};
            for i=1:length(p)
                s=strrep(s,p{i},'');
            end
            values=str2num(s);
            ports.OutputPorts.DataType{idx}='fixpt';
            ports.OutputPorts.FixPointScalingType{idx}='1';
            ports.OutputPorts.IsSigned{idx}=num2str(values(1));
            ports.OutputPorts.WordLength{idx}=num2str(values(2));
            ports.OutputPorts.Slope{idx}=num2str(values(3));
            ports.OutputPorts.Bias{idx}=num2str(values(4));
            ports.OutputPorts.Bus{idx}='off';

            if values(2)>64

                DAStudio.error('Simulink:SFunctionBuilder:DatatypeLengthExceedsLimit');
            end
        else
            ports.OutputPorts.DataType{idx}=datatype;
            ports.OutputPorts.Bus{idx}='off';
        end
        ports.OutputPorts=renamePortDataTypes(ports.OutputPorts);
    case 'parameter'
        idx=strcmp(ports.Parameters.Name,name);
        if~any(idx)
            ME=MSLException('Simulink:SFunctionBuilder:PortNotExist');
            throw(ME);
        end
        ports.Parameters.DataType{idx}=datatype;
        ports.Parameters=renameParameterDataTypes(ports.Parameters);
    end

end

function ports=updatePortDimension(ports,newItem)
    name=newItem{1};
    scope=newItem{2};

    dimension=str2num(newItem{4});
    if isequal(numel(dimension),2)&&any(dimension>1)
        dims='2-D';
    elseif numel(dimension)>2&&any(dimension>1)
        dims='N-D';
    else
        dims='1-D';
    end


    if isfield(name,'oldValue')
        name=name.oldValue;
    end

    switch scope
    case 'input'
        idx=strcmp(ports.InputPorts.Name,name);
        ports.InputPorts.Dims{idx}=dims;
        if isequal(numel(dimension),1)
            ports.InputPorts.Dimensions{idx}=num2str(dimension);
        else
            ports.InputPorts.Dimensions{idx}=strcat('[',regexprep(num2str(dimension),'\s+',','),']');
        end
    case 'output'
        idx=strcmp(ports.OutputPorts.Name,name);
        ports.OutputPorts.Dims{idx}=dims;
        if isequal(numel(dimension),1)
            ports.OutputPorts.Dimensions{idx}=num2str(dimension);
        else
            ports.OutputPorts.Dimensions{idx}=strcat('[',regexprep(num2str(dimension),'\s+',','),']');
        end
    case 'parameter'
    end

end


function ports=updatePortComplexity(ports,newItem)
    name=newItem{1};
    scope=newItem{2};
    complexity=newItem{5};

    if~ismember(complexity,{'real','complex'})
        ME=MSLException('Simulink:SFunctionBuilder:InvalidComplexity');
        throw(ME);
    end



    if isfield(name,'oldValue')
        name=name.oldValue;
    end

    switch scope
    case 'input'
        idx=strcmp(ports.InputPorts.Name,name);
        ports.InputPorts.Complexity{idx}=complexity;
        ports.InputPorts=renamePortDataTypes(ports.InputPorts);
    case 'output'
        idx=strcmp(ports.OutputPorts.Name,name);
        ports.OutputPorts.Complexity{idx}=complexity;
        ports.OutputPorts=renamePortDataTypes(ports.OutputPorts);
    case 'parameter'
        idx=strcmp(ports.Parameters.Name,name);
        ports.Parameters.Complexity{idx}=complexity;
        ports.Parameters=renameParameterDataTypes(ports.Parameters);
    end

end




function ip=newInputPort(item,ports)
    ip=getDefaultPort();


    if isfield(item{1},'oldValue')
        itemName=item{1}.oldValue;
    else
        itemName=item{1};
    end

    itemDataType=item{3};


    if itemName==""
        ip.Name{1}=defaultPortName(ports,'input');
    else
        verifyPortName(item{1},ports)
        ip.Name{1}=item{1};
    end

    ip.DataType{1}=itemDataType;
    ip=renamePortDataTypes(ip);
end

function op=newOutputPort(item,ports)
    op=getDefaultPort();


    if isfield(item{1},'oldValue')
        itemName=item{1}.oldValue;
    else
        itemName=item{1};
    end

    itemDataType=item{3};


    if isempty(itemName)
        op.Name{1}=defaultPortName(ports,'output');
    else
        verifyPortName(itemName,ports)
        op.Name{1}=itemName;
    end
    op.DataType{1}=itemDataType;
    op=renamePortDataTypes(op);
end

function parameter=newParameter(item,ports)
    parameter=getDefaultParameter();


    if isfield(item{1},'oldValue')
        itemName=item{1}.oldValue;
    else
        itemName=item{1};
    end

    itemDataType=item{3};



    if isempty(itemName)
        parameter.Name{1}=defaultPortName(ports,'parameter');
    else
        verifyPortName(itemName,ports)
        parameter.Name{1}=itemName;
    end
    parameter.DataType{1}=itemDataType;
    parameter=renameParameterDataTypes(parameter);
end

function portsInfo=getDefaultPort()
    portsInfo.Name{1}='ALLOW_ZERO_PORTS';
    portsInfo.DataType{1}='real_T';
    portsInfo.Dims{1}='1-D';
    portsInfo.Dimensions{1}='[1,1]';
    portsInfo.Complexity{1}='real';
    portsInfo.Frame{1}='off';
    portsInfo.Bus{1}='off';
    portsInfo.Busname{1}='';
    portsInfo.IsSigned{1}='1';
    portsInfo.WordLength{1}='8';
    portsInfo.FixPointScalingType{1}='0';
    portsInfo.FractionLength{1}='3';
    portsInfo.Slope{1}='2^-3';
    portsInfo.Bias{1}='0';
end

function parametersInfo=getDefaultParameter()
    parametersInfo.Name{1}='ALLOW_ZERO_PARAMETER';
    parametersInfo.DataType{1}='real_T';
    parametersInfo.Complexity{1}='real';
    parametersInfo.Value{1}='1';
end




function name=defaultPortName(ports,portType)
    index=0;
    switch portType
    case 'input'
        prefix='u';
    case 'output'
        prefix='y';
    case 'parameter'
        prefix='p';
    end

    name=strcat(prefix,num2str(index));

    while any(strcmp(name,ports.InputPorts.Name))||...
        any(strcmp(name,ports.OutputPorts.Name))||...
        any(strcmp(name,ports.Parameters.Name))
        index=index+1;
        name=strcat(prefix,num2str(index));
    end
end






function name=defaultLibItemValue(libs,itemType)
    index=0;
    switch itemType
    case 'SRC_PATH'
        prefix='src_path_';
    case 'LIB_PATH'
        prefix='lib_path_';
    case 'INC_PATH'
        prefix='inc_path_';
    case 'ENV_PATH'
        prefix='$env_path_';
    case 'ENTRY'
        prefix='entry_';
    end

    name=strcat(prefix,num2str(index));

    while any(strcmp(name,libs))
        index=index+1;
        name=strcat(prefix,num2str(index));
    end
end

function libraryText=combineLibraryItems(libs)
    libraryText='';

    for i=1:length(libs.SrcPaths)
        libraryText=[libraryText,'SRC_PATH ',libs.SrcPaths{i},newline];
    end
    for i=1:length(libs.LibPaths)
        libraryText=[libraryText,'LIB_PATH ',libs.LibPaths{i},newline];
    end
    for i=1:length(libs.IncPaths)
        libraryText=[libraryText,'INC_PATH ',libs.IncPaths{i},newline];
    end
    for i=1:length(libs.EnvPaths)
        libraryText=[libraryText,'ENV_PATH ',libs.EnvPaths{i},newline];
    end
    for i=1:length(libs.Entries)
        libraryText=[libraryText,libs.Entries{i},newline];
    end
end







function verifyPortName(newName,ports)

    if isempty(newName)
        ME=MSLException('Simulink:SFunctionBuilder:EmptyName');
        throw(ME);
    end

    if any(strcmp(newName,ports.InputPorts.Name))||...
        any(strcmp(newName,ports.OutputPorts.Name))||...
        any(strcmp(newName,ports.Parameters.Name))
        ME=MSLException('Simulink:SFunctionBuilder:DuplicateName');
        throw(ME);
    end

    if~isvarname(newName)
        ME=MSLException('Simulink:SFunctionBuilder:InvalidName');
        throw(ME);
    end
end



function verifyLibName(newName)
    newName=strtrim(newName);
    if isempty(newName)
        ME=MSLException('Simulink:SFunctionBuilder:EmptyPathOrEntry');
        throw(ME);
    end
end

function verifyLibTag(newTag)
    newTag=strtrim(newTag);
    validTags={'SRC_PATH','LIB_PATH','INC_PATH','ENV_PATH','ENTRY'};
    if~any(strcmp(newTag,validTags))
        ME=MSLException('Simulink:SFunctionBuilder:InvalidLibraryTag');
        throw(ME);
    end
end


function port=renamePortDataTypes(port)

    for i=1:length(port.Name)
        [port.DataType{i},port.Complexity{i}]=convertDataTypeaAndComplexity(port.DataType{i},port.Complexity{i},'input/output');
        InFrameBased=port.Frame{i};
        switch InFrameBased
        case 'off'
            port.Frame{i}='FRAME_NO';
        case 'on'
            port.Frame{i}='FRAME_YES';
        case 'auto'
            port.Frame{i}='FRAME_INHERITED';
        case{'FRAME_NO','FRAME_YES','FRAME_INHERITED'}
        otherwise
            port.Frame{i}='FRAME_NO';
        end

    end
end

function parameter=renameParameterDataTypes(parameter)

    for i=1:length(parameter.Name)
        [parameter.DataType{i},parameter.Complexity{i}]=convertDataTypeaAndComplexity(parameter.DataType{i},parameter.Complexity{i},'parameter');
    end
end

function[dataType,complexity]=convertDataTypeaAndComplexity(dataType,complexity,scope)
    switch dataType
    case 'double'
        dataType='real_T';
    case 'single'
        dataType='real32_T';
    case{'boolean','int8','int16','int32','int64','uint8','uint16','uint32','uint64'}
        dataType=strcat(dataType,'_T');
    case{'fixpt','cfixpt'}


        if strcmp(scope,'parameter')
            dataType='real_T';
        end
    case{'real_T','real32_T','int8_T','int16_T','int32_T','int64_T','uint8_T','uint16_T','uint32_T','uint64_T'...
        ,'creal_T','creal32_T','cint8_T','cint16_T','cint32_T','cint64_T','cuint8_T','cuint16_T','cuint32_T','cuint64_T','0','0_T','boolean_T'}

    otherwise
        if startsWith(dataType,'Bus:')&&strcmp(scope,'parameter')


            dataType='real_T';
        elseif~isempty(dataType)
            ME=MSLException('Simulink:SFunctionBuilder:InvalidDataType');
            throw(ME)
        end
    end

    switch complexity
    case 'real'

        if strcmp(dataType(1),'c')
            dataType(1)='';
        end
        complexity='COMPLEX_NO';
    case 'complex'
        if~strcmp(dataType,'boolean_T')

            if~strcmp(dataType(1),'c')
                dataType=['c',dataType];
            end
            complexity='COMPLEX_YES';
        else
            complexity='COMPLEX_NO';
        end

    case 'COMPLEX_YES'
        if~strcmp(dataType,'boolean_T')&&~strcmp(dataType(1),'c')
            dataType=['c',dataType];
        end


    case{'COMPLEX_NO','COMPLEX_INHERITED',''}
    otherwise
        complexity='COMPLEX_INHERITED';
    end
end

function ports=updateLibValue(ports,oldItem,newValue,index)
    newName=strtrim(newValue);
    oldName=strtrim(oldItem{2});

    if strcmp(newName,oldName)
        return
    end

    verifyLibName(newName);
    fieldToUpdate=getFieldsAndIndexesForRanges(ports.LibraryFilesTable,struct('start',index,'end',index,'count',1));
    ports.LibraryFilesTable.(fieldToUpdate{1}.field){fieldToUpdate{1}.indexes}=newName;
end

function ports=updateLibTag(ports,oldItem,newValue,index)

    newTag=strtrim(newValue);
    oldTag=strtrim(oldItem{1});
    if strcmp(newTag,oldTag)
        return;
    end
    name=oldItem{2};


    if isfield(name,'oldValue')
        name=name.oldValue;
    end

    fieldToRemove=getFieldsAndIndexesForRanges(ports.LibraryFilesTable,struct('start',index,'end',index,'count',1));
    ports.LibraryFilesTable.(fieldToRemove{1}.field)(fieldToRemove{1}.indexes)=[];
    verifyLibTag(newTag);

    switch newTag
    case 'SRC_PATH'
        ports.LibraryFilesTable.SrcPaths{end+1}=name;
    case 'LIB_PATH'
        ports.LibraryFilesTable.LibPaths{end+1}=name;
    case 'INC_PATH'
        ports.LibraryFilesTable.IncPaths{end+1}=name;
    case 'ENV_PATH'
        ports.LibraryFilesTable.EnvPaths{end+1}=name;
    case 'ENTRY'
        ports.LibraryFilesTable.Entries{end+1}=name;
    end

end

function tf=compareCode(code1,code2)
    if isempty(code1)&&isempty(code2)
        tf=true;
    else
        tf=strcmp(code1,code2);
    end
end

function verifySFunctionName(sfunctionName)
    if(~isvarname(deblank(sfunctionName))||exist(sfunctionName,'file')==4)


        potentialPackageFile=[sfunctionName,getSFcnPackageExtension];
        files=which(potentialPackageFile);
        if~isempty(files)
            if iscell(files)
                potentialPackageFile=files{1};
            else
                potentialPackageFile=files;
            end
        end

        try
            isSFcnPackage=Simulink.SFcnPackage.isSFcnPackage(sfunctionName,...
            potentialPackageFile);
        catch
            isSFcnPackage=false;
        end
        if~isSFcnPackage
            ME=MSLException('Simulink:blocks:SFunctionBuilderInvalidName',sfunctionName);
            throw(ME);
        end
    end
end


function refreshIcon(blockHandle,inputs,outputs)
    try
        set_param(blockHandle,'SfunBuilderNumInputPorts',num2str(length(inputs.Name)));
    catch

    end
    try
        set_param(blockHandle,'SfunBuilderNumOutputPorts',num2str(length(outputs.Name)));
    catch

    end
    maskDisplay="plot(val(:,1),val(:,2)),disp(sys)";
    for inputIndex=1:length(inputs.Name)
        maskDisplay=strcat(maskDisplay,",","port_label('input'",",",num2str(inputIndex),",","'",inputs.Name{inputIndex},"')");
    end
    for outputIndex=1:length(outputs.Name)
        maskDisplay=strcat(maskDisplay,",","port_label('output'",",",num2str(outputIndex),",","'",outputs.Name{outputIndex},"')");
    end
    try
        set_param(blockHandle,'MaskDisplay',maskDisplay);
    catch

    end
end
