function context=preEmit(this)






    context=containers.Map;





    gConnOld=hdlconnectivity.genConnectivity(0);
    context('connectivity_context')=gConnOld;


    pipe=this.isPipelineSupported;

    context('multiplier_input_pipeline')=hdlgetparameter('multiplier_input_pipeline');
    context('multiplier_output_pipeline')=hdlgetparameter('multiplier_output_pipeline');

    if~pipe.multinput
        hdlsetparameter('multiplier_input_pipeline',0);
    end

    if~pipe.multoutput
        hdlsetparameter('multiplier_output_pipeline',0);
    end

