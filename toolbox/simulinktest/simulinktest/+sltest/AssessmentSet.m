



classdef AssessmentSet
    properties(GetAccess=private,SetAccess=immutable,Hidden)
        Dataset_=Simulink.SimulationData.Dataset();
        Untested_=[];
        Pass_=[];
        Fail_=[];
    end

    methods(Access=private,Hidden)
        function this=AssessmentSet(dataset,untested,pass,fail)
            this.Dataset_=dataset;
            this.Untested_=untested;
            this.Pass_=pass;
            this.Fail_=fail;
        end
    end

    methods
        function disp(this)


            if length(this)~=1
                builtin('disp',this);
                return;
            end

            mc=metaclass(this);
            if feature('hotlinks')
                fprintf('  <a href="matlab: helpPopup %s">%s</a>\n',mc.Name,mc.Name);
            else
                fprintf('  %s\n',mc.Name);
            end

            fprintf('  %s:\n',message('Stateflow:reactive:AssessmentSetSummaryTitle').getString());
            disp(this.getSummary());

            if~isempty(this.Untested_)
                fprintf('\n  %s:\n',message('Stateflow:reactive:AssessmentSetUntestedAsmtTitle').getString());

                for i=1:min(10,length(this.Untested_))
                    idx=this.Untested_(i);
                    elm=this.Dataset_.get(idx);
                    fprintf('    %-2d: %s\n',idx,elm.getDisplayStr());
                end
            end

            if~isempty(this.Pass_)
                fprintf('\n  %s:\n',message('Stateflow:reactive:AssessmentSetPassedAsmtTitle').getString());

                for i=1:min(10,length(this.Pass_))
                    idx=this.Pass_(i);
                    elm=this.Dataset_.get(idx);
                    fprintf('    %-2d: %s\n',idx,elm.getDisplayStr());
                end
            end

            if~isempty(this.Fail_)
                fprintf('\n  %s:\n',message('Stateflow:reactive:AssessmentSetFailedAsmtTitle').getString());

                for i=1:min(10,length(this.Fail_))
                    idx=this.Fail_(i);
                    elm=this.Dataset_.get(idx);
                    fprintf('    %-2d: %s\n',idx,elm.getDisplayStr());
                end
            end
        end

        function summary=getSummary(this)


            summary.Total=this.Dataset_.numElements();
            summary.Untested=length(this.Untested_);
            summary.Passed=length(this.Pass_);
            summary.Failed=length(this.Fail_);
            if summary.Failed>0
                summary.Result=slTestResult.Fail;
            elseif summary.Passed>0
                summary.Result=slTestResult.Pass;
            else
                summary.Result=slTestResult.Untested;
            end
        end

        function asOut=find(this,varargin)
























            if nargin>1
                [varargin{:}]=convertStringsToChars(varargin{:});
            end

            try

                dsOut=this.Dataset_.find(varargin{:});
                if isempty(dsOut)
                    dsOut=Simulink.SimulationData.Dataset();
                end

                n=dsOut.numElements();
                pass=[];
                fail=[];
                untested=[];

                for i=1:n
                    elm=dsOut.get(i);
                    switch elm.Result
                    case slTestResult.Untested
                        untested(end+1)=i;
                    case slTestResult.Pass
                        pass(end+1)=i;
                    case slTestResult.Fail
                        fail(end+1)=i;
                    otherwise
                        assert(false,'unknown result %s',elm.Result);
                    end
                end
                asOut=sltest.AssessmentSet(dsOut,untested,pass,fail);
            catch ME
                ME.throwAsCaller();
            end
        end

        function elms=get(this,arg)





            try
                oldWarnings=warning('off','SimulationData:Objects:InvalidAccessToDatasetElement');
                cleanupWarnings=onCleanup(@()warning(oldWarnings));

                elementVal=this.Dataset_.get(arg);
                if isempty(elementVal)
                    elms=sltest.Assessment.empty();
                elseif isa(elementVal,'sltest.Assessment')
                    elms=elementVal;
                else
                    n=elementVal.numElements();
                    elms=sltest.Assessment.empty(n,0);
                    for i=1:n
                        elms(i)=elementVal.get(i);
                    end
                end
            catch ME
                ME.throwAsCaller();
            end
        end
    end

    methods(Static,Hidden)
        function out=create_(sigElems,untested,pass,fail)
            out=sltest.AssessmentSet(sigElems,untested,pass,fail);
        end
    end
end
