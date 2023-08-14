function scale_apply(~,bd,mdl,runObj)




    results=runObj.getResults;



    perMLFBResults=Simulink.sdi.Map(char('a'),?handle);

    for resultIndex=1:length(results)


        if results(resultIndex).hasApplicableProposals


            currentResult=results(resultIndex);
            uniqueID=currentResult.UniqueIdentifier;
            res_daobject=uniqueID.getObject;
            res_pathItem=uniqueID.getElementName;

            if isa(currentResult,'fxptds.MATLABVariableResult')
                blkObjPath=res_daobject.MATLABFunctionIdentifier.SID;
                if isKey(perMLFBResults,blkObjPath)
                    existingRes=perMLFBResults.getDataByKey(blkObjPath);
                    existingRes{end+1}=currentResult;%#ok<AGROW>
                    perMLFBResults.insert(blkObjPath,existingRes);
                else
                    perMLFBResults.insert(blkObjPath,{currentResult});
                end
            end

            isMutableNamedDT=currentResult.getSpecifiedDTContainerInfo.traceVar();
            if~isMutableNamedDT
                currentAutoscaler=currentResult.getAutoscaler;
                currentAutoscaler.applyProposedScaling(res_daobject,res_pathItem,currentResult.getProposedDT);
            end


            currentResult.setSpecifiedDataType(currentResult.getProposedDT);
            currentResult.updateAcceptFlag;
        end
    end

    sudID=fxptds.SimulinkIdentifier(bd);
    SimulinkFixedPoint.AutoscalerUtils.applyMLFBResults(perMLFBResults,mdl,runObj,sudID);

end


