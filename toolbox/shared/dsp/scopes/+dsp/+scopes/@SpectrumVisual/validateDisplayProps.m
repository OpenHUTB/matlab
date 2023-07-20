function[b,exception]=validateDisplayProps(this,hDlg,b,exception)



    cb=matlabshared.scopes.Validator.Limit;
    if b

        [b,exception,minYLim]=validateLimWidgetValue(this,hDlg,'MinYLim','MinYLim',cb);
    end
    if b

        [b,exception,maxYLim]=validateLimWidgetValue(this,hDlg,'MaxYLim','MaxYLim',cb);
    end

    if b&&(minYLim>=maxYLim)
        b=false;
        [msg,id]=uiscopes.message('InvalidYLim');
        exception=MException(id,msg);
    end
    if b

        [b,exception]=validateColorMapExpresion(this,hDlg,'ColorMap');
    end
    if b

        [b,exception,minColorLim]=validateLimWidgetValue(this,hDlg,'MinColorLim','MinColorLim',cb);
    end
    if b

        [b,exception,maxColorLim]=validateLimWidgetValue(this,hDlg,'MaxColorLim','MaxColorLim',cb);
    end

    if b&&(minColorLim>=maxColorLim)
        b=false;
        [msg,id]=uiscopes.message('InvalidCLim');
        exception=MException(id,msg);
    end
end


function[b,exception,val]=validateLimWidgetValue(this,hDlg,tag,messageTag,validator)



    fulltag=[hDlg.getSource.Register.Name,tag];
    variable=hDlg.getWidgetValue(fulltag);

    [val,errid,errmsg]=evaluateVariable(this.Application,variable);

    if~isempty(errid)
        b=false;
        exception=MException(errid,errmsg);
    elseif~validator(val)

        b=false;
        [msg,id]=uiscopes.message(['Invalid',messageTag]);
        exception=MException(id,msg);
    else
        b=true;
        exception=MException.empty;
    end
end
