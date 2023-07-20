function result=ec_get_placement_rules(obj,attri,packageCSCDef,desiredScope)




















    result=[];
    result.definitionEnable=0;
    result.referenceEnable=0;
    result.poundDefine=0;
    result.placementEnable=0;
    result.HeaderFile='';
    result.mode='None';









    switch(obj.CoderInfo.StorageClass)
    case 'Custom'
        cscdef=ec_get_cscdef(obj,packageCSCDef);
        if cscdef.isAccessMethod
            result.mode='None';
            result.HeaderFile='';
        else
            if~cscdef.IsGrouped
                dataScope=ec_get_ungroupedcsc_prop_value(attri,cscdef,'DataScope');
                dataInit=ec_get_ungroupedcsc_prop_value(attri,cscdef,'DataInit');
                if nargin==4
                    dataScope=desiredScope;
                end
                switch(dataScope)
                case 'Imported'
                    result.HeaderFile=ec_get_ungroupedcsc_prop_value(attri,cscdef,'HeaderFile');
                    result.mode='Include';
                case 'Exported'
                    result.HeaderFile=ec_get_ungroupedcsc_prop_value(attri,cscdef,'HeaderFile');

                    if~strcmp(dataInit,'Macro')
                        result.mode='Data';
                    else

                        result.mode='#Define';
                    end
                otherwise
                    result.mode='None';
                end

            else
                result.mode='None';
            end
        end
    case 'ExportedGlobal'
        result.mode='Data';
        result.HeaderFile='';
    case 'Auto'
        result.mode='None';
        result.HeaderFile='';
    case{'ImportedExtern','ImportedExternPointer'}
        result.mode='Include';
        result.HeaderFile='';
    otherwise
        result.mode='None';
    end


