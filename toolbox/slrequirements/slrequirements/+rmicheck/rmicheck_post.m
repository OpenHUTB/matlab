function[success,message]=rmicheck_post(system)%#ok<INUSD>










    success=rmi.mdlAdvState('cleanup');

    if success==0
        message='mdlAdvState cleanup failed';
    else
        message='';
    end

