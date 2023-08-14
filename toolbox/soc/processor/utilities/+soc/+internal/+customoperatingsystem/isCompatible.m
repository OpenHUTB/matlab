function ret=isCompatible(inputArg,varargin)




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

    osCustomizerObj=createOSCustomizationObject(thisBoard,varargin{:});
    [success,messg]=check(osCustomizerObj);
    if~success
        switch(messg.Identifier)
        case 'soc:os:SkippedOSChecks'
            warning(messg);
        case 'soc:os:RunCustomization'

            disp(getString(messg));
        otherwise
            error(messg);
        end
    end




