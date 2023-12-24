classdef InjectorBindModeHandler<handle

    properties
bindModeSourceObj
bindingsInfo
injPrtHdls
injMdlName
    end


    methods

        function this=InjectorBindModeHandler(injPrtHdl)
            import Simulink.injector.internal.InjectorBindModeHandler.*;
            injMdlH=bdroot(injPrtHdl);
            this.injMdlName=getfullname(injMdlH);
            injRef=get_param(injMdlH,'InjectorContext');
            topMdl=bdroot(injRef);
            injSSHdl=Simulink.injector.internal.getGrInjectorSubsystemForInjectorPort(injPrtHdl);
            injIpHdls=Simulink.injector.internal.getGrInjectorInportsInInjectorSubsystem(injSSHdl);
            injOpHdls=Simulink.injector.internal.getGrInjectorOutportsInInjectorSubsystem(injSSHdl);
            injPrtHdls=[injIpHdls;injOpHdls];
            indx1=(injPrtHdls==injPrtHdl);
            indx2=(injPrtHdls~=injPrtHdl);
            injPrtHdls=[injPrtHdls(indx1);injPrtHdls(indx2)];
            this.injPrtHdls=injPrtHdls;
            injectorPortBlockNames=get_param(injPrtHdls,'Name');
            this.bindModeSourceObj=BindMode.InjectorSourceData(topMdl,this,injectorPortBlockNames);
            this.bindingsInfo=containers.Map;

            for i=1:length(injPrtHdls)
                status=Simulink.injector.internal.getInjectorPortStatus(injPrtHdls(i));
                if strcmp(status,'Valid')
                    [metaData,bindableName]=this.createBindModeMetaData(i);
                    this.bindingsInfo(num2str(injPrtHdls(i),64))=BindMode.BindableRow(true,BindMode.BindableTypeEnum.SLSIGNAL,bindableName,BindMode.SLSignalMetaData(metaData));
                end
            end
        end

        function openModel(this)
            open_system(this.bindModeSourceObj.modelName);
        end

        function activate(this)
            BindMode.BindMode.enableBindMode(this.bindModeSourceObj);
        end

        function formattedData=getBindableData(this,selectionHandles,activeDropDownValue)
            signalRows=BindMode.utils.getSignalRowsInSelection(selectionHandles);
            formattedData.updateDiagramButtonRequired=false;
            formattedData.bindableRows=signalRows;
            if~isempty(activeDropDownValue)
                index=ismember(get_param(this.injPrtHdls,'Name'),activeDropDownValue);
                symbolIdKey=num2str(this.injPrtHdls(index),64);
                if this.bindingsInfo.isKey(symbolIdKey)
                    connectedData{1}=this.bindingsInfo(symbolIdKey);
                    formattedData.bindableRows=BindMode.utils.combineSelectedAndConnectedRows(formattedData.bindableRows,connectedData);
                end
            end

        end

        function success=onRadioSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)
            if isChecked
                index=ismember(get_param(this.injPrtHdls,'Name'),dropDownValue);
                symbolIdKey=num2str(this.injPrtHdls(index),64);
                Simulink.injector.internal.configureInjectorPort(this.injPrtHdls(index),...
                'Outport',...
                cell2mat(get_param(bindableMetaData.hierarchicalPathArr(2:end),'Handle')),...
                bindableMetaData.outputPortNumber);
                [metaData,~]=this.createBindModeMetaData(index);
                this.bindingsInfo(symbolIdKey)=BindMode.BindableRow(true,BindMode.BindableTypeEnum.SLSIGNAL,bindableName,BindMode.SLSignalMetaData(metaData));

                success=true;
            else
                success=false;
            end
        end

        function[metaData,bindableName]=createBindModeMetaData(this,i)
            blkH=Simulink.injector.internal.getInjectedBlock(this.injPrtHdls(i));
            blk=get_param(blkH,'Object');

            metaData.name=blk.name;
            metaData.blockPathStr=blk.getFullName();
            metaData.hierarchicalPathArr={blk.getFullName()};
            metaData.outputPortNumber=Simulink.injector.internal.getInjectedPortIndex(this.injPrtHdls(i));
            metaData.id=this.injPrtHdls(i);
            bindableName=[metaData.name,':',num2str(metaData.outputPortNumber)];

        end

    end

    methods(Static)
        function activateBindMode(injPrtHdl)
            injMdlH=bdroot(injPrtHdl);
            if isempty(get_param(injMdlH,'InjectorContext'))
                return;
            end
            injectorBindModeHandler=Simulink.injector.internal.InjectorBindModeHandler(injPrtHdl);
            injectorBindModeHandler.openModel();
            injectorBindModeHandler.activate();
        end
    end
end
