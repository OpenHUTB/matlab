function outdata=hdlgetfilterdata(filterobj,indata)
    filtersysobj=hdlgetparameter('filter_systemobject');
    if isempty(filtersysobj)

        outdata=filter(filterobj,indata);
    else
        indata=reframeData(filtersysobj,indata);

        filtersysobj_copy=clone(filtersysobj);
        release(filtersysobj_copy);
        reset(filtersysobj_copy);
        if isa(filtersysobj_copy,'dsp.VariableFractionalDelay')
            fdelay_type=hdlgetparameter('fracdelay_datatype');
            fdelay=fi(0,'numerictype',fdelay_type);
            outdatasysobj=filtersysobj_copy(indata,fdelay);
        else
            outdatasysobj=filtersysobj_copy(indata);
        end



        outdata=outdatasysobj;
    end

end


function outdata=reframeData(filtersysobj,indata)

    try
        dfactor=filtersysobj.DecimationFactor;
    catch me %#ok<NASGU>

        dfactor=1;
    end

    lenindata=length(indata);
    extraSamples=mod(lenindata,dfactor);
    outlendata=lenindata-extraSamples;
    indecimdata=indata(1:outlendata);

    outdata=reshape(indecimdata,outlendata,1);

end

