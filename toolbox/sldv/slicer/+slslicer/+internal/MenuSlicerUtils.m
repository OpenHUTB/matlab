classdef MenuSlicerUtils




    methods(Static)
        function cbOpen(callbackInfo)
            modelH=callbackInfo.model.Handle;
            createSlicerDDG(modelH);
        end


        function cbShowDialog(callbackInfo)
            modelH=callbackInfo.model.Handle;
            uiObj=modelslicerprivate('slicerMapper','getUI',modelH);
            if ishandle(uiObj)
                uiObj.show();
            end
        end

        function cbToggleEdit(callbackInfo)
            [actCrit,slcfg,uiObj]=activeSliceCriteria(callbackInfo);
            critList=uiObj.getSource.criteriaListPanel;
            critList.editableHighlight(uiObj);

        end

        function cbClose(callbackInfo)
            modelH=callbackInfo.model.Handle;
            uiObj=modelslicerprivate('slicerMapper','getUI',modelH);

            msObj=modelslicerprivate('slicerMapper','get',modelH);
            if ishandle(uiObj)
                uiObj.delete();
            end

            closeSlicerDDG(msObj.dockedStudio);
        end


        function cbAddTarget(callbackInfo)
            modelH=callbackInfo.model.Handle;
            uiObj=modelslicerprivate('slicerMapper','getUI',modelH);
            if ishandle(uiObj)
                objs=getSelectedObjects(callbackInfo);
                uiObj.show();
                addSelectedHandles(objs);
            end

            function addSelectedHandles(h)


                seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
                dlgSrc=uiObj.getDialogSource;
                sigList=dlgSrc.sigListPanel;
                mex={};
                [status,msg]=sigList.Model.addStart(h);









                if~status
                    vblk=ismember(msg,{'InvalidVirtualBlock'});
                    if all(vblk)


                        for i=1:length(h)
                            toBreak=false;
                            showWarning=false;
                            try

                                targetBlkH=slslicer.internal.getSuggestedBlkHandleForVirtualStartH(h(i),sigList.Model.direction);
                                [~,msg]=slslicer.internal.checkStart(sigList.Model.modelSlicer,targetBlkH,sigList.Model.direction);
                                switch msg
                                case{'StartAddedAlready','ExclusionCannotBeAddedAsStart','ValidDFGBlock'}
                                    qStr=getString(message('Sldv:ModelSlicer:gui:InvalidStartSuggestQestStr'...
                                    ,getfullname(targetBlkH)));
                                    qTitle=getString(message('Sldv:ModelSlicer:gui:InvalidStartSuggestQuestTitle'));
                                    if length(h)==1
                                        ButtonName=questdlg(qStr,qTitle,getString(message('MATLAB:finishdlg:Yes')),...
                                        getString(message('MATLAB:finishdlg:No')),getString(message('MATLAB:finishdlg:Yes')));
                                        if strcmp(ButtonName,getString(message('MATLAB:finishdlg:Yes')))
                                            sigList.Model.addStart(targetBlkH);
                                        end
                                    else
                                        ButtonName=questdlg(qStr,qTitle);
                                        if strcmp(ButtonName,'Yes')
                                            sigList.Model.addStart(targetBlkH);
                                        elseif strcmp(ButtonName,'Cancel')
                                            toBreak=true;
                                        end
                                    end
                                    if~ishandle(uiObj)
                                        return;
                                    end
                                otherwise


                                    showWarning=true;
                                end
                            catch Mex %#ok<NASGU>

                                showWarning=true;
                            end

                            if showWarning
                                mex{end+1}=slslicer.internal.DiagnosticsGenerator.getErrorForStartingPoint(h(i));%#ok<AGROW>
                            end
                            if toBreak
                                break;
                            end
                        end
                    end


                    idex=ismember(msg,{'InvalidVirtualLine'});
                    if any(idex)
                        lineH=h(idex);
                        for index=1:length(lineH)
                            p=get(lineH(index),'SrcPortHandle');
                            mex{end+1}=slslicer.internal.DiagnosticsGenerator.getErrorForStartingPoint(p);
                        end
                    end
                    if slfeature('NewSlicerBackend')==1
                        idex=ismember(msg,{'InactiveHandle'});
                        inactiveH=h(idex);
                        for idx=1:length(inactiveH)
                            elem=inactiveH(idx);
                            if strcmp(get_param(elem,'type'),'line')
                                elem=get(elem,'SrcPortHandle');
                            end
                            mex{end+1}=...
                            slslicer.internal.DiagnosticsGenerator.getErrorForStartingPoint(elem);
                        end
                    end

                end

                if~isempty(mex)

                    modelslicerprivate('MessageHandler','open',sigList.Model.modelSlicer.model);
                    for i=1:length(mex)
                        modelslicerprivate('MessageHandler','warning',mex{i},sigList.Model.modelSlicer.model)
                    end
                    modelslicerprivate('MessageHandler','close');
                end

                if dlgSrc.Busy
                    dlgSrc.Busy=0;
                    uiObj.refresh;
                end



                updateDialogAndHilight(callbackInfo,sigList.Model,dlgSrc.Model,uiObj);
                modelslicerprivate('MessageHandler','close');
            end

        end

        function cbAddTerminal(callbackInfo)
            modelH=callbackInfo.model.Handle;
            uiObj=modelslicerprivate('slicerMapper','getUI',modelH);
            if ishandle(uiObj)
                objs=getSelectedObjects(callbackInfo);

                uiObj.show();

                addSelectedBlockHandles(objs);
            end
            function addSelectedBlockHandles(h)
                dlgSrc=uiObj.getDialogSource;
                sigList=dlgSrc.sigListPanel;
                mex={};
                h=h(h>0);

                for i=1:numel(h)
                    if strcmp(get(h(i),'Type'),'block')

                        ms=sigList.Model.modelSlicer;
                        if ms.isBlockValidTarget(h(i))
                            sigList.Model.addExclusion(h(i));
                        else
                            mex{end+1}=slslicer.internal.DiagnosticsGenerator.getErrorForExclusionPoint(h(i));%#ok<AGROW>
                        end
                    end
                end
                if~isempty(mex)
                    modelslicerprivate('MessageHandler','open',sigList.Model.modelSlicer.model);
                    for i=1:length(mex)
                        modelslicerprivate('MessageHandler','warning',mex{i},sigList.Model.modelSlicer.model);
                    end
                end


                updateDialogAndHilight(callbackInfo,sigList.Model,dlgSrc.Model,uiObj);
                modelslicerprivate('MessageHandler','close');
            end
        end

        function cbShowInSlice(callbackInfo)
            modelH=callbackInfo.model.Handle;

            [sliceMapper,isTopModel]=modelslicerprivate('sliceActiveModelMapper','get',modelH);

            objs=getSelectedObjects(callbackInfo);
            objs(objs==-1)=[];

            if isTopModel
                sliceMapper.highlightInSlice(objs);
            else
                actCrit=activeSliceCriteria(callbackInfo);
                actMdl=get_param(modelH,'Name');
                if~isempty(actCrit)
                    ms=actCrit.modelSlicer;
                    mdlName=getfullname(modelH);
                    if isKey(ms.mdlRefCtxMgr.visibileMdlToActMdl,mdlName)
                        actMdl=ms.mdlRefCtxMgr.visibileMdlToActMdl(mdlName);
                    end
                end
                sliceMapper.highlightInSlice(objs,actMdl);
            end
        end

        function cbShowInOrig(callbackInfo)
            modelH=callbackInfo.model.Handle;
            objs=getSelectedObjects(callbackInfo);
            objs(objs==-1)=[];
            slcrMapObj=modelslicerprivate('sliceMdlMapperObj','get',modelH);
            slcrMapObj.highlightInOrig(objs);
        end

        function cbAddConstraint(callbackInfo)
            selectedHandles=getSelectedObjects(callbackInfo);
            [actCrit,slCfg,~]=activeSliceCriteria(callbackInfo);
            if numel(selectedHandles)==1&&...
                ~isempty(actCrit)
                dlg=actCrit.getConstraintDialog(selectedHandles,slCfg);
                dlg.show();
            end
        end

        function cbEditConstraint(callbackInfo)
            slslicer.internal.MenuSlicerUtils.cbAddConstraint(callbackInfo);
        end

        function cbRemoveConstraint(callbackInfo)
            selectedH=getSelectedObjects(callbackInfo);
            [actCrit,slcfg,uiObj]=activeSliceCriteria(callbackInfo);
            constBlkSID=actCrit.getConstraintBlks;
            if isempty(constBlkSID)
                return;
            end
            changed=false;
            for j=1:numel(selectedH)
                h=selectedH(j);
                if(h<0)
                    continue;
                end
                t=get(h,'Type');
                if(strcmp(t,'block'))
                    sid=Simulink.ID.getSID(h);
                    if(actCrit.removeConstraint(sid))
                        changed=true;
                    end
                end
            end

            if changed
                updateDialogAndHilight(callbackInfo,actCrit,slcfg,uiObj);
            end
        end

        function cbAddCovConstraint(callbackInfo)
            selectedHandles=getSelectedObjects(callbackInfo);
            [actCrit,slcfg,uiObj]=activeSliceCriteria(callbackInfo);
            if numel(selectedHandles)==1&&...
                ~isempty(actCrit)
                if isa(callbackInfo.domain,'StateflowDI.SFDomain')
                    if isa(selectedHandles,'Stateflow.State')||...
                        isa(selectedHandles,'Stateflow.AtomicSubchart')||...
                        isa(selectedHandles,'Stateflow.Transition')
                        changed=actCrit.addCovConstraint(selectedHandles);
                        if changed
                            updateDialogAndHilight(callbackInfo,actCrit,slcfg,uiObj);
                        end
                    end
                end
            end
        end

        function cbRemoveCovConstraint(callbackInfo)
            selectedH=getSelectedObjects(callbackInfo);
            [sc,slcfg,uiObj]=activeSliceCriteria(callbackInfo);
            changed=false;
            for j=1:numel(selectedH)
                if sc.removeCovConstraint(selectedH(j))
                    changed=true;
                end
            end
            if changed
                updateDialogAndHilight(callbackInfo,sc,slcfg,uiObj);
            end
        end


        function cbRemoveTarget(callbackInfo)
            [actCrit,slcfg,uiObj]=activeSliceCriteria(callbackInfo);
            if~isempty(actCrit)
                objHs=getSelectedObjects(callbackInfo);
                changed=actCrit.removeStart(objHs);

                if changed
                    updateDialogAndHilight(callbackInfo,actCrit,slcfg,uiObj);
                end
            end
        end

        function cbRemoveBusElementTarget(callbackInfo)
            [actCrit,slcfg,uiObj]=activeSliceCriteria(callbackInfo);
            if~isempty(actCrit)
                objHs=getSelectedObjects(callbackInfo);
                actCrit.removeAllBusElementStarts(objHs);
                updateDialogAndHilight(callbackInfo,actCrit,slcfg,uiObj);
            end
        end

        function cbRemoveTerminal(callbackInfo)
            [actCrit,slcfg,uiObj]=activeSliceCriteria(callbackInfo);
            if~isempty(actCrit)
                objHs=getSelectedObjects(callbackInfo);
                changed=actCrit.removeExclusion(objHs);
                if changed
                    updateDialogAndHilight(callbackInfo,actCrit,slcfg,uiObj);
                end
            end
        end

        function cbSetSubsystem(callbackInfo)

            modelH=callbackInfo.model.Handle;
            subsysH=getSelectedObjects(callbackInfo);
            createSlicerDDG(modelH);
            uiObj=modelslicerprivate('slicerMapper','getUI',modelH);

            if ishandle(uiObj)
                src=uiObj.getDialogSource;
                sc=src.sigListPanel.Model;
                if~sc.modelSlicer.hasError
                    Transform.SubsystemSliceUtils.addToSlice(subsysH,uiObj);
                end
            end
        end

        function cbRefineDeadlogic(callbackInfo)
            [actCrit,~,uiObj]=activeSliceCriteria(callbackInfo);
            if~isempty(actCrit)
                objHs=getSelectedObjects(callbackInfo);
                dlgSrc=uiObj.getDialogSource;
                sigList=dlgSrc.sigListPanel;
                sigList.openSldvDlg(uiObj);
                dlgSrc.runSldvDlg.getDialogSource.AnalyzedSys=objHs;
            end
        end

        function out=checkUIOpen(callbackInfo)
            modelH=callbackInfo.model.Handle;
            uiObj=modelslicerprivate('slicerMapper','getUI',modelH);


            out=~isempty(uiObj)&&ishandle(uiObj);
        end

        function out=checkUIOpenModel(model)
            modelH=get_param(model,'Handle');
            uiObj=modelslicerprivate('slicerMapper','getUI',modelH);


            out=~isempty(uiObj)&&ishandle(uiObj);
        end

        function out=checkIsEditable(callbackInfo)
            try
                actCrit=activeSliceCriteria(callbackInfo);
                ms=actCrit.modelSlicer;
                out=~ms.compiled;
            catch Mex
                out=false;
            end
        end

        function out=checkIsSimDlgOpen(callbackInfo)
            [~,~,uiObj]=activeSliceCriteria(callbackInfo);
            out=isa(uiObj.getSource.runSimDlg,'DAStudio.Dialog');
        end

        function out=checkIsDialogBusy(callbackInfo)
            out=false;
            modelH=callbackInfo.model.Handle;
            uiObj=modelslicerprivate('slicerMapper','getUI',modelH);
            if ishandle(uiObj)
                out=uiObj.getDialogSource.Busy;
            end
        end

        function out=checkHasSlice(callbackInfo)
            out=false;
            modelH=callbackInfo.model.Handle;

            [sliceMapper,isTopModel]=modelslicerprivate('sliceActiveModelMapper','get',modelH);
            out=~isempty(sliceMapper);
        end

        function out=checkIsASlice(callbackInfo)
            [isSlice,origLoaded]=modelisSlice(callbackInfo);
            out=isSlice&&origLoaded;
        end

        function out=checkHasExcl(callbackInfo)
            out=false;
            actCrit=activeSliceCriteria(callbackInfo);
            if~isempty(actCrit)
                objHs=getSelectedObjects(callbackInfo);
                allExcl=actCrit.getUserExclusions();
                if~isempty(allExcl)
                    allExclH=[allExcl.Handle];
                else
                    allExclH=[];
                end
                x=intersect(objHs,allExclH);
                out=~isempty(x);
            end
        end

        function out=checkHasNonExcl(callbackInfo)
            out=false;
            actCrit=activeSliceCriteria(callbackInfo);
            if~isempty(actCrit)
                objHs=getSelectedObjects(callbackInfo);
                allExcl=actCrit.getUserExclusions();
                if~isempty(allExcl)
                    allExclH=allExcl.Handle;
                else
                    allExclH=[];
                end
                x=setdiff(objHs,allExclH);
                out=~isempty(x);
            end
        end

        function out=checkHasStart(callbackInfo)
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            out=false;
            actCrit=activeSliceCriteria(callbackInfo);
            if~isempty(actCrit)
                objHs=getSelectedObjects(callbackInfo);
                allStarts=actCrit.getUserStarts();
                nonBusElementStarts=arrayfun(@(x)isempty(x.BusElementPath),allStarts);
                allStartH=[allStarts(nonBusElementStarts).Handle];
                x=intersect(objHs,allStartH);
                out=~isempty(x);
            end
        end

        function out=checkHasBusElementStart(callbackInfo)
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            out=false;
            actCrit=activeSliceCriteria(callbackInfo);
            if~isempty(actCrit)
                objHs=getSelectedObjects(callbackInfo);
                allStarts=actCrit.getUserStarts();
                busElementStarts=arrayfun(@(x)~isempty(x.BusElementPath),allStarts);
                allStartH=[allStarts(busElementStarts).Handle];
                x=intersect(objHs,allStartH);
                out=~isempty(x);
            end
        end

        function out=checkHasNonStart(callbackInfo)
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            out=false;
            actCrit=activeSliceCriteria(callbackInfo);
            if~isempty(actCrit)
                objHs=getSelectedObjects(callbackInfo);
                allStarts=actCrit.getUserStarts();
                allStartH=[allStarts.Handle];
                x=setdiff(objHs,allStartH);
                out=~isempty(x);
            end
        end

        function out=checkIsBusSignal(callbackInfo)
            signalHandle=getSelectedObjects(callbackInfo);
            out=false;


            if length(signalHandle)==1&&...
                strcmp(get_param(signalHandle,'Type'),'port')
                sigHierarchy=get_param(signalHandle,'SignalHierarchy');
                if get_param(signalHandle,'CompiledPortBusMode')&&...
                    ~isempty(sigHierarchy)&&~isempty(sigHierarchy.Children)
                    out=true;
                end
            end
        end

        function out=checkHasConstr(callbackInfo)
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            out=false;
            selectedH=getSelectedObjects(callbackInfo);
            [actCriteria,~,~]=activeSliceCriteria(callbackInfo);
            constBlkSID=actCriteria.getConstraintBlks;
            if isempty(constBlkSID)
                return;
            end

            for j=1:numel(selectedH)
                h=selectedH(j);
                if(h<0)
                    continue;
                end
                t=get(h,'Type');
                if(strcmp(t,'block'))
                    sid=Simulink.ID.getSID(h);
                    if ismember(sid,constBlkSID)
                        out=true;
                        return;
                    end
                end
            end
        end

        function out=checkHasCovConstr(callbackInfo)
            out=false;
            [sc,~,~]=activeSliceCriteria(callbackInfo);
            selectedH=getSelectedObjects(callbackInfo);
            if numel(selectedH)==1
                sid=Simulink.ID.getSID(selectedH);
                out=isKey(sc.covConstraints,sid);
            end
        end

        function out=checkHasBlockOrLine(callbackInfo)
            out=false;
            selectedH=getSelectedObjects(callbackInfo);

            for j=1:numel(selectedH)
                h=selectedH(j);
                if(h<0)
                    continue;
                end
                t=get(h,'Type');
                if(strcmp(t,'block'))
                    out=true;
                    return;
                end
                if(strcmp(t,'line'))
                    out=true;
                    return;
                end
            end
        end

        function out=checkSupportsConstr(callbackInfo)
            out=false;
            selectedHandles=getSelectedObjects(callbackInfo);
            if(numel(selectedHandles)==1)
                if isa(callbackInfo.domain,'SLM3I.SLDomain')
                    type=get(selectedHandles,'Type');
                    if(strcmp(type,'block'))
                        blockType=get(selectedHandles,'BlockType');
                        out=any(strcmp(blockType,{'Switch','MultiPortSwitch'}));
                    end
                end
            end
        end

        function out=checkSupportsCovConstr(callbackInfo)


            import slslicer.internal.*
            out=false;
            [sc,~,~]=activeSliceCriteria(callbackInfo);
            if isempty(sc.cvd)||~isa(callbackInfo.domain,'StateflowDI.SFDomain')||...
                sc.modelSlicer.inSteppingMode()
                return;
            end
            selectedHandles=getSelectedObjects(callbackInfo);
            if(numel(selectedHandles)==1)
                out=timeWindowConstraintUtils.isSupported(selectedHandles,sc.cvd);
            end
        end

        function out=checkSubsystemApplicable(callbackInfo,varargin)
            if nargin<2
                out=true;
            else
                out=varargin{1};
            end
            obj=SLStudio.Utils.getOneMenuTarget(callbackInfo);
            try
                ssType=Simulink.SubsystemType(obj.handle);
                if any(strcmp(ssType.getType,...
                    {'atomic','enabled','triggered','enabled and triggered','function call'}))
                    out=true;
                elseif Simulink.SubsystemType.isModelBlock(obj.handle)
                    out=true;
                end
                out=out&&strcmpi(get_param(obj.handle,'CompiledIsActive'),'on');
            catch mex
            end
        end

        function out=checkDeadlogicApplicable(callbackInfo)
            [sc,~,~]=activeSliceCriteria(callbackInfo);
            if sc.modelSlicer.inSteppingMode()
                out=false;
                return;
            end
            out=slslicer.internal.MenuSlicerUtils.checkSubsystemApplicable(callbackInfo,false);
        end

        function out=checkSubsystemInHarness(callbackInfo)

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            uiObj=modelslicerprivate('slicerMapper','getUI',callbackInfo.model.Handle);
            if~isempty(uiObj)
                dlgSrc=uiObj.getDialogSource;
                if dlgSrc.Model.modelSlicer.isHarness
                    out=true;
                else
                    out=false;
                end
            else
                out=false;
            end
        end
    end
end

function out=isModelLoaded(modelName)
    out=false;
    try
        mdlH=get_param(modelName,'Handle');
        out=ishandle(mdlH);
    catch Mex
    end
end

function[isSlice,origLoaded]=modelisSlice(callbackInfo)
    isSlice=false;
    origLoaded=false;
    modelH=callbackInfo.model.Handle;

    try
        origMdlName='';

        if isfield(get_param(modelH,'ObjectParameters'),'SlicerOriginalModel')
            origMdlName=get_param(modelH,'SlicerOriginalModel');
        end
        isSlice=~isempty(origMdlName);

        if(isSlice)
            origLoaded=isModelLoaded(origMdlName);
        end
    catch Mex
    end
end

function[out,slcfg,uiObj]=activeSliceCriteria(callbackInfo)
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    out=[];
    slcfg=[];
    modelH=callbackInfo.model.Handle;
    uiObj=modelslicerprivate('slicerMapper','getUI',modelH);
    if ishandle(uiObj)
        dlgSrc=uiObj.getDialogSource;
        slcfg=dlgSrc.Model;
        sigList=dlgSrc.sigListPanel;
        out=sigList.Model;
    end
end

function updateDialogAndHilight(callbackInfo,actCrit,slcfg,uiObj)
    if nargin<4
        [actCrit,slcfg,uiObj]=activeSliceCriteria(callbackInfo);
    end

    if slcfg.requireAutoRefresh
        actCrit.refresh;
    else
        actCrit.updateSeedColor();
    end
    uiObj.refresh;
end

function showSubsystemParams(callbackInfo)
    blockObj=callbackinfo_get_selection(callbackInfo);
    open_system(blockObj.Handle,'parameter');
end

function objs=getSelectedObjects(cbInfo)
    if~isempty(cbInfo.userdata)
        objs=cbInfo.userdata;
    else
        actCrit=activeSliceCriteria(cbInfo);
        handleMultiInstanceRefs=~isempty(actCrit)&&actCrit.handleMultiInstanceRefs;

        if isa(cbInfo.domain,'SLM3I.SLDomain')

            objs=SLStudio.Utils.getSelectedBlockHandles(cbInfo);
            if isempty(objs)


                objs=getSrcPortsOfSelectedSegments(cbInfo);
            end

            if handleMultiInstanceRefs
                objs=arrayfun(@(obj)loc_getActualHandle(obj),objs);
            end



            if isempty(objs)
                target=SLStudio.Utils.getOneMenuTarget(cbInfo);
                objs=target.handle;
            end

        elseif isa(cbInfo.domain,'StateflowDI.SFDomain')
            objs=SFStudio.Utils.getSelectedStatesAndTransitionIds(cbInfo);
            objs=arrayfun(@(o)idToHandle(sfroot,o),objs,'uni',false);
            objs=[objs{:}];
        end
    end
    function h=loc_getActualHandle(obj)
        h=actCrit.modelSlicer.mdlRefCtxMgr.mapToActualH(obj);
    end
end

function ports=getSrcPortsOfSelectedSegments(cbinfo)
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    segments=SLStudio.Utils.getSelectedSegments(cbinfo);
    ports=[];
    for index=1:length(segments)
        port=SLStudio.Utils.getLineSourcePort(segments(index).container);
        if isa(port,'SLM3I.Port')
            if isempty(ports)
                ports=port.handle;
            else
                ports(end+1)=port.handle;%#ok<AGROW>
            end
        end
    end
    ports=unique(ports);
end


