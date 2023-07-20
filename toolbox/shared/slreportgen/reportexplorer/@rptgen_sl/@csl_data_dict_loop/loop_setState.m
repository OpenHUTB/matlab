function ok=loop_setState(~,currentObject,~)






    adSL=rptgen_sl.appdata_sl;

    adSL.CurrentDataDictionary=currentObject;
    adSL.Context='DataDictionary';

    ok=true;
