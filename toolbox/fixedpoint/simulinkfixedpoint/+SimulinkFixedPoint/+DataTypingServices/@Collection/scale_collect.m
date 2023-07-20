function scale_collect(this,sudObject,modelName,runObj)






    compileHandler=startCompile(this,modelName);%#ok<NASGU>

    errorID='';
    try




        this.discoverResults(runObj,sudObject,modelName);

        allResults=runObj.getResultsAsCellArray;


        cellfun(@(x)(x.clearProposalData),allResults);


        namedDTDetectionUtil=SimulinkFixedPoint.NamedDTDetectionUtil;
        infoCollector=SimulinkFixedPoint.EntityInfoCollector(runObj.getMetaData());

        i=1;
        while(i<=length(allResults))
            currentResult=allResults{i};
            currentObject=currentResult.UniqueIdentifier.getObject;
            currentElementName=currentResult.UniqueIdentifier.getElementName;
            currentAutoscaler=currentResult.getAutoscaler;

            if isa(currentObject,'Simulink.SubSystem')
                currentResult.addComment(DAStudio.message('SimulinkFixedPoint:autoscaling:loggedSubsystem'));
            elseif isa(currentObject,'Simulink.Parameter')


                i=i+1;
                continue;
            else

                info=infoCollector.collectInfo(currentAutoscaler,currentObject,currentElementName);
                if isempty(currentResult.CompiledDT)
                    [~,~,compiledDataTypeStr]=currentAutoscaler.getModelCompiledDesignRange(currentObject,currentElementName);
                    compiledDataType=...
                    SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer(compiledDataTypeStr,[]);
                    if compiledDataType.isBoolean
                        currentResult.updateResultData(struct('CompiledDT',compiledDataTypeStr));
                    end
                end

                this.setResultProperties(currentResult,info);


                addedResults={};


                if~isempty(info.varAssociateParam)
                    addedResults=[addedResults,this.setAssociatedParam(info.varAssociateParam,runObj)];%#ok<*AGROW>
                end


                if~isempty(info.actualSrcIDs)
                    addedResults=[addedResults,SimulinkFixedPoint.Autoscaler.addToSrcList(runObj,currentResult,info.actualSrcIDs)];
                end


                if info.isResolved
                    sdoResult=SimulinkFixedPoint.Autoscaler.createSDOResult(runObj,info.slSignalInfo,modelName);
                    if~isempty(sdoResult)
                        addedResults=[addedResults,{sdoResult}];
                    end



                    if~isempty(info.slSignalInfo.actualSrcID)
                        addedResults=[addedResults,SimulinkFixedPoint.Autoscaler.addToSrcList(runObj,addedResults{end},info.slSignalInfo.actualSrcID)];
                    end
                end


                if info.hasDTConstraints
                    addedResults=[addedResults,this.getDTConstraintRecords(runObj,info.curDTConstraintsSet)];
                end


                if~isempty(info.busObjHandleAndICList)
                    sourcesForResult=SimulinkFixedPoint.AutoscalerUtils.getActualSrcForResult(currentResult);
                    addedResults=[addedResults,this.createAndUpdateBusObjectResults(info.busObjHandleAndICList,sourcesForResult,runObj)];
                end


                if~isempty(info.sharedList)
                    addedResults=[addedResults,findSharedResults(this,info,runObj)];
                end

                allResults=[allResults,addedResults];

                namedDTDetectionUtil.detectAndAddToNamedDTList(currentResult);

            end
            i=i+1;
        end


        paramResults=this.processParameterObjects(modelName,runObj);
        for rIndex=1:length(paramResults)
            namedDTDetectionUtil.detectAndAddToNamedDTList(paramResults{rIndex});
        end



        resultsClientOfNamedType=getListOfResults(namedDTDetectionUtil);
        processNamedDTObjects(this,get_param(modelName,'Object'),runObj,resultsClientOfNamedType);



        Simulink.FixedPointAutoscaler.InternalRange.calcInternalRanges(modelName,runObj);


        this.shareAcrossModelReference(runObj);

    catch eCollectFail


        errorID=eCollectFail;
    end





    runObj.deleteInvalidResults();




    if~isempty(errorID)
        throw(errorID);
    end
end

