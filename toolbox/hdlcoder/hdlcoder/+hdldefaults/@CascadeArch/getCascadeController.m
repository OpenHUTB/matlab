function demuxComp=getCascadeController(this,hN,hInSignals,hOutSignals,decomposeStage,name)



    if(nargin<6)
        name='cascade_controller';
    end

    ipf='hdleml_cascade_controller';
    bmp={decomposeStage};

    demuxComp=this.getCgirCompForEml(hN,hInSignals,hOutSignals,name,ipf,bmp);

end


