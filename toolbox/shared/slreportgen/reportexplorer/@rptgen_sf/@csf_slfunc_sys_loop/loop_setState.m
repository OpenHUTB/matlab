function ok=loop_setState(~,currObj,~)





    rptgen_sl.instantiateLinkedBlock(currObj);

    set_param(0,'CurrentSystem',currObj);



    adsl=rptgen_sl.appdata_sl;

    if isempty(adsl.CurrentModel)
        adsl.CurrentModel=bdroot(currObj);
    end

    adsl.CurrentSystem=currObj;
    adsl.CurrentBlock='';
    adsl.CurrentSignal=-1;
    adsl.Context='System';

    ok=true;