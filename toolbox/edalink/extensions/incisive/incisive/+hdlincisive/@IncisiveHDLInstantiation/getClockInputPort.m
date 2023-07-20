function name=getClockInputPort(this,hC)




    clockName=this.getImplParams('ClockInputPort');

    addClock=this.getImplParams('AddClockPort');

    addClock=isempty(addClock)||strcmpi(addClock,'on');

    bfp=hC.SimulinkHandle;
    blkobj=get_param(bfp,'Object');
    clkpaths=get(blkobj,'ClockPaths');
    clkmodes=evalin('base',get(blkobj,'ClockModes'));

    if length(clkmodes)==1
        [cpath,blkclkname]=this.incisivedehierarchyname(clkpaths);
    else
        clkpathsep=find(clkpaths==';');
        if isempty(clkpathsep)
            error(message('HDLLink:hdlincisive:clockportnumbermismatch',[get(blkobj,'Path'),'/',get(blkobj,'Name')]));
        end
        [cpath,blkclkname]=this.incisivedehierarchyname(clkpaths(1:(clkpathsep(1)-1)));
    end


    if addClock
        if isempty(clockName)
            if isempty(blkclkname)
                name=hdlgetparameter('clockname');
            else
                name=hdllegalnamersvd(blkclkname);
            end
        else
            name=hdllegalnamersvd(clockName);
        end
    else
        name='';
    end

end