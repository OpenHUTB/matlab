classdef ObserverBindModeHandler<handle

    properties
bindModeSourceObj
bindingsInfo
observerPortBlockHandles
    end


    methods

        function this=ObserverBindModeHandler(observerPortBlkH)
            import Simulink.observer.internal.ObserverBindModeHandler.*;
            modelName=bdroot(observerPortBlkH);
            observerPortBlockHandles=Simulink.observer.internal.getObserverPortsInsideObserverModel(modelName);
            indx1=(observerPortBlockHandles==observerPortBlkH);
            indx2=(observerPortBlockHandles~=observerPortBlkH);
            observerPortBlockHandles=[observerPortBlockHandles(indx1);observerPortBlockHandles(indx2)];
            this.observerPortBlockHandles=observerPortBlockHandles;
            observerPortBlockNames=get_param(observerPortBlockHandles,'Name');
            this.bindModeSourceObj=BindMode.ObserverSourceData(modelName,this,observerPortBlockNames);
            this.bindingsInfo=containers.Map;

            for i=1:length(observerPortBlockHandles)
                status=Simulink.observer.internal.getObserverPortStatus(observerPortBlockHandles(i));
                if strcmp(status,'Valid')
                    [metaData,bindableName]=this.createBindModeMetaData(i);
                    this.bindingsInfo(num2str(observerPortBlockHandles(i),64))=BindMode.BindableRow(true,BindMode.BindableTypeEnum.SLSIGNAL,bindableName,BindMode.SLSignalMetaData(metaData));
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
                index=ismember(get_param(this.observerPortBlockHandles,'Name'),activeDropDownValue);
                symbolIdKey=num2str(this.observerPortBlockHandles(index),64);
                if this.bindingsInfo.isKey(symbolIdKey)
                    connectedData{1}=this.bindingsInfo(symbolIdKey);
                    formattedData.bindableRows=BindMode.utils.combineSelectedAndConnectedRows(formattedData.bindableRows,connectedData);
                end
            end

        end


        function success=onRadioSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)
            if isChecked
                index=ismember(get_param(this.observerPortBlockHandles,'Name'),dropDownValue);
                symbolIdKey=num2str(this.observerPortBlockHandles(index),64);
                Simulink.observer.internal.configureObserverPort(this.observerPortBlockHandles(index),...
                'Outport',...
                get_param(bindableMetaData.blockPathStr,'Handle'),...
                bindableMetaData.outputPortNumber);
                [metaData,~]=this.createBindModeMetaData(index);
                this.bindingsInfo(symbolIdKey)=BindMode.BindableRow(true,BindMode.BindableTypeEnum.SLSIGNAL,bindableName,BindMode.SLSignalMetaData(metaData));

                success=true;
            else
                success=false;
            end
        end

        function[metaData,bindableName]=createBindModeMetaData(this,i)
            blkH=Simulink.observer.internal.getObservedBlock(this.observerPortBlockHandles(i));
            blk=get_param(blkH,'Object');

            metaData.name=blk.name;
            metaData.blockPathStr=blk.getFullName();
            metaData.hierarchicalPathArr={blk.getFullName()};
            metaData.outputPortNumber=Simulink.observer.internal.getObservedPortIndex(this.observerPortBlockHandles(i));
            metaData.id=this.observerPortBlockHandles(i);
            bindableName=[metaData.name,':',num2str(metaData.outputPortNumber)];

        end

    end


    methods(Static)
        function activateBindMode(observerPortBlkH)
            observerBindModeHandler=Simulink.observer.internal.ObserverBindModeHandler(observerPortBlkH);
            observerBindModeHandler.openModel();
            observerBindModeHandler.activate();
        end
    end
end
