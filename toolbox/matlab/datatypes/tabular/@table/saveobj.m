function tsave=saveobj(t)




    assert(t.metaDim.length==2);

    tsave=t;




    tsave.ndims=t.metaDim.length;
    tsave.nrows=t.rowDim.length;
    tsave.nvars=t.varDim.length;
    tsave.rownames=t.rowDim.labels;



    [validVarNames,madeValidVarNames]=matlab.lang.makeValidName(t.varDim.labels);
    if any(madeValidVarNames)
        [validVarNames,madeUniqueVarNames]=matlab.lang.makeUniqueStrings(validVarNames,1:t.varDim.length,namelengthmax);
        tsave.props.useVariableNamesOriginal=any(madeValidVarNames|madeUniqueVarNames);
    else
        tsave.props.useVariableNamesOriginal=false;
    end




    [validDimNames,madeValidDimNames]=matlab.lang.makeValidName(t.metaDim.labels);
    if any(madeValidDimNames)
        [validDimNames,madeUniqueDimNames]=matlab.lang.makeUniqueStrings(validDimNames,validVarNames,namelengthmax);
        tsave.props.useDimensionNamesOriginal=any(madeValidDimNames|madeUniqueDimNames);
    else
        tsave.props.useDimensionNamesOriginal=false;
    end

    tsave.varnames=validVarNames;









    tsave.props=saveobj@tabular(t,tsave.props);
    tsave.props=t.setCompatibleVersionLimit(tsave.props,1.0);
    tsave.props.VersionSavedFrom=tsave.props.versionSavedFrom;

    tsave.props.Description=t.arrayProps.Description;

    if tsave.props.useVariableNamesOriginal
        tsave.props.VariableNamesOriginal=t.varDim.labels;
    else
        tsave.props.VariableNamesOriginal={};
    end

    tsave.props.DimensionNames=validDimNames;
    if tsave.props.useDimensionNamesOriginal
        tsave.props.DimensionNamesOriginal=t.metaDim.labels;
    else
        tsave.props.DimensionNamesOriginal={};
    end

    tsave.props.UserData=t.arrayProps.UserData;
    tsave.props.VariableDescriptions=t.varDim.descrs;
    tsave.props.VariableUnits=t.varDim.units;
    if isenum(t.varDim.continuity)
        tsave.props.VariableContinuity=cellstr(t.varDim.continuity);
    else
        tsave.props.VariableContinuity={};
    end
end
