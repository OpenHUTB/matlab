

classdef(Sealed)Promise<handle


    properties(SetAccess=private)
        Fulfilled logical=false
        Rejected logical=false
        Result=codergui.internal.undefined
        Error=codergui.internal.undefined
    end

    properties(Dependent,SetAccess=private)
        Finished logical
        HasResult logical
    end

    properties(Access=private)
FulfillHandler
RejectHandler
FinallyHandler
        Cancelled logical=false
        Next codergui.internal.util.Promise=codergui.internal.util.Promise.empty()
    end

    methods
        function this=Promise(task)





            if nargin==0
                task=[];
            end
            this.validateTask(task);

            if~isempty(task)
                args={@(varargin)this.resolve(varargin{:})};
                taskNargin=nargin(task);
                if taskNargin>1||taskNargin==-1
                    args{end+1}=@(varargin)this.reject(varargin{:});
                elseif taskNargin==0
                    error('Task "%s" must have take at least one argument',func2str(task));
                end
                try
                    feval(task,args{:});
                catch me
                    this.reject(me);
                end
            end
        end

        function next=then(this,onFulfill,onReject)
            if nargin<3
                onReject=[];
            end
            if isscalar(this)
                args={'FulfillHandler',onFulfill};
                if~isempty(onReject)
                    args(end+1:end+2)={'RejectHandler',onReject};
                end
                next=this.chain(args{:});
            else
                next=arrayfun(@(p)p.then(onFulfill,onReject),this);
            end
        end

        function next=caught(this,onReject)
            if isscalar(this)
                next=this.chain('RejectHandler',onReject);
            else
                next=arrayfun(@(p)p.caught(onReject),this);
            end
        end

        function next=finally(this,onFinally)
            if isscalar(this)
                next=this.chain('FinallyHandler',onFinally);
            else
                next=arrayfun(@(p)p.finally(onFinally),this);
            end
        end

        function finished=get.Finished(this)
            finished=this.Fulfilled||this.Rejected||this.Cancelled;
        end

        function hasResult=get.HasResult(this)
            hasResult=~codergui.internal.undefined(this.Result);
        end

        function delete(this)
            this.cancel();
        end
    end

    methods(Static)
        function next=all(varargin)
            promises=[varargin{:}];
            results=cell(size(promises));
            resolveCount=0;
            firstError=[];
            erorred=false;
            resolvers=struct('resolve',[],'reject',[]);
            next=codergui.internal.util.Promise(@storeResolvers);

            if isempty(promises)
                check();
            else
                for i=1:numel(promises)
                    promises(i).then(allResolved(i),@firstRejected);
                end
            end

            function storeResolvers(resolveFun,rejectFun)
                resolvers.resolve=resolveFun;
                resolvers.reject=rejectFun;
            end

            function check()
                if erorred
                    resolvers.reject(firstError);
                elseif resolveCount==numel(promises)
                    resolvers.resolve(results);
                end
            end

            function handler=allResolved(index)

                handler=@callStoreResult;

                function callStoreResult(varargin)
                    storeResult(index,varargin{:});
                end
            end

            function storeResult(index,result)
                if nargin>1
                    results{index}=result;
                end
                resolveCount=resolveCount+1;
                check();
            end

            function firstRejected(err)
                if~erorred
                    erorred=true;
                    firstError=err;
                end
                check();
            end
        end

        function next=race(varargin)
            promises=[varargin{:}];
            fulfilled=false;
            errored=false;
            firstResult=[];
            firstError=[];
            resolvers=struct('resolve',[],'reject',[]);
            next=codergui.internal.util.Promise(@storeResolvers);

            for i=1:numel(promises)
                promises(i).then(@firstResolved,@firstRejected);
            end

            function storeResolvers(resolveFun,rejectFun)
                resolvers.resolve=resolveFun;
                resolvers.reject=rejectFun;
            end

            function check()
                if errored
                    resolvers.reject(firstError);
                elseif fulfilled
                    resolvers.resolve(firstResult);
                end
            end

            function result=firstResolved(result)
                if~fulfilled
                    fulfilled=true;
                    firstResult=result;
                end
                check();
            end

            function firstRejected(err)
                if~errored
                    errored=true;
                    firstError=err;
                end
                check();
            end
        end

        function[promise,pass,fail]=defer()
            promise=codergui.internal.util.Promise(@doNothingTask);

            function doNothingTask(passFun,failFun)
                pass=passFun;
                fail=failFun;
            end
        end

        function promise=newResolved(result)%#ok<*DEFNU>
            if nargin>0
                resolveArgs={result};
            else
                resolveArgs={};
            end
            promise=codergui.internal.util.Promise(@(p,~)p(resolveArgs{:}));
        end

        function promise=newRejected(err)
            if nargin>0
                rejectArgs={err};
            else
                rejectArgs={};
            end
            promise=codergui.internal.util.Promise(@(~,f)f(rejectArgs{:}));
        end

        function[promise,resolve,reject]=taskless()
            promise=codergui.internal.util.Promise();
            resolve=@(varargin)promise.resolve(varargin{:});
            reject=@(varargin)promise.reject(varargin{:});
        end
    end

    methods(Access=private)
        function nextPromise=chain(this,varargin)
            nextPromise=codergui.internal.util.Promise();
            for i=1:2:numel(varargin)
                nextPromise.(varargin{i})=varargin{i+1};
            end
            if this.Finished
                nextPromise.activate(this);
            else
                this.Next(end+1)=nextPromise;
            end
        end

        function activate(this,previous)
            assert(previous.Finished);
            err=[];
            hasResult=false;

            if~isempty(this.FinallyHandler)
                assert(isempty(this.FulfillHandler)&&isempty(this.RejectHandler));
                [result,err,hasResult]=this.evalCallback(this.FinallyHandler,false,previous);
            elseif previous.Fulfilled
                if previous.HasResult
                    args={previous.Result};
                else
                    args={};
                end
                if~isempty(this.FulfillHandler)
                    [result,err,hasResult]=this.evalCallback(this.FulfillHandler,true,args{:});
                else

                    result=previous.Result;
                    hasResult=previous.HasResult;
                end
            elseif previous.Rejected
                if~isempty(this.RejectHandler)
                    [result,err,hasResult]=this.evalCallback(this.RejectHandler,true,previous.Error);
                else

                    err=previous.Error;
                end
            end

            if previous.Cancelled
                this.cancel();
            elseif~isempty(err)
                this.reject(err);
            elseif hasResult
                this.resolve(result);
            else
                this.resolve();
            end
        end

        function resolve(this,result)
            if this.Finished
                return
            end
            if nargin>1
                if isa(result,class(this))
                    result.then(@this.innerResolve,@rejectWrapper);
                    return
                else
                    this.Fulfilled=true;
                    this.Result=result;
                end
            else
                this.Fulfilled=true;
                this.Result=codergui.internal.undefined;
            end
            arrayfun(@(n)n.activate(this),this.Next);


            function rejectWrapper(varargin)
                this.reject(varargin{:});
            end
        end

        function reject(this,err)
            if this.Finished
                return
            end
            this.Rejected=true;
            if nargin>1
                this.Error=err;
                if isempty(this.Next)
                    coder.internal.gui.asyncDebugPrint(err);
                end
            else
                this.Error=[];
            end
            arrayfun(@(n)n.activate(this),this.Next);
        end

        function varargout=innerResolve(this,result)
            if isa(result,class(this))
                this.resolve(result);
            else
                varargout{1}=result;
                this.resolve(result);
            end
        end

        function follow(this,other)
            if other.Fulfilled
                if other.HasResult
                    this.resolve(other.Result);
                else
                    this.resolve();
                end
            elseif other.Rejected
                this.reject(other.Error);
            elseif other.Cancelled
                this.cancel();
            end
        end

        function cancel(this)
            if this.Finished
                return;
            end
            this.Cancelled=true;
            arrayfun(@(n)n.activate(this),this.Next);
        end
    end

    methods(Static,Access=private)
        function[output,err,hasOutput]=evalCallback(callback,hasOutputs,varargin)
            cbInputCount=nargin(callback);
            if cbInputCount~=0&&~isempty(varargin)
                if cbInputCount~=-1
                    args=varargin(1:min(numel(varargin),cbInputCount));
                else
                    args=varargin;
                end
            else
                args={};
            end

            output=[];
            hasOutput=false;
            err=[];

            try
                if hasOutputs&&nargout(callback)~=0
                    output=feval(callback,args{:});
                    hasOutput=true;
                else
                    feval(callback,args{:});
                end
                hasOutput=true;
            catch err
            end
        end

        function validateTask(task)
            if isempty(task)
                return;
            elseif~isa(task,'function_handle')
                if~ischar(task)&&(~isscalar(task)||~isstring(task))
                    error('Task argument must be a function_handle not a "%s"',class(task));
                elseif isempty(which(task))
                    error('Task "%s" must resolve to a valid function on path',task);
                end
            end
        end
    end
end
