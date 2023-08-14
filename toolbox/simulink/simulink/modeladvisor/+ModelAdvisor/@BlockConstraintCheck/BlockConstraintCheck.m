classdef(CaseInsensitiveProperties=true)BlockConstraintCheck<ModelAdvisor.internal.EdittimeCheck




    properties(Access=private)
        ConstraintsGeneratorFunctionHandle=[]
        ConstraintInfo=[];
    end
    properties
        isNewStyle=false;
    end

    methods(Access=public)

        function CheckObj=BlockConstraintCheck(checkID,varargin)


            inputParser=ModelAdvisor.BlockConstraintCheck.inputParamParser(checkID,varargin);
            checkID=inputParser.Results.CheckID;

            CheckObj=CheckObj@ModelAdvisor.internal.EdittimeCheck(checkID);
            CheckObj.CallbackStyle='DetailStyle';

            CheckObj.CallbackContext='None';


            CheckObj.SupportHighlighting=true;
            CheckObj.SupportExclusion=true;
            CheckObj.SupportsEditTime=true;
            CheckObj.setIsBlockConstraintCheck(true);
            CheckObj.DefaultSelection=false;


            CheckObj.setReportStyle('ModelAdvisor.Report.BlockParameterStyle');
            CheckObj.setSupportedReportStyles({'ModelAdvisor.Report.BlockParameterStyle'});

            if~isempty(inputParser.Results.Constraints)
                CheckObj.ConstraintsGeneratorFunctionHandle=inputParser.Results.Constraints;
                CheckObj.isNewStyle=true;
            elseif~isempty(inputParser.Results.XMLFile)
                CheckObj.ConstraintInfo=fileread(inputParser.Results.XMLFile);
                CheckObj.isNewStyle=true;
            elseif~isempty(inputParser.Results.XMLString)
                CheckObj.ConstraintInfo=inputParser.Results.XMLString;
                CheckObj.isNewStyle=true;
            else
                CheckObj.isNewStyle=false;
            end

        end

        function ObjToBeSaved=saveobj(obj)
            ObjToBeSaved.class=class(obj);
            fnames=fieldnames(obj);
            for i=1:length(fnames)

                if any(strcmp(fnames{i},{'CallbackHandle','ResultDetails','status'}))
                    continue;
                end

                ObjToBeSaved.(fnames{i})=obj.(fnames{i});
            end
            ObjToBeSaved.ConstraintInfo=obj.ConstraintInfo;
            ObjToBeSaved.Index=obj.Index;
            ObjToBeSaved.ConstraintsGeneratorFunctionHandle=obj.ConstraintsGeneratorFunctionHandle;
        end

        function constraintString=getConstraintString(this)
            if~isempty(this.ConstraintsGeneratorFunctionHandle)
                constraintString=Advisor.authoring.generateBlockConstraintsDataFile...
                ('constraints.xml',...
                'Constraints',this.ConstraintsGeneratorFunctionHandle(),...
                'GenerateString',true);
            elseif~isempty(this.ConstraintInfo)
                constraintString=this.ConstraintInfo;
            else
                DAStudio.error('edittimecheck:engine:MissingConstraintInfo',this.ID);
            end

        end

        function setConstraints(this,constraintFile)
            this.ConstraintInfo=fileread(constraintFile);
            this.isNewStyle=true;
        end

    end

    methods(Static)
        function ipParser=inputParamParser(checkID,ipValues)

            ipParser=inputParser;

            addRequired(ipParser,'CheckID',@(x)ischar(x))
            addParameter(ipParser,'Constraints',[],@(x)isa(x,'function_handle'))
            addParameter(ipParser,'XMLFile',[],@(x)isempty(Advisor.authoring.DataFile.validate(x)))
            addParameter(ipParser,'XMLString',[],@(x)ischar(x))

            try
                parse(ipParser,checkID,ipValues{:});
            catch ME
                throw(ME);
            end
        end

        function obj=loadobj(savedObj)
            if~isempty(savedObj.ConstraintsGeneratorFunctionHandle)
                obj=ModelAdvisor.BlockConstraintCheck(savedObj.ID,'Constraints',savedObj.ConstraintsGeneratorFunctionHandle);
            elseif~isempty(savedObj.ConstraintInfo)
                obj=ModelAdvisor.BlockConstraintCheck(savedObj.ID,'XMLString',savedObj.ConstraintInfo);
            else
                DAStudio.error('edittimecheck:engine:MissingConstraintInfo',this.ID);
            end

            fnames=fieldnames(savedObj);
            for i=1:length(fnames)
                if any(strcmp(fnames{i},{'class','ResultDetails','status','statusBeforeJustification'}))
                    continue
                end
                obj.(fnames{i})=savedObj.(fnames{i});
            end
        end

    end

end


