function name=getClockInputPort(this,~)



    addClock=this.getImplParams('AddClockPort');

    addClock=isempty(addClock)||strcmpi(addClock,'on');

    if addClock
        clockName=this.getImplParams('ClockInputPort');
        if isempty(clockName)

            paramInfoMap=this.getImplParamInfo;
            paramInfo=paramInfoMap('clockinputport');
            name=paramInfo.DefaultValue;
        else
            name=hdllegalnamersvd(clockName);
        end
    else
        name='';
    end


