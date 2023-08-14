function[b,exception]=validateColorMapExpresion(this,hDlg,tag)



    b=true;
    exception=MException.empty;

    fulltag=[hDlg.getSource.Register.Name,tag];
    variable=hDlg.getWidgetValue(fulltag);


    [~,id,msg]=evaluateColorMapExpression(this,variable);
    if~isempty(id)
        b=false;
        exception=MException(id,msg);
    end
end
