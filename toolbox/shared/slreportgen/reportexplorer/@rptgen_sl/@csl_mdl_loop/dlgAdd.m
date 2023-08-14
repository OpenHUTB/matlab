function newOption=dlgAdd(this,dlgH)





    newOption=rptgen_sl.rpt_mdl_loop_options;

    if~isa(dlgH,'rptgen_sl.rpt_mdl_loop_options')
        currOption=this.dlgCurrentOption;
    else
        currOption=dlgH;
        dlgH=[];
    end

    if isempty(currOption)
        connect(newOption,this,'up');
        this.DlgLoopListIdx=0;
    else

        connect(newOption,currOption,'right');
    end

    if~isempty(dlgH)
        dlgH.refresh;
    end

