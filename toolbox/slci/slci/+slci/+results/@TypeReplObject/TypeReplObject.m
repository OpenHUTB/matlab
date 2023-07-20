

classdef TypeReplObject<slci.results.SourceObject

    properties(Access=private)

        fSlType='';

        fCodeGenType='';

        fReplName='';

        fBaseType='';

        fDataScope='';


        fCodeObject={};

    end

    methods(Access=public,Hidden=true)


        function obj=TypeReplObject(slType,codeGenType)
            if(nargin==0)
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'TYPEREPLACEMENT');
            end
            aKey=slci.results.TypeReplObject.constructKey(codeGenType);
            obj=obj@slci.results.SourceObject(aKey);
            obj.setSlType(slType);
            obj.setCodeGenType(codeGenType);
        end


        function slType=getSlType(obj)
            slType=obj.fSlType;
        end


        function codeGenType=getCodeGenType(obj)
            codeGenType=obj.fCodeGenType;
        end


        function obj=setReplName(obj,aReplName)
            obj.fReplName=aReplName;
        end


        function replName=getReplName(obj)
            replName=obj.fReplName;
        end


        function obj=setBaseType(obj,aBaseType)
            obj.fBaseType=aBaseType;
        end


        function baseType=getBaseType(obj)
            baseType=obj.fBaseType;
        end


        function obj=setDataScope(obj,aDataScope)
            obj.fDataScope=aDataScope;
        end


        function dataScope=getDataScope(obj)
            dataScope=obj.fDataScope;
        end


        function addCodeObject(obj,aObject)
            num=numel(aObject);
            tempKeys=cell(num,1);
            for k=1:numel(aObject)
                aObj=aObject{k};
                if isa(aObj,'slci.results.CodeObject')
                    tempKeys{k}=aObj.getKey();
                else
                    DAStudio.error('Slci:results:InvalidInputArg');
                end
            end
            obj.addCodeKey(tempKeys);
        end


        function addCodeKey(obj,aCodeKeys)
            obj.fCodeObject=slci.results.union(obj.fCodeObject,...
            aCodeKeys);
        end


        function codeKeys=getCodeObject(obj)
            codeKeys=obj.fCodeObject;
        end

    end

    methods(Access=private)


        function obj=setSlType(obj,slType)
            obj.fSlType=slType;
        end


        function obj=setCodeGenType(obj,codeGenType)
            obj.fCodeGenType=codeGenType;
        end

    end

    methods(Access=protected)


        function checkTraceObj(obj,aTraceObj)%#ok
            DAStudio.error('Slci:results:InvalidTraceObject');
        end

    end

    methods(Access=public,Static=true,Hidden=true)

        function key=constructKey(aCodeGenType)
            key=aCodeGenType;
        end

    end


end
