classdef ComponentToSubsystemReferenceLinker<systemcomposer.internal.arch.internal.ComponentToModelLinker









    methods(Access=public)
        function obj=ComponentToSubsystemReferenceLinker(blkH,targetFile)
            obj@systemcomposer.internal.arch.internal.ComponentToModelLinker(blkH,targetFile);
        end
    end

    methods(Access=public)
        function mdlBlkH=linkComponentToSubsystemReference(obj)

            blkH=obj.OldBlockHandle;
            bdH=bdroot(blkH);


            prunerDisabler=systemcomposer.internal.ScopedUnconnectedBusPortBlockPrunerDisabler(bdH);

            try

                obj.runValidationChecks();


                obj.runValidationChecksHook();


                obj.preDisableSimulinkListener();


                obj.disableSimulinkListener();


                obj.cacheConnectionsBeforeDelete();


                obj.deleteConnectedLines();


                obj.preReplaceBlock();


                mdlBlkH=obj.replaceBlock();


                obj.postReplaceBlock();


                obj.enableSimulinkListener();


                obj.postEnableSimulinkListener();


                systemcomposer.internal.arch.internal.processBatchedPluginEvents(bdH);


                prunerDisabler.delete();
            catch ME

                prunerDisabler.delete();
                rethrow(ME);
            end
        end
    end

    methods(Access=protected)
        function runValidationChecksHook(obj)

            if exist(obj.LinkTargetFile,'file')~=4
                baseObj=message(...
                'SystemArchitecture:SaveAndLink:FileDoesNotExist',...
                obj.LinkTargetFile);
                baseException=MSLException([],baseObj);
                throw(baseException);
            end



            parent=get_param(obj.OldBlockHandle,'Parent');
            parentSubdomain=get_param(parent,'SimulinkSubdomain');
            if(parentSubdomain=="SoftwareArchitecture"||...
                parentSubdomain=="AUTOSARArchitecture")
                baseObj=message(...
                'SystemArchitecture:SaveAndLink:SubsystemReferenceNotAllowedInSW');
                baseException=MSLException([],baseObj);
                throw(baseException);
            end
        end

        function subrefBlkH=replaceBlock(obj)

            import systemcomposer.internal.arch.internal.ZCUtils;
            try
                blkFullName=getfullname(obj.OldBlockHandle);
                bdH=get_param(bdroot(obj.OldBlockHandle),'Handle');

                blockParams=ZCUtils.getBlockParams(obj.OldBlockHandle);

                slreq.utils.onHierarchyChange('prechange',bdH);

                subrefBlk=slInternal('replace_block',blkFullName,'simulink/Ports & Subsystems/Subsystem Reference','KeepSID','on');
                subrefBlkH=get_param(subrefBlk,'Handle');
                obj.NewBlockHandle=subrefBlkH;


                domainToSet=SimulinkSubDomainMI.SimulinkSubDomainEnum.Simulink;
                load_system(obj.LinkTargetFile);
                if(get_param(obj.LinkTargetFile,'SimulinkSubdomain')=="Architecture")
                    domainToSet=SimulinkSubDomainMI.SimulinkSubDomainEnum.Architecture;
                end
                SimulinkSubDomainMI.SimulinkSubDomain.setSimulinkSubDomain(...
                obj.NewBlockHandle,domainToSet);

                set_param(subrefBlkH,'ReferencedSubsystem',obj.LinkTargetFile);

                slreq.utils.onHierarchyChange('postchange',bdH);
                ZCUtils.restoreBlockParams(obj.NewBlockHandle,blockParams);
            catch ME
                rethrow(ME);
            end
        end

        function postReplaceBlock(obj)

            assert(~isempty(obj.NewBlockHandle)&&ishandle(obj.NewBlockHandle));
            subrefBlkH=obj.NewBlockHandle;

            obj.archCache.restoreComponentSIDBridgeMapping(subrefBlkH);
            obj.archCache.removeCachedPortsFromBridgeMap;

            mdlFile=get_param(subrefBlkH,'ReferencedSubsystem');
            subrefBdH=load_system(mdlFile);

            comp=systemcomposer.utils.getArchitecturePeer(subrefBlkH);



            prevHasInfo=get_param(subrefBdH,'HasSystemComposerArchInfo');
            if strcmp(prevHasInfo,'off')
                subrefArch=get_param(subrefBdH,'SystemComposerArchitecture');
                if isempty(subrefArch)
                    dFlag=get_param(subrefBdH,'Dirty');
                    set_param(subrefBdH,'HasSystemComposerArchInfo','on');
                    subrefArch=get_param(subrefBdH,'SystemComposerArchitecture');
                    set_param(subrefBdH,'HasSystemComposerArchInfo','off');
                    set_param(subrefBdH,'Dirty',dFlag);
                end
            else
                subrefArch=get_param(subrefBdH,'SystemComposerArchitecture');
            end


            comp.setArchitecture(subrefArch.getImpl,true);

            Simulink.SystemArchitecture.internal.ApplicationManager.addChildrenToBridge(...
            obj.BDHandle,subrefBlkH,comp.getOwnedArchitecture,true);
        end
    end

end


