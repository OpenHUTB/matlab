function idComp=getCascadeControllerIndex(this,hN,hInSignals,hOutSignals,decomposeStage,isStartStage,name)



    if(nargin<7)
        name='cascade_controller_index';
    end

    ipf='hdleml_cascade_index';
    bmp={decomposeStage,isStartStage};

    idComp=this.getCgirCompForEml(hN,hInSignals,hOutSignals,name,ipf,bmp);

end


