function[success,retMsg]=rmicheckdoc_pre(system)









    retMsg='';

    if ispc
        doors_state=rmi.mdlAdvState('doors');
    else

        rmi.mdlAdvState('doors',-1);
        doors_state=-1;
    end

    if doors_state==1||doors_state==-1


        success=1;

    else


        has_doors=rmi.mdlAdvState('has_doors',system);
        if has_doors
            if is_doors_installed()
                [success,retMsg]=checkDoorsLogin();
            else
                success=1;
                rmi.mdlAdvState('doors',-1);
                retMsg='Doors unavailable';

            end
        else
            rmi.mdlAdvState('doors',-1);
            success=1;
        end


    end

    function[out,msg]=checkDoorsLogin()
        if rmidoors.isAppRunning('consistency check')
            rmi.mdlAdvState('doors',1);
            out=1;
            msg='';
        else
            out=0;
            msg='Doors unavailable';






            rmi.mdlAdvState('doors',-1);
        end
