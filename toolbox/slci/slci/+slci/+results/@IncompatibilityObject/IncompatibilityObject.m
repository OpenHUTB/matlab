classdef IncompatibilityObject<handle


    properties(Access=private)
        fKey;





        fCode;
        fMsgString='';
        fIsFatal=false;
        fObjectsInvolved={};
        fHTMLEncode=false;
    end

    methods(Access=public,Hidden=true)

        function obj=IncompatibilityObject(aCompatObject)
            if nargin==0
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'INCOMPATIBILITY');
            end
            obj.fKey=slci.results.IncompatibilityObject.constructKey(aCompatObject);
            obj.fCode=aCompatObject.getCode();
            obj.setMessageString(aCompatObject);
            obj.setIsFatal(aCompatObject.getFatal);
            obj.setHTMLEncode(aCompatObject);
        end

        function aKey=getKey(aObj)
            aKey=aObj.fKey;
        end

        function isFatal=getIsFatal(aObj)
            isFatal=aObj.fIsFatal;
        end

        function aMsgString=getMessageString(aObj)
            aMsgString=aObj.fMsgString;
        end

        function code=getCode(aObj)
            code=aObj.fCode;
        end


        function objsInvolved=getObjectsInvolved(aObj)
            objsInvolved=aObj.fObjectsInvolved;
        end

        function htmlEncode=getHTMLEncode(aObj)
            htmlEncode=aObj.fHTMLEncode;
        end

    end

    methods(Access=public,Hidden=true)

        function setObjectsInvolved(aObj,aBlkSIDs)
            aObj.fObjectsInvolved=slci.results.union(aObj.fObjectsInvolved,...
            aBlkSIDs);
        end
    end



    methods(Access=private)

        function setMessageString(aObj,aCompatObject)


            if aCompatObject.getFatal()
                aMsgString=aCompatObject.getText();
            else
                [~,~,aMsgString,~]=aCompatObject.getMAStrings();
            end
            aObj.fMsgString=aMsgString;
        end

        function setIsFatal(aObj,aIsFatal)
            aObj.fIsFatal=aIsFatal;
        end

        function setHTMLEncode(aObj,aCompatObject)
            constraint=aCompatObject.getConstraint();
            aObj.fHTMLEncode=constraint.getHTMLEncode();
        end

    end

    methods(Static=true,Access=public,Hidden=true)


        function key=constructKey(aCompatObj)
            mlock;
            persistent UniqueIdx;

            keyPrefix=aCompatObj.getCode();
            if(isempty(keyPrefix)||~ischar(keyPrefix))
                error(['Invalid key prefix ',keyPrefix...
                ,'for IncompatibilityObject']);
            end

            if isempty(UniqueIdx);
                UniqueIdx=0;
            else
                UniqueIdx=UniqueIdx+1;
            end
            key=[keyPrefix,'_',num2str(UniqueIdx)];
        end

    end

end
