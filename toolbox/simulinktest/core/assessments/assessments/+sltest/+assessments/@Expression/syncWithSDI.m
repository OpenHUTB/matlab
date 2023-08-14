

function syncWithSDI(self,quantitative)











    if nargin<2
        quantitative=false;
    end

    persistent runID
    if isempty(runID)
        runID=Simulink.sdi.createRun('simulinktest_assessments');
        Simulink.sdi.internal.moveRunToApp(runID,'simulinktest_assessments');
    end

    persistent importedUUIDs
    if isempty(importedUUIDs)
        importedUUIDs=containers.Map;
    end

    hasExtendedResultSetting=self.internal.hasMetadata('extendedResult');
    isSameExtendedResultSetting=false;

    if hasExtendedResultSetting
        isSameExtendedResultSetting=(self.internal.metadata('extendedResult')==sltest.assessments.internal.expression.minimizeUntestedTrace());
    end

    hasResults=self.internal.hasResults();
    hasSignal=self.internal.hasMetadata('sdiAssessmentID')&&...
    self.internal.hasMetadata('sdiImportUUID')&&...
    isKey(importedUUIDs,self.internal.metadata('sdiImportUUID'));
    isSameEvaluationSemantic=self.internal.hasMetadata('isQuantitative')&&self.internal.metadata('isQuantitative')==quantitative;
    assert(hasSignal||~self.internal.hasMetadata('sdiRunID'),'the input expression must not be a sub-expression of another root expression');

    if(~hasResults&&~hasSignal)||~isSameEvaluationSemantic||~isSameExtendedResultSetting

        if(quantitative==false)
            self.internal.verify();
        else
            self.internal.verifyQ();
        end
        hasResults=self.internal.hasResults();
        assert(hasResults,'evaluating the root expression should produce results');
    end

    if(hasResults&&~hasSignal)||~isSameExtendedResultSetting



        startTime=self.internal.startTime;
        endTime=self.internal.endTime;


        root=self.getResultData(startTime,endTime);
        if~quantitative&&~isa(root.Value,'sltest.assessments.Logical')
            error(message('sltest:assessments:InvalidRootDataType'));
        end

        self.visit(@syncToSDI);


        isAssessment=true;
        if(isa(root.Value,'sltest.assessments.Logical'))
            root.Value=slTestResult(root.Value);
            result=slTestResult(max(root.Value));
        else
            if quantitative





                tmpTs=setinterpmethod(timeseries(root.Value,root.Time,'Name',root.Name),root.Interpolation);
                tmpRootExpr=sltest.assessments.Signal(tmpTs)>=0;
                tmpRootExpr.internal.verify();
                tmpRoot=tmpRootExpr.internal.results();
                assert(isa(tmpRoot.Value,'sltest.assessments.Logical'));
                root=tmpRoot;
                root.Value=slTestResult(root.Value);
                result=slTestResult(max(root.Value));
            else
                isAssessment=false;
            end
        end



        if isAssessment
            assessmentID=Simulink.sdi.addToRun(runID,'namevalue',{root.Name},{setinterpmethod(timeseries(root.Value,root.Time,'Name',root.Name),root.Interpolation)});

            sdiEngine=Simulink.sdi.Instance.engine;
            sdiEngine.setMetaDataV2(assessmentID,'IsAssessment',int32(true));
            sdiEngine.setMetaDataV2(assessmentID,'AssessmentResult',int32(result));

            self.internal.setMetadata('sdiAssessmentID',assessmentID);
            self.internal.setMetadata('sdiAssessmentResult',result);
            self.internal.setMetadata('isQuantitative',quantitative);
            self.internal.setMetadata('extendedResult',sltest.assessments.internal.expression.minimizeUntestedTrace());

            if~self.internal.hasMetadata('sdiImportUUID')
                uuid=matlab.lang.internal.uuid;
                self.internal.setMetadata('sdiImportUUID',uuid);
            else
                uuid=self.internal.metadata('sdiImportUUID');
            end
            importedUUIDs(uuid)=true;
        end
    end

    function syncToSDI(expr)
        assert(~expr.internal.hasMetadata('sdiAssessmentID'),'only the root expression should have a verify signal');

        if~(expr.internal.hasMetadata('sdiSignalID')&&...
            expr.internal.hasMetadata('sdiImportUUID')&&...
            isKey(importedUUIDs,expr.internal.metadata('sdiImportUUID')))
            if expr.internal.hasMetadata('originalData')


                res=expr.internal.metadata('originalData');
                if isnumeric(res)||islogical(res)

                    tmp=expr.internal.results(startTime,endTime);
                    res=timeseries(arrayfun(@(x)(res),tmp.Value),tmp.Time,'Name',expr.internal.stringLabel);
                end
                sigID=Simulink.sdi.addToRun(runID,'namevalue',{res.Name},{res});
                isEnumType=isenum(res.Data);
            else


                res=expr.getResultData(startTime,endTime);



                assert(length(res.Time)>1||startTime==endTime||(isinf(startTime)&&isinf(endTime)));
                sigID=Simulink.sdi.addToRun(runID,'namevalue',{res.Name},{setinterpmethod(timeseries(res.Value,res.Time,'Name',res.Name),res.Interpolation)});
                isEnumType=isenum(res.Value);
            end
            expr.internal.setMetadata('sdiSignalID',sigID);
            expr.internal.setMetadata('sdiIsEnum',isEnumType);
            if~expr.internal.hasMetadata('sdiImportUUID')
                exprUUID=matlab.lang.internal.uuid;
                expr.internal.setMetadata('sdiImportUUID',exprUUID);
            else
                exprUUID=expr.internal.metadata('sdiImportUUID');
            end
            importedUUIDs(exprUUID)=true;
        end
    end

end


