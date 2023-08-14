function dlgDelete(this,dlgH)




    if~isa(dlgH,'rptgen_sl.rpt_mdl_loop_options')
        currOption=this.dlgCurrentOption;
    else
        currOption=dlgH;
        dlgH=[];
    end

    if~isempty(currOption)
        leftOption=currOption.left;
        rightOption=currOption.right;

        if isempty(leftOption)&&isempty(rightOption)

        else
            disconnect(currOption);
            delete(currOption);


            if isempty(rightOption)


                this.DlgLoopListIdx=this.DlgLoopListIdx-1;
            elseif~isempty(dlgH)

                dlgH.refresh;
            end
        end
    end



