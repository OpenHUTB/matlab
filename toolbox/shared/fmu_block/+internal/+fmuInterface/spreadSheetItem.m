classdef(Hidden=true)spreadSheetItem<handle&matlab.mixin.Heterogeneous
    properties
        dlgSource;
        dataSource;
        isTopLevel;
        mIisInternal;

        FMUDialogColumn1=DAStudio.message('FMUBlock:FMU:VarName');
        FMUDialogColumn2=DAStudio.message('FMUBlock:FMU:VarVisibility');
        FMUDialogColumn3=DAStudio.message('FMUBlock:FMU:VarStart');
        FMUDialogColumn4=DAStudio.message('FMUBlock:FMU:VarUnit');
        FMUDialogColumn5=DAStudio.message('FMUBlock:FMU:VarBusObjectName');
    end

    methods

        function this=spreadSheetItem
            this.mIisInternal=false;
        end

        function setInternalItem(obj,isInternal)
            obj.mIisInternal=isInternal;
        end

        function updateValueTable(obj,propName,propValue,rowPos1,rowPos2)



            assert(~isempty(rowPos1));

            if obj.dataSource.isInputTab
                switch(propName)
                case obj.FMUDialogColumn2
                    obj.dlgSource.DialogData.InputVisibilityChanged=true;
                    obj.dlgSource.DialogData.inputListSource.valueStructure(rowPos2).IsVisible=logicstr2str(propValue);

                    childrenIdxs=obj.dlgSource.DialogData.inputListSource.valueStructure(rowPos2).ChildrenIndex;
                    children=findChildrenIdxs(obj,childrenIdxs);
                    for i=children
                        obj.dlgSource.DialogData.inputListSource.valueStructure(i).IsVisible=logicstr2str(propValue);
                    end
                case obj.FMUDialogColumn3
                    obj.dlgSource.DialogData.InputStartValueChanged=true;
                    Idxs=obj.dlgSource.DialogData.inputListSource.valueScalarIndex{rowPos1(1)};
                    if numel(Idxs)==1
                        defaultStartStr=obj.dlgSource.DialogData.inputListSource.valueScalarTable(Idxs).start;
                        varNameStr=obj.dlgSource.DialogData.inputListSource.valueScalarTable(Idxs).name;
                    else
                        defaultStartStr=obj.dlgSource.DialogData.inputListSource.valueScalarTable(Idxs(rowPos1(2))).start;
                        varNameStr=obj.dlgSource.DialogData.inputListSource.valueScalarTable(Idxs(rowPos1(2))).name;
                    end


                    if~strcmp(propValue,defaultStartStr)
                        obj.dlgSource.DialogData.InputAlteredNameStartMap(varNameStr)=propValue;
                    else
                        if obj.dlgSource.DialogData.InputAlteredNameStartMap.isKey(varNameStr)
                            obj.dlgSource.DialogData.InputAlteredNameStartMap.remove(varNameStr);
                        end
                    end
                case obj.FMUDialogColumn5
                    obj.dlgSource.DialogData.InputBusObjectNameChanged=true;
                    obj.dlgSource.DialogData.inputListSource.valueStructure(rowPos2).BusObjectName=propValue;
                otherwise
                    assert(false,'Unexpected type');
                end
            else
                switch(propName)
                case obj.FMUDialogColumn2
                    if rowPos2==0
                        obj.dlgSource.DialogData.InternalVisibilityChanged=true;
                        obj.dlgSource.DialogData.outputListSource.internalValueStructure(rowPos1(1)).IsVisible=logicstr2str(propValue);
                    else
                        if obj.mIisInternal
                            obj.dlgSource.DialogData.InternalVisibilityChanged=true;
                            obj.dlgSource.DialogData.outputListSource.internalValueStructure(rowPos2).IsVisible=logicstr2str(propValue);
                            obj.dataSource.internalValueStructure(obj.rowPos2).IsVisible=logicstr2str(propValue);

                            childrenIdxs=obj.dlgSource.DialogData.outputListSource.internalValueStructure(rowPos2).ChildrenIndex;
                            children=findChildrenIdxs(obj,childrenIdxs);
                            for i=children
                                obj.dlgSource.DialogData.outputListSource.internalValueStructure(i).IsVisible=logicstr2str(propValue);
                                obj.dataSource.internalValueStructure(i).IsVisible=logicstr2str(propValue);
                            end
                        else
                            obj.dlgSource.DialogData.OutputVisibilityChanged=true;
                            obj.dlgSource.DialogData.outputListSource.valueStructure(rowPos2).IsVisible=logicstr2str(propValue);

                            childrenIdxs=obj.dlgSource.DialogData.outputListSource.valueStructure(rowPos2).ChildrenIndex;
                            children=findChildrenIdxs(obj,childrenIdxs);
                            for i=children
                                obj.dlgSource.DialogData.outputListSource.valueStructure(i).IsVisible=logicstr2str(propValue);
                            end
                        end
                    end
                case obj.FMUDialogColumn3
                    obj.dlgSource.DialogData.OutputStartValueChanged=true;

                case obj.FMUDialogColumn5
                    if rowPos2==0
                        assert(false,'internal values use flat naming convention');
                    else
                        if obj.mIisInternal
                            obj.dlgSource.DialogData.InternalBusObjectNameChanged=true;
                            obj.dlgSource.DialogData.outputListSource.internalValueStructure(rowPos2).BusObjectName=propValue;
                            obj.dataSource.internalValueStructure(rowPos2).BusObjectName=propValue;
                        else
                            obj.dlgSource.DialogData.OutputBusObjectNameChanged=true;
                            obj.dlgSource.DialogData.outputListSource.valueStructure(rowPos2).BusObjectName=propValue;
                        end
                    end
                otherwise
                    assert(false,'Unexpected type');
                end
            end
        end

        function idxs=findChildrenIdxs(obj,childrenIdxs)
            idxs=childrenIdxs;
            for i=childrenIdxs
                res=obj.dlgSource.DialogData.inputListSource.valueStructure(i).ChildrenIndex;
                if~isempty(res)
                    idxs=[idxs,findChildrenIdxs(obj,res)];
                end
            end
        end

    end
end


function val=logicstr2str(logicVal)
    if strcmp(logicVal,'1')
        val='on';
    else
        val='off';
    end
end

