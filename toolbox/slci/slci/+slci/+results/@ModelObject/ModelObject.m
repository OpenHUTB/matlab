



classdef ModelObject<slci.results.SourceObject

    properties(Access=protected)



        fIncompatibilityKeys={};


        fVerificationImpl;



        fPrimVerSubstatus={};



        fVerSubstatus='';



        fPrimTraceSubstatus={};



        fIsVisible=true;



        fVisibleTargets={};
    end

    methods(Access=protected)

        function obj=ModelObject(aKey)
            if nargin==0
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'MODELOBJECT');
            end
            obj=obj@slci.results.SourceObject(aKey);
            obj.fVerificationImpl=slci.results.VerificationImpl;
        end

    end

    methods(Access=protected)

        function setSubstatus(obj,aSubStatus)


            substatusvals=keys(obj.fReportConfig.VStatusTable);
            if isempty(aSubStatus)||...
                any(strcmpi(substatusvals,aSubStatus))
                obj.fVerSubstatus=aSubStatus;
            else
                DAStudio.error('Slci:results:InvalidSubstatus',aSubStatus);
            end
        end

    end

    methods(Access=public,Hidden=true)

        function setIsVisible(obj,isVisible)
            obj.fIsVisible=isVisible;
        end

        function isVisible=getIsVisible(obj)
            isVisible=obj.fIsVisible;
        end

        function setVisibleTarget(obj,targets)

            assert(numel(targets)==1);
            assert(~obj.getIsVisible());
            assert(~isempty(targets));
            obj.fVisibleTargets=targets;
        end

        function targets=getVisibleTarget(obj)
            targets=obj.fVisibleTargets;
        end


        function addPrimVerSubstatus(obj,aSubstatus)
            obj.fPrimVerSubstatus=slci.results.union(obj.fPrimVerSubstatus,...
            aSubstatus);
        end


        function substatusList=getPrimVerSubstatus(obj)
            substatusList=obj.fPrimVerSubstatus;
        end


        function addPrimTraceSubstatus(obj,aSubstatus)
            obj.fPrimTraceSubstatus=slci.results.union(obj.fPrimTraceSubstatus,...
            aSubstatus);
        end


        function substatusList=getPrimTraceSubstatus(obj)
            substatusList=obj.fPrimTraceSubstatus;
        end


        function aSubstatus=getSubstatus(obj)
            aSubstatus=obj.fVerSubstatus;
        end


        function appendVerificationInfo(obj,otherObj)
            otherVerInfo=otherObj.getVerificationInfo();
            if~otherVerInfo.IsEmpty()
                verInfo=obj.fVerificationImpl;
                verInfo.append(otherVerInfo);
            end
        end


        function addSubstatusForSlice(obj,aSliceObject,aStatus)
            verInfo=obj.getVerificationInfo();
            try
                verInfo.addSubstatusForSlice(aSliceObject.getKey(),aStatus);
            catch err
                if strcmp(err.identifier,'Slci:results:ErrorMultipleVerSubstatuses')
                    DAStudio.error('Slci:results:ErrorMultipleVerSubstatuses',...
                    obj.getKey(),aSliceObject.getKey());
                else
                    err.rethrow();
                end
            end
        end


        function addStatusForSlice(obj,aSliceObject,aStatus)
            verInfo=obj.getVerificationInfo();
            try
                verInfo.addStatusForSlice(aSliceObject.getKey(),aStatus);
            catch err
                if strcmp(err.identifier,'Slci:results:ErrorMultipleVerSubstatuses')
                    DAStudio.error('Slci:results:ErrorMultipleVerSubstatuses',...
                    obj.getKey(),aSliceObject.getKey());
                else
                    err.rethrow();
                end
            end
        end


        function addEngineVerSubstatus(obj,aStatus)
            verInfo=obj.getVerificationInfo();
            verInfo.addEngineSubstatus(aStatus);
        end


        function status=getStatusForSlice(obj,sliceName)
            verInfo=obj.getVerificationInfo();
            try
                status=verInfo.getStatusForSlice(sliceName);
            catch ex
                DAStudio.error('Slci:results:ErrorGetSliceForObject',...
                obj.getName(),sliceName);
            end
        end

        function substatus=getSubstatusForSlice(obj,sliceName)
            verInfo=obj.getVerificationInfo();
            try
                substatus=verInfo.getSubstatusForSlice(sliceName);
            catch ex
                DAStudio.error('Slci:results:ErrorGetSliceForObject',...
                obj.getName(),sliceName);
            end
        end


        function slNames=getSliceNames(obj)
            verInfo=obj.getVerificationInfo();
            slNames=verInfo.getSliceNames();
        end


        function slStatuses=getSliceStatuses(obj)
            verInfo=obj.getVerificationInfo();
            slStatuses=verInfo.getSliceStatuses();
        end


        function slSubstatuses=getSliceSubstatuses(obj)
            verInfo=obj.getVerificationInfo();
            slSubstatuses=verInfo.getSliceSubstatuses();
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




        function computeTraceStatus(obj)
            obj.deriveTraceSubstatus;
            obj.setTraceStatus(obj.fReportConfig.getTraceabilityStatus(...
            obj.fTraceSubstatus));
        end


        function addJustification(~,destObj,blockSID,modelManager)
            if slcifeature('SLCIJustification')==1&&modelManager.isFiltered(blockSID)


                destObj.setStatus('JUSTIFIED');
                destObj.setSubstatus('JUSTIFIED');
                destObj.setTraceStatus('JUSTIFIED');
                destObj.setTraceSubstatus('JUSTIFIED');
            end
        end




        function inheritVerificationInfo(obj,destObjs,slciConfig)
            assert(iscell(destObjs),'Invalid input argument');
            statuses=cell(numel(destObjs)+1,1);
            substatuses=cell(numel(destObjs)+1,1);
            statusWeights=zeros(numel(destObjs)+1,1);
            reportConfig=obj.fReportConfig;

            modelManager=slciConfig.getModelManager();
            for k=1:numel(destObjs)
                destObj=destObjs{k};


                if isa(destObj,'slci.results.HiddenBlockObject')&&~isempty(modelManager)
                    obj.addJustification(destObj,destObj.fOrigBlock,modelManager);
                end

                obj.appendVerificationInfo(destObj);
                statuses{k}=destObj.getStatus();
                substatuses{k}=destObj.getSubstatus();
                statusWeights(k)=reportConfig.getStatusWeight(statuses{k});
            end
            statuses{k+1}=obj.getStatus();
            substatuses{k+1}=obj.getSubstatus();
            statusWeights(k+1)=reportConfig.getStatusWeight(statuses{k+1});

            heaviestStatus=reportConfig.getHeaviest(statuses);
            obj.setStatus(heaviestStatus);

            if~strcmpi(heaviestStatus,'VERIFIED')

                [~,heaviestidx]=max(statusWeights);
                heaviestSubstatus=substatuses(heaviestidx);

                obj.setSubstatus(heaviestSubstatus{1});
            end
        end


        function inheritTraceability(obj,destObjs)
            assert(iscell(destObjs),'Invalid input argument');
            newTraceArray={};
            statuses=cell(numel(destObjs)+1,1);
            substatuses=cell(numel(destObjs)+1,1);
            statusWeights=zeros(numel(destObjs)+1,1);
            reportConfig=obj.fReportConfig;
            for k=1:numel(destObjs)
                destObj=destObjs{k};
                newTraceArray=[newTraceArray,destObj.getTraceArray()];%#ok
                statuses{k}=destObj.getTraceStatus();
                substatuses{k}=destObj.getTraceSubstatus();
                statusWeights(k)=reportConfig.getStatusWeight(statuses{k});
            end
            statuses{k+1}=obj.getTraceStatus();
            statusWeights(k+1)=reportConfig.getStatusWeight(...
            obj.getTraceStatus());
            substatuses{k+1}=obj.getTraceSubstatus();

            obj.addTraceKey(newTraceArray);

            heaviestStatus=reportConfig.getHeaviest(statuses);
            obj.setTraceStatus(heaviestStatus);

            if~strcmpi(heaviestStatus,'TRACED')
                [~,heaviestidx]=max(statusWeights);
                heaviestSubstatus=substatuses(heaviestidx);

                obj.setTraceSubstatus(heaviestSubstatus{1});
            end
        end


        function setIncompatibilityObject(obj,aIncompObjs)
            incompKeys=cell(numel(aIncompObjs),1);
            for k=1:numel(aIncompObjs)
                incompObj=aIncompObjs(k);
                if isa(incompObj,'slci.results.IncompatibilityObject')
                    incompKeys{k}=incompObj.getKey();
                else
                    error(['Incompatibility Object should of type '...
                    ,'slci.results.IncompatibilityObject']);
                end
            end
            obj.setIncompatibilityKey(incompKeys);
        end



        function setIncompatibilityKey(obj,incompKeys)
            obj.fIncompatibilityKeys=slci.results.union(obj.fIncompatibilityKeys,...
            incompKeys);
        end


        function incompKey=getIncompatibilityKey(obj)
            incompKey=obj.fIncompatibilityKeys;
        end
    end

    methods(Access=public)

        function verificationInfo=getVerificationInfo(obj)
            verificationInfo=obj.fVerificationImpl;
        end

    end

    methods(Abstract,Access=protected)

        aggSubstatus=aggVerSubstatus(obj);


        aggSubstatus=aggTraceSubstatus(obj);

    end

    methods(Access=protected)


        deriveTraceSubstatus(obj);

    end


end
