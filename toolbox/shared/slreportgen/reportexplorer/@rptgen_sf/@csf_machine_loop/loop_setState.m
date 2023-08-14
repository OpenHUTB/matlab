function ok=loop_setState(this,currObj,objName)%#ok







    ok=false;

    if(~isempty(currObj)&&ishandle(currObj))

        adSF=rptgen_sf.appdata_sf;
        adSF.CurrentMachine=currObj;
        adSF.CurrentChart=[];
        adSF.CurrentState=[];
        adSF.CurrentObject=currObj;
        adSF.Context='Machine';


        adSL=rptgen_sl.appdata_sl;
        if isempty(adSL.CurrentModel)
            adSL.CurrentModel=adSF.CurrentMachine.Name;
        end

        ok=true;
    end
