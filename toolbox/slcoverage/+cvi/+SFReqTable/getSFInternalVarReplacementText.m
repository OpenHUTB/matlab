function newStr=getSFInternalVarReplacementText(chartSfId,internalVarName)%#ok<INUSL> chartSfId is used in the replacement below!




    newStr=regexprep(internalVarName,'sf_internal_execute_[RA]_(\d+)','${cvi.SFReqTable.getSFInternalVarReplacementTextHelper(chartSfId, $1)}');
