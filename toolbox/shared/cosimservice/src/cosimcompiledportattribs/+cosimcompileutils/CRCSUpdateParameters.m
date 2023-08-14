
function updateStruct=CRCSUpdateParameters(modelName,dfFlagStr,commPortToSlave,commPortFromSlave,maxSigWidth,startTime,stopTime)
    updateStruct=struct('isError',false,'errorMsg','');
    try

        if contains(dfFlagStr,'true')&&contains(dfFlagStr,'false')
            ME=MException('CoSimService:Blocks:MixedSignalNotSupported',DAStudio.message('CoSimService:Blocks:MixedSignalNotSupported',modelName));
            throw(ME)
        end
        wrapperModel=['cosim__wrapper__',modelName];

        recBlockName='sfcnRec';
        transBlockName='sfcnTrans';


        transmitBlock=[wrapperModel,'/',transBlockName];

        sfcnParamStr=get_param(transmitBlock,'Parameters');
        sfcnParamList=regexp(sfcnParamStr,',(?![^\(\[\{]*[\]\)\}])','split');
        sfcnParamList{3}=['uint16([',num2str(commPortToSlave),',',num2str(commPortFromSlave),'])'];
        sfcnParamList{4}=['uint32(',num2str(maxSigWidth),')'];
        sfcnParamNewStr=strjoin(sfcnParamList,',');


        set_param(transmitBlock,'Parameters',sfcnParamNewStr);


        recBlock=[wrapperModel,'/',recBlockName];

        sfcnParamStr=get_param(recBlock,'Parameters');
        sfcnParamList=regexp(sfcnParamStr,',(?![^\(\[\{]*[\]\)\}])','split');
        sfcnParamList{3}=['uint16([',num2str(commPortToSlave),',',num2str(commPortFromSlave),'])'];
        sfcnParamList{4}=['uint32(',num2str(maxSigWidth),')'];
        sfcnParamList{end}=dfFlagStr;
        sfcnParamNewStr=strjoin(sfcnParamList,',');

        set_param(recBlock,'Parameters',sfcnParamNewStr);




        set_param(wrapperModel,'StopTime',['hex2num(''',stopTime,''')']);
    catch eCause
        updateStruct.isError=true;
        if ismethod(eCause,'json')
            updateStruct.errorMsg=eCause.json;
        else
            updateStruct.errorMsg=jsonencode(eCause);
        end
    end
end
