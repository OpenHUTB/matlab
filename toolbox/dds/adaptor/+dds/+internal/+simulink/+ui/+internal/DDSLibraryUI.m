classdef DDSLibraryUI<handle




    properties(Access=private)
        mDDFilepath;
        mDDSMdl;
        mWin;
        mMainListCmpt;
        mMainListObj;
        mDetailsCmpt;
        mDetailsObj;
        mProperties;
        UiListenerFunction;
    end

    properties(Constant)
        DETAILSPANE_WIDTH_RATIO=0.45;
    end


    methods(Static,Access=private)
        function objDDSUI=getUIObj(filepath)
            objDDSUI=[];
            if~isempty(filepath)&&exist(filepath,'file')
                objDDSUI=Simulink.dd.internal.DictionaryViewManager.instance.getView(filepath,'DDSLibrary');
                if isempty(objDDSUI)
                    objDDSUI=dds.internal.simulink.ui.internal.DDSLibraryUI(filepath);
                    Simulink.dd.internal.DictionaryViewManager.instance.setView(filepath,'DDSLibrary',objDDSUI);
                end
            end
        end
    end
    methods(Static,Access=public)

        function hasDDS=checkDDSPart(filespec)
            hasDDS=false;
            try

                hasDDS=Simulink.DDSDictionary.ModelRegistry.hasDDSPart(filespec)||...
                Simulink.DDSDictionary.ModelRegistry.isDDSPartDirty(filespec);
            catch
            end
        end

        function openUI(hNodeObj,ddConn)
            [val,msg]=dds.internal.isInstalledAndLicensed();
            if~val
                errordlg(msg,message('dds:ui:OpenUI_Button').getString);
                return;
            end
            uiOpen=false;
            ddConnObj=ddConn;
            if~any(strcmp(methods(class(ddConnObj)),'getSection'))
                ddConnObj=Simulink.data.dictionary.open(ddConn.filespec);
            end
            filespec=ddConnObj.filepath;

            if Simulink.DDSDictionary.ModelRegistry.hasDDSPart(filespec)||...
                Simulink.DDSDictionary.ModelRegistry.isDDSPartDirty(filespec)
                uiOpen=true;
            else
                title=message('dds:ui:DDSUIDlgTitle').getString;
                question=message('dds:ui:ImportQuestion').getString;
                btnImport=message('dds:ui:ImportBtn').getString;
                btnUseDefault=message('dds:ui:DefaultBtn').getString;
                btnCancel=message('Simulink:utility:CancelButton').string;
                answer=questdlg(question,title,btnImport,btnUseDefault,btnCancel,btnImport);
                result=false;
                if isequal(answer,btnImport)

                    result=dds.internal.simulink.ui.internal.DDSLibraryUI.uiImport(filespec);
                elseif isequal(answer,btnUseDefault)

                    dds.internal.simulink.Util.createFromDefaultDDSXml(filespec);
                    result=true;
                end

                if result
                    ed=DAStudio.EventDispatcher;

                    ed.broadcastEvent('PropertyChangedEvent',hNodeObj);

                    parent=hNodeObj.getParent;

                    ed.broadcastEvent('PropertyChangedEvent',parent);

                    uiOpen=true;
                end
            end

            if uiOpen

                dds.internal.simulink.ui.internal.DDSLibraryUI.open(filespec);
            end
        end

        function result=uiImport(filespec)
            result=false;
            [filename,pathname]=uigetfile(...
            {'*.xml',message('dds:ui:XMLFileDesc').getString},...
            message('dds:ui:ImportDlgTitle').getString,...
            'MultiSelect','on');
            if~isequal(filename,0)&&~isequal(pathname,0)

                if~iscell(filename)
                    filename=fullfile(pathname,filename);
                else
                    for i=1:numel(filename)
                        filename{i}=fullfile(pathname,filename{i});
                    end
                end
            else
                filename='';
            end
            if~isempty(filename)
                try
                    dds.internal.simulink.ui.internal.DDSLibraryUI.importXML(filespec,filename);
                    result=true;
                catch E
                    errordlg(E.message,message('dds:ui:ImportDlgTitle').getString);
                end
            end
        end

        function hWin=open(filepath)
            hWin=[];
            if~isempty(filepath)&&exist(filepath,'file')
                [val,msg]=dds.internal.isInstalledAndLicensed();
                if~val
                    errordlg(msg,message('dds:ui:OpenUI_Button').getString);
                    return;
                end
                if dds.internal.simulink.ui.internal.DDSLibraryUI.checkDDSPart(filepath)
                    objDDSUI=dds.internal.simulink.ui.internal.DDSLibraryUI.getUIObj(filepath);
                    hWin=objDDSUI.show(true);
                end
            end
        end

        function hWin=openSection(filepath,tabName)
            hWin=[];
            if~isempty(filepath)&&exist(filepath,'file')
                objDDSUI=dds.internal.simulink.ui.internal.DDSLibraryUI.getUIObj(filepath);
                objDDSUI.show(false);
                objDDSUI.setCurrentTabByName(tabName);
                hWin=objDDSUI.show(true);
            end
        end

        function closeUI(filepath)
            if~isempty(filepath)&&exist(filepath,'file')
                objDDSUI=Simulink.dd.internal.DictionaryViewManager.instance.getView(filepath,'DDSLibrary');
                if~isempty(objDDSUI)
                    objDDSUI.close();
                    Simulink.dd.internal.DictionaryViewManager.instance.removeView(filepath,'DDSLibrary');
                end
            end
        end

        function updateWin(filepath)
            if~isempty(filepath)&&exist(filepath,'file')
                objDDSUI=Simulink.dd.internal.DictionaryViewManager.instance.getView(filepath,'DDSLibrary');
                if~isempty(objDDSUI)
                    objDDSUI.updateWindow();
                end
            end
        end

        function importXML(ddFilepath,xmlFilepaths)
            if~exist(ddFilepath,'file')
                error(DAStudio.message('MATLAB:open:fileNotFound',ddFilepath));
                return;
            else
                if~iscell(xmlFilepaths)
                    if~exist(xmlFilepaths,'file')
                        error(DAStudio.message('MATLAB:open:fileNotFound',xmlFilepaths));
                        return;
                    end
                else
                    for i=1:numel(xmlFilepaths)
                        if~exist(xmlFilepaths{i},'file')
                            error(DAStudio.message('MATLAB:open:fileNotFound',xmlFilepaths{i}));
                            return;
                        end
                    end
                end
            end

            if dds.internal.simulink.ui.internal.DDSLibraryUI.checkDDSPart(ddFilepath)
                mf0Model=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(ddFilepath);
                clonedModel=dds.internal.simulink.Util.cloneModel(mf0Model);
                dds.internal.simulink.Util.importDDSXml(xmlFilepaths,ddFilepath,'',clonedModel);
            else
                dds.internal.simulink.Util.importDDSXml(xmlFilepaths,ddFilepath);
            end
        end

        function deleteSelection(ddsMdl,selection)
            txn=ddsMdl.beginTransaction;
            for i=1:numel(selection)
                objNode=selection{i}.getElement;
                objNode.destroy;
            end
            txn.commit;
        end

        function result=handleSelectionChange(compSrc,selection,thisObj)%#ok<INUSL> 
            result=thisObj.selectionChanged(selection);
        end

        function handleTabChanged(compSrc,id,thisObj)%#ok<INUSL> 
            thisObj.tabChanged(id);
        end

        function handleDDEvents(ddFileSpec,evtStr)
            if isequal(evtStr,'preClose')||isequal(evtStr,'postClose')
                dds.internal.simulink.ui.internal.DDSLibraryUI.closeUI(ddFileSpec);
            elseif isequal(evtStr,'postSave')
                dds.internal.simulink.ui.internal.DDSLibraryUI.updateWin(ddFileSpec);
            end
        end
    end

    methods(Access=public)

        function this=DDSLibraryUI(ddFilepath)
            this.mDDFilepath=ddFilepath;
            this.mDDSMdl=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(this.mDDFilepath);

            constructUI(this);
        end

        function hWin=show(thisObj,makeVisible)

            if isempty(thisObj.mWin)||~isvalid(thisObj.mMainListCmpt)
                thisObj.constructUI();
            end
            if makeVisible
                thisObj.mWin.show;
            end
            hWin=thisObj.mWin;
        end

        function close(thisObj)
            if~isvalid(thisObj.mMainListCmpt)||~isvalid(thisObj.mWin)
                thisObj.mWin.delete();
            else
                thisObj.mWin.close();
                thisObj.mWin.delete();
            end
        end

        function updateWindow(thisObj)
            confObj=studio.WindowConfiguration;
            confObj=thisObj.setWindowTitle(confObj);
            thisObj.mWin.updateConfiguration(confObj);
        end

        function doImport(thisObj)
            result=dds.internal.simulink.ui.internal.DDSLibraryUI.uiImport(thisObj.mDDFilepath);%#ok<NASGU> 
        end

        function doCreateLibrary(thisObj)
            thisObj.mMainListObj.createLibrary();
        end

        function doAddSection(thisObj)
            thisObj.mMainListObj.addSection();
        end

        function doAddObject(thisObj,type)
            thisObj.mMainListObj.addObject(type);
        end

        function doDuplicate(thisObj)
            thisObj.mMainListObj.duplicateSelection();
        end

        function doDelete(thisObj)
            thisObj.mMainListObj.deleteSelection();
        end

        function doHelp(thisObj)
            thisObj.mMainListObj.showHelp();
        end

    end

    methods(Access=private)

        function constructUI(thisObj)
            thisObj.mDDSMdl=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(thisObj.mDDFilepath);
            if~isempty(thisObj.mWin)&&isvalid(thisObj.mWin)
                thisObj.mWin.delete();
            end

            thisObj.changeListenerStatus(false);

            confObj=thisObj.initToolstrip();
            confObj=thisObj.setWindowTitle(confObj);
            thisObj.mWin=studio.Window(confObj);


            w=thisObj.mWin;
            contextObj=w.getContextObject;
            contextObj.setDDSLibraryUIObj(thisObj);

            thisObj.initMainList();

            thisObj.initDetailsPane();

            thisObj.mMainListCmpt.onSelectionChange=@(src,selection)dds.internal.simulink.ui.internal.DDSLibraryUI.handleSelectionChange(src,selection,thisObj);
            thisObj.mMainListCmpt.onTabChange=@(src,id)dds.internal.simulink.ui.internal.DDSLibraryUI.handleTabChanged(src,id,thisObj);

            thisObj.changeListenerStatus(true);

            Simulink.dd.private.AddDDMgrMATLABCallBackEventHandler('dds.internal.simulink.ui.internal.DDSLibraryUI.handleDDEvents');
        end

        function confObj=setWindowTitle(thisObj,confObj)
            title=message('dds:ui:DDSUIDlgTitle').getString;
            [~,name,ext]=fileparts(thisObj.mDDFilepath);
            shortName=[name,ext];
            ddConn=Simulink.data.dictionary.open(thisObj.mDDFilepath);
            if ddConn.HasUnsavedChanges
                dirtyflag='*';
            else
                dirtyflag='';
            end

            confObj.Title=[title,': ',shortName,dirtyflag];
            confObj.Icon=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','resources','DDSLib.png');
        end

        function changeListenerStatus(thisObj,enable)
            if enable
                thisObj.UiListenerFunction=@thisObj.refresh;
                thisObj.mDDSMdl.addObservingListener(thisObj.UiListenerFunction);
            elseif~isempty(thisObj.UiListenerFunction)
                thisObj.mDDSMdl.removeListener(thisObj.UiListenerFunction);
                thisObj.UiListenerFunction=function_handle.empty();
            end
        end

        function refresh(thisObj,changeReport)
            thisObj.changeListenerStatus(false);
            addlChangeReport=thisObj.dereferenceLinkedElements(changeReport);
            thisObj.mMainListObj.refresh(changeReport);
            if~isempty(addlChangeReport.Modified)||...
                ~isempty(addlChangeReport.Created)||...
                ~isempty(addlChangeReport.Destroyed)
                thisObj.mMainListObj.refresh(addlChangeReport);
            end
            thisObj.changeListenerStatus(true);
            thisObj.mDetailsObj.refresh(changeReport);
            if~isempty(addlChangeReport.Modified)||...
                ~isempty(addlChangeReport.Created)||...
                ~isempty(addlChangeReport.Destroyed)
                thisObj.mDetailsObj.refresh(addlChangeReport);
            end
            thisObj.updateWindow();
        end

        function initMainList(thisObj)
            thisObj.mMainListCmpt=GLUE2.SpreadSheetComponent('DDSMainList');

            thisObj.mMainListObj=dds.internal.simulink.ui.internal.DDSList(thisObj.mMainListCmpt,thisObj.mDDFilepath,thisObj.mDDSMdl);

            thisObj.mMainListCmpt.setSource(thisObj.mMainListObj);
            thisObj.mMainListCmpt.setTitleViewSource(thisObj.mMainListObj);
            thisObj.mWin.addComponent(thisObj.mMainListCmpt,'center');
        end

        function initPropertiesPane(thisObj)
            thisObj.mProperties=GLUE2.PropertyInspectorComponent('Inspector');


            thisObj.mWin.addComponent(thisObj.mProperties,'right');
        end

        function initDetailsPane(thisObj)
            thisObj.mDetailsCmpt=GLUE2.DDGComponent(message('dds:ui:DetailsPane').getString);
            thisObj.mWin.addComponent(thisObj.mDetailsCmpt,'right');
            thisObj.mDetailsCmpt.ShowMinimized=1;
            thisObj.mDetailsCmpt.minimize;
            useDetailActions=true;
            studio=thisObj.mDetailsCmpt.getStudio;
            curPos=studio.getStudioPosition;
            width=curPos(3)*thisObj.DETAILSPANE_WIDTH_RATIO;
            height=curPos(4);
            thisObj.mDetailsCmpt.setPreferredSize(width,height);
            thisObj.mDetailsObj=dds.internal.simulink.ui.internal.DDSDetailsDDG(thisObj.mDetailsCmpt,thisObj.mMainListCmpt,useDetailActions);
            thisObj.mDetailsCmpt.updateSource(thisObj.mDetailsObj);
        end

        function confObj=initToolstrip(thisObj)%#ok<MANU> 

            confObj=studio.WindowConfiguration;
            confObj.ToolstripConfigurationName='ddsLibrary';
            confObj.ToolstripConfigurationPath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin');
            confObj.ToolstripName='ddsLibraryToolstrip';
            tsPath=fullfile(matlabroot,'toolbox','dds','adaptor','+dds','+internal','+simulink','+ui','+internal','ddsLibraryPlugin');


            addpath(tsPath);


            confObj.ToolstripContext='dds.internal.simulink.ui.internal.ddslibCustomContext';

        end

        function setCurrentTabByName(thisObj,tabName)
            thisObj.mMainListObj.setCurrentTabByName(tabName);
        end

        function result=selectionChanged(thisObj,selection)
            result=true;
            thisObj.mMainListObj.setSelected(selection);
            thisObj.mDetailsObj.setSelected(selection);

            contextObj=thisObj.mWin.getContextObject;
            if~isempty(selection)
                contextObj.setSelected(selection);
            else
                contextObj.setTypeChain(thisObj.mMainListObj.getTabTypeChain())
            end
        end

        function tabChanged(thisObj,id)
            thisObj.mMainListObj.tabChanged(id);
            thisObj.mDetailsObj.tabChanged(id);

            contextObj=thisObj.mWin.getContextObject;
            contextObj.setTypeChain(thisObj.mMainListObj.getTabTypeChain())
        end

        function addlChangeReport=dereferenceLinkedElements(~,changeReport)




            addlChangeReport.Created=[];
            addlChangeReport.Modified=[];
            addlChangeReport.Destroyed=[];
            for i=1:numel(changeReport.Modified)
                if isa(changeReport.Modified(i).Element,'dds.datamodel.domain.RegisterType')
                    try
                        for j=1:changeReport.Modified(i).Element.TopicRefs.Size()
                            addlChange=struct('Element',changeReport.Modified(i).Element.TopicRefs(j),'ModifiedProperties','','ModifiedExtensions','');
                            addlChangeReport.Modified=[addlChangeReport.Modified,addlChange];
                        end
                    catch
                    end
                end
            end
        end

    end


end
