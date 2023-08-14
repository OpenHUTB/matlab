classdef SemanticsComplianceCheck<Simulink.sfunction.analyzer.internal.ComplianceCheck


    properties
Description
Category
IsLibrary
    end
    methods
        function obj=SemanticsComplianceCheck(description,category)
            obj@Simulink.sfunction.analyzer.internal.ComplianceCheck(description,category);
        end

        function input=constructInput(obj,inputStruct)
            input=inputStruct;
        end

        function[combinedOutput,x,y]=execute(obj,input)
            model=input.model;
            rootDir=input.rootDir;
            x='';
            y='';
            errorOccurs=0;
            [targets,targetBlockMap]=Simulink.sfunction.analyzer.findSfunctions(model);
            keySet=unique(targets);
            valueSet=cell(1,numel(keySet));
            combinedOutput=containers.Map(keySet,valueSet);

            if isequal(get_param(model,'BlockDiagramType'),'library')
                obj.IsLibrary=true;
                for i=1:numel(targets)
                    [testHarnessModel,errorOccurs,output]=Simulink.sfunction.analyzer.internal.createTestHarnessModel(targets{i},...
                    targetBlockMap(targets{i}),fullfile(rootDir,targets{i}));
                    if errorOccurs==1
                        combinedOutput(targets{i})=output;
                    else
                        try
                            load_system(testHarnessModel);
                            sim(testHarnessModel,'TimeOut',input.TimeOut);
                        catch ex
                            errorOccurs=1;
                        end
                        if errorOccurs==1
                            combinedOutput=obj.getErrorResults(combinedOutput,ex,targets{i});
                        else
                            combinedOutput=obj.getNormalResults(combinedOutput,targets{i});
                        end
                    end
                    close_system(testHarnessModel,0);
                end
            elseif isequal(get_param(model,'BlockDiagramType'),'model')
                obj.IsLibrary=false;
                try
                    sim(model,'TimeOut',input.TimeOut);
                catch me
                    errorOccurs=1;
                end
                if errorOccurs==1
                    combinedOutput=obj.getErrorResults(combinedOutput,me);
                else
                    combinedOutput=obj.getNormalResults(combinedOutput);
                end
            end
        end



        function combinedOutput=getErrorResults(obj,combinedOutput,me,varargin)
            temp.summaryResult=Simulink.sfunction.analyzer.internal.ComplianceCheck.FAIL;
            temp.summaryNum=1;
            temp.content={};
            temp.category=Simulink.sfunction.analyzer.internal.ComplianceCheck.MEX_FILE_CHECK;
            if~obj.IsLibrary
                ss.description='ModelCompileError';
                ss.result=Simulink.sfunction.analyzer.internal.ComplianceCheck.FAIL;
                ss.details={me};
                temp.content{1}=ss;
                keySet=keys(combinedOutput);
                for j=1:numel(keySet)
                    temp.target=keySet{j};
                    combinedOutput(keySet{j})=temp;
                end
            else
                ss.description='TestHarnessCreationError';
                ss.result=Simulink.sfunction.analyzer.internal.ComplianceCheck.FAIL;
                ss.details={me};
                temp.content{1}=ss;
                temp.target=varargin{1};
                combinedOutput(temp.target)=temp;
            end
        end
        function combinedOutput=getNormalResults(obj,combinedOutput,varargin)
            resultMessage=Simulink.SFunCheckResult.getResultMessage();
            if isempty(resultMessage)
                temp.category=Simulink.sfunction.analyzer.internal.ComplianceCheck.MEX_FILE_CHECK;
                temp.summaryResult=Simulink.sfunction.analyzer.internal.ComplianceCheck.PASS;
                temp.summaryNum=0;
                temp.content={};
                if~obj.IsLibrary
                    keySet=keys(combinedOutput);
                    for j=1:numel(keySet)
                        temp.target=keySet{j};
                        combinedOutput(keySet{j})=temp;
                    end
                else
                    temp.target=varargin{1};
                    combinedOutput(varargin{1})=temp;
                end
            else
                temp.category=Simulink.sfunction.analyzer.internal.ComplianceCheck.MEX_FILE_CHECK;
                temp.summaryResult=Simulink.sfunction.analyzer.internal.ComplianceCheck.PASS;
                temp.summaryNum=0;
                temp.content={};
                if~obj.IsLibrary
                    keySet=keys(combinedOutput);
                    for j=1:numel(keySet)
                        temp.target=keySet{j};
                        combinedOutput(keySet{j})=temp;
                    end
                end
                for i=1:numel(resultMessage)
                    msg=resultMessage(i);
                    [~,target,~]=fileparts(msg.SfcnName);
                    temp1.summaryResult=Simulink.sfunction.analyzer.internal.ComplianceCheck.WARNING;
                    temp1.summaryNum=msg.NumberOfIssues;

                    temp1.target=target;
                    temp1.category=Simulink.sfunction.analyzer.internal.ComplianceCheck.MEX_FILE_CHECK;
                    temp1.content=cell(1,temp1.summaryNum);
                    for j=1:temp1.summaryNum
                        tokens=strsplit(msg.Details{j}.Identifier,':');
                        ss.description=tokens{3};

                        if any(strcmp(ss.description,{'CombinedMdlOutputsMdlUpdateWithDiscreteState','ThreadSafetyComplianceUnknown','NotExceptionFree'}))
                            ss.result=Simulink.sfunction.analyzer.internal.ComplianceCheck.WARNING;
                        else
                            ss.result=Simulink.sfunction.analyzer.internal.ComplianceCheck.FAIL;
                            temp1.summaryResult=Simulink.sfunction.analyzer.internal.ComplianceCheck.FAIL;
                        end


                        ss.details={MSLDiagnostic([],msg.Details{j})};
                        temp1.content{j}=ss;
                    end
                    combinedOutput(target)=temp1;
                end
            end

        end
    end
end