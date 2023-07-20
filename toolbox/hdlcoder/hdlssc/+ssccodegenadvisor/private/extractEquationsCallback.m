function[ResultDescription,ResultDetails]=extractEquationsCallback(sys)





    ResultDescription={};
    ResultDetails={};


    modelAdvisorObj=Simulink.ModelAdvisor.getModelAdvisor(sys);
    modelAdvisorObj.setCheckErrorSeverity(1);


    sscCodeGenWorkflowObjCheck=modelAdvisorObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
    sscCodeGenWorkflowObj=sscCodeGenWorkflowObjCheck.ResultData;

    try


        sscCodeGenWorkflowObj.extractEquations();

        solverBlks=sscCodeGenWorkflowObj.SolverConfiguration;


        info=sscCodeGenWorkflowObj.StateSpaceParametersDeamon;


        if(sscCodeGenWorkflowObj.NumberOfSolverIterations<sscCodeGenWorkflowObj.MaxAllowedIters)||sscCodeGenWorkflowObj.UseFixedCost

            formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
            setSubResultStatus(formatTemplate,'Pass');
            setSubBar(formatTemplate,0);
            ResultDescription{end+1}=formatTemplate;
            ResultDetails{end+1}={};

            modelAdvisorObj.setCheckResultStatus(true);
            if sscCodeGenWorkflowObj.UseFixedCost
                iterText=ModelAdvisor.Text(message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:MaxIterationNumberReportFixed').getString);

            else
                iterText=ModelAdvisor.Text(message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:MaxIterationNumberReport',num2str(sscCodeGenWorkflowObj.NumberOfSolverIterations)).getString);
            end
            ResultDescription{end+1}=iterText;
            ResultDetails{end+1}={};


        else





            formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
            setSubResultStatus(formatTemplate,'Warn');
            setSubBar(formatTemplate,0);
            ResultDescription{end+1}=formatTemplate;
            ResultDetails{end+1}={};

            iterText=ModelAdvisor.FormatTemplate('ListTemplate');
            setSubResultStatusText(iterText,...
            ModelAdvisor.Text(message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:MaxIterationNumberExceeded',num2str(sscCodeGenWorkflowObj.MaxAllowedIters)).getString));

            setSubBar(iterText,0);

            setRecAction(iterText,ModelAdvisor.Text(message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:MaxIterationNumberExceededRecommendation').getString));

            modelAdvisorObj.setCheckResultStatus(false);
            modelAdvisorObj.setCheckErrorSeverity(0);

            solverList=ModelAdvisor.FormatTemplate('ListTemplate');
            setListObj(solverList,sscCodeGenWorkflowObj.SolverConfiguration);


            ResultDescription{end+1}=iterText;
            ResultDetails{end+1}={};

            ResultDescription{end+1}=solverList;
            ResultDetails{end+1}={};


        end

        for i=1:numel(sscCodeGenWorkflowObj.SolverTypes)
            if~sscCodeGenWorkflowObj.SolverTypes(1)
                if numel(info(i).data)==1

                    titleObj=ModelAdvisor.Text([sys,' is purely linear.']);
                    ResultDescription{end+1}=titleObj;
                    ResultDetails{end+1}={};
                end
            end
            netTxt=['Details related to the Simscape network ',ssccodegenutils.getBlockHyperlink(solverBlks{i})];
            netObj=ModelAdvisor.Text(netTxt);
            setBold(netObj,'true');
            ResultDescription{end+1}=netObj;
            ResultDetails{end+1}={};

            if sscCodeGenWorkflowObj.SolverTypes(1)

                report=sscCodeGenWorkflowObj.PartSolvers{i}.extractEquationsReport;


                listObj=ModelAdvisor.List();
                listObj.setType('bulleted');
                for j=1:numel(report)
                    listObj.addItem(ModelAdvisor.Text(report{j}))
                end
                ResultDescription{end+1}=listObj;%#ok<*AGROW>
                ResultDetails{end+1}={};

            else


                if isscalar(sscCodeGenWorkflowObj.NumberOfDifferentialVariables)&&sscCodeGenWorkflowObj.NumberOfDifferentialVariables==0
                    sscCodeGenWorkflowObj.NumberOfDifferentialVariables=zeros(1,numel(info));
                end

                listObj=ModelAdvisor.List();
                listObj.setType('bulleted');
                listObj.addItem(ModelAdvisor.Text(['Number of states: ',num2str(size(info(i).data(1).A,1))]));
                listObj.addItem(ModelAdvisor.Text(['Number of inputs: ',num2str(size(info(i).data(1).B,2))]));
                listObj.addItem(ModelAdvisor.Text(['Number of outputs: ',num2str(size(info(i).data(1).C,1))]));
                listObj.addItem(ModelAdvisor.Text(['Number of modes: ',num2str(numel(info(i).data))]));
                listObj.addItem(ModelAdvisor.Text(['Number of differential variables: ',num2str(sscCodeGenWorkflowObj.NumberOfDifferentialVariables(i))]));
                ResultDescription{end+1}=listObj;%#ok<*AGROW>
                ResultDetails{end+1}={};
            end
        end

        resetSubsequentTasks(modelAdvisorObj);
    catch me

        if strcmpi(me.identifier,'getStateSpaceParameters:InfStopTime')
            formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
            setSubResultStatus(formatTemplate,'Fail');
            setSubResultStatusText(formatTemplate,ModelAdvisor.Text(me.message()));
            setRecAction(formatTemplate,...
            ModelAdvisor.Text(message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:InfStopTimeRecommendation').getString));

            setSubBar(formatTemplate,0);
            ResultDescription{end+1}=formatTemplate;
            ResultDetails{end+1}={};
        elseif strcmpi(me.identifier,'physmod:simscape:engine:sli:swl:Nonfinite')



            solverConfiguration=sscCodeGenWorkflowObj.SolverConfiguration;
            recommendation=false;
            for i=1:numel(solverConfiguration)
                solverBlk=solverConfiguration{i};
                useLocalSolver=get_param(solverBlk,'UseLocalSolver');
                if strcmp(useLocalSolver,'on')
                    solverChoice=get_param(solverBlk,'LocalSolverChoice');
                    partitionMethod=get_param(solverBlk,'PartitionMethod');
                    if strcmp(solverChoice,'NE_PARTITIONING_ADVANCER')&&strcmp(partitionMethod,'FAST')
                        recommendation=true;
                    end
                end
            end

            simscapeModel=sscCodeGenWorkflowObj.SimscapeModel;

            altMessage='';

            listHeader='';

            listBody=[];

            if recommendation
                recommendationKey='PartitionMethodRecommendation';
            else
                recommendationKey='';
            end

            useModelName=false;
            [formatTemplate1,formatTemplate2]=utilCreateAdvisorError(...
            me,altMessage,listHeader,...
            listBody,recommendationKey,simscapeModel,useModelName);
            ResultDescription{end+1}=formatTemplate1;
            ResultDetails{end+1}={};
            if~isempty(formatTemplate2)
                ResultDescription{end+1}=formatTemplate2;
                ResultDetails{end+1}={};
            end
            modelAdvisorObj.setCheckResultStatus(false);
        elseif~isempty(me.cause)&&isa(me.cause{1},'MSLException')
            if strcmpi(me.cause{1}.identifier,'physmod:simscape:engine:sli:swl:HdlCodeGenFailed')
                messages=unique(cellfun(@(cause)cause.message,me.cause{1}.cause,'UniformOutput',false));

                blocks=cellfun(@(text)regexp(text,'''(.*)''','tokens'),messages,'UniformOutput',false);
                blocks=blocks(~cellfun(@isempty,blocks));

                blocks=cellfun(@(block)block{1},blocks,'UniformOutput',false);
                blocks=cellfun(@(block)block{1},blocks,'UniformOutput',false);

                listHeader='Unsupported nonlinear blocks in the model:';
                recommendationKey='NonlinearSSCModelRecommendation';
                useModelName=true;
                altMessage='';


                [formatTemplate1,formatTemplate2]=utilCreateAdvisorError(me,altMessage,listHeader,...
                blocks,recommendationKey,sscCodeGenWorkflowObj.SimscapeModel,useModelName);
                ResultDescription{end+1}=formatTemplate1;
                ResultDetails{end+1}={};
                if~isempty(formatTemplate2)
                    ResultDescription{end+1}=formatTemplate2;
                    ResultDetails{end+1}={};
                end
                modelAdvisorObj.setCheckResultStatus(false);
            end

        else

            formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
            setSubResultStatus(formatTemplate,'Fail');
            setSubResultStatusText(formatTemplate,ModelAdvisor.Text(me.message()));
            setSubBar(formatTemplate,0);
            ResultDescription{end+1}=formatTemplate;
            ResultDetails{end+1}={};
            modelAdvisorObj.setCheckResultStatus(false);
        end
    end
end

