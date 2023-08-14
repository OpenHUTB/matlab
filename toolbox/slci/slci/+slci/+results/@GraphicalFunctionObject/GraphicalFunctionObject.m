

classdef GraphicalFunctionObject<slci.results.StateflowObject

    properties(SetAccess=protected,GetAccess=protected)
        fIsInline;
    end

    methods(Access=public,Hidden=true)


        function obj=GraphicalFunctionObject(aSID,aParent,aName)
            if nargin==0
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'GRAPHICALFUNCTIONOBJECT');
            end
            aKey=slci.results.GraphicalFunctionObject.constructKey(aSID);
            obj@slci.results.StateflowObject(aKey,aSID,aName);
            obj.setParent(aParent);
        end


        function setIsInline(obj,isInline)
            if islogical(isInline)
                obj.fIsInline=isInline;
            else
                DAStudio.error('Slci:results:InvalidInputArg');
            end
        end


        function isInline=getIsInline(obj)
            isInline=obj.fIsInline;
        end


        function aDispName=getDispName(obj,datamgr)
            reader=datamgr.getReader('BLOCK');
            parentObj=reader.getObject(obj.getParent());
            parentName=parentObj.getDispName(datamgr);
            fullName=[parentName,'/',obj.getName()];
            aDispName=slci.internal.encodeString(fullName,'all','encode');
        end

    end

    methods(Access=public,Static=true,Hidden=true)

        function key=constructKey(aSID)
            key=aSID;
        end

    end


end