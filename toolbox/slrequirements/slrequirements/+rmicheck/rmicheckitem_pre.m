function[success,message]=rmicheckitem_pre(system)















    [success,message]=rmicheck.rmicheckdoc_pre(system);
    if~success
        return;
    end


    [success,message]=checkState(system,'word');
    if~success
        return;
    end
    [success,message]=checkState(system,'excel');
end

function[result,msg]=checkState(sys,app)

    msg='';

    app_state=feval('rmi.mdlAdvState',app);
    if app_state==1||app_state==-1




        result=1;
        return;
    end


    has_app=feval('rmi.mdlAdvState',['has_',app],sys);
    if has_app
        [result,msg]=doSetup(app);
    else
        result=1;
    end
end

function[res,err]=doSetup(my_app)

    setup_ok=feval(['rmicom.',my_app,'Rpt'],'setup');
    if setup_ok
        res=1;
        err='';
    else


        res=0;
        err=getString(message('Slvnv:consistency:FailedToSetupMS',upper(my_app)));
    end
end


