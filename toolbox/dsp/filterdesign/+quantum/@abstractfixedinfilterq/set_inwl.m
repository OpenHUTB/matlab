function inwl=set_inwl(this,inwl)





    try
        this.privinwl=inwl;
    catch
        error(message('dsp:quantum:abstractfixedinfilterq:set_inwl:MustBeInteger'));
    end


    inwl=[];


