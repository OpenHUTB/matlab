function schema


    schema.package('hdllinkddg');

    if isempty(findtype('CoSimClockTypeEnum'))
        schema.EnumType('CoSimClockTypeEnum',{'Falling','Rising'},[1,2]);
    end

    if isempty(findtype('CoSimConnectionMethodEnum'))
        schema.EnumType('CoSimConnectionMethodEnum',{'Socket','Shared Memory'},[0,1]);
    end

    if isempty(findtype('CoSimTimingModeEnum'))
        schema.EnumType('CoSimTimingModeEnum',{'Tick','fs','ps','ns','us','ms','s'});
    end

    if isempty(findtype('PreRunTimeUnitEnum'))
        schema.EnumType('PreRunTimeUnitEnum',{'fs','ps','ns','us','ms','s'});
    end

    if isempty(findtype('CoSimPortTableColEnum'))
        schema.EnumType('CoSimPortTableColEnum',{'path','ioMode','sampleTime','datatype','sign','fracLength'});
    end

    if isempty(findtype('CoSimClockTableColEnum'))
        schema.EnumType('CoSimClockTableColEnum',{'path','edge','period'});
    end

    if isempty(findtype('ToVcdHdlScaleEnum'))
        schema.EnumType('ToVcdHdlScaleEnum',{'1','10','100'});
    end

    if isempty(findtype('ToVcdHdlTickModeEnum'))
        schema.EnumType('ToVcdHdlTickModeEnum',{'fs','ps','ns','us','ms','s'});
    end

    if isempty(findtype('PreRunTimeUnitEnum'))
        schema.EnumType('PreRunTimeUnitEnum',{'fs','ps','ns','us','ms','s'});
    end

    if isempty(findtype('AutoTimeScaleEnum'))
        schema.EnumType('AutoTimeScaleEnum',{'Determine the timescale when the simulation starts','Timescale:'});
    end

