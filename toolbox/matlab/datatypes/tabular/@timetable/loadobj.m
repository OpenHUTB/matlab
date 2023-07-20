function tt=loadobj(tt_serialized)












    tt=timetable();


    tt_serialized=tabular.handleFailedToLoadVars(tt_serialized,tt_serialized.numRows,tt_serialized.numVars,tt_serialized.varNames);



    if tt.isIncompatible(tt_serialized,'MATLAB:timetable:IncompatibleLoad')
        return;
    end


    tt.data=tt_serialized.data;






    if tt_serialized.versionSavedFrom>=5.0
        if tt_serialized.useVarNamesOrig
            varnames=tt_serialized.varNamesOrig;
        else
            varnames=tt_serialized.varNames;
        end
        if tt_serialized.useDimNamesOrig
            dimnames=tt_serialized.dimNamesOrig;
        else
            dimnames=tt_serialized.dimNames;
        end
    else
        varnames=tt_serialized.varNames;
        dimnames=tt_serialized.dimNames;
    end



    tt.arrayProps.Description=tt_serialized.arrayProps.Description;
    tt.arrayProps.UserData=tt_serialized.arrayProps.UserData;


    tt.metaDim=tt.metaDim.init(tt_serialized.numDims,dimnames);



    tt.rowDim=tt.rowDim.unserializeRowTimes(tt_serialized.numRows,tt_serialized.rowTimes);


    if tt_serialized.versionSavedFrom>=4.0

        tt.arrayProps.TableCustomProperties=tt_serialized.CustomProps;
        tt.varDim=tt.varDim.init(tt_serialized.numVars,...
        varnames,...
        tt_serialized.varDescriptions,...
        tt_serialized.varUnits,...
        tt_serialized.varContinuity,...
        tt_serialized.VariableCustomProps);
    elseif tt_serialized.versionSavedFrom>=3.1

        tt.varDim=tt.varDim.init(tt_serialized.numVars,...
        varnames,...
        tt_serialized.varDescriptions,...
        tt_serialized.varUnits,...
        tt_serialized.varContinuity);
    elseif tt_serialized.versionSavedFrom==3.0
        tt.varDim=tt.varDim.init(tt_serialized.numVars,...
        varnames,...
        tt_serialized.varDescriptions,...
        tt_serialized.varUnits);
    else


        tt.varDim=tt.varDim.init(tt_serialized.numVars,...
        varnames);
    end
end
