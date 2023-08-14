function bpName=getBlockPropertyFromTag(~,tag)





    persistent enumMap;

    if isempty(enumMap)
        enumMap=containers.Map;

        enumMap('Tfldesigner_IntrpMethod_AlgoParam')='InterpMethod';
        enumMap('Tfldesigner_ExtrpMethod_AlgoParam')='ExtrapMethod';
        enumMap('Tfldesigner_IndexSearchMethod')='IndexSearchMethod';
        enumMap('Tfldesigner_RemoveProtection')='RemoveProtectionInput';
        enumMap('Tfldesigner_RemoveProtectionIndex')='RemoveProtectionIndex';
        enumMap('Tfldesigner_SupportTunableTable')='SupportTunableTableSize';
        enumMap('Tfldesigner_TableDimension')='NumberOfTableDimensions';
        enumMap('Tfldesigner_InputSelectObjectTable')='InputsSelectThisObjectFromTable';
        enumMap('Tfldesigner_UseLastTableValue')='UseLastTableValue';
        enumMap('Tfldesigner_ValidIndexReachLast')='ValidIndexMayReachLast';
        enumMap('Tfldesigner_UseLastBreakpoint')='UseLastBreakpoint';
        enumMap('Tfldesigner_BeginIndexSearchUsingPreviousIndexResult')='BeginIndexSearchUsingPreviousIndexResult';
        enumMap('Tfldesigner_RoundMethod')='RndMeth';
        enumMap('Tfldesigner_SatMethod')='SaturateOnIntegerOverflow';
        enumMap('Tfldesigner_UseRowMajorAlgorithm')='UseRowMajorAlgorithm';
        enumMap('Tfldesigner_AngleUnit_AlgoParam')='AngleUnit';
    end


    if isKey(enumMap,tag)
        bpName=enumMap(tag);
    else
        bpName=tag;
    end
