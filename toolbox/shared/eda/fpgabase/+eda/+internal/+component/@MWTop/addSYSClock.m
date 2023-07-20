function addSYSClock(this)

    if strcmpi(this.Partition.Device.SYSCLK.Type,'DIFF')
        this.addprop('sysclk_p');
        this.addprop('sysclk_n');
        this.sysclk_p=eda.internal.component.ClockPort;
        this.sysclk_n=eda.internal.component.ClockPort;
    else
        this.addprop('sysclk');
        this.sysclk=eda.internal.component.ClockPort;
    end
end