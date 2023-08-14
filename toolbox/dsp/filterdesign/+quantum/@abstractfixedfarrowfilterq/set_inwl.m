function inwl=set_inwl(this,inwl)





    try
        this.privinwl=inwl;
    catch
        error(message('dsp:quantum:abstractfixedfarrowfilterq:set_inwl:MustBePosInteger'));
    end


    send_quantizestates(this);


    updateinternalsettings(this);


    inwl=[];


