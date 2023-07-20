function demuxComp=getCascadeController2(this,hN,hInSignals,hOutSignals,count_limit,mode_pre_in,name)



    if(nargin<7)
        name='cascade_controller';
    end

    ipf='hdleml_cascade_controller2';
    bmp={count_limit,mode_pre_in};

    demuxComp=this.getCgirCompForEml(hN,hInSignals,hOutSignals,name,ipf,bmp);

end


