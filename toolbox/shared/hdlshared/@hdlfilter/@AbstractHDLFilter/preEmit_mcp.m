function context=preEmit_mcp(this,context)












    gConnOld=hdlconnectivity.genConnectivity;
    if gConnOld,
        hCD=hdlconnectivity.getConnectivityDirector;
        hCD.setCurrentAdapter('FDHC');

        currpath=hCD.getCurrentHDLPath;


        hCD.setCurrentHDLPath(currpath,...
        hdlgetparameter('Instance_Prefix'),hdlgetparameter('filter_name'));


        context('currentHDLPath')=currpath;
    end


    pipe=this.isPipelineSupported;

    context('multiplier_input_pipeline')=hdlgetparameter('multiplier_input_pipeline');
    context('multiplier_output_pipeline')=hdlgetparameter('multiplier_output_pipeline');

    if~pipe.multinput
        hdlsetparameter('multiplier_input_pipeline',0);
    end

    if~pipe.multoutput
        hdlsetparameter('multiplier_output_pipeline',0);
    end


