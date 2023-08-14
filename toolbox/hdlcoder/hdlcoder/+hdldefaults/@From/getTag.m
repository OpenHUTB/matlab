function[tag,scope]=getTag(this,hC)





    tag='';
    slh=hC.SimulinkHandle;

    if slh>0
        tag=get_param(slh,'GotoTag');
        scope=['ntwk_',get_param(slh,'TagVisibility')];
    end
