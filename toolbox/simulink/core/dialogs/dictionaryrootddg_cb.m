function dictionaryrootddg_cb(hDialog,btnName,dictionaryFullPath)






    warnState=warning('backtrace','off');
    warnCleanup=onCleanup(@()warning(warnState));

    switch btnName
    case 'AddBtn'
        i_AddBtn(hDialog);
    case 'RemoveBtn'
        i_RemoveBtn(hDialog);
    case 'OpenBtn'
        i_OpenBtn(hDialog);
    case 'DictRefTree'
        i_TreeWidget(hDialog);
    case 'variantSaveBtn'
        i_VariantBtn(hDialog,btnName);
    case 'variantCancelBtn'
        i_VariantBtn(hDialog,btnName);
    case 'NewVariantBtn'
        i_NewVariantBtn(hDialog);
    case 'BrowseBtn'
        i_BrowseBtn(hDialog);
    case 'ValueSourceBrowseBtn'
        i_ValueSourceFileBrowser(hDialog);
    case 'valueSourceName'
        ddConn=hDialog.getDialogSource.getConnection();
        filename=hDialog.getWidgetValue('valueSourceName');
        ddConn.ValueSource=filename;
    case 'DepViewBtn'
        i_ViewBtn(dictionaryFullPath);
    case 'AccessBaseWorkspace'

        hDialog.clearWidgetDirtyFlag('AccessBaseWorkspace');
    end

end

function i_AddBtn(dialogH)



    rootNode=dialogH.getDialogSource;
    thisDict=rootNode.getFileSpec;
    [path,~,~]=fileparts(thisDict);
    ddConn=rootNode.getConnection();

    selectedDict=i_GetSelectedFile(dialogH);
    if(~isempty(selectedDict)&&~isequal(selectedDict,path)&&~isequal(selectedDict,thisDict))

        if sl.data.adapter.AdapterManager.hasAdapterForSource(selectedDict)&&(slfeature('SLDDBroker')>0)
            Simulink.internal.slid.DictionaryInterface.addReference(...
            thisDict,which(selectedDict));
            dialogH.refresh();
        end
        [~,~,currentExt]=fileparts(selectedDict);

        if~sl.data.adapter.AdapterManager.hasAdapterForSource(selectedDict)...
            ||strcmp(currentExt,'.sldd')
            ddConn.addReference(selectedDict);
        end
    end
    i_TreeWidget(dialogH);
end

function i_RemoveBtn(dialogH)
    rootNode=dialogH.getDialogSource;
    ddConn=rootNode.getConnection();
    treeData=dialogH.getUserData('DictRefTree');
    if isa(treeData,'containers.Map')
        selectedNodes=dialogH.getWidgetValue('DictRefTree');
        for i=1:length(selectedNodes)
            value=treeData(selectedNodes{i});
            if value{2}
                [~,refFileName,fileExt]=fileparts(value{1});
                if slfeature('SLDDBroker')>0
                    Simulink.internal.slid.DictionaryInterface.removeReference(...
                    rootNode.getFileSpec,value{1});
                    dialogH.refresh();
                else
                    ddConn.removeReference([refFileName,fileExt]);
                end


            end
        end
    end
    i_TreeWidget(dialogH);

end

function i_OpenBtn(dialogH)
    treeData=dialogH.getUserData('DictRefTree');
    if isa(treeData,'containers.Map')
        selectedNodes=dialogH.getWidgetValue('DictRefTree');
        for i=1:length(selectedNodes)
            value=treeData(selectedNodes{i});
            open(value{1});
        end
    end
    dialogH.setWidgetValue('DictRefTree',{});
end

function i_TreeWidget(dialogH)

    selectedNodes={};
    onlyTop=false;
    allowOpen=true;

    treeData=dialogH.getUserData('DictRefTree');
    if isa(treeData,'containers.Map')
        selectedNodes=dialogH.getWidgetValue('DictRefTree');
        onlyTop=true;
        for i=1:length(selectedNodes)
            value=treeData(selectedNodes{i});
            onlyTop=onlyTop&&value{2};
            if allowOpen
                [refpath,~,ext]=fileparts(value{1});
                if isempty(refpath)
                    allowOpen=false;
                else
                    if strcmp(ext,'.sldd')
                        foundfile=Simulink.dd.whichSldd(value{1});
                    else
                        foundfile=which(value{1});
                    end
                    if isempty(foundfile)
                        allowOpen=false;
                    end
                end
            end
        end
    end

    if allowOpen&&isempty(selectedNodes)
        allowOpen=false;
    end
    dialogH.setEnabled('AddBtn',true);
    dialogH.setEnabled('RemoveBtn',onlyTop&&~isempty(selectedNodes));
    dialogH.setEnabled('OpenBtn',allowOpen);

    enableBrowseBtn=(~allowOpen)&&(numel(selectedNodes))==1;
    dialogH.setEnabled('BrowseBtn',enableBrowseBtn);
    dialogH.setVisible('BrowseBtn',enableBrowseBtn);
    dialogH.setVisible('OpenBtn',~enableBrowseBtn);

end

function i_VariantBtn(dialogH,btnName)
    rootNode=dialogH.getDialogSource;

    switch btnName
    case 'variantSaveBtn'
        rootNode.setPropValue('Variant',dialogH.getWidgetValue('variantEdit'));
        dialogH.clearWidgetDirtyFlag('variantEdit');
    case 'variantCancelBtn'
        dialogH.setWidgetValue('variantEdit',rootNode.getPropValue('Variant'));
        dialogH.clearWidgetDirtyFlag('variantEdit');
    end

end

function i_NewVariantBtn(dialogH,~)
    rootNode=dialogH.getDialogSource;
    slprivate('createVariantDict',rootNode.getConnection());
end


function i_BrowseBtn(dialogH)

    selectedNodes={};
    treeData=dialogH.getUserData('DictRefTree');
    if isa(treeData,'containers.Map')
        selectedNodes=dialogH.getWidgetValue('DictRefTree');
    end

    assert(numel(selectedNodes)==1);
    value=treeData(selectedNodes{1});
    filespec=value{1};


    try
        selectedFile=i_GetSelectedFile(dialogH,filespec);
    catch
        selectedFile='';
    end


    if isempty(selectedFile)
        return;
    end



    if~strcmp(filespec,selectedFile)&&isa(treeData,'containers.Map')

        treeNodes=string(selectedNodes{1}).split('/');
        fileNode=treeNodes(end);


        treeStrs=keys(treeData);
        for n=1:length(treeStrs)
            treeStr=string(treeStrs{n});
            treeNodes=treeStr.split('/');
            leafNode=treeNodes(end);

            if~isequal(leafNode,fileNode)
                continue;
            end



            if length(treeNodes)==1

                rootNode=dialogH.getDialogSource;
                ddConn=rootNode.getConnection();
            else
                parentTreeStr=treeNodes(1:end-1).join('/');
                value=treeData(parentTreeStr.char());
                ddConn=Simulink.dd.open(value{1},'SubdictionaryErrorAction','warn');
            end


            if any(strcmp(ddConn.Dependencies,filespec))
                ddConn.removeReference(filespec);
                ddConn.addReference(selectedFile);
            end
        end
    end


    dialogH.refresh();
    i_TreeWidget(dialogH);
end


function i_ValueSourceFileBrowser(hDialog)
    rootNode=hDialog.getDialogSource;
    ddConn=rootNode.getConnection();

    MATfiles=DAStudio.message('MATLAB:uistring:uiopen:MATfiles');
    [filename,pathname]=uigetfile({'*.mat',MATfiles},DAStudio.message('Simulink:tools:MASelectMatFile'));

    if ischar(filename)&&~isempty(filename)&&ischar(pathname)

        [~,~,ext]=fileparts(filename);
        if strcmp(ext,'.mat')==0
            DAStudio.error('Simulink:dialog:WorkspaceCannotImportFromNonMATMATLABFile',filename);
        end


        ddConn.ValueSource=filename;
        hDialog.setWidgetValue('valueSourceName',filename);
    end
end


function i_ViewBtn(dictionaryFullPath)


    dependencies.internal.view(dictionaryFullPath);
end


function selectedDict=i_GetSelectedFile(dialogH,varargin)
    rootNode=dialogH.getDialogSource;
    thisDict=rootNode.getFileSpec;
    [path,~,~]=fileparts(thisDict);
    dialogH.setWidgetValue('DictNewRefName',path);

    ddConn=rootNode.getConnection();

    if(slfeature('SLDDBroker')>0)
        ext=ddConn.getBroker.getSupportedExtensions();
    elseif slfeature('CalibrationWorkflowInDD')>0&&...
        strcmp(dialogH.getWidgetValue('CurrSelectedTab'),'1')
        ext={'.mat'};
    else
        ext={'.sldd'};
    end

    browser=DictionaryReferenceBrowser('open',ext,varargin{:});
    browser.browse(dialogH,'DictNewRefName',false);

    selectedDict=dialogH.getWidgetValue('DictNewRefName');
    dialogH.setWidgetValue('DictNewRefName','');
end


