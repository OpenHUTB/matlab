function ok=loop_setState(this,currObj,objName)%#ok






    ok=false;

    if(~isempty(currObj)&&ishandle(currObj))

        if isa(currObj,'Stateflow.LinkChart')
            referenceBlock=get_param(currObj.Path,'referenceblock');
            currObj=find(slroot,'-isa','Stateflow.Chart','Path',referenceBlock);
        end

        adSF=rptgen_sf.appdata_sf;
        adSF.CurrentObject=currObj;
        adSF.Context='Object';

        if isa(currObj,'Stateflow.Machine')
            adSF.CurrentMachine=currObj;

        elseif isa(currObj,'Stateflow.Chart')
            adSF.CurrentChart=currObj;

        elseif isa(currObj,'Stateflow.State')
            adSF.CurrentState=currObj;

        end

        adSF.LegibleSize=this.LegibleFontSize;

        adSL=rptgen_sl.appdata_sl;
        if isempty(adSL.CurrentModel)
            adSL.CurrentModel=adSF.CurrentMachine.Name;
        end

        ok=true;
    end