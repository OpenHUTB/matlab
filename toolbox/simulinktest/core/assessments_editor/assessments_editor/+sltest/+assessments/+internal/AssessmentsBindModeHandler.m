classdef AssessmentsBindModeHandler<handle


    properties
bindModeSourceObj
symbolsInfo
bindingsInfo
showParameters
    end

    methods

        function this=AssessmentsBindModeHandler(symbolsInfo,showParameters)
            import sltest.assessments.internal.AssessmentsBindModeHandler.*;
            this.symbolsInfo=symbolsInfo;
            if isempty(symbolsInfo.harnessName)
                modelName=symbolsInfo.modelName;
                systemModelName='';
            else
                modelName=symbolsInfo.harnessName;
                systemModelName=symbolsInfo.modelName;
            end
            this.bindModeSourceObj=BindMode.AssessmentsSourceData(modelName,systemModelName,this,this.symbolsInfo.symbolNames);
            this.bindingsInfo=containers.Map;
            this.showParameters=showParameters;
            this.initializeBindingInfo();
        end

        function openModel(this)
            if~isempty(this.bindModeSourceObj.systemModelName)


                open_system(this.bindModeSourceObj.systemModelName);
                harnessObj=sltest.harness.find(this.bindModeSourceObj.systemModelName,'Name',this.bindModeSourceObj.modelName);
                if~isempty(harnessObj)
                    sltest.harness.open(harnessObj.ownerFullPath,harnessObj.name);
                else

                end
            else

                open_system(this.bindModeSourceObj.modelName);
            end
        end

        function activate(this)
            BindMode.BindMode.enableBindMode(this.bindModeSourceObj);
        end

        function result=checkSourceValidity(this)
            import sltest.assessments.internal.AssessmentsBindModeHandler.*;

            if(isfield(this.symbolsInfo,'clientValidityFunction')&&~isempty(this.symbolsInfo.clientValidityFunction))
                fhandle=str2func(this.symbolsInfo.clientValidityFunction);
                result=fhandle(this.symbolsInfo.clientId);
            else
                result=true;
            end

            if~result


                msgId='sltest:assessments:editor:BindModeSourceInvalid';
                editors=GLUE2.Util.findAllEditors(this.bindModeSourceObj.modelName);
                studio=editors(1).getStudio;
                activeEditor=studio.App.getActiveEditor();
                activeEditor.deliverInfoNotification(msgId,message(msgId).string());

                deactivateBindModeForModel(this.bindModeSourceObj.modelName);


                message.publish(['/Assessments/',this.symbolsInfo.clientId,'/closeBindModeDialog'],[]);
            end
        end

        function formattedData=getBindableData(this,selectionHandles,activeDropDownValue)
            import sltest.assessments.internal.AssessmentsBindModeHandler.*



            if this.checkSourceValidity()==false
                formattedData={};
                return;
            end

            signalRows=BindMode.utils.getSignalRowsInSelection(selectionHandles);
            if this.showParameters
                [parameterRows,updateDiagramNeeded]=BindMode.utils.getParameterRowsInSelection(selectionHandles,true);
                formattedData.updateDiagramButtonRequired=updateDiagramNeeded;
                formattedData.bindableRows=[signalRows,parameterRows];
            else
                formattedData.updateDiagramButtonRequired=false;
                formattedData.bindableRows=signalRows;
            end


            if~isempty(activeDropDownValue)
                symbolId=getSymbolIdFromDropDownValue(this.symbolsInfo,activeDropDownValue);
            else
                symbolId=this.symbolsInfo.symbolIds(1);
            end
            symbolIdKey=num2str(symbolId,64);
            if this.bindingsInfo.isKey(symbolIdKey)
                connectedData{1}=this.bindingsInfo(symbolIdKey);
                formattedData.bindableRows=BindMode.utils.combineSelectedAndConnectedRows(formattedData.bindableRows,connectedData);
            end
        end

        function success=onRadioSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)
            import sltest.assessments.internal.AssessmentsBindModeHandler.*;

            if isChecked
                symbolId=getSymbolIdFromDropDownValue(this.symbolsInfo,dropDownValue);

                mappingInfo.symbolId=symbolId;
                mappingInfo.bindableType=bindableType;
                mappingInfo.bindableName=bindableName;
                mappingInfo.bindableMetaData=bindableMetaData;


                message.publish(['/Assessments/',this.symbolsInfo.clientId,'/',this.symbolsInfo.widgetIndex,'/bindSymbol'],mappingInfo);

                this.bindingsInfo(num2str(symbolId,64))=BindMode.BindableRow(true,BindMode.BindableTypeEnum.getEnumTypeFromChar(bindableType),bindableName,BindMode.utils.getBindableMetaDataFromStruct(bindableType,bindableMetaData));

                success=true;
            else
                success=false;
            end
        end

        function initializeBindingInfo(this)
            for i=1:length(this.symbolsInfo.symbolIds)
                if iscell(this.symbolsInfo.bindingInfo)
                    bindingInfo=this.symbolsInfo.bindingInfo{i};
                else
                    bindingInfo=this.symbolsInfo.bindingInfo(i);
                end
                if strcmp(bindingInfo.mappingType,'Map To Model Element')||strcmp(bindingInfo.mappingType,'Map To Expression')
                    this.bindingsInfo(num2str(this.symbolsInfo.symbolIds(i),64))=BindMode.BindableRow(true,BindMode.BindableTypeEnum.getEnumTypeFromChar(bindingInfo.bindableType),bindingInfo.bindableName,BindMode.utils.getBindableMetaDataFromStruct(bindingInfo.bindableType,bindingInfo.bindableMetaData));
                end
            end
        end

        function result=checkBindableExists(~,elementType,bindableMetaData)
            if(isfield(bindableMetaData,'blockHandle'))
                blockHandle=str2double(bindableMetaData.blockHandle);
            else
                try
                    blockHandle=get_param(bindableMetaData.blockPathStr,'Handle');
                catch
                    blockHandle=-1;
                end
            end
            if blockHandle==-1
                errordlg(message('sltest:assessments:editor:InvalidBindableBlock').getString(),message('sltest:assessments:editor:InvalidBindableDialogTitle').getString());
                result=false;
                return;
            end
            if(strcmp(elementType,BindMode.BindableTypeEnum.SLSIGNAL.char))
                portNumber=bindableMetaData.outputPortNumber;
                portHs=get_param(blockHandle,'porthandles');
                outPortH=portHs.Outport(portNumber);
                lineHandle=get(outPortH,'Line');
                if lineHandle==-1
                    errordlg(message('sltest:assessments:editor:InvalidBindableSignal').getString(),message('sltest:assessments:editor:InvalidBindableDialogTitle').getString());
                    result=false;
                    return;
                end
            end
            result=true;
        end
    end

    methods(Static,Access=private)
        function[modelName,systemModelName]=getModelInfo(clientId)
            tc=sltest.testmanager.TestCase('',str2double(clientId));
            mainModelName=tc.getProperty('model');
            harnessModelName=tc.getProperty('harnessname');
            if isempty(harnessModelName)
                modelName=mainModelName;
                systemModelName='';
            else
                modelName=harnessModelName;
                systemModelName=mainModelName;
            end
        end

        function result=getSymbolIdFromDropDownValue(symbolsInfo,dropDownValue)
            result=symbolsInfo.symbolIds(strcmp(symbolsInfo.symbolNames,dropDownValue));
        end

        function deactivateBindModeForModel(modelName)
            if isempty(find_system('Name',modelName,'type','block_diagram'))

                return;
            end
            modelObj=get_param(modelName,'Object');
            BindMode.BindMode.disableBindMode(modelObj);
        end
    end

    methods(Static)
        function activateBindMode(symbolsInfo,showParameters)
            if nargin<2
                showParameters=false;
            end
            assessmentsBindModeHandler=sltest.assessments.internal.AssessmentsBindModeHandler(symbolsInfo,showParameters);
            assessmentsBindModeHandler.openModel();
            assessmentsBindModeHandler.activate();
        end

        function deactivateBindMode(modelName)
            import sltest.assessments.internal.AssessmentsBindModeHandler.*;
            deactivateBindModeForModel(modelName);
        end
    end
end
