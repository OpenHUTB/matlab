function dutEnb=ClkEnbRoute(this,dut_clkenb)

    if~isempty(this.buildInfo.getClockPortName)
        if strcmpi(this.buildInfo.ClockEnableAssertedLevel,'Active-high')
            dutEnb=dut_clkenb;%#ok<*NASGU>
        else
            dutEnb=this.signal('Name','dutEnb','FiType','boolean');
            this.assign('~ dut_clkenb',dutEnb);
        end
    else
        dutEnb='';
    end
end