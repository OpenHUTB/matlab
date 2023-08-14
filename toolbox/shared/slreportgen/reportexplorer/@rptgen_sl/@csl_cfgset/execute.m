function out=execute(this,d,varargin)




    out=[];
    bailOut=false;
    msg=@(key)rptgen.rpt_var_display.msg(key);
    try
        dName=this.getDisplayName();
        [dValue,dName,sourceInfoArr]=this.getDisplayValue(dName);
        if~exist('dValue','var')
            bailOut=true;
            this.status(msg('execute_get_display_value_failed'),1);

        elseif isempty(dValue)
            bailOut=true;
            this.status(msg('execute_empty_value'),4);
        end

    catch ex
        this.status(ex.message,2);
        bailOut=true;
    end

    if bailOut
        return
    end

    if strcmp(this.TitleMode,'manual')
        dName=rptgen.parseExpressionText(this.CustomTitle);
    end

    warningToTurnOffId='Simulink:ConfigSet:SimModeMovedToMdlInvalidGet';
    warning('off',warningToTurnOffId);
    out=this.reportVariable(d,dName,dValue);
    warning('on',warningToTurnOffId);

    if~isempty(sourceInfoArr)
        tableMaker=d.makeNodeTable(sourceInfoArr,0,true);
        tableMaker.setNumHeadRows(0);
        tableMaker.setPageWide(false);
        tableMaker.setBorder(false);
        tableMaker.setTitle('');
        tableMaker.setNumCols(2);

        rpt=rptgen.findRpt(this);
        if~isempty(rpt)&&~strcmpi(rpt.Format,'html')&&~strcmpi(rpt.Format,'dom-htmx')
            columnWidths=[25,100];


            tableMaker.setColWidths(columnWidths);
            tableMaker.setPageWide(true);
        end

        sourceTable=tableMaker.createTable();
        out.insertBefore(sourceTable,out.getFirstChild());
    end





    if isprop(dValue,'Components')
        nComps=length(dValue.Components);
        for i=1:nComps
            if isa(dValue.Components(i),'hdlcoderui.hdlcc')

                cliobj=dValue.Components(i).getCLI();
                if~isempty(cliobj)


                    frag=d.createDocumentFragment();
                    frag.appendChild(out);


                    hdl=this.reportVariable(d,dValue.Components(i).Name,cliobj);
                    frag.appendChild(hdl);

                    out=frag;
                end
            end
        end
    end
