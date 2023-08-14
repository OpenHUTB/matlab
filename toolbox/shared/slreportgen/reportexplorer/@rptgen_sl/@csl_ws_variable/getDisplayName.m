function dNames=getDisplayName(this)




    adSL=rptgen_sl.appdata_sl;

    switch lower(adSL.Context)
    case 'workspacevar'
        vars=adSL.CurrentWorkspaceVar;
    otherwise
        looper=rptgen_sl.csl_ws_var_loop();
        vars=looper.loop_getLoopObjects();
    end

    if isempty(this.PropSrc)
        this.PropSrc=rptgen_sl.propsrc_sl_ws_var;
    end

    this.Variables=containers.Map;

    for i=1:length(vars)
        this.Variables(vars(i).Name)=vars(i);
    end

    dNames=this.Variables.keys;
