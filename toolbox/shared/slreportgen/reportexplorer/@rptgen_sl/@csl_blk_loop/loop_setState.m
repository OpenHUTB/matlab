function ok=loop_setState(~,currObj,~)





    rptgen_sl.instantiateLinkedBlock(currObj);


    find_system(currObj,'SearchDepth',0);

    adsl=rptgen_sl.appdata_sl;

    if isempty(adsl.CurrentModel)
        adsl.CurrentModel=bdroot(currObj);
    end

    adsl.Context='Block';
    adsl.CurrentBlock=currObj;

    ok=true;
