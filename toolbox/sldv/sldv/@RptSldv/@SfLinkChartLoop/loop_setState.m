function ok=loop_setState(this,currObj,objName)%#ok







    ok=false;

    if(~isempty(currObj)&&ishandle(currObj))

        currMachine=get(currObj,'Machine');

        if isa(currObj,'Stateflow.LinkChart')
            referenceBlock=get_param(currObj.Path,'referenceblock');
            chartBlock=get_param(currObj.Path,'Object');
            currObj=find(slroot,'-isa','Stateflow.Chart','Path',referenceBlock);
        else
            chartBlock=get_param(sf('Private','chart2block',currObj.Id),'Object');
        end

        adSF=rptgen_sf.appdata_sf;
        adSF.CurrentMachine=currMachine;
        adSF.CurrentChart=currObj;
        adSF.CurrentChartBlock=chartBlock;
        adSF.CurrentState=[];
        adSF.CurrentObject=currObj;
        adSF.Context='Chart';

        ok=true;

    end
