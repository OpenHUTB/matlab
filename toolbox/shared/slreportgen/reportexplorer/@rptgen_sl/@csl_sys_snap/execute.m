function out=execute(this,d,varargin)






    sysName=get(rptgen_sl.appdata_sl,'CurrentSystem');

    if isempty(sysName)

        warnStr=getString(message('RptgenSL:rsl_csl_sys_snap:cannotFindSystem'));
        out=createComment(d,warnStr);
        this.status(warnStr,2);

    elseif strcmp(get_param(sysName,'Type'),'block')...
        &&slprivate('is_stateflow_based_block',sysName)

        warnStr=getString(message('RptgenSL:rsl_csl_sys_snap:cannotSnapshotStateflow'));
        out=createComment(d,warnStr);
        this.status(warnStr,2);

    else
        out=gr_makeGraphic(this,d,sysName);

    end
