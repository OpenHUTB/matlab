function auxData=simrfV2_getauxdata(block)





    auxData=get_param([block,'/AuxData'],'UserData');

    if isempty(auxData)
        auxData.Version=2.0;
        auxData.Ckt=[];


        simrfV2Constants=simrfV2_constants();
        auxData.Plot=simrfV2Constants.Plot;


        auxData.Spars=[];


        set_param([block,'/AuxData'],'UserData',auxData);

    end

end