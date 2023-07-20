













































classdef AvxCompare<int32
    enumeration
        CMP_EQ_OQ(0x00)
        CMP_LT_OS(0x01)
        CMP_LE_OS(0x02)
        CMP_UNORD_Q(0x03)
        CMP_NEQ_UQ(0x04)
        CMP_NLT_US(0x05)
        CMP_NLE_US(0x06)
        CMP_ORD_Q(0x07)
        CMP_EQ_UQ(0x08)
        CMP_NGE_US(0x09)
        CMP_NGT_US(0x0a)
        CMP_FALSE_OQ(0x0b)
        CMP_NEQ_OQ(0x0c)
        CMP_GE_OS(0x0d)
        CMP_GT_OS(0x0e)
        CMP_TRUE_UQ(0x0f)
        CMP_EQ_OS(0x10)
        CMP_LT_OQ(0x11)
        CMP_LE_OQ(0x12)
        CMP_UNORD_S(0x13)
        CMP_NEQ_US(0x14)
        CMP_NLT_UQ(0x15)
        CMP_NLE_UQ(0x16)
        CMP_ORD_S(0x17)
        CMP_EQ_US(0x18)
        CMP_NGE_UQ(0x19)
        CMP_NGT_UQ(0x1a)
        CMP_FALSE_OS(0x1b)
        CMP_NEQ_OS(0x1c)
        CMP_GE_OQ(0x1d)
        CMP_GT_OQ(0x1e)
        CMP_TRUE_US(0x1f)
    end

    methods(Static)
        function hEnt=createEntry(key,implName,simdType,outType,compare)
            hEnt=RTW.TflCFunctionEntry;
            hEnt.setTflCFunctionEntryParameters('Key',key);

            hEnt.addConceptualArg(RTW.SimdHelper.simdArg('y1',outType,'RTW_IO_OUTPUT'));
            hEnt.addConceptualArg(RTW.SimdHelper.simdArg('u1',simdType,'RTW_IO_INPUT'));
            hEnt.addConceptualArg(RTW.SimdHelper.simdArg('u2',simdType,'RTW_IO_INPUT'));

            impl=RTW.SimdImplementation;
            impl.Name=implName;

            impl.Return=RTW.SimdHelper.simdArg('y1',outType,'RTW_IO_OUTPUT');
            impl.addArgument(RTW.SimdHelper.simdArg('u1',simdType,'RTW_IO_INPUT'));
            impl.addArgument(RTW.SimdHelper.simdArg('u2',simdType,'RTW_IO_INPUT'));

            constant=hEnt.createTflArgFromParamVals('RTW.TflArgNumericConstant',...
            'Name',string(compare),...
            'IOType','RTW_IO_INPUT',...
            'IsSigned',true,...
            'WordLength',8,...
            'FractionLength',0,...
            'Value',int32(compare));
            impl.addArgument(constant);

            hEnt.Implementation=impl;
        end
    end
end

