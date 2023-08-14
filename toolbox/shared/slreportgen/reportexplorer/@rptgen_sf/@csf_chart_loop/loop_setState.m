function ok=loop_setState(this,currObj,objName)%#ok







    ok=false;

    if(~isempty(currObj)&&ishandle(currObj))

        currMachine=get(currObj,'Machine');

        if isa(currObj,'Stateflow.LinkChart')
            referenceBlock=get_param(currObj.Path,'referenceblock');
            currObj=find(slroot,'-isa','Stateflow.Chart','Path',referenceBlock);
        end

        adSF=rptgen_sf.appdata_sf;
        adSF.CurrentMachine=currMachine;
        adSF.CurrentChart=currObj;
        adSF.CurrentState=[];
        adSF.CurrentObject=currObj;
        adSF.Context='Chart';

        adSL=rptgen_sl.appdata_sl;
        if isempty(adSL.CurrentModel)
            adSL.CurrentModel=currMachine.Name;
        end

        ok=true;

    end
