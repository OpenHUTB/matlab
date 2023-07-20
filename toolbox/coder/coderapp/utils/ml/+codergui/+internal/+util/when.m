function result=when(arg,varargin)



    charArgSelector=cellfun('isclass',varargin,'char');
    charArgs=repmat({''},size(varargin));
    charArgs(charArgSelector)=lower(varargin(charArgSelector));

    promise=[];
    if isa(arg,'codergui.internal.util.Promise')
        if isscalar(arg)
            promise=arg;
        else
            promise=codergui.internal.util.Promise.all(arg);
        end
    elseif iscell(arg)
        expandFlag=strcmp(varargin,'expandcell');
        if any(expandFlag)
            expandArgs=varargin(~expandFlag);
            promises=cell(0,numel(arg));
            for i=1:numel(arg)
                promises{i}=codergui.internal.util.when(arg{i},expandArgs{:});
            end
            promise=codergui.internal.util.Promise.all(promises);
        end
    end

    paramIndices=find(ismember(charArgs,{'then','catch','finally','alwayspromise','rethrow','expandcell'}));
    alwaysPromise=false;
    rethrowErrors=false;

    for i=1:numel(paramIndices)
        param=varargin{paramIndices(i)};
        if i<numel(paramIndices)
            values=varargin(paramIndices(i)+1:paramIndices(i+1)-1);
        else
            values=varargin(paramIndices(i)+1:numel(varargin));
        end
        switch param
        case 'alwayspromise'
            alwaysPromise=isempty(values)||values{1};
        case 'rethrow'
            rethrowErrors=isempty(values)||values{1};
        case 'expandcell'
        otherwise
            initPromise();
            promise=feval(param,promise,values{:});
        end
    end

    if alwaysPromise
        result=initPromise();
    elseif~isempty(promise)
        if promise.Finished
            if promise.Fulfilled
                result=promise.Result;
            elseif promise.Rejected
                if rethrowErrors
                    if isa(promise.Error,'MException')
                        promise.Error.rethrow();
                    else
                        error(promise.Error);
                    end
                else
                    result=[];
                end
            end
        else
            result=promise;
        end
    else
        result=arg;
    end



    function newPromise=initPromise()
        if isempty(promise)
            if isa(arg,'function_handle')
                promise=codergui.internal.util.Promise(arg);
            else
                promise=codergui.internal.util.Promise(@(resolve)resolve(arg));
            end
        end
        newPromise=promise;
    end
end

