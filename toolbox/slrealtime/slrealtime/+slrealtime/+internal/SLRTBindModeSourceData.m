classdef SLRTBindModeSourceData<BindMode.BindModeSourceData














    properties(SetAccess=protected,GetAccess=public)
        modelName;
        clientName=BindMode.ClientNameEnum.SLRT;
        isGraphical=false;
        modelLevelBinding=true;
        sourceElementPath;
        hierarchicalPathArray;
        sourceElementHandle;
        allowMultipleConnections=true;
        requiresDropDownMenu=false;
        dropDownElements;
    end



    methods
        function obj=SLRTBindModeSourceData(modelName,bindType,retDataFuncH,varargin)
            obj.modelName=modelName;
            obj.BindType=bindType;
            obj.RetDataFuncH=retDataFuncH;
            if nargin>3&&~isempty(varargin{1})
                obj.DataMap=varargin{1};
            else
                obj.DataMap=containers.Map('KeyType','char','ValueType','any');
            end
        end

        function bindableData=getBindableData(this,selectionHandles,activeDropDownValue)
            if this.BindType==this.SIGNALS
                bindableData=this.getBindableSignalData(selectionHandles,activeDropDownValue);
            elseif this.BindType==this.PARAMETERS
                bindableData=this.getBindableParameterData(selectionHandles,activeDropDownValue);
            else
                bindableDataSigs=this.getBindableSignalData(selectionHandles,activeDropDownValue);
                bindableDataParams=this.getBindableParameterData(selectionHandles,activeDropDownValue);
                bindableData.updateDiagramButtonRequired=bindableDataSigs.updateDiagramButtonRequired||bindableDataParams.updateDiagramButtonRequired;
                bindableData.bindableRows=[bindableDataSigs.bindableRows,bindableDataParams.bindableRows];
            end
        end

        function result=onCheckBoxSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)
            if strcmp(bindableType,'SLSIGNAL')
                result=this.onCheckBoxSignalSelectionChange(dropDownValue,bindableType,bindableName,bindableMetaData,isChecked);
            else
                result=this.onCheckBoxParameterSelectionChange(dropDownValue,bindableType,bindableName,bindableMetaData,isChecked);
            end
        end
    end

    properties(Constant)
        SIGNALS=1
        PARAMETERS=2
        BOTH=3
    end

    properties(Access=private)
        DataMap={}
        BindType=slrealtime.internal.SLRTBindModeSourceData.SIGNALS
        RetDataFuncH=[]
    end

    methods
        function delete(this)
            this.RetDataFuncH(this.DataMap);
        end

        function val=allowBindWhenSimulating(this)
            val=true;
        end

        function bindableData=getBindableSignalData(this,selectionHandles,activeDropDownValue)
            for idx=1:numel(selectionHandles)
                if(selectionHandles(idx)==0)
                    continue;
                end
                if(strcmp(get_param(selectionHandles(idx),'Type'),'port'))&&...
                    (strcmp(get_param(selectionHandles(idx),'PortType'),'state'))
                    selectionHandles(idx)=0;
                    continue;
                end
            end

            selectionRows=BindMode.utils.getSignalRowsInSelection(selectionHandles);
            for i=1:length(selectionRows)
                blockPathStr=join(selectionRows{i}.bindableMetaData.hierarchicalPathArr(2:end),'/');
                uniqueSignalId=[blockPathStr{1},':',num2str(selectionRows{i}.bindableMetaData.outputPortNumber)];
                if this.DataMap.isKey(uniqueSignalId)
                    selectionRows{i}.isConnected=true;
                end
            end

            bindableData.updateDiagramButtonRequired=false;
            bindableData.bindableRows=selectionRows;
        end

        function bindableData=getBindableParameterData(this,selectionHandles,activeDropDownValue)
            [selectionRows,updateDiagramNeeded_selection]=BindMode.utils.getParameterRowsInSelection(selectionHandles);
            for i=1:length(selectionRows)
                if length(selectionRows{i}.bindableMetaData.hierarchicalPathArr)>2

                    activeEditor=BindMode.utils.getLastActiveEditor();
                    BindMode.utils.showHelperNotification(activeEditor,message('SimulinkHMI:HMIBindMode:ModelRefNotSupportedText').string())
                    bindableData=[];
                    return;
                end

                if isa(selectionRows{i}.bindableMetaData,'BindMode.VariableMetaData')

                    path='';
                else
                    path=selectionRows{i}.bindableMetaData.blockPathStr;
                end
                uniqueSignalId=[path,':',selectionRows{i}.bindableMetaData.name];

                if this.DataMap.isKey(uniqueSignalId)
                    selectionRows{i}.isConnected=true;
                end
            end


            for i=1:length(selectionHandles)
                try
                    params=get_param(selectionHandles(i),'InstanceParameters');
                catch
                    continue;
                end
                for nParam=1:length(params)
                    isConnected=false;

                    prefix=[get_param(selectionHandles(i),'Name'),':'];
                    for j=1:params(nParam).Path.getLength()
                        blks=split(params(nParam).Path.getBlock(j),'/');
                        prefix=[prefix,blks{end},':'];%#ok
                    end
                    bindableName=[prefix,params(nParam).Name];
                    bindableMetaData=slrealtime.internal.SLRTInstanceParamMetaData(...
                    params(nParam).Name,...
                    getfullname(selectionHandles(i)),...
                    params(nParam).Path.convertToCell());
                    if isempty(selectionRows)
                        selectionRows{1}=BindMode.BindableRow(isConnected,'SLPARAMETER',bindableName,bindableMetaData);
                    else
                        selectionRows{end+1}=BindMode.BindableRow(isConnected,'SLPARAMETER',bindableName,bindableMetaData);
                    end
                end
            end

            bindableData.updateDiagramButtonRequired=updateDiagramNeeded_selection;
            bindableData.bindableRows=selectionRows;
        end

        function result=onCheckBoxSignalSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)
            blockPathStr=join(bindableMetaData.hierarchicalPathArr(2:end),'/');
            uniqueSignalId=[blockPathStr{1},':',num2str(bindableMetaData.outputPortNumber)];

            try
                phs=get_param(bindableMetaData.hierarchicalPathArr{end},'PortHandles');
                bindableMetaData.signalLabel=get_param(phs.Outport(bindableMetaData.outputPortNumber),'name');
            catch
                bindableMetaData.signalLabel=[];
            end

            if isChecked&&~this.DataMap.isKey(uniqueSignalId)
                this.DataMap(uniqueSignalId)=bindableMetaData;
            elseif~isChecked&&this.DataMap.isKey(uniqueSignalId)
                this.DataMap.remove(uniqueSignalId);
            end
            result=true;
        end

        function result=onCheckBoxParameterSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)
            if isfield(bindableMetaData,'workspaceType')&&~isempty(bindableMetaData.workspaceType)

                bindableMetaData.blockPathStr='';
                bindableMetaData.hierarchicalPathArr{1}='';
                bindableMetaData.hierarchicalPathArr{2}='';
            end

            if isfield(bindableMetaData,'instHierarchicalPathArr')

                bindableMetaData.hierarchicalPathArr=[bindableMetaData.hierarchicalPathArr;bindableMetaData.instHierarchicalPathArr];
                uniqueSignalId=bindableName;
            else
                uniqueSignalId=[bindableMetaData.blockPathStr,':',bindableMetaData.name];
            end

            if isChecked&&~this.DataMap.isKey(uniqueSignalId)
                this.DataMap(uniqueSignalId)=bindableMetaData;
            elseif~isChecked&&this.DataMap.isKey(uniqueSignalId)
                this.DataMap.remove(uniqueSignalId);
            end
            result=true;
        end
    end
end
