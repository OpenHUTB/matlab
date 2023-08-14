classdef ComponentToModelLinker<handle











    properties(Access=protected)
        OldBlockHandle;
        BDHandle;
        LinkTargetFile;
        NewBlockHandle;
        archPluginTxn;
        archCache;
    end

    methods(Access=public)
        function obj=ComponentToModelLinker(blkH,targetFile)
            assert(ishandle(blkH));
            obj.OldBlockHandle=blkH;
            obj.BDHandle=get_param(bdroot(blkH),'Handle');
            obj.LinkTargetFile=targetFile;
            obj.NewBlockHandle=[];
        end
    end

    methods(Access=public)
        function mdlBlkH=linkComponentToModel(obj)

            blkH=obj.OldBlockHandle;
            bdH=bdroot(blkH);


            prunerDisabler=systemcomposer.internal.ScopedUnconnectedBusPortBlockPrunerDisabler(bdH);

            try

                obj.runValidationChecks();


                obj.runValidationChecksHook();


                obj.preDisableSimulinkListener();


                obj.preDisableSimulinkListenerHook();


                obj.disableSimulinkListener();


                obj.cacheConnectionsBeforeDelete();


                obj.cacheConnectionsBeforeDeleteHook();


                obj.deleteConnectedLines();


                obj.preReplaceBlock();


                obj.preReplaceBlockHook();


                mdlBlkH=obj.replaceBlock();


                obj.postReplaceBlock();


                obj.postReplaceBlockHook();


                obj.enableSimulinkListener();


                obj.enableSimulinkListenerHook();


                obj.postEnableSimulinkListener();


                obj.postEnableSimulinkListenerHook();


                systemcomposer.internal.arch.internal.processBatchedPluginEvents(bdH);


                prunerDisabler.delete();
            catch ME

                prunerDisabler.delete();
                rethrow(ME);
            end
        end
    end

    methods(Sealed,Access=protected)
        function runValidationChecks(obj)


            try
                app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(obj.BDHandle);
                app.validateModelRefName(obj.OldBlockHandle,obj.LinkTargetFile);
            catch ME
                rethrow(ME);
            end

            if~isempty(Simulink.loadsave.resolveFile(obj.LinkTargetFile))

                interface=Simulink.MDLInfo.getInterface(obj.LinkTargetFile);


                if isempty(interface)
                    baseObj=message(...
                    'SystemArchitecture:SaveAndLink:FileNotAllowedForLinking',...
                    obj.LinkTargetFile);
                    baseException=MSLException([],baseObj);
                    throw(baseException);
                end
                if(~isempty(interface.Trigports)||~isempty(interface.Enableports))
                    baseObj=message(...
                    'SystemArchitecture:SaveAndLink:RootLevelControlPortsNotSupportedForArchitecture',...
                    obj.LinkTargetFile);
                    baseException=MSLException([],baseObj);
                    throw(baseException);
                end


                if strcmpi(get_param(obj.BDHandle,'SimulinkSubDomain'),'SoftwareArchitecture')&&...
                    strcmpi(interface.SimulinkSubDomainType,'Architecture')

                    baseObj=message(...
                    'SystemArchitecture:SoftwareArchitecture:CannotReferenceSystemArchitecture',...
                    obj.LinkTargetFile);
                    baseException=MSLException([],baseObj);
                    throw(baseException);
                end


                try
                    resolvedFile=Simulink.loadsave.resolveFile(obj.LinkTargetFile);
                    [~,~,extension]=fileparts(resolvedFile);
                    if extension==".slxp"
                        Simulink.ModelReference.ProtectedModel.getOptions(resolvedFile,'runAllConsistencyChecks');
                    end
                catch ME
                    rethrow(ME);
                end
            end
        end

        function preDisableSimulinkListener(~)
        end

        function disableSimulinkListener(obj)


            obj.archPluginTxn=systemcomposer.internal.arch.internal.ArchitecturePluginTransaction(get_param(obj.BDHandle,'Name'));
        end

        function cacheConnectionsBeforeDelete(obj)

            obj.archCache=systemcomposer.internal.arch.internal.ComponentConnectionCache(obj.OldBlockHandle);
        end

        function deleteConnectedLines(obj)
            systemcomposer.internal.arch.internal.ZCUtils.DeleteConnectedLines(obj.OldBlockHandle);
        end

        function preReplaceBlock(obj)

            bdH=bdroot(obj.OldBlockHandle);
            bridgeData=get_param(bdH,'SimulinkArchBridgeData');
            curComp=systemcomposer.utils.getArchitecturePeer(obj.OldBlockHandle);

            if~(curComp.isReferenceComponent||curComp.isImplComponent)||...
                curComp.isSubsystemReferenceComponent


                curArch=curComp.getOwnedArchitecture;
                subComps=curArch.getComponentsAcrossHierarchy;
                for idx=1:numel(subComps)
                    curHdl=systemcomposer.utils.getSimulinkPeer(subComps(idx));
                    curSID=get_param(curHdl,'SID');
                    bridgeData.removeBlockHandleSIDPairByHandle(curHdl);
                    bridgeData.removeElemPairForSID(curSID);
                end
                subPorts=curArch.getPortsAcrossHierarchy;
                for idx=1:numel(subPorts)
                    curHdl=systemcomposer.utils.getSimulinkPeer(subPorts(idx));
                    curSID=get_param(curHdl,'SID');
                    if(numel(curHdl)==1)
                        bridgeData.removeBlockHandleSIDPairByHandle(curHdl);
                        bridgeData.removeElemPairForSID(curSID);
                    else
                        for locIdx=1:length(curHdl)
                            bridgeData.removeBlockHandleSIDPairByHandle(curHdl(locIdx));
                            bridgeData.removeElemPairForSID(curSID{locIdx});
                        end
                    end
                end
            end
        end
    end

    methods(Access=protected)
        function mdlBlkH=replaceBlock(obj)

            import systemcomposer.internal.arch.internal.ZCUtils;
            try
                blkFullName=getfullname(obj.OldBlockHandle);
                bdH=get_param(bdroot(obj.OldBlockHandle),'Handle');

                blockParams=ZCUtils.getBlockParams(obj.OldBlockHandle);

                slreq.utils.onHierarchyChange('prechange',bdH);

                mdlBlk=slInternal('replace_block',blkFullName,'simulink/Ports & Subsystems/Model','KeepSID','on');
                mdlBlkH=get_param(mdlBlk,'Handle');
                obj.NewBlockHandle=mdlBlkH;
                set_param(mdlBlkH,'ModelFile',obj.LinkTargetFile);

                slreq.utils.onHierarchyChange('postchange',bdH);
                ZCUtils.restoreBlockParams(obj.NewBlockHandle,blockParams);
            catch ME
                rethrow(ME);
            end
        end

        function postReplaceBlock(obj)

            assert(~isempty(obj.NewBlockHandle)&&ishandle(obj.NewBlockHandle));
            mdlBlkH=obj.NewBlockHandle;

            obj.archCache.restoreComponentSIDBridgeMapping(mdlBlkH);
            obj.archCache.removeCachedPortsFromBridgeMap;


            mdlFile=get_param(mdlBlkH,'ModelFile');
            refBdH=-1;

            if(strcmpi(get_param(mdlBlkH,'ProtectedModel'),'off'))
                if(~isempty(mdlFile))
                    refBdH=load_system(mdlFile);
                else
                    refBdH=load_system(get_param(obj.NewBlockHandle,'ModelName'));
                end
            end

            comp=systemcomposer.utils.getArchitecturePeer(mdlBlkH);
            mfMdl=mf.zero.getModel(comp);
            txn=mfMdl.beginTransaction;



            if(ishandle(refBdH)&&(strcmpi(get_param(refBdH,'SimulinkSubDomain'),'Architecture')||...
                strcmpi(get_param(refBdH,'SimulinkSubDomain'),'SoftwareArchitecture')||...
                strcmpi(get_param(refBdH,'SimulinkSubDomain'),'AUTOSARArchitecture')))
                ZCModel=get_param(refBdH,'SystemComposerModel');
                refArch=ZCModel.Architecture.getImpl;


                comp.referenceArchitecture(refArch);
            elseif(ishandle(refBdH)&&strcmpi(get_param(refBdH,'SimulinkSubDomain'),'Simulink'))
                prevHasInfo=get_param(refBdH,'HasSystemComposerArchInfo');
                if strcmp(prevHasInfo,'off')

                    refArch=get_param(refBdH,'SystemComposerArchitecture');
                    if isempty(refArch)



                        inAutosarArch=Simulink.internal.isArchitectureModel(obj.BDHandle,'AUTOSARArchitecture');
                        oldStatus=systemcomposer.internal.arch.internal.parameterSyncWarningStatus(~inAutosarArch);
                        c=onCleanup(@()systemcomposer.internal.arch.internal.parameterSyncWarningStatus(oldStatus));

                        dFlag=get_param(refBdH,'Dirty');
                        set_param(refBdH,'HasSystemComposerArchInfo','on');
                        refArch=get_param(refBdH,'SystemComposerArchitecture');
                        set_param(refBdH,'HasSystemComposerArchInfo','off');
                        set_param(refBdH,'Dirty',dFlag);
                    end
                else
                    refArch=get_param(refBdH,'SystemComposerArchitecture');
                end




                comp.setArchitecture(refArch.getImpl);
            else
                assert(strcmpi(get_param(mdlBlkH,'ProtectedModel'),'on'));
                app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(obj.BDHandle);
                app.refreshComponentInterfaceForProtectedModelBlock(comp,mdlBlkH);
            end

            txn.commit;
        end
    end

    methods(Sealed,Access=protected)
        function enableSimulinkListener(obj)


            delete(obj.archPluginTxn);
        end

        function postEnableSimulinkListener(obj)

            assert(~isempty(obj.NewBlockHandle)&&ishandle(obj.NewBlockHandle));
            mdlBlkH=obj.NewBlockHandle;
            comp=systemcomposer.utils.getArchitecturePeer(mdlBlkH);
            obj.archCache.recreateConnectionsBetweenCachedPorts(comp);
        end

    end



    methods(Access=protected)
        function runValidationChecksHook(obj)
            isRefSWArch=false;
            if~isempty(Simulink.loadsave.resolveFile(obj.LinkTargetFile))
                interface=Simulink.MDLInfo.getInterface(obj.LinkTargetFile);
                isRefSWArch=strcmpi(interface.SimulinkSubDomainType,'SoftwareArchitecture');
            end




            if isRefSWArch&&strcmpi(get_param(obj.BDHandle,'SimulinkSubDomain'),'Architecture')
                compName=get_param(obj.OldBlockHandle,'Name');
                if~systemcomposer.internal.arch.internal.isValidCIdentifier(compName)
                    throw(MSLException('SystemArchitecture:SoftwareArchitecture:InvalidComponentNameForLinking',...
                    getfullname(obj.OldBlockHandle)));
                end
            end
        end

        function preDisableSimulinkListenerHook(~)

        end

        function cacheConnectionsBeforeDeleteHook(~)

        end

        function preReplaceBlockHook(~)

        end

        function postReplaceBlockHook(obj)
            if strcmpi(get_param(obj.BDHandle,'SimulinkSubDomain'),'SoftwareArchitecture')

                set_param(obj.NewBlockHandle,'ScheduleRates','On');
                set_param(obj.NewBlockHandle,'ScheduleRatesWith','Ports');


                swComp=systemcomposer.utils.getArchitecturePeer(obj.NewBlockHandle);
                if isequal(slfeature('SoftwareModelingIRT'),1)&&~swComp.isReferenceComponent
                    set_param(obj.NewBlockHandle,'ShowModelInitializePort','On');
                    set_param(obj.NewBlockHandle,'ShowModelResetPorts','On');
                    set_param(obj.NewBlockHandle,'ShowModelTerminatePort','On');
                end
            end

            if strcmpi(get_param(obj.BDHandle,'SimulinkSubDomain'),'Architecture')


                isRefSWArch=false;
                if~isempty(Simulink.loadsave.resolveFile(obj.LinkTargetFile))
                    interface=Simulink.MDLInfo.getInterface(obj.LinkTargetFile);
                    isRefSWArch=strcmpi(interface.SimulinkSubDomainType,'SoftwareArchitecture');
                end
                if isRefSWArch||...
                    strcmp(get_param(obj.NewBlockHandle,'IsModelRefExportFunction'),'on')
                    set_param(obj.NewBlockHandle,'ScheduleRatesWith','Schedule Editor');
                    set_param(obj.NewBlockHandle,'ScheduleRates','On');
                end
            end
        end

        function enableSimulinkListenerHook(~)

        end

        function postEnableSimulinkListenerHook(~)

        end
    end
end



