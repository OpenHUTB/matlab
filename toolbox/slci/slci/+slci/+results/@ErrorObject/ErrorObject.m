classdef ErrorObject<handle

    properties(Access=private)
        fKey;
        fMessageString='';
    end

    methods(Access=public,Hidden=true)

        function obj=ErrorObject(aMsgString)
            if nargin==0
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'ERROR');
            end
            obj.setKey();
            obj.setMessageString(aMsgString);
        end

        function aKey=getKey(aObj)
            aKey=aObj.fKey();
        end

        function aMsgString=getMessageString(aObj)
            aMsgString=aObj.fMessageString;
        end

    end

    methods(Access=private)

        function setKey(aObj)
            aObj.fKey=slci.results.ErrorObject.constructKey();
        end

        function setMessageString(aObj,aMsgString)
            aObj.fMessageString=aMsgString;
        end
    end

    methods(Static=true,Access=public,Hidden=true)

        function key=constructKey()
            mlock;
            persistent UniqueIdx;

            if isempty(UniqueIdx);
                UniqueIdx=0;
            else
                UniqueIdx=UniqueIdx+1;
            end
            keyPrefix='Error';
            key=[keyPrefix,'_',num2str(UniqueIdx)];
        end

    end
end
