function status=isPortOverClked(this,snk)


    if this.clkrate>1
        status=true;
    else
        assert(this.minPortSampleTime>0);
        if isa(snk,'hdlcoder.signal')

            sigRate=snk.SimulinkRate;
        else

            sigRate=snk.HDLSampleTime;
        end

        if sigRate>this.minPortSampleTime
            status=true;
        else
            status=false;
        end
    end


