function hdlsetparameter(param,newvalue)





    if hdlisfiltercoder

        hdl_parameters=PersistentHDLPropSet;
        hdl_parameters.INI.setProp(param,newvalue);

    else

        hDriver=hdlcurrentdriver;
        hDriver.setParameter(param,newvalue);

    end
