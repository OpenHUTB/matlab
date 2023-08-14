function dutReset=ResetRoute(this)

    if~isempty(this.buildInfo.getClockPortName)
        dutReset=this.signal('Name','dutReset','FiType','boolean');
        if strcmpi(this.buildInfo.ResetAssertedLevel,'Active-high')
            this.assign('bitor(reset, dut_softReset)',dutReset);
        else
            dutRst_tmp=this.signal('Name','dutRst_tmp','FiType','boolean');
            this.assign('bitor(reset, dut_softReset)',dutRst_tmp);
            this.assign('~dutRst_tmp',dutReset);
        end
    else
        dutReset='';
    end
end