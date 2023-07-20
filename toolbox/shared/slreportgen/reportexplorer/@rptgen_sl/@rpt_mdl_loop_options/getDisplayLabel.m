function displayLabel=getDisplayLabel(this)





    if strcmp(this.MdlName,'$current')
        displayLabel=getString(message('RptgenSL:rsl_rpt_mdl_loop_options:currentDiagramLabel'));

    elseif strcmp(this.MdlName,'$all')
        displayLabel=getString(message('RptgenSL:rsl_rpt_mdl_loop_options:allOpenModelsLabel'));

    elseif strcmp(this.MdlName,'$alllib')
        displayLabel=getString(message('RptgenSL:rsl_rpt_mdl_loop_options:allOpenLibrariesLabel'));

    elseif strcmp(this.MdlName,'$pwd')
        displayLabel=getString(message('RptgenSL:rsl_rpt_mdl_loop_options:diagramsInCurrentDirectoryLabel'));

    elseif isempty(this.MdlName)
        displayLabel=getString(message('RptgenSL:rsl_rpt_mdl_loop_options:enterModelNameLabel'));

    else
        [~,displayLabel]=fileparts(this.MdlName);
    end

    if(~this.Active)
        displayLabel=['(',displayLabel,')'];
    end