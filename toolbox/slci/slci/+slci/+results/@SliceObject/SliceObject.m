classdef SliceObject<slci.results.SourceObject

    properties(Access=protected)


        fsliceName;

        fSourceObject={};


        fFunctionScope;
        fContributingSources={};
    end

    methods(Access=protected)

        function obj=SliceObject(aKey,aName,aFunctionScope)
            if nargin==0
                DAStudio.error('Slci:results:DefaultConstructorError','SLICE');
            end
            obj=obj@slci.results.SourceObject(aKey);
            obj.setFunctionScope(aFunctionScope);
            obj.setName(aName);
        end

        function addSourceKey(obj,aSourceKey)
            if~any(strcmp(obj.fSourceObject,aSourceKey))
                obj.fSourceObject=[obj.fSourceObject,{aSourceKey}];
            end
        end

        function setFunctionScope(obj,aFunction)
            obj.fFunctionScope=aFunction;
        end

    end

    methods(Access=private)

        function setName(obj,aName)
            obj.fsliceName=aName;
        end

    end

    methods(Access=public,Hidden=true)


        function aSourceObject=getSourceObject(obj)
            aSourceObject=obj.fSourceObject;
        end


        function aFunction=getFunctionScope(obj)
            aFunction=obj.fFunctionScope;
        end


        function contribSources=getContributingSources(obj)
            contribSources=obj.fContributingSources;
        end


        function appendContributingSources(obj,aContribSourceObjectArray)
            num=numel(aContribSourceObjectArray);
            tempKeys=cell(num,1);
            for k=1:num
                contribObject=aContribSourceObjectArray{k};
                obj.checkContributingObject(contribObject);
                tempKeys{k,1}=contribObject.getKey();
            end
            obj.appendContributingSourceKey(tempKeys);
        end

        function aName=getName(obj)
            aName=obj.fsliceName;
        end


        function appendContributingSourceKey(obj,aSourceObjectKeys)
            obj.fContributingSources=slci.results.union(...
            obj.fContributingSources,...
            aSourceObjectKeys);
        end

    end



end
