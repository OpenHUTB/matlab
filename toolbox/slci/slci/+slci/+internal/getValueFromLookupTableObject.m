


function out=getValueFromLookupTableObject(lutObj,objName)
    out=containers.Map('KeyType','char','ValueType','any');
    out('IsVarSizeLUT')=(slfeature('VariableSizeLookupTables')==2)...
    &&lutObj.AllowMultipleInstancesOfTypeToHaveDifferentTableBreakpointSizes;
    out('IsParameterArg')=slci.internal.isParameterArgument(bdroot,objName);
    out('BreakPointsSpec')=lutObj.BreakpointsSpecification;
    out('TunableSizeNames')={lutObj.Breakpoints.TunableSizeName};
    out('TableDataType')=resolveDataType(lutObj.Table);
    out('BreakPointsDataType')=resolveDataType(lutObj.Breakpoints(1));
    out('TableFields')=lutObj.Table.FieldName;
    out('BreakpointsFields')={lutObj.Breakpoints.FieldName};
    out('CSCName')=lutObj.CoderInfo.CustomStorageClass;
    if strcmpi(lutObj.CoderInfo.StorageClass,'Model default')
        out("StorageClassType")='SimulinkGlobal';
    else
        out("StorageClassType")=lutObj.CoderInfo.StorageClass;
    end
    out('StorageClassAlias')=lutObj.CoderInfo.Alias;
    out('SupportTunableSize')=lutObj.SupportTunableSize;
    out('Identifier')=lutObj.CoderInfo.Identifier;

end


function out=resolveDataType(obj)
    out=obj.DataType;
    if slcifeature('MdlRefLUTObjSupport')==1&&strcmp(out,'auto')
        out=class(obj.Value);
    end
end
