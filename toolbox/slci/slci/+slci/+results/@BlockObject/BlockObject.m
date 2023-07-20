



classdef BlockObject<slci.results.ModelObject

    properties(SetAccess=protected,GetAccess=protected)

        fBlockName;
        fBlockType;
        fBlockParentName;
        fSID;
        fBlockHandle;



        fDispBlockType='';
    end


    methods(Access=public,Hidden=true)

        function obj=BlockObject(blkHandle)
            if nargin==0
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'BLOCKOBJECT');
            end
            aKey=slci.results.BlockObject.constructKey(blkHandle);
            obj=obj@slci.results.ModelObject(aKey);
            obj.setBlockProperties(blkHandle);
        end
    end

    methods

        function set.fBlockName(obj,aBlockName)
            if isempty(aBlockName)||~ischar(aBlockName)
                DAStudio.error('Slci:results:InvalidBlockName');
            end
            obj.fBlockName=aBlockName;
        end

        function set.fSID(obj,aSID)
            if isempty(aSID)||~ischar(aSID)
                DAStudio.error('Slci:results:InvalidBlockSID');
            end
            obj.fSID=aSID;
        end

        function set.fBlockType(obj,aBlockType)
            if isempty(aBlockType)||~ischar(aBlockType)
                DAStudio.error('Slci:results:InvalidBlockType');
            end
            obj.fBlockType=aBlockType;
        end


    end

    methods(Access=protected)


        function setBlockProperties(obj,blkHandle)

            obj.fBlockHandle=blkHandle;
            obj.setBlockSID(blkHandle);
            obj.setBlockName(blkHandle);
            obj.setBlockParentName(blkHandle);
            obj.setBlockType(blkHandle);
            obj.setDispBlockType(blkHandle);
            obj.computeIsInlined(blkHandle);
        end

        function setBlockSID(obj,blkHandle)
            obj.fSID=Simulink.ID.getSID(blkHandle);
        end

        function setBlockName(obj,blkHandle)
            obj.fBlockName=get_param(blkHandle,'Name');
        end

        function setBlockParentName(obj,blkHandle)
            obj.fBlockParentName=get_param(blkHandle,'Parent');
        end

        function setBlockType(obj,blkHandle)
            blkType=get_param(blkHandle,'BlockType');
            obj.fBlockType=blkType;
        end




        function setDispBlockType(obj,blkHandle)
            blkType=obj.getBlockType();
            if slci.internal.isMatlabFunctionBlock(...
                get_param(blkHandle,'Object'))
                obj.fDispBlockType='Matlab Function block';
            elseif slci.internal.isStateflowBasedBlock(blkHandle)
                obj.fDispBlockType='Stateflow block';
            elseif strcmpi(blkType,'SubSystem')||...
                strcmpi(blkType,'S-Function')
                maskType=get_param(blkHandle,'MaskType');
                if~isempty(maskType)
                    if strcmpi(maskType,'CMBlock')
                        obj.fDispBlockType='Model Info block';
                    else
                        obj.fDispBlockType=maskType;
                    end
                end
            end
        end

        function computeIsInlined(obj,blkHandle)

            if slci.results.isInlinedBlockObject(obj.getBlockType(),blkHandle)
                obj.setIsInlined();
            end
        end

    end


    methods(Access=public,Hidden=true)

        function handle=getBlockHandle(obj)
            handle=obj.fBlockHandle;
        end


        function objectName=getName(obj)
            objectName=obj.fBlockName;
        end

        function blockSID=getBlockSID(obj)
            blockSID=obj.fSID;
        end

        function blockType=getBlockType(obj)
            blockType=obj.fBlockType;
        end

        function blockParent=getBlockParentName(obj)
            blockParent=obj.fBlockParentName;
        end

        function blockParent=getParent(obj)
            blockParent=obj.fBlockParent;
        end

        function blockFullName=getBlockFullName(obj)
            blockFullName=[obj.getBlockParentName(),'/',obj.getName()];
        end

        function blockType=getDispBlockType(obj)
            blockType=obj.fDispBlockType;
            if isempty(blockType)


                blockType=obj.getBlockType();
            end
        end

        function isRootInport=IsRootInport(obj)
            primSubstatus=obj.getPrimVerSubstatus();
            if any(strcmpi(primSubstatus,'ROOTINPORT'))
                isRootInport=true;
            else
                isRootInport=false;
            end
        end

        function isInlined=IsInlined(obj)
            primSubstatus=obj.getPrimVerSubstatus();
            if any(strcmpi(primSubstatus,'INLINED'))
                isInlined=true;
            else
                isInlined=false;
            end
        end

    end

    methods(Access=public,Hidden=true)


        function setIsUnsupported(obj)
            obj.addPrimVerSubstatus('UNSUPPORTED');
            obj.addPrimTraceSubstatus('UNSUPPORTED');
        end

        function setIsRootInport(obj)
            obj.addPrimVerSubstatus('ROOTINPORT');
            obj.addPrimTraceSubstatus('ROOTINPORT');
        end

        function setIsInlined(obj)
            obj.addPrimVerSubstatus('INLINED');
            obj.addPrimTraceSubstatus('INLINED');
        end

        function setIsVirtual(obj)
            obj.addPrimVerSubstatus('VIRTUAL');
            obj.addPrimTraceSubstatus('VIRTUAL');
        end






        function computeStatus(obj,varargin)


            aggSubstatus=obj.aggVerSubstatus();





            if obj.IsRootInport()
                obj.setSubstatus(aggSubstatus);
                aggStatus=obj.fReportConfig.getStatus(aggSubstatus);
                obj.setStatus(aggStatus);
            else

                verInfo=obj.getVerificationInfo();
                if~verInfo.IsEmpty()
                    obj.setSubstatus(verInfo.getComputedEngineSubstatus());
                    obj.setStatus(verInfo.getComputedEngineStatus());
                    if obj.IsInlined()


                        obj.overrideEngineStatus('INLINED');
                    end
                else
                    obj.setSubstatus(aggSubstatus);
                    obj.setStatus(obj.fReportConfig.getStatus(aggSubstatus));
                end


                if slcifeature('SLCIJustification')==1
                    assert(nargin==2,'SLCI Configuration is not passed.');
                    if nargin==2
                        conf=varargin{1};
                    end
                    fname=fullfile(conf.getReportFolder(),...
                    [conf.getModelName(),'_justification.json']);
                    if isfile(fname)
                        modelManager=slci.view.ModelManager(fname);
                        if modelManager.isFiltered(obj.fSID)

                            substatus='JUSTIFIED';
                            obj.overrideEngineStatus(substatus);
                            obj.addPrimTraceSubstatus('JUSTIFIED');
                        end
                    end
                end
            end

        end


        function overrideEngineStatus(obj,substatus)
            if(any(strcmpi(obj.getStatus,...
                {'VERIFIED','PARTIALLY_PROCESSED','UNABLE_TO_PROCESS',...
                'JUSTIFIED'})))
                obj.setSubstatus(substatus);
                obj.setStatus(obj.fReportConfig.getStatus(substatus));
            end
        end


        function aDispName=getDispName(obj,datamgr)
            repModelwith=obj.fReportConfig.getRepModelName();
            mdl=datamgr.getMetaData('ModelName');
            replacedName=...
            regexprep(obj.getBlockFullName(),mdl,repModelwith,'once');
            aDispName=slci.internal.encodeString(replacedName,'all','encode');
        end

        function hlink=getLink(obj,datamgr)%#ok
            hlink=obj.getBlockSID();
        end

        function callback=getCallback(obj,datamgr)


            blkLink=obj.getLink(datamgr);
            if isempty(blkLink)
                callback=obj.getDispName(datamgr);
            else
                modelFileName=datamgr.getMetaData('ModelFileName');
                encodedModelFileName=slci.internal.encodeString(...
                modelFileName,'all','encode');
                callback=slci.internal.ReportUtil.appendCallBack(...
                obj.getDispName(datamgr),encodedModelFileName,blkLink);
            end
        end

    end

    methods(Access=protected)



        function substatus=aggVerSubstatus(obj)
            primSubstatusList=obj.getPrimVerSubstatus();
            if~isempty(primSubstatusList)

                severityList={'ROOTINPORT',...
                'INLINED',...
                'OPTIMIZED',...
                'VIRTUAL',...
                'UNSUPPORTED'};
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
                'ROOTINPORT',...
                'VERIFICATION_FAILED_TO_VERIFY',...
                'INLINED',...
                'JUSTIFIED',...
                'VERIFICATION_PARTIALLY_PROCESSED',...
                'VERIFICATION_UNABLE_TO_PROCESS',...
                'TRACED',...
                'OPTIMIZED',...
                'VIRTUAL',...
'UNSUPPORTED'...
                };
                substatus=slci.internal.ReportUtil.getHeaviestSubstatus(...
                primSubstatusList,...
                severityList);
            else
                substatus='UNKNOWN';
            end
        end

        function checkTraceObj(obj,aTraceObj)%#ok
            if~isa(aTraceObj,'slci.results.CodeObject')
                DAStudio.error('Slci:results:ErrorTraceObjects','BLOCKOBJECT',...
                class(aTraceObj));
            end
        end

    end

    methods(Static=true,Access=public,Hidden=true)

        function isInlined=isInlinedSubsystem(blkHdl,blockType)



            blkObj=get_param(blkHdl,'Object');
            if strcmpi(blockType,'SubSystem')
                subSystemType=slci.internal.getSubsystemType(blkObj);
                if slci.results.BlockObject.isHiddenOrInlinedSubsystem(...
                    blkObj)||strcmpi(subSystemType,'Variant')
                    isInlined=true;
                    return;
                end
            end
            isInlined=false;
        end

    end

    methods(Static=true,Access=public,Hidden=true)

        function key=constructKey(blkHandle)
            key=Simulink.ID.getSID(blkHandle);
        end

    end

    methods(Static=true,Access=private)

        function flag=isHiddenOrInlinedSubsystem(blkObj)

            flag=false;

            subSystemType=slci.internal.getSubsystemType(blkObj);
            ishiddenOrInlinedSS=...
            (slci.internal.isSynthesized(blkObj)...
            ||strcmpi(blkObj.RTWSystemCode,'Inline'))...
            &&(strcmpi(subSystemType,'Function-call')...
            ||strcmpi(subSystemType,'Atomic')...
            ||strcmpi(subSystemType,'Action'));

            if ishiddenOrInlinedSS
                flag=true;
            elseif slci.internal.isMatlabFunctionBlock(blkObj)
                ph=blkObj.PortHandles;
                isVirtual=strcmpi(blkObj.TreatAsAtomicUnit,'off')&&...
                isempty(ph.Trigger);
                isInlinedOrVirtual=strcmpi(blkObj.RTWSystemCode,'Inline')...
                ||isVirtual;
                flag=isInlinedOrVirtual;
            end

        end

    end


end


