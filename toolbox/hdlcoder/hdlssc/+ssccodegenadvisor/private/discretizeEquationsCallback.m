function[ResultDescription,ResultDetails]=discretizeEquationsCallback(sys)





    ResultDescription={};
    ResultDetails={};


    modelAdvisorObj=Simulink.ModelAdvisor.getModelAdvisor(sys);
    modelAdvisorObj.setCheckErrorSeverity(1);


    sscCodeGenWorkflowObjCheck=modelAdvisorObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
    sscCodeGenWorkflowObj=sscCodeGenWorkflowObjCheck.ResultData;


    modelAdvisorObj.setCheckErrorSeverity(1);
    try

        sscCodeGenWorkflowObj.discretizeEquations();

        solverBlks=sscCodeGenWorkflowObj.SolverConfiguration;







        if sscCodeGenWorkflowObj.SolverTypes(1)
            [maxConfigs,totalBytes]=max(cellfun(@(x)x.getMaxConfigs,sscCodeGenWorkflowObj.PartSolvers));

        else
            maxConfigs=max(arrayfun(@(x)size(x.Ad,3),sscCodeGenWorkflowObj.StateSpaceParameters));


            bytesA=8*sum(arrayfun(@(x)numel(x.Ad),sscCodeGenWorkflowObj.StateSpaceParameters));
            bytesB=8*sum(arrayfun(@(x)numel(x.Bd),sscCodeGenWorkflowObj.StateSpaceParameters));
            bytesC=8*sum(arrayfun(@(x)numel(x.Cd),sscCodeGenWorkflowObj.StateSpaceParameters));
            bytesD=8*sum(arrayfun(@(x)numel(x.Dd),sscCodeGenWorkflowObj.StateSpaceParameters));
            totalBytes=bytesA+bytesB+bytesC+bytesD;
        end

        if totalBytes>2^31
            formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');

            setSubResultStatus(formatTemplate,'Fail');
            setSubResultStatusText(formatTemplate,ModelAdvisor.Text(message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:TooManyModes',maxConfigs).getString));

            setSubBar(formatTemplate,0);
            ResultDescription{end+1}=formatTemplate;
            ResultDetails{end+1}={};
            modelAdvisorObj.setCheckResultStatus(false);


        elseif maxConfigs>3000
            formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
            setSubResultStatus(formatTemplate,'Warn');
            setSubResultStatusText(formatTemplate,ModelAdvisor.Text(message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:ManyModes',maxConfigs).getString));

            setSubBar(formatTemplate,0);
            ResultDescription{end+1}=formatTemplate;
            ResultDetails{end+1}={};


            modelAdvisorObj.setCheckErrorSeverity(0);
            modelAdvisorObj.setCheckResultStatus(false);

        else


            formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
            setSubResultStatus(formatTemplate,'Pass');
            setSubBar(formatTemplate,0);
            ResultDescription{end+1}=formatTemplate;
            ResultDetails{end+1}={};
            modelAdvisorObj.setCheckResultStatus(true);

        end

        if isfield(sscCodeGenWorkflowObj.StateSpaceParameters(1),'DiscreteSampleTime')
            sampleTime=sscCodeGenWorkflowObj.StateSpaceParameters(1).DiscreteSampleTime;
        else
            sampleTime=sscCodeGenWorkflowObj.PartSolvers{1}.SampleTime;
        end

        TextObj=ModelAdvisor.Text(['Discrete sample time of all Simscape networks: ',num2str(sampleTime)]);
        ResultDescription{end+1}=TextObj;
        ResultDetails{end+1}={};
        if sscCodeGenWorkflowObj.SolverTypes(1)
            titleObj=ModelAdvisor.Text('Summary of the Partition Solver representation:');
            ResultDescription{end+1}=titleObj;%#ok<*AGROW>
            ResultDetails{end+1}={};


            for i=1:numel(sscCodeGenWorkflowObj.SolverTypes)
                netTxt=['Details related to the Simscape network ',ssccodegenutils.getBlockHyperlink(solverBlks{i})];
                netObj=ModelAdvisor.Text(netTxt);
                setBold(netObj,'true');
                ResultDescription{end+1}=netObj;
                ResultDetails{end+1}={};

                report=sscCodeGenWorkflowObj.PartSolvers{i}.discretizeReport;
                tableObj=ModelAdvisor.FormatTemplate('TableTemplate');
                setColTitles(tableObj,[{'Clump'},{'Parameter size of Ad'},{'Parameter size of Bd'}]);
                if~isempty(report{1})
                    addRow(tableObj,[{'Differential Clump'},report(1),{' '}]);
                end
                for j=2:numel(report)
                    addRow(tableObj,[{['Algebraic Clump ',num2str(j-1)]},...
                    report{j}(1),report{j}(2)]);

                end
                setSubBar(tableObj,0);
                ResultDescription{end+1}=tableObj;
                ResultDetails{end+1}={};


            end


        else

            titleObj=ModelAdvisor.Text('Summary of the state-space representation:');
            ResultDescription{end+1}=titleObj;%#ok<*AGROW>
            ResultDetails{end+1}={};

            for i=1:numel(sscCodeGenWorkflowObj.StateSpaceParameters)
                netTxt=['Details related to the Simscape network ',ssccodegenutils.getBlockHyperlink(solverBlks{i})];
                netObj=ModelAdvisor.Text(netTxt);
                setBold(netObj,'true');
                ResultDescription{end+1}=netObj;
                ResultDetails{end+1}={};



                tableObj=ModelAdvisor.FormatTemplate('TableTemplate');
                setColTitles(tableObj,[{'Parameter'},{'Parameter size'}]);
                addRow(tableObj,[{'A'},...
                {[num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Ad,1))...
                ,' x ',num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Ad,2))...
                ,' x ',num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Ad,3))]}]);
                addRow(tableObj,[{'B'},...
                {[num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Bd,1))...
                ,' x ',num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Bd,2))...
                ,' x ',num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Bd,3))]}]);
                addRow(tableObj,[{'F0'},...
                {[num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).F0d,1))...
                ,' x ',num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).F0d,2))...
                ,' x ',num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).F0d,3))]}]);
                addRow(tableObj,[{'C'},...
                {[num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Cd,1))...
                ,' x ',num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Cd,2))...
                ,' x ',num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Cd,3))]}]);
                addRow(tableObj,[{'D'},...
                {[num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Dd,1))...
                ,' x ',num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Dd,2))...
                ,' x ',num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Dd,3))]}]);
                addRow(tableObj,[{'Y0'},...
                {[num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Y0d,1))...
                ,' x ',num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Y0d,2))...
                ,' x ',num2str(size(sscCodeGenWorkflowObj.StateSpaceParameters(i).Y0d,3))]}]);
                setSubBar(tableObj,0);
                ResultDescription{end+1}=tableObj;
                ResultDetails{end+1}={};
            end
        end

        resetSubsequentTasks(modelAdvisorObj);
    catch me

        formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
        setSubResultStatus(formatTemplate,'Fail');
        setSubResultStatusText(formatTemplate,ModelAdvisor.Text(me.message()));
        setSubBar(formatTemplate,0);
        ResultDescription{end+1}=formatTemplate;
        ResultDetails{end+1}={};
        modelAdvisorObj.setCheckResultStatus(false);
    end
end


