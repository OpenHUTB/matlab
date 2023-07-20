function postEmit(this,context)








    oldConn=context('connectivity_context');
    hdlconnectivity.genConnectivity(oldConn);


    hdlsetparameter('multiplier_input_pipeline',context('multiplier_input_pipeline'));
    hdlsetparameter('multiplier_output_pipeline',context('multiplier_output_pipeline'));


