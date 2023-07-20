function list=getBuiltInDataTypeList()




    separator=DAStudio.message('SystemArchitecture:PropertyInspector:Separator');

    list={'double','single','int8','uint8','int16','uint16','int32','uint32','int64','uint64','boolean',separator,'fixdt(1,16)','fixdt(1,16,0)','fixdt(1,16,2^0,0)'};


end