function reportRanges(obj)





    cleanupObj=obj.enterTracePoint('Report Ranges');%#ok<NASGU>


    obj.loadRangeData;

    number_of_objectives=numel(obj.rangeData.Objectives);

    for iObjective=1:number_of_objectives
        if strcmpi(obj.rangeData.Objectives(iObjective).status,'Falsified - No Counterexample')

            ME=fxptui.FPTMException('SimulinkFixedPoint:Autoscaling:RangeAnalysisBadDesignRange',...
            DAStudio.message('SimulinkFixedPoint:autoscaling:RangeAnalysisBadDesignRange'),...
            get_param(obj.model,'Handle'));
            throw(ME);
        end
    end

    if slsvTestingHook('RAviaRTWtesting')>1
        fprintf(obj.debugFileHandle,'%s\n','Following is a print out of each individual ''rangeRecord''');
        fprintf(obj.debugFileHandle,'%s\n','object output in private method');
        fprintf(obj.debugFileHandle,'%s\n','''Simulink.FixedPointAutoscaler.RangeAnalyzer.reportRanges''.');
        fprintf(obj.debugFileHandle,'%s\n','Each of these ''rangeRecord'' objects is handed off to');
        fprintf(obj.debugFileHandle,'%s\n','''SimulinkFixedPoint.ApplicationData.addDataFromDerivedRange''');
        fprintf(obj.debugFileHandle,'%s\n\n\n','exactly as it appears below.');
    end

    functionMap=containers.Map;

    for iObjective=1:number_of_objectives
        objective=obj.rangeData.Objectives(iObjective);


        rangeRecord=obj.objectiveToRangeRecord(objective);


        if isempty(rangeRecord)||rangeRecord.isEmptyRange||(~isempty(rangeRecord.instanceHandle)&&~isempty(rangeRecord.emlId))
            continue;
        end

        if~isempty(rangeRecord.emlId)
            functionMap(rangeRecord.emlId.MATLABFunctionIdentifier.UniqueKey)=rangeRecord.emlId.MATLABFunctionIdentifier;
        end


        if slsvTestingHook('RAviaRTWtesting')==1
            RAviaRTWTestRangeRecord(rangeRecord);
        end

        SimulinkFixedPoint.ApplicationData.addDataFromDerivedRange(rangeRecord,obj.runName);
        if slsvTestingHook('RAviaRTWtesting')>1
            fprintf(obj.debugFileHandle,'Objective %i rangeRecord.\n',iObjective);
            fprintf(obj.debugFileHandle,'According to SLDV this corresponds to ''%s''.\n',...
            obj.rangeData.ModelObjects(objective.modelObjectIdx).slPath);
            if rangeRecord.isSFRecord

                sfData=idToHandle(sfroot,str2double(rangeRecord.tag));

                chartId=sf('DataChartParent',sfData.Id);
                chartHandle=sf('Private','chart2block',chartId);
                chartSys=get_param(chartHandle,'Object');
                blkPath=chartSys.getFullName;

            else

                portURL=Simulink.URL.parseURL(rangeRecord.tag);
                blkURL=portURL.getParent;
                blkObj=get_param(blkURL,'Object');
                blkPath=blkObj.getFullName;
            end
            fprintf(obj.debugFileHandle,'According to our tag, this corresponds to ''%s''.\n\n',...
            blkPath);
            fprintf(obj.debugFileHandle,'%s\n\n',rangeRecord.toString);
        end

    end


    ed=fxptui.FPTEventDispatcher.getInstance;

    mapKeys=functionMap.keys;

    for keyIdx=1:numel(mapKeys)
        functionID=functionMap(mapKeys{keyIdx});





        ed.broadcastEvent('FunctionAddedEvent',...
        fxptui.FPTTreeUpdateEventData(...
        functionID,...
        Simulink.ID.getFullName(functionID.SID)));
    end


