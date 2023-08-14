function dataHeaderName=getPeripheralDataHdrName(hCS,peripheralType)





    coProcessorPattern='\(\w*\W*\S*';

    hardwareBoard=strtrim(regexprep(get_param(hCS,'HardwareBoard'),coProcessorPattern,''));
    boardName=lower(matlab.lang.makeValidName(hardwareBoard));
    dataHeaderName=sprintf('%s_%s_data.h',boardName,peripheralType);
end


