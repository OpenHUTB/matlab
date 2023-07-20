classdef(Abstract)Advisable<handle





























    properties(Transient,Hidden)
        EnableAdvising=false
    end

    properties(Transient,GetAccess=private,SetAccess=immutable)
Advisors
    end

    properties(Transient,Access=private)
        ActiveAdvisees={}
        Registered=false
        Reentrant=false
    end

    methods(Hidden,Sealed)
        function this=Advisable()
            this.Advisors=containers.Map();
            registry=coder.internal.gui.AdvisableRegistry.SINGLETON;
            this.EnableAdvising=registry.RegistryEnabled;
            this.doRegister();
        end

        function varargout=adviseAround(this,adviseeName,advisor)
            if nargout>0
                varargout={this.addAdvisor('Around',adviseeName,advisor,nargout)};
            else
                this.addAdvisor('Around',adviseeName,advisor,nargout);
                varargout={};
            end
        end

        function varargout=adviseInstead(this,adviseeName,advisor)
            if nargout>0
                varargout={this.addAdvisor('Instead',adviseeName,advisor,nargout)};
            else
                this.addAdvisor('Instead',adviseeName,advisor,nargout);
                varargout={};
            end
        end

        function varargout=adviseBefore(this,adviseeName,advisor)
            if nargout>0
                varargout={this.addAdvisor('Before',adviseeName,advisor,nargout)};
            else
                this.addAdvisor('Before',adviseeName,advisor,nargout);
                varargout={};
            end
        end

        function varargout=adviseAfter(this,adviseeName,advisor)
            if nargout>0
                varargout={this.addAdvisor('After',adviseeName,advisor,nargout)};
            else
                this.addAdvisor('After',adviseeName,advisor,nargout);
                varargout={};
            end
        end

        function unadvise(this,adviseeName)
            if exist('adviseeName','var')
                if this.Advisors.isKey(adviseeName)
                    this.Advisors.remove(adviseeName);
                end
            else
                this.Advisors.remove(this.Advisors.keys());
            end
            if this.Registered&&isempty(this.Advisors)
                this.Registered=false;
                coder.internal.gui.AdvisableRegistry.SINGLETON.unregister(this);
            end
        end

        function varargout=subsref(this,s)
            if this.EnableAdvising&&~ismember(s(1).type,this.ActiveAdvisees)&&...
                strcmp(s(1).type,'.')&&this.Advisors.isKey(s(1).subs)
                hasArgs=length(s)>1&&strcmp(s(2).type,'()');
                if hasArgs
                    args=s(2).subs;
                    nextIndex=3;
                else
                    args={};
                    nextIndex=2;
                end

                hasMore=nextIndex<=length(s);
                adviseeName=s(1).subs;

                if hasMore

                    expectedOut=1;
                else
                    expectedOut=nargout;
                end

                this.ActiveAdvisees{end+1}=adviseeName;
                try
                    if expectedOut>0
                        [varargout{1:nargout}]=this.advise(adviseeName,args,expectedOut);
                    else
                        this.advise(adviseeName,args,expectedOut);
                        varargout={};
                    end
                    this.ActiveAdvisees=setdiff(this.ActiveAdvisees,adviseeName);
                catch me
                    this.ActiveAdvisees=setdiff(this.ActiveAdvisees,adviseeName);
                    rethrow(me);
                end

                if hasMore

                    if nargout>0
                        varargout={builtin('subsref',varargout{1},s(nextIndex:end))};
                    else
                        builtin('subsref',varargout{1},s(nextIndex:end));
                        varargout={};
                    end
                end
            elseif nargout>0
                [varargout{1:nargout}]=builtin('subsref',this,s);
            else
                builtin('subsref',this,s);
            end
        end
    end

    methods
        function set.EnableAdvising(this,enable)
            validateattributes(enable,{'logical'},{'scalar'});
            this.EnableAdvising=enable;
            if~enable
                munlock;
                this.unadvise();
            else
                mlock;
            end
        end
    end

    methods(Access=private)
        function varargout=advise(this,adviseeName,args,expectedOutputs)
            varargout={};
            advisorCell=this.Advisors(adviseeName);
            [advisorType,advisor]=advisorCell{:};
            argsWithThis=[{this},args];

            switch advisorType
            case 'Before'
                doBefore();
            case 'After'
                doAfter();
            case 'Around'
                doAround();
            otherwise
                doInstead();
            end

            function doBefore()
                advOutCount=nargout(advisor);
                if abs(advOutCount)==1
                    finalArgs=advisor(adviseeName,argsWithThis{:});
                elseif advOutCount==0
                    advisor(adviseeName,argsWithThis{:});
                    finalArgs=args;
                else
                    error('Before advisor should return at most one output (a cell array)');
                end
                if~iscell(finalArgs)
                    finalArgs={finalArgs};
                end

                if expectedOutputs>0
                    [varargout{1:expectedOutputs}]=feval(adviseeName,this,finalArgs{:});
                else
                    feval(adviseeName,this,finalArgs{:})
                end
            end

            function doAfter()
                if expectedOutputs>0
                    [preOut{1:expectedOutputs}]=feval(adviseeName,argsWithThis{:});
                    varargout={advisor(adviseeName,this,preOut{:})};
                else
                    feval(adviseeName,argsWithThis{:})
                    advisor(adviseeName,this);
                end
            end

            function doAround()
                if expectedOutputs>0
                    [varargout{1:expectedOutputs}]=advisor(adviseeName,@invokeOriginalMethod,expectedOutputs,argsWithThis{:});
                else
                    advisor(adviseeName,@invokeOriginalMethod,0,argsWithThis{:});
                end

                function varargout=invokeOriginalMethod(varargin)
                    if nargin>1
                        if varargin{1}==this
                            normArgs=varargin;
                        else
                            normArgs=[{this},varargin];
                        end
                    else
                        normArgs={this};
                    end
                    if nargout>0
                        [varargout{1:nargout}]=feval(adviseeName,normArgs{:});
                    else
                        feval(adviseeName,normArgs{:})
                    end
                end
            end

            function doInstead()
                if expectedOutputs>0
                    [varargout{1:expectedOutputs}]=advisor(adviseeName,expectedOutputs,args{:});
                else
                    advisor(adviseeName,expectedOutputs,args{:});
                end
            end
        end

        function varargout=addAdvisor(this,advisorType,adviseeName,advisor,expectedOutputs)
            caller=['advise',advisorType];
            validateattributes(advisor,{'function_handle'},{'scalar'},caller);
            validatestring(advisorType,{'Around','Instead','Before','After'},caller);
            validateattributes(adviseeName,{'char'},{'scalartext'},caller);
            assert(ismethod(this,adviseeName),'Advisee argument must provide a valid method name');

            this.Advisors(adviseeName)={advisorType,advisor};

            if~this.Registered
                this.doRegister();
            end

            if expectedOutputs~=0
                varargout={onCleanup(@()this.unadvise(adviseeName))};
            else
                varargout={};
            end
        end

        function doRegister(this)
            if~this.Reentrant
                this.Reentrant=true;
                this.Registered=coder.internal.gui.AdvisableRegistry.SINGLETON.register(this);
                this.Reentrant=false;
            end
        end
    end
end