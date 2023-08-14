function ok=loop_setState(this,currObj,objName)%#ok







    ok=false;

    if(~isempty(currObj)&&ishandle(currObj))

        adSF=rptgen_sf.appdata_sf;
        adSF.CurrentState=currObj;
        adSF.CurrentObject=currObj;


        adSF.Context='State';

        adSL=rptgen_sl.appdata_sl;
        if isempty(adSL.CurrentModel)
            adSL.CurrentModel=adSF.CurrentMachine.Name;
        end

        ok=true;
    end