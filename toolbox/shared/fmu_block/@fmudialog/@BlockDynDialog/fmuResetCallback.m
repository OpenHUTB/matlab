function fmuResetCallback(this,dlg,tag)

    block=this.getBlock();
    switch(tag)
    case 'inputList'
        inTree=this.DialogData.inputListSource.valueStructure;
        for i=1:length(inTree)

            this.DialogData.inputListSource.valueStructure(i).IsVisible='on';

            this.DialogData.inputListSource.valueStructure(i).BusObjectName='';
            if~isempty(inTree(i).ChildrenIndex)
                this.DialogData.inputListSource.valueStructure(i).BusObjectName=inTree(i).Name;
            end
        end

        for k=1:length(this.DialogData.inputListSource.valueScalarTable)
            varName=this.DialogData.inputListSource.valueScalarTable(k).name;
            if this.DialogData.InputAlteredNameStartMap.isKey(varName)
                this.DialogData.InputAlteredNameStartMap.remove(varName);
            end
        end

        set_param(block.Handle,'FMUInputVisibility',[]);
        set_param(block.Handle,'FMUInputBusObjectName',[]);
        set_param(block.Handle,'FMUInputAlteredNameStartMap',[]);
        dlg.refreshWidget('inputList');

    case 'outputList'

        outTree=this.DialogData.outputListSource.valueStructure;
        internalList=this.DialogData.outputListSource.internalValueStructure;
        for i=1:length(outTree)

            this.DialogData.outputListSource.valueStructure(i).IsVisible='on';

            this.DialogData.outputListSource.valueStructure(i).BusObjectName='';
            if~isempty(outTree(i).ChildrenIndex)
                this.DialogData.outputListSource.valueStructure(i).BusObjectName=outTree(i).Name;
            end
        end

        for i=1:length(internalList)
            this.DialogData.outputListSource.internalValueStructure(i).IsVisible='off';
        end

        set_param(block.Handle,'FMUOutputVisibility',[]);
        set_param(block.Handle,'FMUOutputBusObjectName',[]);
        set_param(block.Handle,'FMUInternalNameVisibilityList',[]);
        dlg.refreshWidget('outputList');
    end
