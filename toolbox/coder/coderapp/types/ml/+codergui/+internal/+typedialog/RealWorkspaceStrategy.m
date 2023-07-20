classdef(Sealed)RealWorkspaceStrategy<codergui.internal.typedialog.WorkspaceStrategy&...
    internal.matlab.datatoolsservices.WorkspaceListener




    properties(Constant,Access=private)
        VALUE_STORAGE=containers.Map('KeyType','double','ValueType','any')
    end

    methods
        function requestWorkspaceUpdate(this)
            try
                builtin("_dtcallback",@()doUpdateWorkspace(evalin("caller","whos"),...
                evalin("caller","dbstack(1, '-completenames')")));
            catch me
                tderror(me);
            end

            function doUpdateWorkspace(whosInfo,stack)
                if isvalid(this)
                    try
                        whosInfo=assignToWorkspaces(whosInfo,stack);
                        this.notify("WorkspaceChanged",...
                        codergui.internal.typedialog.WorkspaceEventData(whosInfo,stack,true));
                    catch ex
                        tderror(ex);
                    end
                end
            end
        end

        function promise=readInWorkspace(this,varNamesOrCode)
            [promise,resolve,reject]=codergui.internal.util.Promise.taskless();
            try
                cmd=sprintf("%s.doReadInWorkspace(%s)",class(this),mat2str(string(varNamesOrCode)));
                builtin("_dtcallback",@()onResolve(evalin("caller",cmd)));
            catch me
                reject(me);
            end

            function onResolve(results)
                for i=1:numel(results)
                    if~isempty(results(i).error)
                        reject(results(i).error);
                        return
                    end
                end
                resolve(results);
            end
        end

        function promise=writeVariable(this,varName,uniqify,value)
            [promise,resolve,reject]=codergui.internal.util.Promise.taskless();
            try
                [valueToken,valueCleanup]=this.storeValue(value);%#ok<SETNU>
                cmd=sprintf("%s.doWriteInCaller('%s', %d, %d)",class(this),varName,uniqify,valueToken);
                builtin("_dtcallback",@()onResolve(evalin("caller",cmd)));
            catch me
                reject(me);
            end

            function onResolve(result)
                if~isempty(result.error)
                    reject(result.error);
                else
                    resolve(result);
                end
                valueCleanup=[];
            end
        end

        function workspaceUpdated(this,~,~)
            if nargin==1||~isvalid(this)
                return
            end
            this.requestWorkspaceUpdate();
        end
    end

    methods(Static,Access=private)
        function[valueToken,valueCleanup]=storeValue(value)
            mlock;
            persistent valueTokenCounter;
            if isempty(valueTokenCounter)
                valueTokenCounter=1;
            else
                valueTokenCounter=valueTokenCounter+1;
            end

            valueToken=valueTokenCounter;
            valueMap=codergui.internal.typedialog.RealWorkspaceStrategy.VALUE_STORAGE;
            valueMap(valueToken)=value;
            valueCleanup=onCleanup(@()valueMap.remove(valueToken));
        end

        function value=getStoredValue(valueToken)
            value=codergui.internal.typedialog.RealWorkspaceStrategy.VALUE_STORAGE(valueToken);
        end
    end

    methods(Static,Hidden)
        function result=doReadInWorkspace(varOrCode)
            varOrCode=cellstr(varOrCode);
            result=cell2struct(cell(0,2),{'value','error'},2);
            for i=1:numel(varOrCode)
                try
                    result(i).value=evalin('caller',varOrCode{i});
                    result(i).error=[];
                catch me
                    result(i).value=codergui.internal.undefined();
                    result(i).error=me.message;
                end
            end
        end

        function result=doWriteInCaller(varName,uniqify,valueToken)
            try
                assert(isnumeric(valueToken),"Cannot read value");
                value=codergui.internal.typedialog.RealWorkspaceStrategy.getStoredValue(valueToken);
                if uniqify
                    varName=deriveUniqueVariableName(varName,evalin('caller','who'));
                end
                assignin('caller',varName,value);
                result.varName=varName;
                result.error=[];
            catch me
                result.varName='';
                result.error=me;
            end
        end
    end
end


function whosInfo=assignToWorkspaces(whosInfo,stack)
    whosInfo=whosInfo(~[whosInfo.global]);
    isBase=false(1,numel(whosInfo));


    for i=1:numel(whosInfo)
        var=whosInfo(i);
        if isempty(var.nesting.function)&&var.nesting.level==1


            if isempty(stack)


                isBase(i)=true;
            elseif startsWith(stack(1).name,'@')

                if numel(stack)==1

                    isBase(i)=true;
                end
            end
        end
    end



    isBase=num2cell(isBase);
    [whosInfo.isBase]=isBase{:};
end