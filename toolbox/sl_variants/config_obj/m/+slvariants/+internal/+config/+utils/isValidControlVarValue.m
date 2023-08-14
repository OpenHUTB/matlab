function is=isValidControlVarValue(v)




    if isa(v,'double')||isa(v,'Simulink.data.Expression')||isenum(v)||isnumeric(v)||islogical(v)
        is=true;
        return;
    end

    if~Simulink.variant.utils.isCharOrString(v)
        is=isScalarParameterObj(v)||isScalarVariantControlObj(v);
        return;
    end
    is=slvariants.internal.config.utils.isNonEmptyString(v);
    is=is&&isempty(find(strcmp(v,{'v','is'}),1));
    if~is
        return;
    end
    try
        varAssignStr=strcat('avar = ',v,';');
        eval(varAssignStr);
    catch
        is=false;
    end
end

function is=isScalarParameterObj(d)



    is=~isempty(d)&&isscalar(d)&&...
    isa(d,'Simulink.Parameter');
end

function is=isScalarVariantControlObj(d)




    is=~isempty(d)&&isscalar(d)&&...
    isa(d,'Simulink.VariantControl');
end


