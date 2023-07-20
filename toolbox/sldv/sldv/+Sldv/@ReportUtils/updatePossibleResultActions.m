function possibleResultActions=updatePossibleResultActions(possibleResultActions,sldvData,model,isHighlighted,objectives,canApplyFilter)















    defaultReport=strcmp(sldvData.AnalysisInformation.Options.RequirementsTableAnalysis,'off');

    possibleResultActions=updateFieldIfPresent(possibleResultActions,'Filter',canApplyFilter);
    possibleResultActions=updateFieldIfPresent(possibleResultActions,'Harness',false);
    possibleResultActions=updateFieldIfPresent(possibleResultActions,'Report',defaultReport);
    possibleResultActions=updateFieldIfPresent(possibleResultActions,'Highlight',~isHighlighted);
    possibleResultActions=updateFieldIfPresent(possibleResultActions,'SimForCov',false);
    possibleResultActions=updateFieldIfPresent(possibleResultActions,'DispUnsatisfiable',false);
    possibleResultActions=updateFieldIfPresent(possibleResultActions,'ExportToSlTest',false);
    possibleResultActions=updateFieldIfPresent(possibleResultActions,'SaveToSpreadsheet',false);





    [testOrCounterExData,dataType]=Sldv.DataUtils.getSimData(sldvData);

    if isempty(testOrCounterExData)
        return;
    end






    if isempty(objectives)
        allStatus={};
    else
        allStatus={objectives.status};
    end

    if isfield(possibleResultActions,'Harness')...
        ||isfield(possibleResultActions,'SimForCov')...
        ||isfield(possibleResultActions,'DispUnsatisfiable')

        switch(sldvData.AnalysisInformation.Options.Mode)
        case 'TestGeneration'
            if strcmpi(dataType,getString(message('Sldv:KeyWords:TestCaseTitle')))




                isXIL=Sldv.DataUtils.isXilSldvData(sldvData);
                if any(strcmp(allStatus,'Satisfied'))||...
                    any(strcmp(allStatus,'Satisfied by existing testcase'))||...
                    any(strcmp(allStatus,'Satisfied - needs simulation'))||...
                    any(strcmp(allStatus,'Undecided with testcase'))||...
                    any(strcmp(allStatus,'Undecided due to runtime error'))||...
                    (isXIL&&any(strcmp(allStatus,'Satisfied - needs simulation')))
                    possibleResultActions=updateFieldIfPresent(possibleResultActions,'Harness',true);
                    possibleResultActions=updateFieldIfPresent(possibleResultActions,'SimForCov',true);
                    possibleResultActions=updateFieldIfPresent(possibleResultActions,...
                    'SaveToSpreadsheet',slavteng('feature','ExcelSupport')>0);
                end
                possibleResultActions=updateFieldIfPresent(possibleResultActions,'DispUnsatisfiable',...
                any(strcmp(allStatus,'Unsatisfiable')));
            end

        case{'DesignErrorDetection','PropertyProving'}
            if strcmpi(dataType,getString(message('Sldv:KeyWords:CexTitle')))

                if any(strcmp(allStatus,'Falsified'))||...
                    any(strcmp(allStatus,'Falsified - needs simulation'))||...
                    any(strcmp(allStatus,'Undecided with counterexample'))||...
                    any(strcmp(allStatus,'Undecided due to runtime error'))
                    possibleResultActions=updateFieldIfPresent(possibleResultActions,'Harness',true);
                    possibleResultActions=updateFieldIfPresent(possibleResultActions,...
                    'SaveToSpreadsheet',slavteng('feature','ExcelSupport')>0);
                end
            end
        end
    end

    if isfield(possibleResultActions,'ExportToSlTest')

        if(slfeature('ExportTestcasesInSLTest')&&...
            Simulink.harness.internal.isInstalled()&&...
            Simulink.harness.internal.licenseTest()&&...
            possibleResultActions.Harness)
            possibleResultActions=updateFieldIfPresent(possibleResultActions,'ExportToSlTest',true);

            if strcmp(get_param(model,'isHarness'),'on')
                possibleResultActions=updateFieldIfPresent(possibleResultActions,'ExportToSlTest',true);
            end


            if strcmp(get_param(model,'isHarness'),'off')&&isfield(sldvData.ModelInformation,'SubsystemPath')
                blockH=get_param(sldvData.ModelInformation.SubsystemPath,'handle');
                if Sldv.utils.isAtomicSubchartSubsystem(blockH)
                    possibleResultActions=updateFieldIfPresent(possibleResultActions,'ExportToSlTest',false);
                end
            end
        end
    end
end

function resultStruct=updateFieldIfPresent(resultStruct,field,value)
    if isfield(resultStruct,field)
        resultStruct.(field)=value;
    end
end
