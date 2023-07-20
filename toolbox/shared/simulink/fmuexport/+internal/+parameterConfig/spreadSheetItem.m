classdef(Hidden=true)spreadSheetItem<handle&matlab.mixin.Heterogeneous
    properties
        dataSource;
        isTopLevel;

        paramDialogColumn1=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterName');
        paramDialogColumn2=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterExported');
        paramDialogColumn3=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterSource');
        paramDialogColumn4=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterDescription');
        paramDialogColumn5=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterUnit');
        paramDialogColumn6=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterExportedName');
    end

    methods

        function this=spreadSheetItem
        end

        function updateValueTable(obj,propName,propValue,rowPos1,rowPos2)



            assert(~isempty(rowPos1));
            switch(propName)
            case obj.paramDialogColumn2
                obj.dataSource.valueStructure(rowPos2).exported=logicstr2str(propValue);
            case obj.paramDialogColumn6
                names={obj.dataSource.valueStructure.exportedName};

                if isempty(intersect(names,propValue))

                    obj.dataSource.valueStructure(rowPos2).exportedName=propValue;
                else

                    warnID='FMUExport:FMU:FMU2ExpCSParameterNameAlreadyExist';
                    warndlg(DAStudio.message(warnID,propValue));
                end
            otherwise
                assert(false,'Unexpected type');
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

