function ok=loop_setState(~,currObj,~)





    adsl=rptgen_sl.appdata_sl;

    if isempty(adsl.CurrentModel)
        adsl.CurrentModel=get_param(bdroot(currObj),'Name');
    end

    adsl.Context='Annotation';
    adsl.CurrentAnnotation=currObj;

    ok=true;
