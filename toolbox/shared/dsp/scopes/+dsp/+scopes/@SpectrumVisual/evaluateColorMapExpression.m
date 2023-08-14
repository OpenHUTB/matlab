function[val,errid,msg]=evaluateColorMapExpression(this,mapExpression)




    msg='';
    errid='';
    val=[];
    try





        oldShowHiddenHandles=get(0,'ShowHiddenHandles');
        set(0,'ShowHiddenHandles','on');
        val=evalin('base',mapExpression);
        set(0,'ShowHiddenHandles',oldShowHiddenHandles);
    catch
        set(0,'ShowHiddenHandles',oldShowHiddenHandles);
        errid='Spcuilib:scopes:ErrorFailedEvaluatingColormap';
        msg=getString(message(errid));
    end


    if isempty(msg)

        if size(val,2)~=3
            [msg,errid]=uiscopes.message('InvalidColormapDimensions');
        elseif~isreal(val)||issparse(val)||~isnumeric(val)
            [msg,errid]=uiscopes.message('ColormapNotReal');
        elseif any(val(:)<0)||any(val(:)>1)
            [msg,errid]=uiscopes.message('InvalidColormapRange');
        end
    end
    if isempty(errid)
        this.ColorMapMatrix=val;
    elseif nargout<2
        error(message(errid));
    end
end
