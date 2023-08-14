function inwl=set_inwl(this,inwl)





    try
        this.privinwl=inwl;
    catch
        error(message('dsp:quantum:fixeddelayfilterq:set_inwl:MustBePosInteger'));
    end


    send_quantizestates(this);


    inwl=[];


