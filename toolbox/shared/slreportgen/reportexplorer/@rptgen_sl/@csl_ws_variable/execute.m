function out=execute(this,d,varargin)





    adSL=rptgen_sl.appdata_sl;

    switch lower(adSL.Context)
    case 'workspacevar'
        workspaceVars=adSL.CurrentWorkspaceVar;
    otherwise
        looper=rptgen_sl.csl_ws_var_loop();
        workspaceVars=looper.loop_getLoopObjects();
    end

    if(this.customFilteringEnabled)
        this.PropertyFilterCode=this.customFilteringCode;
    else
        this.PropertyFilterCode=this.buildPropertyFilterCode();
    end

    out=d.createDocumentFragment;
    psVar=rptgen_sl.propsrc_sl_ws_var;

    for i=1:length(workspaceVars)
        workspaceVar=workspaceVars(i);
        varValue=psVar.getPropValue(workspaceVar,'Value');
        varValue=varValue{1};
        varName=workspaceVar.Name;

        varInfo=this.reportVariable(d,varName,varValue);
        out.appendChild(varInfo);

        if this.ShowUsedBy
            usedByList=this.makeUsedByBlocksDescription(d,workspaceVar);
            out.appendChild(usedByList);
        end

        if this.ShowWorkspace
            workspaceInfo=this.makeWorkspaceDescription(d,workspaceVar);
            out.appendChild(workspaceInfo);
        end
    end
