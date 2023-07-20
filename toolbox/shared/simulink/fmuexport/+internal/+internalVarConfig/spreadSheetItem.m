classdef(Hidden=true)spreadSheetItem<handle&matlab.mixin.Heterogeneous




    properties
        dataSource;
        isTopLevel;

        ivDialogColumn1=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVName');
        ivDialogColumn2=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVExported');
        ivDialogColumn3=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVSource');
        ivDialogColumn4=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVDescription');
        ivDialogColumn5=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVUnit');
        ivDialogColumn6=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVExportedName');
        ivDialogColumn7=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVDatatype');
        ivDialogColumn8=DAStudio.message('FMUExport:FMU:FMU2ExpCSIVExportedDatatype');
    end

    methods

        function this=spreadSheetItem
        end

        function updateValueTable(obj,propName,propValue,rowPos1,rowPos2)



            assert(~isempty(rowPos1));
            switch(propName)
            case obj.ivDialogColumn2
                obj.dataSource.valueStructure(rowPos2).exported=logicstr2str(propValue);
            case obj.ivDialogColumn6
                names={obj.dataSource.valueStructure.exportedName};

                if isempty(intersect(names,propValue))

                    obj.dataSource.valueStructure(rowPos2).exportedName=propValue;
                else

                    warnID='FMUExport:FMU:FMU2ExpCSIVNameAlreadyExist';
                    warndlg(DAStudio.message(warnID,propValue));
                end
            otherwise
                assert(false,'Unexpected type');
            end
        end

        function hiliteFcn(obj)

            Idxs=obj.dataSource.valueScalarIndex{obj.rowPos1(1)};
            if numel(Idxs)==1
                blkPath=obj.dataSource.valueScalarTable(Idxs).blkPath;
            else
                blkPath=obj.dataSource.valueScalarTable(Idxs(1)).blkPath;
            end
            if strcmp(obj.rowSource,'Logged Signal')||strcmp(obj.rowSource,'Test Point')

                tmp=split(blkPath,':');
                blk=tmp{1};
                port=str2num(tmp{2});
                ph=get_param(blk,'PortHandles');
                oph=ph.Outport;
                line=get_param(oph(port),'line');
                hilite_system(line,'find');
                obj.dataSource.highlights=[obj.dataSource.highlights,line];
            else

                bh=get_param(blkPath,'Handle');
                hilite_system(bh,'find');
                obj.dataSource.highlights=[obj.dataSource.highlights,bh];
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

