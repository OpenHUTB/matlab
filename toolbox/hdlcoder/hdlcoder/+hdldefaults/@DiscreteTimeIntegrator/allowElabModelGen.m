function retval=allowElabModelGen(this,hN,hC)%#ok<INUSL>




    resetType=get_param(hC.SimulinkHandle,'ExternalReset');

    if strcmpi(resetType,'rising')||strcmpi(resetType,'falling')



        retval=true;
    else

        retval=false;
    end
