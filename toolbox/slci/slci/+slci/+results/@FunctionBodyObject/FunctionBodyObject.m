



classdef FunctionBodyObject<matlab.mixin.Copyable

    properties(Access=protected)
        fKey;
        fName;
        fIsDefined=false;
        fExpectedEmpty=false;
        fCodeEmptyFunctionStatus='UNKNOWN';
        fCodeStatus='UNKNOWN';
        fCodeSubstatus='UNKNOWN';
        fTempVarStatus='UNKNOWN';
        fTempVarSubstatus='UNKNOWN';
        fCodeSlices={};
        fCodes={};
        fTempVarObjects={};

        fBodyStartCodeLocation='';
        fBodyEndCodeLocation='';

        fSignatureStartCodeLoc='';
        fSignatureEndCodeLoc='';

        fType;
    end

    properties(Constant=true,GetAccess=protected)
        fReportConfig=slci.internal.ReportConfig;
    end

    methods(Access=public,Hidden=true)


        function obj=FunctionBodyObject(aKey,aName,aType)
            if nargin==0
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'FUNCTION BODY');
            end
            obj.setName(aName);
            obj.setKey(aKey);
            obj.setType(aType);
        end

        function aName=getKey(obj)
            aName=obj.fKey;
        end

        function setName(obj,aName)
            if isempty(aName)||~ischar(aName)
                error('invalid input argument');
            else
                obj.fName=aName;
            end
        end

        function aName=getName(obj)
            aName=obj.fName;
        end

        function setType(obj,aType)
            if isempty(aType)||~ischar(aType)
                error('invalid input argument');
            else
                obj.fType=aType;
            end
        end

        function aType=getType(obj)
            aType=obj.fType;
        end

        function isExpectedEmpty=getExpectedEmpty(obj)
            isExpectedEmpty=obj.fExpectedEmpty;
        end


        function startCode=getBodyStartCodeLocation(obj)
            startCode=obj.fBodyStartCodeLocation;
        end


        function endCode=getBodyEndCodeLocation(obj)
            endCode=obj.fBodyEndCodeLocation;
        end


        function startCode=getSignatureStartCodeLoc(obj)
            startCode=obj.fSignatureStartCodeLoc;
        end


        function endCode=getSignatureEndCodeLoc(obj)
            endCode=obj.fSignatureEndCodeLoc;
        end

        function aCodeStatus=getCodeStatus(obj)
            aCodeStatus=obj.fCodeStatus;
        end

        function aTempStatus=getTempVarStatus(obj)
            aTempStatus=obj.fTempVarStatus;
        end

        function aCodeSubstatus=getCodeSubstatus(obj)
            aCodeSubstatus=obj.fCodeSubstatus;
        end

        function aTempSubstatus=getTempVarSubstatus(obj)
            aTempSubstatus=obj.fTempVarSubstatus;
        end

        function codeSlices=getCodeSlices(obj)
            codeSlices=obj.fCodeSlices;
        end

        function codeKeys=getCodes(obj)
            codeKeys=obj.fCodes;
        end

        function tempObjects=getTempVarObjects(obj)
            tempObjects=obj.fTempVarObjects;
        end

    end

    methods(Access=private)

        function setKey(obj,aKey)
            slci.results.FunctionBodyObject.validateKey(aKey);
            obj.fKey=aKey;
        end


        function aggStatus=computeStatus(obj,ObjectKeys,reader,varargin)
            aggStatus=obj.fReportConfig.defaultStatus;
            numObjs=numel(ObjectKeys);
            if numObjs>0
                Objects=reader.getObjects(ObjectKeys);
                for p=1:numObjs
                    Object=Objects{p};
                    status=Object.getStatus();
                    reportConfig=obj.fReportConfig;
                    aggStatus=reportConfig.getHeaviestStatus(status,...
                    aggStatus);
                end
            end
        end


        function computeCodeEmptyFunctionStatus(obj,datamgr)
            assert(~obj.hasCodes());
            if~isempty(datamgr.getKeys('ERROR'))


                obj.fCodeEmptyFunctionStatus='ERROR';
            else
                if~obj.getIsDefined()
                    obj.fCodeEmptyFunctionStatus='UNDEFINED_FUNCTION';
                elseif obj.getExpectedEmpty()

                    obj.fCodeEmptyFunctionStatus='EXPECTED_EMPTY_FUNCTION';
                else

                    obj.fCodeEmptyFunctionStatus='MISSING_FUNCTION_CODE';
                end
            end
        end

        function emptyStatus=getTempVarEmptyFunctionStatus(obj,datamgr)%#ok
            if~isempty(datamgr.getKeys('ERROR'))


                emptyStatus='ERROR';
            else
                emptyStatus='VERIFIED';
            end
        end

    end

    methods(Access=public,Hidden=true)

        function setIsDefined(obj,aIsDefined)
            if~islogical(aIsDefined)
                DAStudio.error('Slci:results:InvalidInputArg');
            else
                obj.fIsDefined=aIsDefined;
            end
        end

        function isDefined=getIsDefined(obj)
            isDefined=obj.fIsDefined;
        end

        function setExpectedEmpty(obj,aExpectedEmpty)
            if isempty(aExpectedEmpty)||~islogical(aExpectedEmpty)
                DAStudio.error('Slci:results:InvalidInputArg');
            else
                obj.fExpectedEmpty=aExpectedEmpty;
            end
        end


        function setBodyStartCodeLocation(obj,aStartCode)
            if(isempty(aStartCode)||~ischar(aStartCode))
                DAStudio.error('Slci:results:InvalidStartCodeLocation');
            else
                obj.fBodyStartCodeLocation=aStartCode;
            end
        end


        function setBodyEndCodeLocation(obj,aEndCode)
            if(isempty(aEndCode)||~ischar(aEndCode))
                DAStudio.error('Slci:results:InvalidEndCodeLocation');
            else
                obj.fBodyEndCodeLocation=aEndCode;
            end
        end


        function setSignatureStartCodeLoc(obj,aStartCode)
            if(isempty(aStartCode)||~ischar(aStartCode))
                DAStudio.error('Slci:results:InvalidStartCodeLocation');
            else
                obj.fSignatureStartCodeLoc=aStartCode;
            end
        end


        function setSignatureEndCodeLoc(obj,aEndCode)
            if(isempty(aEndCode)||~ischar(aEndCode))
                DAStudio.error('Slci:results:InvalidEndCodeLocation');
            else
                obj.fSignatureEndCodeLoc=aEndCode;
            end
        end

        function setCodeStatus(obj,aCodeStatus)
            if any(strcmp(obj.fReportConfig.getTopVerStatusList(),aCodeStatus))
                obj.fCodeStatus=aCodeStatus;
            else
                DAStudio.error('Slci:results:InvalidStatus',aCodeStatus);
            end
        end

        function setTempVarStatus(obj,aTempStatus)
            if any(strcmp(obj.fReportConfig.getTopVerStatusList(),aTempStatus))
                obj.fTempVarStatus=aTempStatus;
            else
                DAStudio.error('Slci:results:InvalidStatus',aTempStatus);
            end
        end


        function setCodeSubstatus(obj,aCodeSubstatus)
            if isKey(obj.fReportConfig.TopVerStatusTable,aCodeSubstatus)
                obj.fCodeSubstatus=aCodeSubstatus;
            else
                DAStudio.error('Slci:results:InvalidSubstatus',...
                aCodeSubstatus);
            end
        end

        function setTempVarSubstatus(obj,aTempSubstatus)
            if isKey(obj.fReportConfig.TopVerStatusTable,aTempSubstatus)
                obj.fTempVarSubstatus=aTempSubstatus;
            else
                DAStudio.error('Slci:results:InvalidSubstatus',...
                aTempSubstatus);
            end
        end


        function addSingleCodeSlice(obj,aSliceKey)
            if~any(strcmp(obj.fCodeSlices,aSliceKey))
                obj.fCodeSlices{end+1}=aSliceKey;
            end
        end


        function addCodeSlices(obj,aSliceKeys)
            obj.fCodeSlices=slci.results.union(obj.fCodeSlices,aSliceKeys);
        end


        function addSingleCode(obj,aCode)
            if~any(strcmp(obj.fCodes,aCode))
                obj.fCodes{end+1}=aCode;
            end
        end


        function addCodes(obj,aCodes)
            obj.fCodes=slci.results.union(obj.fCodes,aCodes);
        end



        function addTempVarObjects(obj,aTempVarObjects)
            obj.fTempVarObjects=slci.results.union(obj.fTempVarObjects,...
            aTempVarObjects);
        end


        function computeCodeStatus(obj,datamgr)
            if obj.hasCodes()
                codeReader=datamgr.getReader('CODE');
                codeKeys=obj.fCodes;
                obj.fCodeSubstatus=obj.computeStatus(codeKeys,codeReader);
            else

                obj.computeCodeEmptyFunctionStatus(datamgr);
                obj.fCodeSubstatus=obj.fReportConfig.getStatus(...
                obj.getCodeEmptyFunctionStatus());
            end
            obj.setCodeStatus(obj.fReportConfig.getTopVerStatus(obj.fCodeSubstatus));
        end

        function hasCode=hasCodes(obj)
            hasCode=~isempty(obj.fCodeSlices);
        end

        function emptyStatus=getCodeEmptyFunctionStatus(obj)
            emptyStatus=obj.fCodeEmptyFunctionStatus;
        end



        function computeTempVarStatus(obj,datamgr)
            tempKeys=obj.getTempVarObjects();
            numTemps=numel(tempKeys);
            if numTemps>0
                tempVarReader=datamgr.getReader('TEMPVAR');
                obj.fTempVarSubstatus=obj.computeStatus(tempKeys,tempVarReader);
            else
                obj.fTempVarSubstatus=obj.getTempVarEmptyFunctionStatus(datamgr);
            end
            obj.setTempVarStatus(obj.fReportConfig.getTopVerStatus(obj.fTempVarSubstatus));
        end

    end

    methods(Static=true,Access=protected,Hidden=true)

        function validateKey(aKey)
            if(isempty(aKey)||~ischar(aKey))
                DAStudio.error('Slci:results:InvalidKey','FUNCTIONBODY');
            end
        end

    end

    methods(Static,Hidden,Access=public)


        function key=constructKey(aSysName,aType,aSampleTime)
            key=slci.results.FunctionInterfaceObject.constructKey(aSysName,...
            aType,...
            aSampleTime);
        end

    end


end

