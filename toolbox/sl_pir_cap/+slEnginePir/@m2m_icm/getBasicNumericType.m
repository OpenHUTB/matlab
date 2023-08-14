function dataType=getBasicNumericType(aThis,aDataTypeStr,aFcnCallerBlk)
    basicTypes={'boolean','double','single','int8','int16','int32','int64','uint8','uint16','uint32','uint64'};
    if isempty(find(strcmpi(aDataTypeStr,basicTypes),1))
        dataType=getBasicTypeFromWorkspace(aThis,aDataTypeStr,aFcnCallerBlk);
    else
        dataType=[aDataTypeStr,'(1)'];
    end
end

function datatype=getBasicTypeFromWorkspace(aThis,aDataType,aFcnCallerBlk)
    currSys=bdroot(aFcnCallerBlk);
    wsHandle=get_param(currSys,'modelworkspace');
    if strfind(aDataType,'Bus: ')==1
        busTypeStr=strrep(aDataType,' ','');
        busTypeStr=busTypeStr(5:end);
        datatype=['SP_',busTypeStr];

        initVal=getInitBusStruct(aThis,aThis.fMdl,busTypeStr);
    else
        datatype=['SP_',aDataType];
        initVal=0;
    end
    if~hasVariable(wsHandle,datatype)
        temp=Simulink.Parameter;
        temp.DataType=aDataType;
        temp.Value=initVal;
        wsHandle.assignin(datatype,temp);
    end
end
