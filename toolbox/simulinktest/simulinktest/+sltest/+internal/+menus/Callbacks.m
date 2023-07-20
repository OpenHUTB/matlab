classdef Callbacks



    methods(Static)





        function createHarnessForBlock(cbinfo)
            [sel,isCompatSingleSel]=sltest.internal.menus.getHarnessSelectionAndValidate(cbinfo);
            if isCompatSingleSel






                Simulink.harness.internal.closeHarnessDialogs(cbinfo.model.Name);
                Simulink.harness.dialogs.createDialog.create(sel);
            end
        end

        function createHarnessForBD(cbinfo)

            Simulink.harness.internal.closeHarnessDialogs(cbinfo.model.Name);
            Simulink.harness.dialogs.createDialog.create(cbinfo.model);
        end

        function importHarnessForBD(cbinfo)

            Simulink.harness.internal.closeHarnessDialogs(cbinfo.model.Name);
            Simulink.harness.dialogs.importDialog.create(cbinfo.model);
        end

        function importHarnessForBlock(cbinfo)
            [sel,isCompatSingleSel]=sltest.internal.menus.getHarnessSelectionAndValidate(cbinfo);
            if isCompatSingleSel

                Simulink.harness.internal.closeHarnessDialogs(cbinfo.model.Name);
                Simulink.harness.dialogs.importDialog.create(sel);
            end
        end





        function openSTM(~)
            sltestmgr;
        end

        function convertToExternal(cbinfo)
            Simulink.harness.internal.convertInternalHarnesses(cbinfo.model.Name,true);
        end

        function convertToInternal(cbinfo)
            Simulink.harness.internal.convertExternalHarnesses(cbinfo.model.Name,true);
        end

        function convertAllToIndependent(cbinfo)
            Simulink.harness.internal.exportAllHarnesses(cbinfo.model.Name,true);
        end

        function convertToIndependent(cbinfo)
            Simulink.harness.internal.exportHarness(cbinfo.model.Name,true);
        end

        function pushHarness(cbinfo)
            owner=Simulink.harness.internal.getHarnessOwnerBD(cbinfo.model.Handle);
            harness=Simulink.harness.internal.getHarnessList(owner,'active');
            Simulink.harness.internal.pushAndNotify(harness);
        end

        function rebuildHarness(cbinfo)
            owner=Simulink.harness.internal.getHarnessOwnerBD(cbinfo.model.Handle);
            harness=Simulink.harness.internal.getHarnessList(owner,'active');
            Simulink.harness.internal.rebuildAndNotify(harness);
        end

        function openHarnessPropertiesDialog(cbinfo)

            h=Simulink.harness.internal.getHarnessInfoForHarnessBD(get_param(cbinfo.model.Name,'handle'));
            Simulink.harness.dialogs.updateDialog.create(h);
        end

        function openHarnessListDialog(cbinfo)
            [sel,isCompatSingleSel]=sltest.internal.menus.getHarnessSelectionAndValidate(cbinfo);
            if isCompatSingleSel
                harnesses=Simulink.harness.internal.getHarnessList(cbinfo.model.Name,'all',sel.Handle);
                if~isempty(harnesses)
                    Simulink.harness.dialogs.harnessListDialog.create(cbinfo.model.Name,harnesses(1).ownerFullPath);
                else
                    Simulink.harness.dialogs.harnessListDialog.create(cbinfo.model.Name,[]);
                end
            elseif isequal(sel,cbinfo.model)
                Simulink.harness.dialogs.harnessListDialog.create(cbinfo.model.Name,cbinfo.model.Name);
            else
                Simulink.harness.dialogs.harnessListDialog.create(cbinfo.model.Name,[]);
            end
        end

        function harnessCheck(cbinfo)
            owner=Simulink.harness.internal.getHarnessOwnerBD(cbinfo.model.Handle);
            harness=Simulink.harness.internal.getHarnessList(owner,'active');
            Simulink.harness.internal.checkAndNotify(harness);
        end




        function toggleHarnessMgrApp(cbinfo)

            if isempty(cbinfo.EventData)
                show=true;
            else
                show=cbinfo.EventData;
            end

            c=dig.Configuration.get();
            app=c.getApp('testHarnessManagerApp');

            if isempty(app)
                return;
            end


            if strcmpi(get_param(cbinfo.model.Handle,'IsHarness'),'on')
                return;
            end

            customContext=sltest.internal.menus.SLTContext(cbinfo.model,app);

            st=cbinfo.studio;
            sa=st.App;
            acm=sa.getAppContextManager;

            if show
                cc=acm.getCustomContext('testHarnessManagerApp');
                if isempty(cc)

                    acm.activateApp(customContext);
                else

                    ts=st.getToolStrip;
                    ts.ActiveTab=cc.DefaultTabName;
                end
            else
                acm.deactivateApp(app.name);
            end
        end

        function goToTop(cbinfo)
            open_system(cbinfo.model.Name);
        end

        function createHarness(cbinfo)






            Simulink.harness.internal.closeHarnessDialogs(cbinfo.model.Name);
            sel=sltest.internal.menus.getHarnessSelectionForToolStripCreateImport(cbinfo);
            Simulink.harness.dialogs.createDialog.create(sel);
        end

        function importHarness(cbinfo)
            Simulink.harness.internal.closeHarnessDialogs(cbinfo.model.Name);
            sel=sltest.internal.menus.getHarnessSelectionForToolStripCreateImport(cbinfo);
            Simulink.harness.dialogs.importDialog.create(sel);
        end

        function closeHarnessBD(cbinfo)
            h=Simulink.harness.internal.getHarnessInfoForHarnessBD(get_param(cbinfo.model.Name,'handle'));
            if strcmp(h.ownerType,'Simulink.BlockDiagram')
                Simulink.harness.internal.closeBDHarness(h.model,h.name,true);
            else
                Simulink.harness.internal.closeHarness(h.model,h.name,h.ownerHandle,true);
            end
        end

        function openTestCasePropertiesDialog(cbinfo)
            h=Simulink.harness.internal.getHarnessInfoForHarnessBD(get_param(cbinfo.model.Name,'handle'));
            Simulink.harness.dialogs.harnessBadgeDialog.create(h);
        end


        function setHarnessName(cbinfo)
            h=Simulink.harness.internal.getHarnessInfoForHarnessBD(get_param(cbinfo.model.Name,'handle'));
            if~strcmp(h.name,cbinfo.EventData)
                Simulink.harness.internal.closeHarnessDialogs(h.model);

                newHarnessName=cbinfo.EventData;

                wstate=warning('off','Simulink:Harness:WarnAboutNameShadowingOnCreationfromCMD');
                oc=onCleanup(@()warning(wstate));
                if~strcmp(h.name,newHarnessName)
                    Simulink.harness.internal.validateHarnessName(h.model,[],...
                    newHarnessName);
                end
                oc.delete;

                if~strcmp(h.name,newHarnessName)&&...
                    ~isempty(which(newHarnessName))&&...
                    ~isequal(newHarnessName,h.model)&&...
                    isempty(find_system('SearchDepth',0,'type','block_diagram','Name',newHarnessName))
                    warnStr=DAStudio.message('Simulink:Harness:WarnAboutNameShadowingOnRename');
                    title=DAStudio.message('Simulink:Harness:WarnAboutNameShadowingOnRenameTitle');
                    choice=questdlg(warnStr,title,'Continue','Cancel','Continue');
                    if~strcmpi(choice,'continue')
                        return;
                    end
                end

                sltest.harness.set(h.ownerFullPath,h.name,'Name',newHarnessName);
            end
        end

        function setRebuildOnOpen(cbinfo)
            h=Simulink.harness.internal.getHarnessInfoForHarnessBD(get_param(cbinfo.model.Name,'handle'));
            Simulink.harness.internal.closeHarnessDialogs(h.model);
            sltest.harness.set(h.ownerFullPath,h.name,'RebuildOnOpen',cbinfo.EventData);
        end

        function setRebuildWithoutCompile(cbinfo)
            h=Simulink.harness.internal.getHarnessInfoForHarnessBD(get_param(cbinfo.model.Name,'handle'));
            Simulink.harness.internal.closeHarnessDialogs(h.model);
            sltest.harness.set(h.ownerFullPath,h.name,'RebuildWithoutCompile',cbinfo.EventData);
        end

        function setRebuildModelData(cbinfo)
            h=Simulink.harness.internal.getHarnessInfoForHarnessBD(get_param(cbinfo.model.Name,'handle'));
            Simulink.harness.internal.closeHarnessDialogs(h.model);
            sltest.harness.set(h.ownerFullPath,h.name,'RebuildModelData',cbinfo.EventData);
        end

        function setSyncOptionOnOpenAndClose(cbinfo)
            if(cbinfo.EventData)
                h=Simulink.harness.internal.getHarnessInfoForHarnessBD(get_param(cbinfo.model.Name,'handle'));
                Simulink.harness.internal.closeHarnessDialogs(h.model);
                sltest.harness.set(h.ownerFullPath,h.name,'SynchronizationMode','SyncOnOpenAndClose');
            end
        end

        function setSyncOptionOnOpenOnly(cbinfo)
            if(cbinfo.EventData)
                h=Simulink.harness.internal.getHarnessInfoForHarnessBD(get_param(cbinfo.model.Name,'handle'));
                Simulink.harness.internal.closeHarnessDialogs(h.model);
                sltest.harness.set(h.ownerFullPath,h.name,'SynchronizationMode','SyncOnOpen');
            end
        end

        function setSyncOptionOnPushRebuildOnly(cbinfo)
            if(cbinfo.EventData)
                h=Simulink.harness.internal.getHarnessInfoForHarnessBD(get_param(cbinfo.model.Name,'handle'));
                Simulink.harness.internal.closeHarnessDialogs(h.model);
                sltest.harness.set(h.ownerFullPath,h.name,'SynchronizationMode','SyncOnPushRebuildOnly');
            end
        end

        function AddObserverReference(~)
            Simulink.observer.internal.createObserverMdlAndAddSpecificPorts(gcs,[],false);
        end

        function AddObserverPort(~)
            Simulink.observer.internal.addObserverPortsForSignalsInObserver(-1,gcs,false);
        end

        function ManageThisObserverDialog(cbinfo)
            obsRefBlk=get_param(cbinfo.model.Name,'ObserverContext');
            Simulink.observer.dialog.ObsPortDialog.getInstance(get_param(obsRefBlk,'Handle'));
        end

        function ManageObserverDialog(cbinfo)
            obsRefBlk=cbinfo.getSelection();
            Simulink.observer.dialog.ObsPortDialog.getInstance(obsRefBlk.Handle);
        end

        function ObserverBlockParams(cbinfo)
            obsRefBlk=cbinfo.getSelection();
            open_system(obsRefBlk.Handle,'Parameter');
        end

        function ObserveSignals(cbinfo)
            sltest.internal.menus.Callbacks.ObserveSignalsInNewObserver(cbinfo);
        end

        function ObserveSignalsInNewObserver(cbinfo)
            selection=cbinfo.getSelection();
            if isa(selection,'Stateflow.State')
                assert(isscalar(selection));
                isDiagram=GLUE2.HierarchyService.isDiagram(cbinfo.targetHID);
                s=struct('SFObj',selection.Id,'Spec','Self','IsDiagram',isDiagram);
                Simulink.observer.internal.createObserverMdlAndAddSpecificPorts(gcs,s,true);
            else
                srcPrtHdls=unique(arrayfun(@(x)x.SrcPortHandle,selection));
                srcPrtHdls=srcPrtHdls(arrayfun(@(x)(x~=-1&&strcmp(get_param(x,'PortType'),'outport')),srcPrtHdls));
                Simulink.observer.internal.createObserverMdlAndAddSpecificPorts(gcs,srcPrtHdls,true);
            end
        end

        function ObserveSignalsInExistingObserver(cbinfo,blkPath)
            selection=cbinfo.getSelection();
            obsMdl=get_param(blkPath,'ObserverModelName');
            if exist(obsMdl,'File')==0
                DAStudio.error('Simulink:Observer:ObsMdlNotFound',obsMdl,blkPath);
            elseif~bdIsLoaded(obsMdl)
                Simulink.observer.internal.openObserverMdlFromObsRefBlk(get_param(blkPath,'Handle'));
            end

            srcPrtHdls=unique(arrayfun(@(x)x.SrcPortHandle,selection));
            srcPrtHdls=srcPrtHdls(arrayfun(@(x)(x~=-1&&strcmp(get_param(x,'PortType'),'outport')),srcPrtHdls));
            bpList=Simulink.sltblkmap.internal.getParentBlockPath(srcPrtHdls);
            blkList=[];
            for j=1:numel(bpList)-1
                if bdroot(bpList(j))==get_param(bdroot(blkPath),'Handle')
                    blkList=bpList(j:end-1);
                    break;
                end
            end
            Simulink.observer.internal.addObserverPortsForSignalsInObserver({blkList,srcPrtHdls},obsMdl,true);
        end

        function GotoLoadedObserverPort(~,obsRefH,blkPath)
            blkH=get_param(blkPath,'Handle');
            mdlH=bdroot(blkH);
            ctxBlk=get_param(mdlH,'CoSimContext');

            if isempty(ctxBlk)||get_param(ctxBlk,'Handle')~=obsRefH
                try
                    Simulink.sltblkmap.internal.convertStandaloneMdlToContexted(mdlH,obsRefH);
                catch ME
                    Simulink.observer.internal.error(ME,true,'Simulink:Observer:ObserverStage',getfullname(mdlH));
                    return;
                end
            end
            sys=get_param(blkPath,'Parent');
            if~strcmp(get_param(sys,'Open'),'on')
                open_system(sys,'force','Window');
            else
                open_system(sys);
            end

            portHandles=get_param(blkH,'PortHandles');
            linH=get_param(portHandles.Outport,'Line');
            if linH~=-1
                hdls=[blkH,linH];
            else
                hdls=blkH;
            end
            SLStudio.HighlightSignal.removeHighlighting(mdlH);
            SLStudio.EmphasisStyleSheet.applyStyler(mdlH,hdls);
        end

        function GotoUnloadedObserverPort(~,obsRefH,mdlName,blkSID)
            try
                open_system(obsRefH);
            catch ME
                Simulink.observer.internal.error(ME,true,'Simulink:Observer:ObserverStage',mdlName);
                return;
            end

            blkH=Simulink.ID.getHandle(blkSID);
            if blkH==-1
                Simulink.observer.internal.error(DAStudio.message('Simulink:Observer:ObserverPortNoLongerValid',blkSID),true,'Simulink:Observer:ObserverStage',mdlName);
            end

            sys=get_param(blkH,'Parent');
            if~strcmp(get_param(sys,'Open'),'on')
                open_system(sys,'force','Window');
            else
                open_system(sys);
            end

            portHandles=get_param(blkH,'PortHandles');
            linH=get_param(portHandles.Outport,'Line');
            if linH~=-1
                hdls=[blkH,linH];
            else
                hdls=blkH;
            end
            mdlH=bdroot(blkH);
            SLStudio.HighlightSignal.removeHighlighting(mdlH);
            SLStudio.EmphasisStyleSheet.applyStyler(mdlH,hdls);
        end

        function SendBlockToObserver(cbinfo)
            sltest.internal.menus.Callbacks.SendBlockToNewObserver(cbinfo);
        end

        function SendBlockToNewObserver(cbinfo)
            selection=cbinfo.getSelection();
            Simulink.observer.internal.sendBlockToObserver(selection.getFullName,'',true);
        end

        function SendBlockToExistingObserver(cbinfo,blkPath)
            selection=cbinfo.getSelection();
            obsMdl=get_param(blkPath,'ObserverModelName');
            if exist(obsMdl,'File')==0
                DAStudio.error('Simulink:Observer:ObsMdlNotFound',obsMdl,blkPath);
            elseif~bdIsLoaded(obsMdl)
                Simulink.observer.internal.openObserverMdlFromObsRefBlk(get_param(blkPath,'Handle'));
            end

            Simulink.observer.internal.sendBlockToObserver(selection.getFullName,obsMdl,true);
        end
    end

end
