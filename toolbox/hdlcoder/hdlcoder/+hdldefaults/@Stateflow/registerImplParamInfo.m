function registerImplParamInfo(this)

    registerImplParamInfo@hdlimplbase.SFBase(this)
    if strcmpi(hdlfeature('EnableClockDrivenOutput'),'on')
        this.addImplParamInfo('ClockDrivenOutput','ENUM','off',{'on','off'});
    end
end