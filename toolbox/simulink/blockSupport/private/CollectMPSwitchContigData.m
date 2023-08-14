function Data=CollectMPSwitchContigData(block,h)%#ok<*INUSD>




    dts=get_param(block,'CompiledPortAliasedThruDataTypes');

    Data.CPortDtype=dts.Inport{1};


    Data.isEnumType=false;
    if Simulink.data.isSupportedEnumClass(Data.CPortDtype)
        Data.isEnumType=true;
        [Data.EnumVals,Data.EnumStrs]=enumeration(Data.CPortDtype);
        Data.EnumInts=double(Data.EnumVals);
    end

end
