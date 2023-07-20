classdef CustomCheck<handle








    properties(Access=private)
        DataFile='';
        Constraints;
        CompositeConstraints=[];
        NumConstraints=0;
        ResultStatus=false;
        EnableFixIt=false;
        ErrorSeverity=0;
        CheckOutputFormatting;
        HasCustomFixCallback=false;


        CompileState='None';
        SupportLibrary=true;
        SupportExclusion=false;
        HasFix=false;
    end

    properties(Access=private)
        CheckType;
    end

    properties(Constant,Access=private)
        PossibleCompileStates={'None','PostCompile'};
    end

    methods
        function this=CustomCheck(dataFile,varargin)



            if~isempty(varargin)
                if rem(length(varargin),2)~=0
                    DAStudio.error('Advisor:engine:invalidArgPairing','Advisor.authoring.CustomCheck');
                end

                if~ischar(varargin{1})
                    DAStudio.error('Advisor:engine:NonStringPropertyName');
                end

                for i=1:2:length(varargin)
                    if strcmpi(varargin{i},'CustomActionCallback')
                        if~islogical(varargin{i+1})
                            DAStudio.error('Advisor:engine:UnsupportedMethodInput','Advisor.authoring.CustomCheck');
                        else
                            this.HasCustomFixCallback=varargin{i+1};
                        end
                    elseif strcmpi(varargin{i},'CheckType')
                        if~ischar(varargin{i+1})
                            DAStudio.error('Advisor:engine:UnsupportedMethodInput','Advisor.authoring.CustomCheck');
                        else
                            this.CheckType=varargin{i+1};
                        end
                    else
                        DAStudio.error('Advisor:engine:UnknownProperty',varargin{1});
                    end
                end
            end

            this.DataFile=Advisor.authoring.DataFile(dataFile);

            this.Constraints=containers.Map('KeyType','char','ValueType','any');

            this.CheckOutputFormatting=Advisor.authoring.OutputFormatting('check');

            domObj=this.DataFile.parseAndValidate;

            this.scanDataFileContent(domObj);

            this.Constraints=this.verifyConstraintDependencies(this.Constraints);

            if(numel(this.CompositeConstraints)>0)
                this.CompositeConstraints=...
                this.verifyCompositeConstraintDependencies(this.CompositeConstraints,this.Constraints);
            end


            if~strcmp(this.CheckType,'BlockConstraint')

                this.aggregateConstraintProperties();


                this.ErrorSeverity=this.getErrorSeverity();
            end
        end



        function[checkStatus,constraintData]=getConstraintResultData(this)
            constraintData=cell(this.NumConstraints);


            checkStatus=this.ResultStatus;

            constraintIDs=this.Constraints.keys;

            for n=1:this.NumConstraints
                constraint=this.Constraints(constraintIDs{n});
                constraintData{n}=constraint.getConstraintResultData();
            end
        end
    end

    methods(Hidden)





        function of=getOutputFormattingObj(this)

            of=Advisor.authoring.OutputFormatting('check');


            if this.ResultStatus==true
                statusString='Pass';
            else
                if this.ErrorSeverity==0
                    statusString='Warn';
                else
                    statusString='Fail';
                end
            end
            of.setResultStatus(statusString);
            of.setDataFileName(this.DataFile.getFileName());


            of.setConstraints(this.Constraints);
        end




        function getDocumentation(this)

            filename=this.DataFile.getFileName();
            [~,name,~]=fileparts(filename);
            filename=[name,'.html'];

            fid=fopen(filename,'w+');

            doc=Advisor.Document;
            doc.setTitle(sprintf('Documentation for data file %s.',this.DataFile.getFileName()));

            table=Advisor.Table(3,1);
            table.setRowHeading(1,'Data File name');
            table.setRowHeading(2,'Data File full path');
            table.setRowHeading(3,'Number of constraints');
            table.setEntry(1,1,this.DataFile.getFileName());
            table.setEntry(2,1,which(this.DataFile.getFileName()));
            table.setEntry(3,1,num2str(this.NumConstraints));
            doc.addItem([table,Advisor.LineBreak]);

            doc.addItem('Table of constraints:');

            keys=this.Constraints.keys;
            for n=1:this.NumConstraints
                constraint=this.Constraints(keys{n});
                p=constraint.getDocumentation();
                doc.addItem(p);
            end

            fprintf(fid,'%s',doc.emitHTML);
            fclose(fid);

        end

        function def=getCheckDefintionData(this)
            def.CompileStatus=this.CompileState;
            def.HasAction=this.HasFix;
            def.SupportExclusion=this.SupportExclusion;
            def.SupportLibrary=this.SupportLibrary;
            def.ErrorSeverity=this.ErrorSeverity;
        end



        function status=hasDataFileNameChanged(this,newName)
            status=true;


            oldPathString=this.DataFile.getPathString();

            [path,~,~]=fileparts(newName);



            if isempty(path)
                if exist(newName,'file')~=2
                    DAStudio.error('Advisor:engine:CCIncorrectDataFile');
                else
                    newName=which(newName);
                end
            end

            if strcmp(oldPathString,newName)
                status=false;
            end
        end
    end


    methods(Access=private)

        scanDataFileContent(this,domObj);




        function rescanDataFile(this)
            this.Constraints=containers.Map('KeyType','char','ValueType','any');
            this.NumConstraints=0;

            this.CompositeConstraints='';

            domObj=this.DataFile.parseAndValidate;

            this.scanDataFileContent(domObj);

            this.Constraints=this.verifyConstraintDependencies(this.Constraints);

            if(numel(this.CompositeConstraints)>0)
                this.CompositeConstraints=...
                this.verifyCompositeConstraintDependencies(this.CompositeConstraints,this.Constraints);
            end

            if~strcmp(this.CheckType,'BlockConstraint')
                this.aggregateConstraintProperties();
            end

            this.DataFile.updateTimeStamp();
        end





        function aggregateConstraintProperties(this)

            this.SupportLibrary=true;
            this.SupportExclusion=false;
            this.CompileState='None';
            this.HasFix=false;

            constraintIDs=this.Constraints.keys;

            for n=1:this.NumConstraints
                constraint=this.Constraints(constraintIDs{n});


                currentCompileStateIdx=find(strcmp(this.PossibleCompileStates,...
                this.CompileState),1);

                constraintCompileStateIdx=find(strcmp(this.PossibleCompileStates,...
                constraint.CompileState),1);

                if isempty(constraintCompileStateIdx)
                    DAStudio.error('Advisor:engine:CCUnsupportedCompileState');
                end

                if constraintCompileStateIdx>currentCompileStateIdx
                    this.CompileState=constraint.CompileState;
                end


                this.SupportLibrary=this.SupportLibrary&&constraint.SupportLibrary;




                this.SupportExclusion=this.SupportExclusion&&constraint.SupportExclusion;


                this.HasFix=this.HasFix||constraint.HasFix;
            end
        end




        function[checkResultStatus,resultData]=checkCompatability(this,system)
            checkResultStatus=true;

            if~strcmp(this.CheckType,'BlockConstraint')

                this.refresh();
            end

            constraintIDs=this.Constraints.keys;

            if(numel(this.CompositeConstraints)>0)
                resultData=[];
                for n=1:numel(this.CompositeConstraints)
                    [tempResultStatus,tempResultData]=this.CompositeConstraints{n}.check(system);
                    checkResultStatus=checkResultStatus&&tempResultStatus;
                    resultData=[resultData;tempResultData];%#ok<AGROW>
                end
            else
                resultData=[];
                for n=1:this.NumConstraints


                    if this.Constraints(constraintIDs{n}).IsRootConstraint

                        [tempResultStatus,tempResultData,~,~]=this.checkConstraint(system,constraintIDs{n});
                        checkResultStatus=checkResultStatus&&tempResultStatus;
                        resultData=[resultData,tempResultData];%#ok<AGROW>
                    end
                end
            end

            this.setResultStatus(checkResultStatus);


            this.saveObjectWithModelAdvisor;


            this.setFixItStatus;
        end



        function result=fixCompatabilityIssues(this,system)
            constraintIDs=this.Constraints.keys;

            for n=1:this.NumConstraints
                tempConstraint=this.Constraints(constraintIDs{n});

                if tempConstraint.Status==false

                    tempConstraint.fixIncompatability(system);
                end
            end


            mdlAdvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
            mdlAdvObj.setActionEnable(false);

            of=Advisor.authoring.OutputFormatting('action');
            of.setConstraints(this.Constraints);


            result=of.getFormattedOutput(system);
        end



        function status=isDataFileUpToDate(this)
            status=false;

            if this.DataFile.isUpToDate
                status=true;
            end
        end


        function ft=getFormattedCheckOutput(this,system)


            of=this.CheckOutputFormatting;


            if this.ResultStatus==true
                statusString='Pass';
            else
                if this.ErrorSeverity==0
                    statusString='Warn';
                else
                    statusString='Fail';
                end
            end
            of.setResultStatus(statusString);
            of.setDataFileName(this.DataFile.getFileName());


            of.setConstraints(this.Constraints);


            ft=of.getFormattedOutput(system);
        end


        function addConstraint(this,Constraint)
            if~(isa(Constraint,'Advisor.authoring.Constraint')||isa(Constraint,'Advisor.authoring.internal.Constraint'))
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','addConstraint');
            end

            this.Constraints(Constraint.getID())=Constraint;
            this.NumConstraints=this.NumConstraints+1;
        end


        function addCompositeConstraint(this,Constraint)
            if~(isa(Constraint,'Advisor.authoring.CompositeConstraint'))
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','addCompositeConstraint');
            end

            this.CompositeConstraints{end+1}=Constraint;
        end




        function setFixItStatus(this)




            mdlAdvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;


            id=mdlAdvObj.getActiveCheck;


            c=mdlAdvObj.CheckCellArray{mdlAdvObj.CheckIDMap(id)};

            if~isempty(c.Action)
                if(this.ResultStatus==false)&&(this.EnableFixIt||...
                    this.HasCustomFixCallback)
                    mdlAdvObj.setActionEnable(true);
                else
                    mdlAdvObj.setActionEnable(false);
                end
            end
        end




        function refresh(this)
            constraintIDs=this.Constraints.keys;

            this.EnableFixIt=false;
            this.ResultStatus=false;

            for n=1:this.NumConstraints
                constraint=this.Constraints(constraintIDs{n});
                constraint.refreshStatus();
            end
        end



        function status=checkConstraintID(this,IDString)
            if this.Constraints.isKey(IDString)
                status=false;
            else
                status=true;
            end
        end



        function setResultStatus(this,status)
            this.ResultStatus=status;
        end

        [constrResultStatus,constrResultData,wasChecked,isInformational]=checkConstraint(this,system,constraintID)






        function saveObjectWithModelAdvisor(this)
            maObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();

            id=maObj.getActiveCheck();



            storage=Advisor.authoring.CheckStorage.getInstance;
            storage.setData(id,this);
        end


        function validateAggregatedProperties(this)

            maObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
            checkObj=maObj.CheckCellArray{maObj.CheckIDMap(maObj.getActiveCheck)};
            properties='';

            if checkObj.SupportLibrary~=this.SupportLibrary
                properties=[properties,'SupportLibrary, '];
            end

            if checkObj.SupportExclusion~=this.SupportExclusion
                properties=[properties,'SupportExclusion, '];
            end


            if~strcmp(checkObj.CallbackContext,this.CompileState)
                properties=[properties,'CompileState, '];
            end


            if~this.HasCustomFixCallback&&(~isempty(checkObj.Action))~=this.HasFix
                properties=[properties,'Action, '];
            end


            if~isempty(properties)
                properties=[properties(1:end-2),'.'];
                DAStudio.error('Advisor:engine:CCCheckDefOutdated',properties);
            end
        end
    end

    methods(Static)







        function[checkResultStatus,resultData]=checkAlgorithmCallback(system,varargin)
            maObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();


            storage=Advisor.authoring.CheckStorage.getInstance;

            checkID=maObj.getActiveCheck;

            cc=storage.getData(checkID);





            if nargin>1&&rem(length(varargin),2)==1
                dataFileName=varargin{1};
                varargin(1)=[];
                checkType='';
            else

                inputParams=maObj.getInputParameters(checkID);
                dataFileName=inputParams{1}.Value;

                checkObj=maObj.getCheckObj(checkID);
                if(checkObj.getIsBlockConstraintCheck())
                    checkType='BlockConstraint';
                else
                    checkType='';
                end
            end


            if isempty(cc)||cc.hasDataFileNameChanged(dataFileName)
                if strcmp(checkType,'BlockConstraint')
                    varargin={varargin{:},'CheckType',checkType};
                    cc=Advisor.authoring.CustomCheck(dataFileName,varargin{:});
                else
                    cc=Advisor.authoring.CustomCheck(dataFileName,varargin{:});
                end
            elseif~cc.isDataFileUpToDate
                cc.rescanDataFile;
            end






            cc.validateAggregatedProperties();


            [checkResultStatus,resultData]=cc.checkCompatability(system);

        end

        function ResultDescription=checkCallback(system,varargin)




            checkType='';
            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
            checkID=mdladvObj.getActiveCheck;

            checkObj=mdladvObj.getCheckObj(checkID);
            if(checkObj.getIsBlockConstraintCheck())
                checkType='BlockConstraint';
            else
                checkType='';
            end

            mdladvObj.setCheckResultStatus(false);
            ResultDescription={};


            if isempty(varargin)
                [status,ResultData]=Advisor.authoring.CustomCheck.checkAlgorithmCallback(system);
            else
                [status,ResultData]=Advisor.authoring.CustomCheck.checkAlgorithmCallback(system,varargin{:});
            end

            if strcmp(checkType,'BlockConstraint')
                storage=Advisor.authoring.CheckStorage.getInstance;
                CustomCheckObj=storage.getData(checkID);
                ResultDescription=Advisor.authoring.CustomCheck.outputFormattingCallbackForBlockConstraints(status,CustomCheckObj,ResultData);
            else

                ResultDescription{end+1}=Advisor.authoring.CustomCheck.outputFormattingCallback();
            end

            mdladvObj.setCheckResultStatus(status);
        end

        function newStyleCheckCallback(system,CheckObj,varargin)




            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
            mdladvObj.setCheckResultStatus(false);


            if isempty(varargin)
                [status,ResultData]=Advisor.authoring.CustomCheck.checkAlgorithmCallback(system);
            else
                [status,ResultData]=Advisor.authoring.CustomCheck.checkAlgorithmCallback(system,varargin{:});
            end


            storage=Advisor.authoring.CheckStorage.getInstance;
            cc=storage.getData(CheckObj.ID);
            of=cc.CheckOutputFormatting;

            [Description,StatusMsg,RecAction]=of.getResultDetailsInfo();

            for ii=1:numel(ResultData)
                ResultData(ii).Description=Description;
                ResultData(ii).Status=StatusMsg;
                ResultData(ii).RecAction=RecAction;
            end

            CheckObj.setResultDetails(ResultData);


            mdladvObj.setCheckResultStatus(status);
        end

        function ResultDescription=newStyleReportCallback(CheckObj)
            storage=Advisor.authoring.CheckStorage.getInstance;
            cc=storage.getData(CheckObj.ID);
            maObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();
            ResultDescription=cc.getFormattedCheckOutput(maObj.SystemName);
        end




        function ft=outputFormattingCallback()
            maObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();

            id=maObj.getActiveCheck();

            storage=Advisor.authoring.CheckStorage.getInstance;
            cc=storage.getData(id);

            ft=cc.getFormattedCheckOutput(maObj.SystemName);
        end



        function result=actionCallback(~)




            maObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();

            id=maObj.getActiveCheck();

            storage=Advisor.authoring.CheckStorage.getInstance;
            cc=storage.getData(id);

            result=num2cell(cc.fixCompatabilityIssues(maObj.SystemName));
        end





        constraints=verifyConstraintDependencies(constraints)
        composites=verifyCompositeConstraintDependencies(composites,constraints)
    end

    methods(Static=true,Access=private)



        ft=outputFormattingCallbackForBlockConstraints(status,CustomCheckObj,ResultData)


        function severity=getErrorSeverity()

            maObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj();

            if~isempty(maObj)
                checkId=maObj.getActiveCheck;

                if~isempty(checkId)
                    checkObj=maObj.getCheckObj(maObj.getActiveCheck);

                    severity=checkObj.ErrorSeverity;
                else
                    severity=0;
                end
            else
                severity=0;
            end
        end
    end
end

