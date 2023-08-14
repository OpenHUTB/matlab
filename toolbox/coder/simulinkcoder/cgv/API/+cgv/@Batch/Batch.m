















classdef Batch<handle

    properties
        Name;
        Description;
        TestResultsFileName='TestResults';
        TestList;
    end

    properties(SetAccess=private)
        StartTime;
        StartTic;
    end

    properties(Access=private)
        PreReportFcn={};
        PostReportFcn={};
        HeaderReportFcn={};
        TrailerReportFcn={};
    end


    properties(Hidden)

        ReportData;
    end

    methods
        function this=Batch()
            if~license('test','Cert_Kit_IEC')
                DAStudio.error('RTW:cgv:NoCertKitLicense');
            end
            this.Name='';
            this.Description='';
            this.TestList={};
        end

        function testList=getTests(this,varargin)
            if isempty(varargin)
                name='';
            elseif length(varargin)==1
                name=varargin{1};
                if~ischar(name)
                    DAStudio.error('RTW:cgv:ParamToFcnMustBeString','getTests');
                end
            else
                DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
            end
            listLen=length(this.TestList);
            testList={};
            for listNdx=1:listLen
                test=this.TestList{listNdx};
                objs=cell(1,1);
                objs{1}=test.cgvObj1;
                if~isempty(test.cgvObj2)
                    objs{2}=test.cgvObj2;
                end


                if isempty(name)||...
                    strcmp(name,test.cgvObj1.Name)||...
                    (~isempty(test.cgvObj2)&&strcmp(name,test.cgvObj2.Name))
                    testList{end+1}=objs;%#ok<AGROW>
                end
            end
        end

        function errList=getErrors(this)
            if isempty(this.StartTime)
                DAStudio.error('RTW:cgv:RunHasNotBeenCalled')
            end
            errList={};
            for listNdx=1:length(this.TestList)
                test=this.TestList{listNdx};
                if strcmp(test.result,DAStudio.message('RTW:cgv:RsError'))||...
                    strcmp(test.result,DAStudio.message('RTW:cgv:RsFail'))
                    objs=cell(1,1);
                    objs{1}=test.cgvObj1;
                    if~isempty(test.cgvObj2)
                        objs{2}=test.cgvObj2;
                    end
                    errList{end+1}=objs;%#ok<AGROW>
                end
            end
        end

        function addHeaderReportFcn(this,callbackFcn)
            if nargin~=2
                DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
            end
            this.checkCallback(callbackFcn,1);
            this.HeaderReportFcn=callbackFcn;
        end
        function addPreReportFcn(this,callbackFcn)
            if nargin~=2
                DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
            end
            this.checkCallback(callbackFcn,2);
            this.PreReportFcn=callbackFcn;
        end
        function addPostReportFcn(this,callbackFcn)
            if nargin~=2
                DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
            end
            this.checkCallback(callbackFcn,2);
            this.PostReportFcn=callbackFcn;
        end
        function addTrailerReportFcn(this,callbackFcn)
            if nargin~=2
                DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
            end
            this.checkCallback(callbackFcn,2);
            this.TrailerReportFcn=callbackFcn;
        end
    end

    methods(Access=private)

        function checkCallback(~,callbackFcn,expectedNumArgs)
            if~isa(callbackFcn,'function_handle')
                DAStudio.error('RTW:cgv:NotFunctionHandle');
            elseif nargin(callbackFcn)~=expectedNumArgs
                stk=dbstack;
                DAStudio.error('RTW:cgv:CallbackNeedsNParams',stk(2).name,expectedNumArgs,nargin(callbackFcn));
            end
        end
    end
end

