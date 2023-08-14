function tt_serialized=saveobj(tt)









    tt_serialized=saveobj@tabular(tt);
    tt_serialized=tt.setCompatibleVersionLimit(tt_serialized,2.0);

    tt_serialized.arrayProps=tt.arrayProps;
    tt_serialized.data=tt.data;
    tt_serialized.numDims=tt.metaDim.length;


    [validVarNames,madeValidVarNames]=matlab.lang.makeValidName(tt.varDim.labels);
    if any(madeValidVarNames)
        [validVarNames,madeUniqueVarNames]=matlab.lang.makeUniqueStrings(validVarNames,1:tt.varDim.length,namelengthmax);
        tt_serialized.useVarNamesOrig=any(madeValidVarNames|madeUniqueVarNames);
    else
        tt_serialized.useVarNamesOrig=false;
    end


    [validDimNames,madeValidDimNames]=matlab.lang.makeValidName(tt.metaDim.labels);
    if any(madeValidDimNames)
        [validDimNames,madeUniqueDimNames]=matlab.lang.makeUniqueStrings(validDimNames,validVarNames,namelengthmax);
        tt_serialized.useDimNamesOrig=any(madeValidDimNames|madeUniqueDimNames);
    else
        tt_serialized.useDimNamesOrig=false;
    end

    tt_serialized.dimNames=validDimNames;
    if tt_serialized.useDimNamesOrig
        tt_serialized.dimNamesOrig=tt.metaDim.labels;
    else
        tt_serialized.dimNamesOrig={};
    end
    tt_serialized.varNames=validVarNames;
    if tt_serialized.useVarNamesOrig
        tt_serialized.varNamesOrig=tt.varDim.labels;
    else
        tt_serialized.varNamesOrig={};
    end

    tt_serialized.numRows=tt.rowDim.length;
    tt_serialized.numVars=tt.varDim.length;
    tt_serialized.varDescriptions=tt.varDim.descrs;
    tt_serialized.varUnits=tt.varDim.units;





    tt_serialized.rowTimes=tt.rowDim.serializeRowTimes();

    continuity=tt.varDim.continuity;
    if isobject(continuity)&&isenum(continuity)
        tt_serialized.varContinuity=cellstr(continuity);
    else
        tt_serialized.varContinuity={};
    end
end
