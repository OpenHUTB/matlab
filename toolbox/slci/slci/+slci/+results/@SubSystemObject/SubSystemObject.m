


classdef SubSystemObject<slci.results.BlockObject
    properties(Access=private)

        fCFuncName='';

        fMFuncName='';

        fCFileName='';

        fMFileName='';
    end

    methods


        function obj=SubSystemObject(aSID)
            if(nargin==0)
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'SUBSYSTEM_OBJECT');
            end
            aKey=slci.results.SubSystemObject.constructKey(aSID);

            obj@slci.results.BlockObject(aKey);
        end


        function setCFuncName(obj,aCName)
            obj.fCFuncName=aCName;
        end


        function cName=getCFuncName(obj)
            cName=obj.fCFuncName;
        end


        function setMFuncName(obj,aMName)
            obj.fMFuncName=aMName;
        end


        function mName=getMFuncName(obj)
            mName=obj.fMFuncName;
        end


        function setCFileName(obj,aCName)
            obj.fCFileName=aCName;
        end


        function cName=getCFileName(obj)
            cName=obj.fCFileName;
        end


        function setMFileName(obj,aMName)
            obj.fMFileName=aMName;
        end


        function mName=getMFileName(obj)
            mName=obj.fMFileName;
        end
    end

    methods(Static=true,Access=public,Hidden=true)

        function key=constructKey(aSID)

            key=slci.results.BlockObject.constructKey(...
            get_param(aSID,'handle'));
        end
    end

    methods(Access=protected)


        function checkTraceObj(obj,aTraceObj)%#ok
            DAStudio.error('Slci:results:InvalidTraceObject');
        end

    end
end