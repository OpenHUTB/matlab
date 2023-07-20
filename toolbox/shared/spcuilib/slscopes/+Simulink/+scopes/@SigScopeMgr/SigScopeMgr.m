classdef SigScopeMgr<handle







    properties(SetAccess=private)
        mBlockDiagramHandle=[];
        mSelectedBlock=[];
        mStudio=[];


        mSelectedTab=[];
        mSelectedViewer=[];
        mSelectedGenerator=[];
        mSelectedSignal=[];



        bindModeSourceDataObj=[];



        mMarkedBlockDiagramItems=[];



        mModelModelPreCompListener=[];
        mModelSimStopListener=[];
        mIsSimulating=false;

        mDestroyModelEvent=[];
        mSignalNameChangedListener=[];

        mDialogTagsCreated={};




        mScopeVisualChanged=[];
    end

    properties(SetAccess=public)


        viewerSpreadsheetData=[];
        generatorSpreadsheetData=[];
        signalSpreadsheetData=[];
    end

    methods(Static,Access=public,Hidden)



        out=setgetSSM_Map(createMap,varargin);



        out=setget_SSM_Tag(tagKey,varargin);



        out=setget_SSM_DlgToStudio(tagKey,varagin);

        handleEditorChanged(~,~,~);

        function key=handleToKey(mdlHandle)


            key=sprintf('%10.20f',mdlHandle);
        end

        function[ssmComponent,tagName]=getSSMgrComponent(studio,varargin)




            ssmTagMap=Simulink.scopes.SigScopeMgr.setget_SSM_Tag();
            ssmTags=[];
            if~isempty(ssmTagMap)&&ssmTagMap.isKey(studio.getStudioTag())
                ssmTags=Simulink.scopes.SigScopeMgr.setget_SSM_Tag(studio.getStudioTag());
            end
            if nargin>1&&isempty(ssmTags)
                mdlName=varargin{1};
                tagName=['SSMgr_',mdlName,'_',studio.getStudioTag()];
                if nargin>2
                    ssmTags=Simulink.scopes.SigScopeMgr.setget_SSM_Tag(studio.getStudioTag(),tagName,tagName);
                else
                    ssmTags=Simulink.scopes.SigScopeMgr.setget_SSM_Tag(studio.getStudioTag(),tagName);
                end
            end

            tagName=[];
            ssmComponent=[];
            if~isempty(ssmTags)
                tagName=ssmTags.DDGTag;

                ssmComponent=studio.getComponent('GLUE2:DDG Component',ssmTags.ComponentTag);
            end
        end

        function source=getSSMgrSource(mdlHandle,studio,selected)


            SSMgrMap=Simulink.scopes.SigScopeMgr.setgetSSM_Map();

            if isempty(SSMgrMap)
                SSMgrMap=Simulink.scopes.SigScopeMgr.setgetSSM_Map(1);
            end

            SsmKey=Simulink.scopes.SigScopeMgr.handleToKey(mdlHandle);
            if SSMgrMap.isKey(SsmKey)
                source=SSMgrMap(SsmKey);
                if~isvalid(source.mStudio)
                    source.mStudio=studio;
                end
            else
                source=Simulink.scopes.SigScopeMgr(mdlHandle,studio,selected);
            end
        end

        function updateAllDDGForSource(source)

            ssm=getDDGDialog(source);
            for i=1:numel(ssm)
                ssm(i).refresh();
            end
        end

        function dlg=getDlgForStudio(studio)


            dlg=[];
            [ssmComponent,~]=Simulink.scopes.SigScopeMgr.getSSMgrComponent(studio);
            if~isempty(ssmComponent)
                dlgSrc=ssmComponent.getSource();
                dlg=DAStudio.ToolRoot.getOpenDialogs(dlgSrc);
            end
        end
    end

    methods(Static,Access=public)


        ioLibraries=getViewersAndGenerators(ioType);




        function showSigScopeMgr(cbinfo,selected)




            Simulink.scopes.SigScopeMgr.getViewersAndGenerators('viewer');
            Simulink.scopes.SigScopeMgr.getViewersAndGenerators('siggen');

            if cbinfo.model.handle~=cbinfo.editorModel.handle
                mdlHandle=cbinfo.editorModel.handle;
            else
                mdlHandle=cbinfo.model.handle;
            end
            studio=cbinfo.studio;

            [ssmComponent,tagName]=Simulink.scopes.SigScopeMgr.getSSMgrComponent(studio,cbinfo.editorModel.name,1);
            source=Simulink.scopes.SigScopeMgr.getSSMgrSource(mdlHandle,studio,selected);
            source.mStudio=studio;



            if(isempty(ssmComponent))


                comp=DAStudio.openEmbeddedDDGForSource(cbinfo.studio,source,tagName,getString(message('Spcuilib:scopes:SSMgrTitle')),'Right','Tabbed');
                dlg=comp.getDialog();
                Simulink.scopes.SigScopeMgr.setget_SSM_DlgToStudio(dlg.DialogTag,cbinfo.studio.getStudioTag());

                if isempty(source.mDialogTagsCreated)
                    source.mDialogTagsCreated={dlg.DialogTag};
                else
                    source.mDialogTagsCreated=[source.mDialogTagsCreated,{dlg.DialogTag}];
                end










                c=cbinfo.studio.getService('GLUE2:ActiveEditorChanged');
                c.registerServiceCallback(@Simulink.scopes.SigScopeMgr.handleEditorChanged);
            else
                if(~ssmComponent.isVisible())
                    cbinfo.studio.showComponent(ssmComponent);
                    ssm=ssmComponent.getDialog();
                    source=ssm.getSource();




                    source.setSignalSpreadsheetChildren(source.signalSpreadsheetData);




                    selectedObject.mSelectionHandle=source.mSelectedSignal;
                    Simulink.scopes.SigScopeMgr.onSignalSelectionChanged('',{selectedObject},source);
                else
                    Simulink.scopes.SigScopeMgr.updateAllDDGForSource(source);
                end
            end
            source.createVisualChangedEventListeners();
        end

        function hideSignalAndScopeMgr(cbinfo)
            studio=cbinfo.studio;
            ssmComponent=Simulink.scopes.SigScopeMgr.getSSMgrComponent(studio,cbinfo.editorModel.name,1);
            studio.hideComponent(ssmComponent);
        end

        function showSigScopeMgrNavigation(studio,~,mdlHandle,~)




            source=Simulink.scopes.SigScopeMgr.getSSMgrSource(mdlHandle,studio,[]);
            [ssmComponent,~]=Simulink.scopes.SigScopeMgr.getSSMgrComponent(studio);

            if~isempty(ssmComponent)

                if(ssmComponent.getSource()~=source)
                    ssmComponent.updateSource(source);
                end


                Simulink.scopes.SigScopeMgr.setget_SSM_Tag(studio.getStudioTag(),source.getTagName());



                Simulink.scopes.SigScopeMgr.updateAllDDGForSource(source);
            else




                studioComponents=studio.getAllComponents();

                DDGComponentsIndex=cellfun(@(x)isa(x,'GLUE2.DDGComponent'),studioComponents);
                DDGComponents=studioComponents(DDGComponentsIndex);


                ssmIndex=cellfun(@(x)isa(x.getSource,class(source)),DDGComponents);

                ssmComponent=DDGComponents{ssmIndex};


                for i=1:numel(ssmComponent)
                    if ssmComponent(i).getSource.mBlockDiagramHandle~=mdlHandle
                        studio.destroyComponent(ssmComponent(i));
                    end
                end
            end
        end

        function r=onViewerSelectionChanged(~,sels,dlg,dlgSrc)


            dlgSrc.clearMarkedSignals();



            sigSpreadSheetIntef=dlg.getWidgetInterface('ssMgrSignalSpreadsheet');
            if length(sels)==1

                dlgSrc.mSelectedViewer=sels{1}.mSource;
                nameColumn=getString(message('Spcuilib:scopes:SSMgrName'));


                if strcmp(get_param(dlgSrc.mSelectedViewer,'BlockType'),'Scope')
                    sigSpreadSheetIntef.setColumns({getString(message('Spcuilib:scopes:SSMgrDisplay')),...
                    nameColumn},'','',true);
                else
                    sigSpreadSheetIntef.setColumns({getString(message('Spcuilib:scopes:SSMgrInput')),...
                    nameColumn},'','',true);
                end
            else
                dlgSrc.mSelectedViewer=[];
            end



            sigSpreadSheetIntef.update();

            dlgSrc.refreshButtons();




            if~isempty(dlgSrc.mSelectedViewer)
                portHandles=get_param(dlgSrc.mSelectedViewer,'IOSignals');
                portHandles=vertcat(portHandles{:});
                portHandles=unique([portHandles.Handle]);
                slsignalselector.utils.hiliteSelectedSignals(portHandles);
            end




            if BindMode.BindMode.isEnabled(dlgSrc.mBlockDiagramHandle)


                dlgSrc.startBindMode(dlgSrc);
            end


            r=true;
        end

        function onItemClicked(~,~,~,dlg,dlgSrc)








            editor=BindMode.utils.getLastActiveEditor();
            assert(~isempty(editor));
            mdlHandle=editor.getStudio().App.blockDiagramHandle;
            if BindMode.BindMode.isEnabled(mdlHandle)&&(isempty(dlgSrc.bindModeSourceDataObj)||~dlgSrc.bindModeSourceDataObj.isvalid())


                dlgSrc.startBindMode(dlgSrc);
            end


            ss=dlg.getWidgetInterface('ssMgrSignalSpreadsheet');
            if~isempty(ss)
                ss.update;
            end
        end

        function r=onGeneratorSelectionChanged(~,sels,dlgSrc)



            dlgSrc.clearMarkedSignals();

            if length(sels)==1
                dlgSrc.mSelectedGenerator=sels{1}.mSource;
            else
                dlgSrc.mSelectedGenerator=[];
            end

            dlgSrc.refreshSignalSpreadsheet();
            dlgSrc.refreshButtons();

            if~isempty(dlgSrc.bindModeSourceDataObj)&&dlgSrc.bindModeSourceDataObj.isvalid()


                dlgSrc.startBindMode(dlgSrc);
            end


            r=true;
        end

        function r=onSignalSelectionChanged(~,sels,dlgSrc)



            dlgSrc.clearHighlightedSignal();

            if length(sels)==1
                dlgSrc.mSelectedSignal=sels{1}.mSelectionHandle;


                if(~isempty(dlgSrc.mSelectedSignal))
                    studio=dlgSrc.mStudio;
                    editor=studio.App.getActiveEditor();
                    assert(~isempty(editor));

                    newHdl=dlgSrc.updatePort(dlgSrc.mSelectedSignal);
                    slsignalselector.utils.hiliteSelectedSignals(newHdl);

                end
            else
                dlgSrc.mSelectedSignal=[];
            end


            r=true;


        end

        function onViewerGenTabChanged(dlg,~,idx)



            nameColumn=getString(message('Spcuilib:scopes:SSMgrName'));

            dlgToStudioMap=Simulink.scopes.SigScopeMgr.setget_SSM_DlgToStudio();
            if~isempty(dlgToStudioMap)&&dlgToStudioMap.isKey(dlg.DialogTag)
                studioTag=dlgToStudioMap(dlg.DialogTag);
                studio=DAS.Studio.getStudio(studioTag);
                as=studio.getToolStrip().getActionService();
                context=as.Context;
            else
                context=[];
            end

            if(idx==0)

                dlg.getDialogSource.setSelectedTab('viewers');
                if~isempty(context)
                    context.SSMActiveTab='viewers';
                end






                sigSpreadsheetWidget=dlg.getWidgetInterface('ssMgrSignalSpreadsheet');
                viewerSpreadsheetWidget=dlg.getWidgetInterface('ssMgrViewerSpreadsheet');

                if isempty(viewerSpreadsheetWidget.getSelection)||strcmp(get_param(viewerSpreadsheetWidget.getSelection{1}.mSource,'BlockType'),'Scope')
                    sigSpreadsheetWidget.setColumns({getString(message('Spcuilib:scopes:SSMgrDisplay')),...
                    nameColumn},'','',true);
                else
                    sigSpreadsheetWidget.setColumns({getString(message('Spcuilib:scopes:SSMgrInput')),...
                    nameColumn},'','',true);
                end
            elseif(idx==1)


                dlg.getDialogSource.setSelectedTab('generators');
                if~isempty(context)
                    context.SSMActiveTab='generators';
                end
                sigSpreadsheetWidget=dlg.getWidgetInterface('ssMgrSignalSpreadsheet');
                sigSpreadsheetWidget.setColumns({getString(message('Spcuilib:scopes:SSMgrOutput')),...
                nameColumn},'','',true);
            end





            dlgSrc=dlg.getDialogSource;

            bindModeObj=dlgSrc.bindModeSourceDataObj;


            if~isempty(bindModeObj)&&bindModeObj.isvalid


                dlgSrc.startBindMode(dlgSrc);
            end
        end

        function onParamsButton(src)
            open_system(src.getSelectedViewerGenerator());
        end

        function onDeleteButton(src)

            selected=src.getSelectedViewerGenerator();


            bindModeObj=src.bindModeSourceDataObj;


            if(~isempty(bindModeObj)&&bindModeObj.isvalid)
                model=bdroot(selected);
                BindMode.BindMode.disableBindMode(get_param(bindModeObj.modelName,'Object'));
            end


            sigandscopemgr('DeleteObject',selected);



            if(strcmpi(src.getSelectedTab(),'viewers'))
                src.mSelectedViewer=[];
                entryToRemove=find(ismember([src.viewerSpreadsheetData.mSource],selected));
                if~isempty(entryToRemove)
                    src.viewerSpreadsheetData(entryToRemove)=[];
                end
            elseif(strcmpi(src.getSelectedTab(),'generators'))
                src.mSelectedGenerator=[];
                entryToRemove=find(ismember([src.generatorSpreadsheetData.mSource],selected));
                if~isempty(entryToRemove)
                    src.generatorSpreadsheetData(entryToRemove)=[];
                end
            end

            src.refresh();
        end

        function onHelpButton(~)
            slprophelp('sigandscopemgr')
        end

        function onAddButton(src)




            ts=src.mStudio.getToolStrip();
            as=ts.getActionService();
            ctx=as.Context;







            if(strcmpi(src.getSelectedTab(),'viewers'))
                if isempty(ctx)
                    type=Simulink.iomanager.IOType.findIOType('Scope');
                else
                    Simulink.scopes.AddViewerDialog.show(ctx,1);
                end
            elseif(strcmpi(src.getSelectedTab(),'generators'))
                if isempty(ctx)
                    type=Simulink.iomanager.IOType.findIOType('Clock');
                else
                    Simulink.scopes.AddGeneratorDialog.show(ctx,1);
                end
            end
            if isempty(ctx)
                sigandscopemgr('AddObject',src.mBlockDiagramHandle,type);
                src.refresh();
            end
        end

        function onSigSelectButton(src)






            editor=BindMode.utils.getLastActiveEditor();
            assert(~isempty(editor));
            mdlHandle=editor.getStudio().App.blockDiagramHandle;






            if BindMode.BindMode.isEnabled(mdlHandle)&&src.bindModeSourceDataObj.isvalid
                BindMode.BindMode.disableBindMode(get_param(mdlHandle,'Object'));
            elseif BindMode.BindMode.isEnabled(mdlHandle)&&~isempty(BindMode.BindMode.getInstance().bindModeSourceDataObj.webScopeClientID)
                src.bindModeSourceDataObj=BindMode.BindMode.getInstance().bindModeSourceDataObj;
                BindMode.BindMode.disableBindMode(get_param(mdlHandle,'Object'));
            else
                src.startBindMode(src);
            end
        end

        function startBindMode(src)




            selected=src.getSelectedViewerGenerator();
            numAxes=sigandscopemgr('GetNumPorts',selected);
            multipleSigs=0;
            dropDownPrefix=getString(message('Spcuilib:scopes:BindToInputType'));
            isScope=strcmp('Scope',get_param(selected,'BlockType'))||strcmp('WebTimeScopeBlock',get_param(selected,'BlockType'));



            if((~isempty(isScope)&&isScope)||strcmpi(src.getSelectedTab(),'generators'))



                multipleSigs=1;



                dropDownPrefix=getString(message('Spcuilib:scopes:BindToDisplayType'));
            elseif strcmp('MPlay',get_param(selected,'MaskType'))
                multipleSigs=1;
            end



            if~isempty(selected)

                if strcmp(src.mSelectedTab,'generators')

                    src.enterPortSelectionBindMode(src,selected)
                else

                    src.enterSignalSelectionBindMode(src,selected,numAxes,multipleSigs,dropDownPrefix);
                end
            end
        end

        function onPromoteButton(~)


            errordlg('The Promote to Results Gallery button will be implemented once the Simulink Toolstrip is enabled, or otherwise will be removed.');
        end

        function onClose(src)
            src.clearMarkedSignals();
            src.clearHighlightedSignal();
        end

        function enterSignalSelectionBindMode(src,selected,numAxes,allowMultipleConnections,dropDownPrefix)






            SigSelController=Simulink.scopes.source.SignalSelectorController.getInstance;
            if~isempty(SigSelController.bindModeSourceDataObj)&&SigSelController.bindModeSourceDataObj.isvalid



                mdlHandle=get_param(SigSelController.bindModeSourceDataObj.modelName,'Handle');
                BindMode.BindMode.disableBindMode(get_param(mdlHandle,'Object'));
            end



            blockPath=getfullname(selected);



            editor=SLM3I.SLDomain.getLastActiveEditorFor(bdroot(selected));
            if isempty(editor)
                editor=GLUE2.Util.findAllEditors(get_param(bdroot(selected),'Name'));
            end
            assert(~isempty(editor));
            bindModeSource=get_param(editor.getStudio().App.blockDiagramHandle,'Name');


            src.bindModeSourceDataObj=BindMode.SignalSelectorSourceData(bindModeSource,blockPath,...
            allowMultipleConnections,numAxes,false,dropDownPrefix);



            src.bindModeSourceDataObj.setUpdateCallback(@src.refreshSignalSpreadsheet);

            BindMode.BindMode.enableBindMode(src.bindModeSourceDataObj);
            src.checkForWebScopesAndUpdateVisual();
        end

        function enterPortSelectionBindMode(src,selected)




            src.bindModeSourceDataObj=BindMode.PortSelectorSourceData(selected);



            src.bindModeSourceDataObj.setUpdateCallback(@src.refreshSignalSpreadsheet);

            BindMode.BindMode.enableBindMode(src.bindModeSourceDataObj);
        end

        function updateSSMFromRightClickContextMenu(cbinfo)






            modelH=cbinfo.editorModel.Handle;

            dlgs=DAStudio.ToolRoot.getOpenDialogs;

            for index=1:length(dlgs)
                dlg=dlgs(index);
                source=dlg.getSource();
                if isa(source,'Simulink.scopes.SigScopeMgr')&&...
                    source.mBlockDiagramHandle==modelH
                    source.refresh();
                end
            end
        end

        function updateAllSSMWindows()







            dlgs=DAStudio.ToolRoot.getOpenDialogs;


            dialogIndeces=1:numel(dlgs);


            isSSMdlg=arrayfun(@(x)strfind(dlgs(x).dialogTag,'SSMgr'),dialogIndeces,'UniformOutput',false);



            for i=1:numel(isSSMdlg)
                if isSSMdlg{i}
                    dlgs(dialogIndeces(i)).getDialogSource.refresh();
                end
            end
        end

        function actionStruct=onSignalSpreadSheetContextMenuCB(~,item,~,dlgSrc)







            name=getString(message('Spcuilib:scopes:SSMgrSignalProperties'));
            command='';
            enabled=true;


            if(strcmp(get_param(item.mSelectionHandle,'Type'),'block'))
                enabled=false;
            end
            if enabled
                if(strcmpi(dlgSrc.mSelectedTab,'generators'))
                    viewerSiggenSelection=dlgSrc.mSelectedGenerator;
                else
                    viewerSiggenSelection=get_param(item.mSelectionHandle,'ParentHandle');
                end
                command=@(compTag)sigandscopemgr('SigPropDialog',item.mSelectionHandle,viewerSiggenSelection);
            end
            actionStruct=struct('label',name,'enabled',enabled,'command',command);










        end

        function actionStruct=onViewerSiggenSpreadSheetContextMenuCB(~,item,~,dlgSrc)





            name=getString(message('Spcuilib:scopes:SSMgrHighlightConnectedSignals'));
            enabled=true;

            if isempty([dlgSrc.signalSpreadsheetData.mSelectionHandle])
                enabled=false;
            end

            command=@(compTag)dlgSrc.rightClickViewerSiggenHighlight(item,dlgSrc);
            actionStruct=struct('label',name,'enabled',enabled,'command',command);
        end
    end

    methods

        function this=SigScopeMgr(mdlHandle,studio,selected)

            this.mBlockDiagramHandle=mdlHandle;
            this.mStudio=studio;

            if nargin>2&&~isempty(selected)

                this.mSelectedBlock=selected;
            end



            cosObj=get_param(this.mBlockDiagramHandle,'InternalObject');
            if(isempty(this.mModelModelPreCompListener))
                this.mModelModelPreCompListener=event.listener(cosObj,'SLCompEvent::PRE_COMPILE_UI_MODEL_EVENT',@(~,~)this.isModelSimulating);
            end




            if isempty(this.mDestroyModelEvent)
                this.mDestroyModelEvent=event.listener(cosObj,'SLGraphicalEvent::DESTROY_MODEL_EVENT',@(~,~)this.modelDestroyed);
            end




            if isempty(this.mModelSimStopListener)
                this.mModelSimStopListener=event.listener(cosObj,'SLExecEvent::SIMSTATUS_STOPPED',@(~,~)this.isModelSimStopped);
            end


            this.mIsSimulating=~strcmp(get_param(bdroot(this.mBlockDiagramHandle),'SimulationStatus'),'stopped');

            this.mSignalNameChangedListener=addlistener(cosObj,'SLGraphicalEvent::POST_SET_SIGNAL_NAME_EVENT',@(~,event)this.signalNameChanged(event));


            Simulink.scopes.SigScopeMgr.setgetSSM_Map(0,this.mBlockDiagramHandle,this);
        end

        function delete(~)

        end

        function deleteListenersAndMaps(this)
            SSMgrMap=Simulink.scopes.SigScopeMgr.setgetSSM_Map();
            SsmKey=Simulink.scopes.SigScopeMgr.handleToKey(this.mBlockDiagramHandle);
            if~isempty(SSMgrMap)&&SSMgrMap.isKey(SsmKey)
                SSMgrMap.remove(SsmKey);
                this.mModelSimStopListener=[];
                this.mIsSimulating=[];
                this.mDestroyModelEvent=[];
                this.mScopeVisualChanged=[];
                this.mSignalNameChangedListener=[];
            end


            ssmTagMap=Simulink.scopes.SigScopeMgr.setget_SSM_Tag();
            if~isempty(ssmTagMap)&&isvalid(this.mStudio)&&ssmTagMap.isKey(this.mStudio.getStudioTag())
                ssmTagMap.remove(this.mStudio.getStudioTag());
            end


            dlgToStudioMap=Simulink.scopes.SigScopeMgr.setget_SSM_DlgToStudio();
            if~isempty(dlgToStudioMap)
                dlgToStudioMap.remove(this.mDialogTagsCreated);
            end
        end


        dlgStruct=getDialogSchema(this,dlgName);

        function setSignalSpreadsheetChildren(this,selSignals)

            this.clearMarkedSignals();



            this.signalSpreadsheetData=selSignals;








































        end



        function clearMarkedSignals(this)

            if(~isempty(this.mMarkedBlockDiagramItems))
                studio=this.mStudio;


                sl_find('RemoveResultsMarkedStyle',this.mMarkedBlockDiagramItems,...
                studio.getStudioTag());
                this.mMarkedBlockDiagramItems=[];
            end
        end



        function clearHighlightedSignal(this)
            if(~isempty(this.mSelectedSignal))
                modelName=get_param(this.mBlockDiagramHandle,'name');
                studio=this.mStudio;
                highlightType='select';
                editor=studio.App.getActiveEditor();
                assert(~isempty(editor));

                oldHdl=this.updatePort(this.mSelectedSignal);
                sl_find('DeselectObjects',oldHdl,{modelName},...
                highlightType,editor,studio.getStudioTag());
            end
        end

        function selectedTab=getSelectedTab(this)
            selectedTab=this.mSelectedTab;
        end

        function setSelectedTab(this,tab)
            this.mSelectedTab=tab;
            this.refreshSignalSpreadsheet();
            this.refreshButtons();
        end

        function refreshSignalSpreadsheet(this)
            dlg=this.getDDGDialog();




            for i=1:numel(dlg)
                dlg(i).refreshWidget('ssMgrSignalSpreadsheet');
            end

        end

        function refreshViewerSpreadsheet(this)

            dlg=this.getDDGDialog();
            for i=1:numel(dlg)
                dlg(i).refreshWidget('ssMgrViewerSpreadsheet');
            end
        end

        function refreshSiggenSpreadsheet(this)

            dlg=this.getDDGDialog();
            for i=1:numel(dlg)
                dlg(i).refreshWidget('ssMgrGeneratorSpreadsheet');
            end
        end

        function sel=getSelectedViewerGenerator(this)

            sel=[];
            if(strcmpi(this.mSelectedTab,'viewers'))
                sel=this.mSelectedViewer;
            elseif(strcmpi(this.mSelectedTab,'generators'))
                sel=this.mSelectedGenerator;
            end
        end

        function refresh(this)
            ssm=this.getDDGDialog();



            for i=1:numel(ssm)
                ssm(i).refreshWidget('ssMgrViewerSpreadsheet');
                ssm(i).refreshWidget('ssMgrGeneratorSpreadsheet');
                ssm(i).refreshWidget('ssMgrSignalSpreadsheet');
                ssm(i).refresh();

                this.createVisualChangedEventListeners();
            end
        end

        function refreshButtons(this)
            ssm=this.getDDGDialog();
            selectedViewerGenerator=this.getSelectedViewerGenerator();











            if~isempty(selectedViewerGenerator)
                buttonsEnabled=true;
            else
                buttonsEnabled=false;
            end

            for i=1:numel(ssm)

                ssm(i).setEnabled('ssMgrParamsButton',buttonsEnabled);
                ssm(i).setEnabled('ssMgrPromoteButton',buttonsEnabled);


                if this.mIsSimulating
                    ssm(i).setEnabled('ssMgrDeleteButton',false);
                    ssm(i).setEnabled('ssMgrSelectButton',false);
                    ssm(i).setEnabled('ssMgrAddButton',false);
                else
                    ssm(i).setEnabled('ssMgrDeleteButton',buttonsEnabled);
                    ssm(i).setEnabled('ssMgrSelectButton',buttonsEnabled);
                end
            end
        end

        function tagName=getTagName(this)
            mdlName=get_param(this.mBlockDiagramHandle,'name');
            tagName=['SSMgr','_',mdlName,'_',this.mStudio.getStudioTag()];

        end
    end

    methods(Access=protected)
        function isModelSimulating(src,~)







            ssm=src.getDDGDialog();
            for i=1:numel(ssm)
                ssm(i).setEnabled('ssMgrAddButton',false);
                ssm(i).setEnabled('ssMgrDeleteButton',false);
                ssm(i).setEnabled('ssMgrSelectButton',false);



                ssm(i).setEnabled('ssMgrViewerSpreadsheet',false);
                ssm(i).setEnabled('ssMgrGeneratorSpreadsheet',false);
                ssm(i).setEnabled('ssMgrSignalSpreadsheet',false);

                src.mIsSimulating=true;
            end
        end

        function isModelSimStopped(src,~)






            ssm=src.getDDGDialog();
            for i=1:numel(ssm)
                ssm(i).setEnabled('ssMgrAddButton',true);


                ssm(i).setEnabled('ssMgrViewerSpreadsheet',true);
                ssm(i).setEnabled('ssMgrGeneratorSpreadsheet',true);
                ssm(i).setEnabled('ssMgrSignalSpreadsheet',true);

                src.mIsSimulating=false;
            end
        end

        function modelDestroyed(this,~)
            SSMgrMap=Simulink.scopes.SigScopeMgr.setgetSSM_Map();
            SsmKey=Simulink.scopes.SigScopeMgr.handleToKey(this.mBlockDiagramHandle);
            if SSMgrMap.isKey(SsmKey)
                this.deleteListenersAndMaps();
            end
        end

        function rightClickSignalHighlight(~,sels,dlgSrc)







            dlgSrc.clearHighlightedSignal();

            if length(sels)==1
                dlgSrc.mSelectedSignal=sels.mSelectionHandle;


                if(~isempty(dlgSrc.mSelectedSignal))
                    modelName=get_param(dlgSrc.mBlockDiagramHandle,'name');
                    studio=dlgSrc.mStudio;
                    highlightType='select';
                    editor=studio.App.getActiveEditor();
                    assert(~isempty(editor));
                    viewMode='fullView';

                    newHdl=dlgSrc.updatePort(dlgSrc.mSelectedSignal);


                    otherArguments=struct('editor',editor,...
                    'highlightType',highlightType,...
                    'viewMode',viewMode,...
                    'studioTag',studio.getStudioTag(),...
                    'modelName',modelName);

                    sl_find('SelectObjects',newHdl,otherArguments);
                end
            else
                dlgSrc.mSelectedSignal=[];
            end
        end

        function rightClickViewerSiggenHighlight(~,~,dlgSrc)




            dlgSrc.clearMarkedSignals();

            selSignals=dlgSrc.signalSpreadsheetData;
            if(~isempty(dlgSrc.signalSpreadsheetData))
                studio=dlgSrc.mStudio;

                handles=unique([selSignals.mSelectionHandle]);


                handles=arrayfun(@(x)dlgSrc.updatePort(x),handles);

                editor=studio.App.getActiveEditor();
                assert(~isempty(editor));
                highlightType='markObject';
                viewMode='fullView';
                studioTag=studio.getStudioTag();

                if(~isempty(handles))
                    otherArguments=struct('editor',editor,...
                    'highlightType',highlightType,...
                    'viewMode',viewMode,...
                    'studioTag',studioTag);

                    dlgSrc.mMarkedBlockDiagramItems=sl_find('SelectObjects',...
                    handles,otherArguments);
                end
            end
        end

        function signalNameChanged(src,event)










            spreadsheetSignals={src.signalSpreadsheetData.mSelectionHandle};


            if~isempty(spreadsheetSignals)&&any(find([spreadsheetSignals{:}]==event.PortHandle))
                ssm=src.getDDGDialog();
                for i=1:numel(ssm)
                    ssm(i).refreshWidget('ssMgrSignalSpreadsheet');
                end
            end
        end

        function createVisualChangedEventListeners(source)

            viewerList=[source.viewerSpreadsheetData.mSource];
            viewerList=viewerList(ishandle(viewerList));
            if~isempty(viewerList)
                scopeViewerIndex=arrayfun(@(list)strcmp('Scope',get_param(list,'BlockType')),viewerList);
                scopeViewers=viewerList(scopeViewerIndex);


                if~isempty(scopeViewers)
                    scopeSpecObjs=get_param(scopeViewers,'ScopeSpecificationObject');
                    if~isempty(scopeSpecObjs)
                        if~iscell(scopeSpecObjs)
                            scopeSpecObjs={scopeSpecObjs};
                        end




                        scopeSpecObjs=scopeSpecObjs(~cellfun('isempty',scopeSpecObjs));
                        if~all(cellfun('isempty',scopeSpecObjs))
                            hApp=cellfun(@(scopeSpecObj)scopeSpecObj.Block.UnifiedScope,scopeSpecObjs);
                            source.mScopeVisualChanged=addlistener(hApp,'VisualChanged',@(~,~)source.visualChangedCallback);
                        end
                    end
                end
            end
        end

        function visualChangedCallback(src,~)

            src.refreshViewerSpreadsheet();
            src.refreshSignalSpreadsheet();
        end
    end

    methods(Access=private)


        function hdlOut=updatePort(~,hdlIn)
            hdlOut=hdlIn;
            if~isempty(hdlOut)&&strcmpi(get_param(hdlOut,'type'),'port')


                if isempty(get_param(hdlOut,'line'))||get_param(hdlOut,'line')==-1
                    obj=get_param(hdlOut,'parent');
                    hdlOut=get_param(obj,'handle');
                end
            end
        end

        function dlg=getDDGDialog(this)
            dlg=DAStudio.ToolRoot.getOpenDialogs(this);
        end

        function checkForWebScopesAndUpdateVisual(this)
            try
                viewerCOSI=get_param(this.bindModeSourceDataObj.sourceElementHandle,'BlockCOSI');
                if~isempty(viewerCOSI)&&~isempty(viewerCOSI.ClientID)
                    this.bindModeSourceDataObj.setWebScopeClientID(viewerCOSI.ClientID);

                    if strcmp('Scope',get_param(this.mSelectedViewer,'BlockType'))||strcmp('WebTimeScopeBlock',get_param(this.mSelectedViewer,'BlockType'))
                        numberOfAxes.action=['getNumberOfAxes',viewerCOSI.ClientID];
                        numberOfAxes.params=[];
                        webscopeChannelName=['/webscope',viewerCOSI.ClientID];
                        message.publish(webscopeChannelName,numberOfAxes);
                    end
                end
            catch
            end
        end
    end

end