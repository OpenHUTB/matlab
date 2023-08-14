function iniDialogData(this)




    block=this.getBlock();
    maskObj=Simulink.Mask.get(block.Handle);
    paraObj=maskObj.Parameters;
    lstParams={paraObj(:).Name};
    num_params=length(lstParams);


    this.DialogData.NumParams=num_params;
    this.DialogData.ListParams=lstParams;
    this.DialogData.ListPrompt={paraObj(:).Prompt};
    this.DialogData.ListType={paraObj(:).Type};
    this.DialogData.ListEnum={paraObj(:).TypeOptions};
    this.DialogData.ListValue={paraObj(:).Value};
    this.DialogData.ListEnabled=cellfun(@str2logic,{paraObj(:).Enabled});
    this.DialogData.ListVisible=cellfun(@str2logic,{paraObj(:).Visible});


    this.Dialogdata.ParameterTreeViewSource=[];
    this.DialogData.inputListSource=[];
    this.DialogData.outputListSource=[];


    this.DialogData.PromptLength=cellfun(@length,this.DialogData.ListPrompt);
    this.DialogData.ValueLength=cellfun(@length,this.DialogData.ListValue);


    for i=1:num_params
        if strcmp(this.DialogData.ListType{i},'checkbox')
            this.DialogData.ValueLength(i)=1;





        elseif strcmp(this.DialogData.ListType{i},'popup')
            this.DialogData.ValueLength(i)=max(cellfun(@length,this.DialogData.ListEnum{i}));
            this.DialogData.ListType{i}='combobox';







        end
    end
    this.DialogData.ListOldValue=this.DialogData.ListValue;


    this.DialogData.ChangeList=zeros(1,num_params);


    this.DialogData.DebugLoggingFilter=block.FMUDebugLoggingFilter;
    this.DialogData.FMUSampleTime=block.FMUSampleTime;
    this.DialogData.FMUToleranceValue=block.FMUToleranceValue;



    this.DialogData.InputBusStruct=eval(block.FMUInputBusStruct);
    this.DialogData.InputBusObjectName=block.FMUInputBusObjectName;
    this.DialogData.InputBusStructTable=cell(length(this.DialogData.InputBusStruct),3);
    this.DialogData.InputBusStructTableData=cell(length(this.DialogData.InputBusStruct),1);
    for i=1:length(this.DialogData.InputBusStruct)
        this.DialogData.InputBusStructTable{i,1}.Type='text';
        this.DialogData.InputBusStructTable{i,1}.Name=num2str(this.DialogData.InputBusStruct{i}.port);

        this.DialogData.InputBusStructTable{i,2}.Type='text';
        this.DialogData.InputBusStructTable{i,2}.Name=this.DialogData.InputBusStruct{i}.name;
        this.DialogData.InputBusStructTable{i,2}.WordWrap=true;

        this.DialogData.InputBusStructTable{i,3}.Type='edit';
        if isequal(this.DialogData.InputBusObjectName,[])
            this.DialogData.InputBusStructTableData{i,1}=this.DialogData.InputBusStruct{i}.name;
        elseif i<=length(this.DialogData.InputBusObjectName)
            this.DialogData.InputBusStructTableData{i,1}=this.DialogData.InputBusObjectName{i};
        else
            this.DialogData.InputBusStructTableData{i,1}=this.DialogData.InputBusStruct{i}.name;
        end
        this.DialogData.InputBusStructTable{i,3}.Value=this.DialogData.InputBusStructTableData{i,1};
        this.DialogData.InputBusStructTable{i,3}.Enabled=~this.isHierarchySimulating;
        this.DialogData.InputBusStructTable{i,3}.WordWrap=true;
    end


    this.DialogData.InputBusStructTableDataChanged=false;
    this.DialogData.InputVisibilityChanged=false;
    this.DialogData.InputStartValueChanged=false;
    this.DialogData.InputBusObjectNameChanged=false;


    cellVal=block.FMUInputAlteredNameStartMap;
    if isempty(cellVal)
        this.DialogData.InputAlteredNameStartMap=containers.Map;
    else
        this.DialogData.InputAlteredNameStartMap=containers.Map(cellVal(:,1),cellVal(:,2));
    end



    this.DialogData.OutputBusStruct=eval(block.FMUOutputBusStruct);
    this.DialogData.OutputBusObjectName=block.FMUOutputBusObjectName;
    this.DialogData.OutputBusStructTable=cell(length(this.DialogData.OutputBusStruct),3);
    this.DialogData.OutputBusStructTableData=cell(length(this.DialogData.OutputBusStruct),1);
    for i=1:length(this.DialogData.OutputBusStruct)
        this.DialogData.OutputBusStructTable{i,1}.Type='text';
        this.DialogData.OutputBusStructTable{i,1}.Name=num2str(this.DialogData.OutputBusStruct{i}.port);

        this.DialogData.OutputBusStructTable{i,2}.Type='text';
        this.DialogData.OutputBusStructTable{i,2}.Name=this.DialogData.OutputBusStruct{i}.name;
        this.DialogData.OutputBusStructTable{i,2}.WordWrap=true;

        this.DialogData.OutputBusStructTable{i,3}.Type='edit';
        if isequal(this.DialogData.OutputBusObjectName,[])
            this.DialogData.OutputBusStructTableData{i,1}=this.DialogData.OutputBusStruct{i}.name;
        elseif i<=length(this.DialogData.OutputBusObjectName)
            this.DialogData.OutputBusStructTableData{i,1}=this.DialogData.OutputBusObjectName{i};
        else
            this.DialogData.OutputBusStructTableData{i,1}=this.DialogData.OutputBusStruct{i}.name;
        end
        this.DialogData.OutputBusStructTable{i,3}.Value=this.DialogData.OutputBusStructTableData{i,1};
        this.DialogData.OutputBusStructTable{i,3}.Enabled=~this.isHierarchySimulating;
        this.DialogData.OutputBusStructTable{i,3}.WordWrap=true;
    end


    this.DialogData.OutputBusStructTableDataChanged=false;
    this.DialogData.OutputVisibilityChanged=false;
    this.DialogData.OutputStartValueChanged=false;
    this.DialogData.OutputBusObjectNameChanged=false;

    this.DialogData.InternalVisibilityChanged=false;


    if slfeature('FMUNativeSimulinkBehavior')
        this.DialogData.SimulateUsing=block.SimulateUsing;
    end


    this.iniTreeViewData(block);
end


function iniTreeViewData(this,block)



    scalarVariableList=block.FMUScalarVariableList;


    if isempty(this.Dialogdata.ParameterTreeViewSource)
        this.DialogData.ParameterTreeViewSource=...
        internal.fmudialog.FMUSpreadSheetSource(...
        this,...
        this.DialogData.ListValue,...
        this.DialogData.ListType,...
        this.DialogData.ListEnum,...
        block.FMUParameterStructure,...
        block.FMUParameterCompleteOrderedIndex,...
        scalarVariableList,...
        false);
    end


    if isempty(this.DialogData.inputListSource)


        inTree=block.FMUInputStructure;
        inTreeRootIndex=0;
        inTreeRootBusIndex=0;
        inVisibility=block.FMUInputVisibility;
        inBusObj=block.FMUInputBusObjectName;
        flag=zeros(1,length(inTree));
        for i=1:length(inTree)
            if~isempty(inTree(i).ChildrenIndex)

                flag(inTree(i).ChildrenIndex)=1;
            end
        end
        for i=1:length(inTree)

            inTree(i).IsRoot=false;
            inTree(i).IsVisible='on';
            inTree(i).BusObjectName='';

            if flag(i)==0

                inTreeRootIndex=inTreeRootIndex+1;
                inTree(i).IsRoot=true;
                if~isempty(inTree(i).ChildrenIndex)

                    inTreeRootBusIndex=inTreeRootBusIndex+1;
                    inTree(i).BusObjectName=inTree(i).Name;

                    if inTreeRootBusIndex<=length(inBusObj)
                        inTree(i).BusObjectName=inBusObj{inTreeRootBusIndex};
                    else
                        inTree(i).BusObjectName=inTree(i).Name;
                    end
                end

                if inTreeRootIndex<=length(inVisibility)
                    inTree(i).IsVisible=logic2str(logical(inVisibility{inTreeRootIndex}));
                end
            end
        end



        inTreeIndices=block.FMUInputCompleteOrderedIndex;


        inListType=cell(1,length(inTreeIndices));
        inListEnum=cell(1,length(inTreeIndices));
        for i=1:length(inTreeIndices)
            inListType{i}='edit';
            inListEnum{i}={};
        end

        this.DialogData.inputListSource=...
        internal.fmuInterface.spreadSheetSource(...
        this,...
        inListType,...
        inListEnum,...
        inTree,...
        inTreeIndices,...
        scalarVariableList,...
        true);
    end


    if isempty(this.DialogData.outputListSource)


        outTree=block.FMUOutputStructure;
        outTreeRootIndex=0;
        outTreeRootBusIndex=0;
        outVisibility=block.FMUOutputVisibility;
        outBusObj=block.FMUOutputBusObjectName;
        flag=zeros(1,length(outTree));
        for i=1:length(outTree)
            if~isempty(outTree(i).ChildrenIndex)

                flag(outTree(i).ChildrenIndex)=1;
            end
        end
        for i=1:length(outTree)

            outTree(i).IsRoot=false;
            outTree(i).IsVisible='on';
            outTree(i).BusObjectName='';

            if flag(i)==0

                outTreeRootIndex=outTreeRootIndex+1;
                outTree(i).IsRoot=true;
                if~isempty(outTree(i).ChildrenIndex)

                    outTreeRootBusIndex=outTreeRootBusIndex+1;

                    if outTreeRootBusIndex<=length(outBusObj)
                        outTree(i).BusObjectName=outBusObj{outTreeRootBusIndex};
                    else
                        outTree(i).BusObjectName=outTree(i).Name;
                    end
                end

                if outTreeRootIndex<=length(outVisibility)
                    outTree(i).IsVisible=logic2str(logical(outVisibility{outTreeRootIndex}));
                end
            end
        end



        outTreeIndices=block.FMUOutputCompleteOrderedIndex;


        outListType=cell(1,length(outTreeIndices));
        outListEnum=cell(1,length(outTreeIndices));
        for i=1:length(outTreeIndices)
            outListType{i}='edit';
            outListEnum{i}={};
        end


        internalTree=block.FMUInternalStructure;
        internalTreeRootIndex=0;
        internalTreeRootBusIndex=0;
        internalVisibility=block.FMUInternalNameVisibilityList;
        internalBusObj=block.FMUInternalBusObjectName;
        flag=zeros(1,length(internalTree));
        for i=1:length(internalTree)



            internalTree(i).IsRoot=false;
            internalTree(i).IsVisible='off';
            internalTree(i).BusObjectName='';



            if flag(i)==0

                internalTreeRootIndex=internalTreeRootIndex+1;
                internalTree(i).IsRoot=true;
                if~isempty(internalTree(i).ChildrenIndex)

                    internalTreeRootBusIndex=internalTreeRootBusIndex+1;

                    if internalTreeRootBusIndex<=length(internalBusObj)
                        internalTree(i).BusObjectName=outBusObj{internalTreeRootBusIndex};
                    else
                        internalTree(i).BusObjectName=internalTree(i).Name;
                    end
                end

                if internalTreeRootIndex<=length(internalVisibility)
                    internalTree(i).IsVisible=logic2str(logical(internalVisibility{internalTreeRootIndex}));
                end
            end
        end

        internalTreeIndices=block.FMUInternalCompleteOrderedIndex;


        internalListType=cell(1,length(internalTreeIndices));
        internalListEnum=cell(1,length(internalTreeIndices));
        for i=1:length(internalTreeIndices)
            internalListType{i}='edit';
            internalListEnum{i}={};
        end

        internalMapping=block.FMUInternalMapping;
        if strcmp(internalMapping,'Structured')
            this.DialogData.outputListSource=...
            internal.fmuInterface.spreadSheetSource(...
            this,...
            outListType,...
            outListEnum,...
            outTree,...
            outTreeIndices,...
            scalarVariableList,...
            false,{},{},{},{},false);

            internalListSource=internal.fmuInterface.spreadSheetSource(...
            this,...
            internalListType,...
            internalListEnum,...
            internalTree,...
            internalTreeIndices,...
            scalarVariableList,...
            false,internalListType,internalListEnum,internalTree,internalTreeIndices,true);
            this.DialogData.outputListSource.internalValueWidgetType=internalListSource.valueWidgetType;
            this.DialogData.outputListSource.internalValueWidgetOptions=internalListSource.valueWidgetOptions;
            this.DialogData.outputListSource.internalValueStructure=internalListSource.valueStructure;
            this.DialogData.outputListSource.internalValueScalarIndex=internalListSource.valueScalarIndex;
            this.DialogData.outputListSource.dlgSource=internalListSource.dlgSource;
            localNode=internal.fmuInterface.spreadSheetStruct(internalListSource,0,...
            DAStudio.message('FMUBlock:FMU:InternalVariables'),'',internalListSource.spreadRowObjs,true);

            this.DialogData.outputListSource.spreadRowObjs=[this.DialogData.outputListSource.spreadRowObjs,localNode];
        else
            this.DialogData.outputListSource=...
            internal.fmuInterface.spreadSheetSource(...
            this,...
            outListType,...
            outListEnum,...
            outTree,...
            outTreeIndices,...
            scalarVariableList,...
            false,...
            internalListType,...
            internalListEnum,...
            internalTree,...
            internalTreeIndices,...
            false);
        end
    end
end


function result=str2logic(str)


    if strcmp(str,'on')
        result=true;
    else
        result=false;
    end

end

function val=logic2str(logicVal)
    if logicVal
        val='on';
    else
        val='off';
    end
end
