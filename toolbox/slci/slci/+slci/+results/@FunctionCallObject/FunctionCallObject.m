


classdef FunctionCallObject<slci.results.SourceObject

    properties(Access=private)

        fCName='';

        fAttribute='';


        fCodeKeys={};

        fBlockKeys={};

        fStatus='';

        fKind='';
    end

    methods


        function obj=FunctionCallObject(aKey,aCName,aAttribute,aStatus,aKind)
            if(nargin==0)
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'FUNCTIONCALL');
            end

            obj=obj@slci.results.SourceObject(aKey);
            obj.setCName(aCName);
            obj.setAttribute(aAttribute);
            obj.setStatus(aStatus);
            obj.setKind(aKind);
        end


        function setCName(obj,aCName)
            obj.fCName=aCName;
        end


        function C_Name=getCName(obj)
            C_Name=obj.fCName;
        end


        function setAttribute(obj,aAttribute)
            obj.fAttribute=aAttribute;
        end


        function attribute=getAttribute(obj)
            attribute=obj.fAttribute;
        end


        function addCodeKey(obj,aCodeKeys)
            obj.fCodeKeys=slci.results.union(...
            obj.fCodeKeys,aCodeKeys);
        end


        function codeKeys=getCodeKeys(obj)
            codeKeys=obj.fCodeKeys;
        end


        function addBlockKey(obj,aBlockKeys)
            obj.fBlockKeys=slci.results.union(...
            obj.fBlockKeys,aBlockKeys);
        end


        function blockKeys=getBlockKeys(obj)
            blockKeys=obj.fBlockKeys;
        end


        function setStatus(obj,aStatus)
            obj.fStatus=aStatus;
        end


        function status=getStatus(obj)
            status=obj.fStatus;
        end


        function setKind(obj,aKind)
            obj.fKind=aKind;
        end


        function kind=getKind(obj)
            kind=obj.fKind;
        end

    end

    methods(Static=true,Access=public,Hidden=true)

        function key=constructKey(aCName,aAttribute)
            key=[aCName,'::',aAttribute];
        end
    end

    methods(Access=protected)


        function checkTraceObj(obj,aTraceObj)%#ok
            DAStudio.error('Slci:results:InvalidTraceObject');
        end

    end
end
