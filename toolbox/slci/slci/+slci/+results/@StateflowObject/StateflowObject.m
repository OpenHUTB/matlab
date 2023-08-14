



classdef StateflowObject<slci.results.ModelObject

    properties(SetAccess=protected,GetAccess=protected)
        fSID='';
        fName='';

        fParent;
        fSubcomponents={};
    end

    methods(Access=public,Hidden=true)


        function obj=StateflowObject(aKey,aSID,aName)
            if nargin==0
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'STATEFLOWOBJECT');
            end
            obj@slci.results.ModelObject(aKey);
            obj.setSID(aSID);
            obj.setName(aName);
        end

        function objectName=getName(obj)
            objectName=obj.fName;
        end

        function objectSID=getSID(obj)
            objectSID=obj.fSID;
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


            if slcifeature('SLCIJustification')==1
                assert(nargin==2,'SLCI Configuration is not passed.');
                obj.justifyBlock(varargin{1});
            end
        end


        function hlink=getLink(obj,datamgr)%#ok
            hlink=obj.getSID();
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


        function addComponents(obj,acomponents)
            obj.fSubcomponents=union(acomponents,obj.fSubcomponents);
        end


        function setComponents(obj,acomponents)
            if iscell(acomponents)
                obj.fSubcomponents=acomponents;
            else
                DAStudio.error('Slci:results:InvalidInputArg');
            end
        end


        function subcomponents=getComponents(obj)
            subcomponents=obj.fSubcomponents;
        end


        function parent=getParent(obj)
            parent=obj.fParent;
        end


        function setParent(obj,aParent)
            if isa(aParent,'slci.results.StateflowObject')
                obj.fParent=aParent.getKey();
            else
                DAStudio.error('Slci:results:InvalidInputArg');
            end
        end

    end

    methods(Access=private)


        function setName(obj,aName)
            obj.fName=aName;
        end


        function setSID(obj,aSID)
            obj.fSID=aSID;
        end
    end


    methods(Access=protected)

        function checkTraceObj(obj,aTraceObj)%#ok
            if~isa(aTraceObj,'slci.results.CodeObject')
                DAStudio.error('Slci:results:ErrorTraceObjects',...
                'STATEFLOWOBJECT',...
                class(aTraceObj));
            end
        end


        function substatus=aggVerSubstatus(obj)
            primSubstatusList=obj.getPrimVerSubstatus();
            if~isempty(primSubstatusList)
                severityList={'VIRTUAL','OPTIMIZED','INLINED'};
                substatus=slci.internal.ReportUtil.getHeaviestSubstatus(...
                primSubstatusList,...
                severityList);
            else
                substatus='UNABLE_TO_PROCESS';
            end
        end


        function aggStatus=aggTraceSubstatus(obj)
            primSubstatusList=obj.getPrimTraceSubstatus();
            if~isempty(primSubstatusList)










                severityList={...
                'VERIFICATION_FAILED_TO_VERIFY',...
                'JUSTIFIED',...
                'VERIFICATION_PARTIALLY_PROCESSED',...
                'VERIFICATION_UNABLE_TO_PROCESS',...
                'TRACED',...
                'VIRTUAL',...
                'OPTIMIZED',...
'INLINED'...
                };
                aggStatus=slci.internal.ReportUtil.getHeaviestSubstatus(...
                primSubstatusList,...
                severityList);
            else
                aggStatus='UNKNOWN';
            end
        end


        function justifyBlock(obj,varargin)




            if~iscell(varargin{1})
                conf=varargin{1};
            else
                conf=varargin{1}{1};
            end

            fileName=fullfile(conf.getReportFolder(),...
            [conf.getModelName(),'_justification.json']);
            if isfile(fileName)
                modelManager=slci.view.ModelManager(fileName);
                if modelManager.isFiltered(obj.getSID)

                    obj.overrideEngineStatus('JUSTIFIED');
                    obj.addPrimTraceSubstatus('JUSTIFIED');
                end
            end
        end


        function overrideEngineStatus(obj,subStatus)
            if(any(strcmpi(obj.getStatus,...
                {'VERIFIED','PARTIALLY_PROCESSED','UNABLE_TO_PROCESS',...
                'JUSTIFIED'})))
                obj.setSubstatus(subStatus);
                obj.setStatus(obj.fReportConfig.getStatus(subStatus));
            end
        end

    end

end

