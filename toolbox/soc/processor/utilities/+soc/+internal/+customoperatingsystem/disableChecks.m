function ret=disableChecks(inputArg)




    ret=true;
    isInArgModel=isequal(exist(inputArg,'file'),4);
    if isInArgModel
        data=codertarget.data.getData(getActiveConfigSet(inputArg));
        thisBoard=data.TargetHardware;
    else
        thisBoard=inputArg;
    end
    isSupportedBoard=ismember(thisBoard,soc.internal.customoperatingsystem.getHardwareBoards);

    if~isSupportedBoard

        disp('### Skip operating system verification ...')
        return;
    end
    osCustomizerObj=createOSCustomizationObject(thisBoard);
    disableChecks(osCustomizerObj);




