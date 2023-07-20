

classdef SignalOfInterestConfigData<BindMode.BindModeSourceData






    properties(SetAccess=protected,GetAccess=public)
        modelName;
        clientName=BindMode.ClientNameEnum.MAPPINGS;
        isGraphical=false;
        sourceElementPath;
        sourceElementHandle;
        allowMultipleConnections=true;
        requiresDropDownMenu=false;
        modelLevelBinding=true;
        hierarchicalPathArray={}
        dropDownElements;
        modelMapping;
    end

    methods
        function newObj=SignalOfInterestConfigData(modelName,key)
            newObj.modelName=modelName;
            newObj.modelMapping=Simulink.CodeMapping.get(modelName,key);
        end

        function bindableData=getBindableData(this,selectionHandles,activeDropDownValue)
            selectionRows=this.getSignalRowsInSelection(selectionHandles);
            bindableData.updateDiagramButtonRequired=false;
            bindableData.bindableRows=selectionRows;
        end

        function result=onCheckBoxSelectionChange(this,~,~,~,bindableMetaData,isChecked)
            portHandles=get_param(bindableMetaData.blockPathStr,'PortHandles');
            ph=portHandles.Outport(bindableMetaData.outputPortNumber);
            if isChecked
                try
                    this.modelMapping.addSignal(ph);
                catch ME
                    errordlg(regexprep(ME.message,'<.*?>',''));
                end
                result=false;
            else
                this.modelMapping.removeSignal(ph);
                result=true;
            end
        end
    end

    methods(Access=private)
        function selectionRows=getSignalRowsInSelection(this,selectionHandles)



            blockHandles=[];
            portHandles=[];

            for idx=1:numel(selectionHandles)
                if(selectionHandles(idx)==0)
                    continue;
                end
                type=get_param(selectionHandles(idx),'Type');
                if(strcmp(type,'port'))
                    portHandles(end+1)=selectionHandles(idx);
                elseif(strcmp(type,'block'))
                    blockHandles(end+1)=selectionHandles(idx);
                end
            end

            segHs=utils.getSignalsForSelectedBlocks(num2cell(blockHandles));
            segHs(segHs==-1)=[];
            portHs=arrayfun(@(x)get_param(x,'SrcPortHandle'),segHs);
            allPortHandles=union(portHandles,portHs);
            selectionRows=cell(1,numel(allPortHandles));
            for idx=1:numel(allPortHandles)
                connectStatus=false;
                bindableType=BindMode.BindableTypeEnum.SLSIGNAL;
                bindableName=get_param(allPortHandles(idx),'Name');
                sourceBlockPath=getfullname(get_param(get_param(allPortHandles(idx),'Parent'),'Handle'));
                outportNumber=get_param(allPortHandles(idx),'PortNumber');
                bindableMetaData=BindMode.SLSignalMetaData(bindableName,sourceBlockPath,outportNumber);
                selectionRows{idx}=BindMode.BindableRow(connectStatus,bindableType,bindableName,bindableMetaData);
            end
            selectionRows=selectionRows(~cellfun('isempty',selectionRows));
        end
    end
end
