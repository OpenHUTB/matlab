function t=loadobj(s)






    t=table();


    s=tabular.handleFailedToLoadVars(s,s.nrows,s.nvars,s.varnames);



    serialized_props=s.props;
    if isfield(serialized_props,'VersionSavedFrom')&&...
        serialized_props.VersionSavedFrom>=2.2&&...
        t.isIncompatible(serialized_props,'MATLAB:table:IncompatibleLoad')
        return;
    end


    t.data=s.data;



    t.arrayProps.Description=s.props.Description;
    t.arrayProps.UserData=s.props.UserData;






    if isfield(s.props,'VersionSavedFrom')&&s.props.VersionSavedFrom>=4.0
        if s.props.useVariableNamesOriginal
            varnames=s.props.VariableNamesOriginal;
        else
            varnames=s.varnames;
        end
        if s.props.useDimensionNamesOriginal
            dimnames=s.props.DimensionNamesOriginal;
        else
            dimnames=s.props.DimensionNames;
        end
    else
        varnames=s.varnames;
        dimnames=s.props.DimensionNames;
    end









    if isfield(s.props,'VersionSavedFrom')
        t.metaDim=t.metaDim.init(s.ndims,dimnames);
    else
        if iscellstr(dimnames)&&(dimnames(2)=="Variable")%#ok<ISCLSTR>



            dimnames(2)=t.defaultDimNames(2);
        end

        dimnames=t.metaDim.fixLabelsForCompatibility(dimnames);
        t.metaDim=t.metaDim.init(2,dimnames);
        t.metaDim=t.metaDim.checkAgainstVarLabels(varnames,'warnBackCompat');
    end




    if isequal(s.rownames,{})
        t.rowDim=t.rowDim.init(s.nrows);
    else
        rowNames=matlab.internal.tabular.private.rowNamesDim.makeValidName(s.rownames,'warn');
        t.rowDim=t.rowDim.init(s.nrows,rowNames);
    end


    if~isfield(s.props,'VersionSavedFrom')||s.props.VersionSavedFrom<=2.0
        t.varDim=t.varDim.init(s.nvars,...
        varnames,...
        s.props.VariableDescriptions,...
        s.props.VariableUnits);
    elseif(s.props.VersionSavedFrom>=2.1)&&(s.props.VersionSavedFrom<3.0)
        t.varDim=t.varDim.init(s.nvars,...
        varnames,...
        s.props.VariableDescriptions,...
        s.props.VariableUnits,...
        s.props.VariableContinuity);
    else
        t.arrayProps.TableCustomProperties=s.props.CustomProps;
        t.varDim=t.varDim.init(s.nvars,...
        varnames,...
        s.props.VariableDescriptions,...
        s.props.VariableUnits,...
        s.props.VariableContinuity,...
        s.props.VariableCustomProps);
    end
end
