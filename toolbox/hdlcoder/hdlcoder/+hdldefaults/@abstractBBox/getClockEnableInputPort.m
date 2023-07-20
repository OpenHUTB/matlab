function name=getClockEnableInputPort(this,~)



    addClockEnable=this.getImplParams('AddClockEnablePort');

    addClockEnable=isempty(addClockEnable)||strcmpi(addClockEnable,'on');

    if addClockEnable
        clockEnableName=this.getImplParams('ClockEnableInputPort');
        if isempty(clockEnableName)


            paramInfoMap=this.getImplParamInfo;
            paramInfo=paramInfoMap('clockenableinputport');
            name=paramInfo.DefaultValue;
        else
            name=hdllegalnamersvd(clockEnableName);
        end
    else
        name='';
    end


