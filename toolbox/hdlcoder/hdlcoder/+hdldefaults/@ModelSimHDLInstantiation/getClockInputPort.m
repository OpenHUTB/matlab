function name=getClockInputPort(this,hC)





    clockName=this.getImplParams('ClockInputPort');

    addClock=this.getImplParams('AddClockPort');

    addClock=isempty(addClock)||strcmpi(addClock,'on');

    if addClock


        if isempty(clockName)
            bfp=hC.SimulinkHandle;
            blkobj=get_param(bfp,'Object');
            clkpaths=get(blkobj,'ClockPaths');
            clkmodes=this.hdlslResolve('ClockModes',bfp);

            if length(clkmodes)==1
                [~,blkclkname]=this.mtidehierarchyname(clkpaths);
            else
                clkpathsep=find(clkpaths==';');
                if isempty(clkpathsep)
                    blkclkname='';
                else
                    [~,blkclkname]=this.mtidehierarchyname(clkpaths(1:(clkpathsep(1)-1)));
                end
            end

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

