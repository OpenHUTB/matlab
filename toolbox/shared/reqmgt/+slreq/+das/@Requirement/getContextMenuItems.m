function items=getContextMenuItems(this,caller)



    reqData=slreq.data.ReqData.getInstance();

    currentObj=this;
    isJustificaion=currentObj.isJustification;
    isExternalReq=currentObj.isExternal;




    cView=slreq.utils.getCallerView(caller,true);


    editorSelection=cView.getCurrentSelection;
    isMultiSelection=numel(editorSelection)>1;
    if isMultiSelection
        isSiblings=editorSelection.isSiblings();
    else
        isSiblings=true;
    end
    isReqSetBackedBySlx=arrayfun(@(selection)selection.RequirementSet.isBackedBySlx(),editorSelection);
    selectionContainsReqTable=any(isReqSetBackedBySlx);


    cntxtMenuBuilder=slreq.gui.ContextMenuBuilder(caller);

    template=struct('name','','tag','','callback','','accel','','enabled','on','visible','on');
    cut=template;
    cut.name=getString(message('Slvnv:slreq:Cut'));
    cut.tag='Requirement:Cut';
    cut.callback='slreq.das.Requirement.onCutItem';
    cut.accel='Ctrl+x';
    cut.enabled=bool2OnOff(~selectionContainsReqTable);

    copy=template;
    copy.name=getString(message('Slvnv:slreq:Copy'));
    copy.tag='Requirement:Copy';
    copy.accel='Ctrl+c';
    copy.callback='slreq.das.Requirement.onCopyItem';
    copy.enabled=bool2OnOff(~selectionContainsReqTable);

    paste=template;
    paste.name=getString(message('Slvnv:slreq:Paste'));
    paste.tag='Requirement:Paste';
    paste.accel='Ctrl+v';
    paste.callback='slreq.das.Requirement.onPasteItem';
    paste.enabled=bool2OnOff(reqData.hasCripboardItem()&&~selectionContainsReqTable);

    addChildReq=template;
    addChildReq.name=getString(message('Slvnv:slreq:AddChildRequirement'));
    addChildReq.tag='Requirement:AddChildRequirement';
    addChildReq.accel='';
    addChildReq.callback='slreq.das.Requirement.onAddChildRequirement';
    addChildReq.enabled=bool2OnOff(~selectionContainsReqTable);

    addSiblingReq=template;
    addSiblingReq.name=getString(message('Slvnv:slreq:AddRequirementAfter'));
    addSiblingReq.tag='Requirement:AddRequirementAfter';
    addSiblingReq.accel='';
    addSiblingReq.callback='slreq.das.Requirement.onAddRequirementAfter';
    addSiblingReq.enabled=bool2OnOff(~selectionContainsReqTable);

    moveUp=template;

    moveUp.name=getString(message('Slvnv:slreq:MoveUp'));
    moveUp.tag='Requirement:MoveUp';
    moveUp.accel='';
    moveUp.callback='slreq.das.Requirement.onMoveUpRequirement';
    moveUp.enabled=bool2OnOff(this.canMoveUp(cView)&&~selectionContainsReqTable);

    moveDown=template;
    moveDown.name=getString(message('Slvnv:slreq:MoveDown'));
    moveDown.tag='Requirement:MoveDown';
    moveDown.accel='';
    moveDown.callback='slreq.das.Requirement.onMoveDownRequirement';
    moveDown.enabled=bool2OnOff(this.canMoveDown(cView)&&~selectionContainsReqTable);


    delReq=template;
    delReq.name=getString(message('Slvnv:slreq:Delete'));
    delReq.tag='Requirement:Delete';
    delReq.accel='del';
    delReq.callback='slreq.das.Requirement.onDeleteRequirement';
    delReq.enabled=bool2OnOff(~selectionContainsReqTable);

    isTopLevelReference=false;
    if isExternalReq

        cut.enabled='off';
        paste.enabled='off';
        addChildReq.enabled='off';
        delReq.enabled='off';
        if isa(currentObj.parent,'slreq.das.RequirementSet')
            isTopLevelReference=true;

            delReq.enabled='on';
        else

            addSiblingReq.enabled='off';
        end
    elseif isJustificaion

        addChildReq.enabled='off';
        if isa(currentObj.parent,'slreq.das.RequirementSet')

            addSiblingReq.name=getString(message('Slvnv:slreq:AddRequirementBefore'));
            addSiblingReq.tag='Requirement:AddRequirementBefore';
        else
            addSiblingReq.enabled='off';
        end
    elseif~isSiblings

        delReq.enabled='off';
    end
    cut.enabled=delReq.enabled;
    if~isSiblings
        copy.enabled='off';
    end

    hasChildren=~isempty(currentObj.children);
    expandAll=template;
    expandAll.name=getString(message('Slvnv:slreq:ExpandAll'));
    expandAll.tag='Requirement:ExpandAll';
    expandAll.callback='slreq.das.Requirement.onExpandAll';
    expandAll.enabled=bool2OnOff(hasChildren);

    collapseAll=template;
    collapseAll.name=getString(message('Slvnv:slreq:CollapseAll'));
    collapseAll.tag='Requirement:CollapseAll';
    collapseAll.callback='slreq.das.Requirement.onCollapseAll';
    collapseAll.enabled=bool2OnOff(hasChildren);

    suppressNumber=template;
    if currentObj.dataModelObj.hIdxEnabled
        sectionNumberSuppressed=false;
        suppressNumber.name=getString(message('Slvnv:slreq:SectionNumberDisable'));
    else
        sectionNumberSuppressed=true;
        suppressNumber.name=getString(message('Slvnv:slreq:SectionNumberEnable'));
    end
    suppressNumber.tag='Requirement:SuppressNumber';
    suppressNumber.accel='';
    suppressNumber.callback='slreq.das.Requirement.onSuppressNumber';

    forceNumber=template;
    forceNumber.name=getString(message('Slvnv:slreq:SectionNumberSet'));
    forceNumber.tag='Requirement:SetSectionNumber';
    forceNumber.accel='';
    forceNumber.callback='slreq.das.Requirement.onSetSectionNumber';
    forceNumber.enabled=bool2OnOff(~sectionNumberSuppressed);


    linkWithBlock=template;
    linkWithBlock.tag='Requirement:LinkWithSelectedBlock';
    linkWithBlock.accel='';
    linkWithBlock.callback='slreq.das.Requirement.onLinkToSelectedBlock';

    linkWithBlock.name=getString(message('Slvnv:slreq:LinkWithSelectedSimulink'));
    if~(dig.isProductInstalled('Simulink')&&license('test','simulink'))
        linkWithBlock.visible='off';
    end


    linkWithViewElemInZC=template;

    linkWithViewElemInZC.tag='Requirement:LinkWithSelectedZCViewElement';
    linkWithViewElemInZC.accel='';
    linkWithViewElemInZC.callback='slreq.das.Requirement.onLinkToSelectedZCElement';


    linkWithViewElemInZC.name=getString(message('Slvnv:slreq:LinkWithSelectedViewElement'));
    linkWithViewElemInZC.enabled='off';

    if dig.isProductInstalled('Simulink')&&is_simulink_loaded&&dig.isProductInstalled('System Composer')


        zcElem=sysarch.getCurrentSelection();
        if~isempty(zcElem)&&numel(zcElem)==1
            zcUUID=zcElem{1}.getZCIdentifier;
            modelName=get_param(sysarch.getBDRoot(),'Name');
            name=sysarch.getSummary(zcUUID,modelName);
            objType=sysarch.getObjectType(zcUUID,modelName);
            linkWithViewElemInZC.name=getString(message('Slvnv:slreq:LinkWithSelectedResolvedObj',name,objType));
            linkWithViewElemInZC.enabled='on';

        end
    else
        linkWithViewElemInZC.visible='off';
    end

    disablelinkWithBlock=false;
    if dig.isProductInstalled('Simulink')&&is_simulink_loaded&&~isJustificaion
        [hdl,isSF]=rmisl.getSelection;
        if isempty(hdl)||numel(hdl)>1
            disablelinkWithBlock=true;
            if~isempty(bdroot)&&Simulink.internal.isArchitectureModel(bdroot)


                linkWithBlock.name=getString(message('Slvnv:slreq:LinkWithSelectedArchitectureElement'));
            end
        end
        if~disablelinkWithBlock&&isSF







            if strcmpi(caller,'standalone')

                currentDiagramHandle=slreq.utils.DAStudioHelper.getCurrentBDHandle();
            else





                rootDiagram=bdroot(caller);
                currentDiagramHandle=slreq.utils.DAStudioHelper.getCurrentCanvasModelHandle(rootDiagram,true);
            end

            sr=sfroot;
            sfobj=sr.idToHandle(hdl);
            if~strcmp(sfobj.Machine.Name,getfullname(currentDiagramHandle))
                disablelinkWithBlock=true;
            end

        end

        if disablelinkWithBlock
            linkWithBlock.enabled='off';
        else





            if~rmisl.inLibrary(hdl,isSF)&&~rmisl.inSubsystemReference(hdl,isSF)
                [objName,objType]=rmi.objname(hdl);

                if strcmp(objName,'undef')

                    linkWithBlock.enabled='off';
                else
                    if strcmp(objType,'ModelReference')





                        objRootName=getfullname(bdroot(hdl));
                        if strcmpi(get_param(objRootName,'IsHarness'),'on')


                            ownerName=Simulink.harness.internal.getHarnessOwnerBD(objRootName);
                            if strcmp(get_param(hdl,'ModelName'),ownerName)








                                objName=ownerName;
                                objType=getString(message('Slvnv:rmi:resolveobj:BlockDiagram'));
                            end
                        end
                    end

                    msgId='Slvnv:slreq:LinkWithSelectedResolvedObj';
                    if numel(objName)>30

                        objName=[objName(1:30),'...'];
                    end
                    linkWithBlock.name=getString(message(msgId,objName,objType));
                end
            else
                linkWithBlock.enabled='off';
            end
        end
    else
        linkWithBlock.enabled='off';
        linkWithBlock.name=getString(message('Slvnv:slreq:LinkWithSelectedSimulink'));
    end

    linkWithTest=template;
    linkWithTest.name=getString(message('Slvnv:slreq:LinkWithSelectedTest'));
    linkWithTest.tag='Requirement:LinkWithSelectedTest';
    linkWithTest.accel='';
    linkWithTest.callback='slreq.das.Requirement.onLinkToSelectedTest';

    if dig.isProductInstalled('Simulink Test')
        if~sltest.testmanager.isOpen

            linkWithTest.enabled='off';
        else
            [~,testCaseId,~]=stm.internal.util.getCurrentTestCase();
            if isempty(testCaseId)||isJustificaion
                linkWithTest.enabled='off';
            end
        end
    else
        linkWithTest.visible='off';
    end

    linkWithFaultAna=template;
    linkWithFaultAna.name=getString(message('Slvnv:slreq:LinkWithSelectedFaultObj'));
    linkWithFaultAna.tag='Requirement:LinkWithSelectedFaultTable';
    linkWithFaultAna.accel='';
    linkWithFaultAna.callback='slreq.das.Requirement.onLinkToSelectedFaultElement';
    linkWithFaultAna.visible='off';
    linkWithFaultAna.enabled='off';
    if rmifa.isFaultLinkingEnabled()
        linkWithFaultAna.visible='on';
        if dig.isProductInstalled('Simulink')&&is_simulink_loaded&&~isempty(gcs)
            if strcmpi(caller,'standalone')
                objH=get_param(gcs,'handle');
            else
                objH=get_param(cView.sourceID,'handle');
            end
            if rmifa.isFaultTableSelectionValid(objH)
                linkWithFaultAna.enabled='on';
            end
        end
    end

    linkWithSafetyManager=template;
    linkWithSafetyManager.name=getString(message('Slvnv:slreq:LinkWithSelectedSafetyManagerObj'));
    linkWithSafetyManager.tag='Requirement:LinkWithSelectedSafetyManager';
    linkWithSafetyManager.accel='';
    linkWithSafetyManager.callback='slreq.das.Requirement.onLinkToSelectedSafetyManagerElement';
    linkWithSafetyManager.visible='off';
    linkWithSafetyManager.enabled='off';
    if rmism.isSafetyManagerLinkingEnabled()
        linkWithSafetyManager.visible='on';
        if rmism.isSafetyManagerSelectionValid()
            linkWithSafetyManager.enabled='on';
        end
    end



    linkTargetReqObject=this.view.linkTargetReqObject;
    srcStr='';
    if~isempty(linkTargetReqObject)
        if~isempty(linkTargetReqObject.Summary)
            srcStr=sprintf('"%s : %s"',linkTargetReqObject.Id,linkTargetReqObject.Summary);
        else
            srcStr=sprintf('"%s"',linkTargetReqObject.Id);
        end
        if numel(srcStr)>30
            srcStr=[srcStr(1:30),'..."'];
        end
    end







    runTests=template;
    runTests.name=getString(message('Slvnv:rmisl:menus_rmi_object:RunTestMenuItemName'));
    runTests.tag='Requirement:RunTests';
    runTests.callback='slreq.app.CallbackHandler.onOpenTestExecutionDialog';
    mm=slreq.app.MainManager.getInstance();
    reqEditor=mm.requirementsEditor;
    if isempty(reqEditor)
        isShowVerificationOn=false;
    else
        isShowVerificationOn=reqEditor.displayVerificationStatus;
    end
    if isShowVerificationOn
        verificationLinks=slreq.data.ResultManager.getHierarchicalLinksForRequirement(this);
        if isJustificaion||isempty(verificationLinks)
            runTests.enabled='off';
        end
        rm=slreq.data.ResultManager.getInstance();
        hasVerificationProducts=rm.hasNecessaryVerificationProducts(verificationLinks);
    end



    justificationSubmenu=struct('name',getString(message('Slvnv:slreq:Justification')),'type','submenu','tag','Requirement:JustificationSubmenu','callback','');
    justificationSubmenu.items={};
    isReqLinkForJustification=false;

    if~isJustificaion&&strcmp(caller,'standalone')

        justImplNew=template;
        justImplNew.name=getString(message('Slvnv:slreq:CreateNewForImplementation'));
        justImplNew.tag='Requirement:CreateNewForImplementation';
        justImplNew.callback='slreq.das.Requirement.onNewInmplementationJustification';
        justVerifNew=template;
        justVerifNew.name=getString(message('Slvnv:slreq:CreateNewForVerification'));
        justVerifNew.tag='Requirement:CreateNewForVerification';
        justVerifNew.callback='slreq.das.Requirement.onNewVerificationJustification';
        if~isempty(linkTargetReqObject)...
            &&linkTargetReqObject.isJustification


            isReqLinkForJustification=true;
            justSelectedEnabled='on';
            selectedJustObjStr=srcStr;
        else
            selectedJustObjStr=getString(message('Slvnv:slreq:JustificationSelected'));
            justSelectedEnabled='off';
        end
        justImplSelected=template;
        justImplSelected.name=getString(message('Slvnv:slreq:JustifyForImplementation',selectedJustObjStr));
        justImplSelected.tag='Requirement:SelectionJustificationLinkingForImplementation';
        justImplSelected.callback='slreq.das.Requirement.onSelectionJustificationLinkingForImplementation';
        justImplSelected.enabled=justSelectedEnabled;
        justVerifSelected=template;
        justVerifSelected.name=getString(message('Slvnv:slreq:JustifyForVerification',selectedJustObjStr));
        justVerifSelected.tag='Requirement:SelectionJustificationLinkingForVerification';
        justVerifSelected.callback='slreq.das.Requirement.onSelectionJustificationLinkingForVerification';
        justVerifSelected.enabled=justSelectedEnabled;
        justificationSubmenu.items=[justImplNew,justVerifNew,justImplSelected,justVerifSelected];

    else
        justificationSubmenu.enabled='off';
    end
    linkEditor=template;
    linkEditor.name=getString(message('Slvnv:rmisl:menus_rmi_object:EditAddLinks'));
    linkEditor.tag='Requirement:EditAddLinks';
    linkEditor.callback='slreq.das.Requirement.onOpenLinkEditor';

    spInspectorMenu=[];
    if ishandle(caller)

        spObj=this.view.getCurrentSpreadSheetObject(bdroot(caller));
        if~isempty(spObj)
            if isa(currentObj,'slreq.das.Requirement')
                if~spObj.isInspectorVisible

                    spInspectorMenu=template;
                    spInspectorMenu.name=getString(message('Slvnv:slreq:Inspect'));
                    spInspectorMenu.tag='Requirement:Inspect';
                    spInspectorMenu.callback='slreq.gui.ReqSpreadSheet.openPropertyInspector';
                end
            end
        end
    else

    end

    selectionLinking={};
    selectionStart=template;
    selectionStart.name=getString(message('Slvnv:slreq:SelectForLinkingWithReq'));
    selectionStart.tag='Requirement:SelectForLinkingWithReq';
    selectionStart.callback='slreq.das.Requirement.onStartLinking';
    selectionLinking{end+1}=selectionStart;
    completeLinking=template;
    if~isempty(linkTargetReqObject)...
        &&isvalid(linkTargetReqObject)...
        &&~isequal(currentObj,linkTargetReqObject)...
        &&~currentObj.isJustification...
        &&~isReqLinkForJustification





        if isMultiSelection
            dstStr=getString(message('Slvnv:slreq:CurrentlySelectedReq'));
        elseif~isempty(currentObj.Summary)
            dstStr=sprintf('"%s : %s"',currentObj.Id,currentObj.Summary);
        else
            dstStr=sprintf('"%s"',currentObj.Id);
        end
        if numel(dstStr)>30
            dstStr=[dstStr(1:30),'..."'];
        end

        completeLinking.name=getString(message('Slvnv:slreq:LinkFromTo',srcStr,dstStr));
        completeLinking.tag='Requirement:LinkFromTo';
        completeLinking.callback='slreq.das.Requirement.onCompleteSelectionLinking';
        completeLinking.accel='';
        selectionLinking{1}=[selectionStart,completeLinking];
    end


    copyUrl=template;
    copyUrl.name=getString(message('Slvnv:rmisl:menus_rmi_object:CopyURL'));
    copyUrl.tag='Requirement:CopyUrlToClipboard';
    copyUrl.callback='slreq.das.Requirement.onCopyUrl';

    isInSpreadsheet=ishandle(caller);
    if isInSpreadsheet

        cut.accel='';
        copy.accel='';
        paste.accel='';
        delReq.accel='';
        addChildReq.accel='';
        addSiblingReq.accel='';
        linkWithBlock.accel='';
        linkWithTest.accel='';
        linkEditor.accel='';
        copyUrl.accel='';
    end
    items{1}=[cut,copy,paste,delReq];
    items{2}=[addChildReq,addSiblingReq,moveUp,moveDown];
    items{3}=[expandAll,collapseAll];
    items{4}=[suppressNumber,forceNumber];
    items{5}=[linkWithBlock,linkWithViewElemInZC,linkWithTest,linkWithFaultAna,linkWithSafetyManager,[selectionLinking{:}]];
    if~isInSpreadsheet

        if isShowVerificationOn&&hasVerificationProducts
            items=[items,runTests];
        end
        items{end+1}=justificationSubmenu;
    end
    items{end+1}=linkEditor;
    items{end+1}=copyUrl;


    baseItems=this.getBaseContextMenuItems(caller);
    items=[items,baseItems];

    if isTopLevelReference



        if isFileArtifact(currentObj.dataModelObj.domain)
            docMoveMenu=template;
            docMoveMenu.name=getString(message('Slvnv:slreq:UpdateSrcDocLocation'));
            docMoveMenu.tag='Requirement:UpdateSrcDocLocation';
            docMoveMenu.callback='slreq.das.Requirement.onUpdateSrcLocation';
            items=[{docMoveMenu},items];
        end
    end


    if isInSpreadsheet
        if~isempty(spInspectorMenu)
            items=[{spInspectorMenu},items];
        end
    end

    skipTags={delReq.tag,cut.tag,copy.tag,linkWithBlock.tag,...
    linkWithTest.tag,linkWithFaultAna.tag,linkWithSafetyManager.tag,linkWithViewElemInZC.tag,completeLinking.tag};


    dpMenu=template;
    dpMenu.name=getString(message('Slvnv:slreq_tracediagram:ContextMenu'));
    dpMenu.tag='ReqLink:TraceDiagram';
    dpMenu.callback='slreq.internal.tracediagram.utils.generateTraceDiagram';
    items=[items,{dpMenu}];

    items=cntxtMenuBuilder.adjustMenuEnabledStateBySelection(items,skipTags);

    function tf=isFileArtifact(domain)


        if contains(domain,'REQIF')||contains(domain,'ReqIF:')
            tf=true;
        else


            docType=rmi.linktype_mgr('resolveByRegName',domain);
            tf=~isempty(docType)&&docType.isFile;
        end
    end
end

function onoff=bool2OnOff(tf)
    if tf
        onoff='on';
    else
        onoff='off';
    end
end

