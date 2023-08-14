classdef(Hidden=true)FMUSpreadSheetItem<handle&matlab.mixin.Heterogeneous
    properties
        dlgSource;
        dataSource;
        isTopLevel;

        FMUDialogColumn1=DAStudio.message('FMUBlock:FMU:Parameter');
        FMUDialogColumn2=DAStudio.message('FMUBlock:FMU:Value');
        FMUDialogColumn3=DAStudio.message('FMUBlock:FMU:Unit');
        FMUDialogColumn4=DAStudio.message('FMUBlock:FMU:Description');
    end

    methods

        function this=FMUSpreadSheetItem
        end

        function updateValueString(obj,propValue,rowValueStringPos)


            assert(~isempty(rowValueStringPos));

            if length(rowValueStringPos)==1

                obj.dataSource.valueString{rowValueStringPos(1)}=propValue;
            else
                assert(~obj.isTopLevel);




                strRange=obj.dataSource.valueStructurePosition{rowValueStringPos(1)}{rowValueStringPos(2)};

                strLenChange=length(propValue)-(strRange(2)-strRange(1)+1);

                obj.dataSource.valueString{rowValueStringPos(1)}=[obj.dataSource.valueString{rowValueStringPos(1)}(1:strRange(1)-1),propValue,obj.dataSource.valueString{rowValueStringPos(1)}(strRange(2)+1:end)];

                obj.dataSource.valueStructurePosition{rowValueStringPos(1)}{rowValueStringPos(2)}(2)=obj.dataSource.valueStructurePosition{rowValueStringPos(1)}{rowValueStringPos(2)}(2)+strLenChange;
                for i=rowValueStringPos(2)+1:length(obj.dataSource.valueStructurePosition{rowValueStringPos(1)})
                    obj.dataSource.valueStructurePosition{rowValueStringPos(1)}{i}=obj.dataSource.valueStructurePosition{rowValueStringPos(1)}{i}+strLenChange;
                end
            end


            obj.dlgSource.DialogData.ChangeList(rowValueStringPos(1))=1;
            obj.dlgSource.DialogData.ListValue{rowValueStringPos(1)}=obj.dataSource.valueString{rowValueStringPos(1)};
        end

    end
end
