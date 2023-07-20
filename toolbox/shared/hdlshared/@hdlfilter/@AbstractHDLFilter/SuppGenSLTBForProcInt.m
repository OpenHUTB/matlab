function[success,msg]=SuppGenSLTBForProcInt(this)






    if strcmpi(this.getHDLParameter('filter_coefficient_source'),'processorinterface')
        success=false;
        msg='Generation of cosimulation model is not supported when ''CoefficientSource'' is set to ''ProcessorInterface''.';
    else
        success=true;
        msg=[];
    end



