
classdef TempVarObject<slci.results.SourceObject




    properties(Access=private)

        fName;
        fFunctionScope;

        fCodeObject={};
        fSubstatus='';
    end

    methods(Access=public,Hidden=true)

        function obj=TempVarObject(aKey,aName,aFunctionScope,aCodeObject)
            if(nargin==0)
                DAStudio.error('Slci:results:DefaultConstructorError','TEMPVAR');
            end
            obj=obj@slci.results.SourceObject(aKey);
            obj.fName=aName;
            obj.addFunctionScope(aFunctionScope);
            obj.addCodeObject(aCodeObject);
        end


        function aCode=getCodeObject(obj)
            aCode=obj.fCodeObject;
        end

        function aScope=getFunctionScope(obj)
            aScope=obj.fFunctionScope;
        end

        function aStatus=getSubstatus(obj)
            aStatus=obj.fSubstatus;
        end

    end

    methods(Access=public,Hidden=true)

        function addCodeObject(obj,aObject)
            num=numel(aObject);
            tempKeys=cell(num,1);
            for k=1:numel(aObject)
                aObj=aObject{k};
                if isa(aObj,'slci.results.CodeObject')
                    tempKeys{k}=aObj.getKey();
                else
                    error(['CodeObject for a TempVarObject '...
                    ,'cannot be of type ',class(aObj)]);
                end
            end
            obj.addCodeKey(tempKeys);
        end

        function setSubstatus(obj,aSubstatus)
            if isempty(obj.getSubstatus())
                obj.fSubstatus=aSubstatus;
                obj.computeStatus();
            else
                error(['Cannot overwrite temp variables substatus '...
                ,obj.getSubstatus()]);
            end
        end


        function computeStatus(obj,varargin)
            if~isempty(obj.getSubstatus())
                obj.setStatus(obj.fReportConfig.getStatus(obj.getSubstatus()));
            end
        end

        function dispName=getDispName(obj,datamgr)%#ok
            dispName=slci.internal.encodeString(obj.fName,'all','encode');
        end
    end

    methods(Access=protected)
        function addCodeKey(obj,aCodeKeys)

            obj.fCodeObject=slci.results.union(obj.fCodeObject,aCodeKeys);
        end

        function addFunctionScope(obj,aFunctionScope)
            obj.fFunctionScope=aFunctionScope;
        end

        function checkTraceObj(obj,aTraceObj)%#ok


            if~(isa(aTraceObj,'slci.results.ModelObject'))
                DAStudio.error('Slci:results:ErrorTraceObjects','TEMPVAR',...
                class(aTraceObj));
            end
        end
    end

    methods(Static=true,Access=public,Hidden=true)

        function key=constructKey(tempVarName,tempVarFuncKey)
            key=[tempVarFuncKey,':',tempVarName];
        end
    end

end
