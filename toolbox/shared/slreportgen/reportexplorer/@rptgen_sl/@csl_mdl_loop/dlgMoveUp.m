function dlgMoveUp(this,dlgH)






    if~isa(dlgH,'rptgen_sl.rpt_mdl_loop_options')
        currOption=this.dlgCurrentOption;
    else
        currOption=dlgH;
        dlgH=[];
    end

    if~isempty(currOption)
        if moveUp(currOption)&&~isempty(dlgH)

            this.DlgLoopListIdx=this.DlgLoopListIdx-1;
            dlgH.setWidgetValue('ModelList',this.DlgLoopListIdx);
            dlgH.refresh;
        end
    end



