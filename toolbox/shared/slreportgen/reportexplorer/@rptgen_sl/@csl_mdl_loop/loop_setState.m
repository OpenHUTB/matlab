function ok=loop_setState(h,currObj,~)





    try
        sysH=find_system(0,'SearchDepth',1,'Name',currObj,'Type','block_diagram');
        ok=true;
    catch ME %#ok
        sysH=[];
        ok=false;
    end

    if isempty(sysH)
        try
            load_system(currObj);
            ok=strcmp(get_param(currObj,'Type'),'block_diagram');
        catch ME
            h.status(ME.message,2);
            ok=false;
            currObj='';
        end
    else


        set_param(0,'CurrentSystem',currObj);
    end

    if~ok
        return;
    end

    adSL=rptgen_sl.appdata_sl;

    adSL.CurrentModel=currObj;
    adSL.CurrentSystem=currObj;
    adSL.Context='Model';




    optObj=h.findOptionsObject(currObj);
    if~isempty(optObj)
        try
            adSL.ReportedSystemList=optObj.getReportedSystems(currObj);
        catch ME

            h.status(ME.message,2);
            ok=false;
        end
    end
