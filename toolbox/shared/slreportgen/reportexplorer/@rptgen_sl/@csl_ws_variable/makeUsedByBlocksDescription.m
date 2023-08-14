function out=makeUsedByBlocksDescription(this,d,workspaceVar)





    ps=rptgen_sl.propsrc_sl_ws_var();
    adSL=rptgen_sl.appdata_sl();

    if(nargin<2)
        workspaceVar=adSL.CurrentWorkspaceVar;
    end

    if(length(workspaceVar)~=1)
        error(message('Simulink:rptgen_sl:InvalidInputsUsedBy'));
    end

    usedBy=ps.getPropValue(workspaceVar,'UsedByBlocks');
    usedBy=usedBy{1};

    if rptgen.use_java
        lm=com.mathworks.toolbox.rptgencore.docbook.ListMaker(usedBy);
    else
        lm=mlreportgen.re.internal.db.ListMaker(usedBy);
    end
    setTitle(lm,this.msg('UsedByListTitle'));
    setListType(lm,'itemizedlist');
    setListStyleName(lm,'"rgDDVarUsedByList"');
    setTitleStyleName(lm,'"rgDDVarUsedByListTitle"');

    if rptgen.use_java
        out=lm.createList(java(d));
    else
        out=createList(lm,d.Document);
    end