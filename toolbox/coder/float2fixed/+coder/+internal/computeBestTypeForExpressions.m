function reportInfoAsArray=computeBestTypeForExpressions(exprInfoMap,typeProposalSettings)
    fcns=exprInfoMap.keys;
    reportInfoAsArray={};

    for ii=1:length(fcns)
        fcn=fcns{ii};
        reportInfoAsArray{end+1}={fcn};%#ok<*AGROW>
        fcnExprMap=exprInfoMap(fcn);
        exprs=fcnExprMap.keys;
        for jj=1:length(exprs)
            exprPos=exprs{jj};
            mxInfoLoc=fcnExprMap(exprPos);

            if~isempty(mxInfoLoc.SymbolName)||strcmp(mxInfoLoc.NodeTypeName,'const')
                continue;
            end

            simMin=mxInfoLoc.SimMin;
            simMax=mxInfoLoc.SimMax;
            isInteger=mxInfoLoc.IsAlwaysInteger;
            proposedType=coder.internal.getBestNumericTypeForVal(simMin...
            ,simMax...
            ,isInteger...
            ,typeProposalSettings);

            rI=buildReportInfo(exprPos...
            ,''...
            ,simMin...
            ,simMax...
            ,''...
            ,''...
            ,simMin...
            ,simMax...
            ,isInteger...
            ,proposedType...
            ,typeProposalSettings.defaultFimath...
            ,mxInfoLoc.RatioOfRange...
            ,mxInfoLoc.TextStart...
            ,mxInfoLoc.TextLength);
            reportInfoAsArray{end}{end+1}=rI;
        end
    end
end

function rI=buildReportInfo(exprPos,inferred_Type,simMin,simMax,derivedMin,derivedMax,acceptedMin,acceptedMax,acceptedIsInt,proposedType,defaultFimath,ratioOfRange,textStart,textLength)
    rI.exprPos=exprPos;
    rI.inferred_Type=inferred_Type;

    rI.DesignMin='';
    rI.DesignMax='';
    rI.IsInteger=coder.internal.convertBoolToYesNo(acceptedIsInt);

    [simMin,simMax]=coder.internal.VarTypeInfo.ResetImposibleSimData(simMin,simMax);
    rI.SimMin=coder.internal.compactButAccurateNum2Str(simMin);
    rI.SimMax=coder.internal.compactButAccurateNum2Str(simMax);
    rI.DerivedMin=coder.internal.compactButAccurateNum2Str(derivedMin);
    rI.DerivedMax=coder.internal.compactButAccurateNum2Str(derivedMax);
    rI.AcceptedMin=coder.internal.compactButAccurateNum2Str(acceptedMin);
    rI.AcceptedMax=coder.internal.compactButAccurateNum2Str(acceptedMax);
    rI.ProposedType=coder.internal.getNumericTypeStr(proposedType);
    rI.RoundMode=defaultFimath.RoundingMethod;
    rI.OverflowMode=defaultFimath.OverflowAction;
    rI.RatioOfRange=ratioOfRange;
    rI.TextStart=textStart;
    rI.TextLength=textLength;
end