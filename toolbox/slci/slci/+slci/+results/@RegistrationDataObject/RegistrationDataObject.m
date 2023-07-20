





classdef RegistrationDataObject<slci.results.ModelObject

    properties(Access=protected)


        fType='';
    end

    methods(Access=public,Hidden)

        function obj=RegistrationDataObject(aKey,aType)
            if nargin==0
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'REGISTRATIONDATAOBJECT');
            end
            slci.results.RegistrationDataObject.validateKey(aKey);
            obj=obj@slci.results.ModelObject(aKey);
            obj.setType(aType);
        end


        function computeStatus(obj,varargin)

            verInfo=obj.getVerificationInfo();
            if~verInfo.IsEmpty()
                obj.setSubstatus(verInfo.getComputedEngineSubstatus());
                obj.setStatus(verInfo.getComputedEngineStatus());
            else

                aggSubstatus=obj.aggVerSubstatus();
                aggStatus=obj.fReportConfig.getStatus(aggSubstatus);
                obj.setSubstatus(aggSubstatus);
                obj.setStatus(aggStatus);
            end
        end


        function dispName=getDispName(obj,datamgr)%#ok            
            switch obj.fType
            case 'INPUT'
                dispType='input initialization code';
            case 'OUTPUT'
                dispType='output initialization code';
            case 'BLOCKIO'
                dispType='block I/O initialization code';
            case 'DWORK'
                dispType='dwork initialization code';
            case 'GLOBALSTATE'
                dispType='global state initialization code';
            case 'TIMING'
                dispType='timing initialization code';
            otherwise
                DAStudio.error('Slci:results:InvalidType',obj.fType);
            end
            dispName=dispType;
        end

        function linkSID=getLink(obj,datamgr)%#ok
            modelFile=datamgr.getMetaData('ModelName');
            linkSID=modelFile;
        end

        function callback=getCallback(obj,datamgr)
            link=obj.getLink(datamgr);
            if isempty(link)
                callback=obj.getDispName(datamgr);
            else
                modelFileName=datamgr.getMetaData('ModelFileName');
                encodedModelFileName=slci.internal.encodeString(...
                modelFileName,'all','encode');
                callback=slci.internal.ReportUtil.appendCallBack(...
                obj.getDispName(datamgr),encodedModelFileName,link);
            end
        end

    end

    methods(Access=protected,Hidden)

        function setType(obj,aType)
            obj.fType=aType;
        end

        function substatus=aggVerSubstatus(obj)
            primSubstatusList=obj.getPrimVerSubstatus();
            if~isempty(primSubstatusList)

                severityList={'OPTIMIZED'};
                substatus=slci.internal.ReportUtil.getHeaviestSubstatus(...
                primSubstatusList,...
                severityList);
            else
                substatus='UNABLE_TO_PROCESS';
            end
        end

        function substatus=aggTraceSubstatus(obj)
            primSubstatusList=obj.getPrimTraceSubstatus();
            if~isempty(primSubstatusList)

                severityList={...
                'VERIFICATION_FAILED_TO_VERIFY',...
                'VERIFICATION_PARTIALLY_PROCESSED',...
                'VERIFICATION_UNABLE_TO_PROCESS',...
                'TRACED',...
                'OPTIMIZED'};
                substatus=slci.internal.ReportUtil.getHeaviestSubstatus(...
                primSubstatusList,...
                severityList);
            else
                substatus='UNKNOWN';
            end
        end

        function checkTraceObj(obj,aTraceObj)%#ok
            if~isa(aTraceObj,'slci.results.CodeObject')
                DAStudio.error('Slci:results:ErrorTraceObjects',...
                'REGISTRATIONDATAOBJECT',...
                class(aTraceObj));
            end
        end
    end

    methods(Static,Hidden,Access=protected)

        function validateKey(aKey)
            if(isempty(aKey)||~ischar(aKey))
                DAStudio.error('Slci:results:InvalidKey','REGISTRATIONDATAOBJECT');
            end
        end

    end

    methods(Static,Hidden,Access=public)


        function key=constructKey(aType)
            key=aType;
        end

    end


end
