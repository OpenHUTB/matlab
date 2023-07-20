function dlgstruct=getDialogSchema(h,name)%#ok






    [installed,licenseAvailable]=rmi.isInstalled();

    if(~isempty(h.reqItems)&&h.reqIdx<=0)
        h.reqIdx=1;
    end

    if(~isempty(h.dialogUD)&&~isempty(h.reqItems)&&h.dialogUD.activeReq>0)
        h.reqIdx=h.dialogUD.activeReq;
        h.dialogUD.activeReq=0;
    end

    if(isempty(h.typeItems))
        initTypes(h);
    end

    bNew.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:New'));
    bNew.Type='pushbutton';
    bNew.Tag='bNew';
    bNew.Mode=true;
    bNew.ObjectMethod='doNewItem';
    bNew.MethodArgs={'%dialog'};
    bNew.ArgDataTypes={'handle'};
    bNew.Enabled=installed&&licenseAvailable;


    surr_item=false;
    if~installed||~licenseAvailable
        editable=false;
    elseif isempty(h.reqItems)
        editable=false;
    elseif h.reqIdx<=0&&h.reqIdx>length(h.reqItems)
        editable=false;
    else
        this_link=h.reqItem(h.reqIdx);
        if strcmp(this_link.reqsys,'doors')||~this_link.linked
            editable=false;
            surr_item=true;
        else
            editable=true;
        end
    end

    bCopy.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:Copy'));
    bCopy.Tag='bCopy';
    bCopy.Type='pushbutton';
    bCopy.ObjectMethod='doCopyItem';
    bCopy.MethodArgs={'%dialog'};
    bCopy.ArgDataTypes={'handle'};
    bCopy.Enabled=editable;

    bDelete.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:Delete'));
    bDelete.Tag='bDelete';
    bDelete.Type='pushbutton';
    bDelete.ObjectMethod='doDeleteItem';
    bDelete.MethodArgs={'%dialog'};
    bDelete.ArgDataTypes={'handle'};
    if surr_item
        protectSurrogateLinks=rmi.settings_mgr('get','protectSurrogateLinks');
        if~isempty(protectSurrogateLinks)&&protectSurrogateLinks
            bDelete.Enabled=false;
        end
    else
        bDelete.Enabled=editable;
    end

    bUp.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:Up'));
    bUp.Tag='bUp';
    bUp.Type='pushbutton';
    bUp.ObjectMethod='doUpItem';
    bUp.MethodArgs={'%dialog'};
    bUp.ArgDataTypes={'handle'};
    bUp.Enabled=editable&&h.reqIdx>1;

    bDown.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:Down'));
    bDown.Tag='bDown';
    bDown.Type='pushbutton';
    bDown.ObjectMethod='doDownItem';
    bDown.MethodArgs={'%dialog'};
    bDown.ArgDataTypes={'handle'};
    bDown.Enabled=editable&&h.reqIdx<length(h.reqItems);

    actionsGroup.Type='panel';
    actionsGroup.Items={bNew,bUp,bDown,bDelete,bCopy};
    actionsGroup.LayoutGrid=[5,1];
    actionsGroup.ColSpan=[1,1];
    actionsGroup.RowSpan=[1,1];

    reqsListbox.Type='listbox';
    reqsListbox.Tag='lb';
    reqsListbox.Entries={};
    reqsListbox.ToolTip=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:SelectRequirementTo'));
    if~isempty(h.reqItems)
        if h.reqIdx>length(h.reqItems)||h.reqIdx<=0
            h.reqIdx=1;
        end
        for i=1:length(h.reqItems)
            if isempty(strtrim(h.reqItems(i).description))
                h.reqItems(i).description=getString(message('Slvnv:reqmgt:NoDescriptionEntered'));
            end
            reqsListbox.Entries{end+1}=h.reqItems(i).description;
        end
        if h.reqIdx>0
            reqsListbox.Value=h.reqIdx-1;
        end
    end
    reqsListbox.RowSpan=[1,1];
    reqsListbox.ColSpan=[2,4];
    reqsListbox.ObjectMethod='doSelItem';
    reqsListbox.Graphical=true;
    reqsListbox.MethodArgs={'%dialog'};
    reqsListbox.ArgDataTypes={'handle'};
    reqsListbox.Mode=true;
    reqsListbox.MultiSelect=false;

    descLabel.Name=[getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:Description')),': '];
    descLabel.Type='text';
    descLabel.RowSpan=[2,2];
    descLabel.ColSpan=[1,1];
    descEdit.Tag='descEdit';
    descEdit.Type='edit';
    descEdit.ToolTip=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:LabelUsedIn'));
    if isempty(h.reqItems)
        descEdit.Value='';
        descEdit.Enabled=false;
    else
        reqInfo=h.reqItems(h.reqIdx);
        descEdit.Value=reqInfo.description;
        if slreq.data.Link.isDefaultDisplayLabel(reqInfo.description)







            targetSummary=getLinkedTargetSummary(reqInfo.reqsys,reqInfo.doc,reqInfo.id);
            if~isempty(targetSummary)
                descEdit.ToolTip=targetSummary;
            end
        end
    end
    descEdit.PlaceholderText=getString(message('Slvnv:reqmgt:NoDescriptionEntered'));
    descEdit.Mode=true;
    descEdit.RowSpan=[2,2];
    descEdit.ColSpan=[2,4];
    descEdit.ObjectMethod='changeDescItem';
    descEdit.MethodArgs={'%dialog'};
    descEdit.ArgDataTypes={'handle'};
    descEdit.Enabled=editable;

    docLabel.Name=[getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:Document')),': '];
    docLabel.Type='text';
    docLabel.RowSpan=[4,4];
    docLabel.ColSpan=[1,1];

    docEdit.Type='combobox';
    docEdit.Tag='docEdit';
    docEdit.Editable=true;
    docEdit.RowSpan=[4,4];
    docEdit.ColSpan=[2,3];
    docEdit.Mode=true;
    docEdit.ToolTip=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:RequirementDocument'));
    docEdit.Entries={};
    h.docHistory={};
    docEdit.ObjectMethod='changeDocItem';
    docEdit.MethodArgs={'%dialog'};
    docEdit.ArgDataTypes={'handle'};
    docEdit.Enabled=editable;

    if editable
        history=rmi.history('get');
    else
        history={};
    end
    docTypes=rmi.linktype_mgr('all');

    if~isempty(h.reqItems)&&~isempty(history)

        docTypeItem=[];
        if(h.typeItems(h.reqIdx)>0)
            docTypeItem=docTypes(h.typeItems(h.reqIdx));
        end
        for i=1:length(history(:,1))
            if isempty(docTypeItem)
                docEdit.Entries{end+1}=history{i,1};
                h.docHistory=[h.docHistory;history(i,:)];
            else
                if strcmp(history{i,2},'other')
                    [~,~,fileExt]=fileparts(history{i,1});
                    reqTarget=rmi.linktype_mgr('resolve','other',fileExt);
                else
                    reqTarget=rmi.linktype_mgr('resolveByRegName',history{i,2});
                end
                if isempty(reqTarget)||docTypeItem==reqTarget
                    docEdit.Entries{end+1}=history{i,1};
                    h.docHistory=[h.docHistory;history(i,:)];
                end
            end
        end
    end

    docEdit.Value='';
    if(isempty(h.reqItems))
        docEdit.Enabled=false;
    elseif(length(h.reqItems)==1)
        h.reqIdx=1;
        docEdit.Value=h.reqItems.doc;
    elseif h.reqIdx>0&&h.reqIdx<=length(h.reqItems)
        docEdit.Value=h.reqItems(h.reqIdx).doc;
    else
        h.reqIdx=1;
        docEdit.Value=h.reqItems(h.reqIdx).doc;
    end

    typeLabel.Name=[getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:DocumentType')),': '];
    typeLabel.Type='text';
    typeLabel.RowSpan=[3,3];
    typeLabel.ColSpan=[1,1];
    typeEdit.Type='combobox';
    typeEdit.Tag='typeEdit';
    typeEdit.Mode=true;
    typeEdit.ObjectMethod='typeSel';
    typeEdit.MethodArgs={'%dialog'};
    typeEdit.ArgDataTypes={'handle'};

    typeEdit.Entries={getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:UnspecifiedType'))};
    for i=1:length(docTypes)
        typeEdit.Entries{end+1}=docTypes(i).Label;
    end
    typeEdit.RowSpan=[3,3];
    typeEdit.ColSpan=[2,3];
    typeEdit.Value=0;
    if~isempty(h.reqItems)&&~isempty(h.typeItems)&&h.reqIdx>0
        typeEdit.Value=h.typeItems(h.reqIdx);
    end
    typeEdit.Enabled=editable;

    bBrowser.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:Browse'));
    bBrowser.Type='pushbutton';
    bBrowser.Tag='bBrowser';
    bBrowser.RowSpan=[4,4];
    bBrowser.ColSpan=[4,4];
    bBrowser.MatlabMethod='feval';
    bBrowser.MatlabArgs={@doOpen,'%source','%dialog'};
    bBrowser.Enabled=editable;

    docTypeItem=[];
    if isempty(h.reqItems)
        bBrowser.Enabled=false;
    else
        if h.typeItems(h.reqIdx)>0
            docTypeItem=docTypes(h.typeItems(h.reqIdx));

            if isempty(docTypeItem.Extensions)&&isempty(docTypeItem.BrowseFcn)
                bBrowser.Enabled=false;
            end
        end
    end

    bSelection.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:UseCurrent'));
    bSelection.ToolTip=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:FillFieldsUsingCurrent'));
    bSelection.Type='pushbutton';
    bSelection.Tag='autoFill';
    bSelection.RowSpan=[3,3];
    bSelection.ColSpan=[4,4];
    bSelection.MatlabMethod='feval';
    bSelection.MatlabArgs={@autoFillCallback,'%source','%dialog'};
    bSelection.Enabled=editable&&~isempty(docTypeItem)&&~isempty(docTypeItem.SelectionLinkLabel);

    locLabel.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:LocationTypeIdentifier'));
    locLabel.Type='text';
    locLabel.RowSpan=[5,5];
    locLabel.ColSpan=[1,1];

    locBookMark.Type='combobox';
    locBookMark.Tag='locBookMark';
    locBookMark.RowSpan=[5,5];
    locBookMark.ColSpan=[2,2];
    locBookMark.Entries={};
    locBookMark.Value=0;
    locBookMark.ToolTip=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:LocationTypeIndicates'));
    locBookMark.Mode=true;
    locBookMark.ObjectMethod='doLocChange';
    locBookMark.MethodArgs={'%dialog'};
    locBookMark.ArgDataTypes={'handle'};
    locBookMark.Tag='locBookMark';
    locBookMark.Enabled=editable;

    locEdit.Type='edit';
    locEdit.Tag='locEdit';
    locEdit.RowSpan=[5,5];
    locEdit.ColSpan=[3,4];
    locEdit.Mode=true;
    locEdit.ObjectMethod='doLocChange';
    locEdit.MethodArgs={'%dialog'};
    locEdit.ArgDataTypes={'handle'};
    locEdit.Enabled=editable;

    locEdit.Value='';


    if h.reqIdx==0||isempty(h.typeItems)||h.typeItems(h.reqIdx)==0
        locEdit.Enabled=false;
        locBookMark.Enabled=false;
        [~,~,locBookMark.Entries]=getBookMarkEntries(h);
        h.locItems=locBookMark.Entries;
    elseif~isempty(h.reqItems)
        [locEdit.Value,locBookMark.Value,locBookMark.Entries]=getBookMarkEntries(h);
        h.locItems=locBookMark.Entries;
    end
    if isempty(locBookMark.Entries)
        locBookMark.Enabled=false;
        locEdit.Enabled=false;
    elseif numel(locBookMark.Entries)==1
        locBookMark.Enabled=false;
        locEdit.Enabled=~isempty(docEdit.Value);
    end

    tagLabel.Name=[getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:UserTag')),': '];
    tagLabel.Type='text';
    tagLabel.RowSpan=[6,6];
    tagLabel.ColSpan=[1,1];

    tagEdit.Type='combobox';
    tagEdit.Tag='tagEdit';
    tagEdit.ToolTip=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:CommaSeparatedTags'));
    tagEdit.Editable=true;
    tagEdit.RowSpan=[6,6];
    tagEdit.ColSpan=[2,4];
    tagEdit.Mode=true;
    tagEdit.Enabled=editable;
    if(isempty(h.reqItems))
        tagEdit.Value='';
        tagEdit.Enabled=false;
    elseif length(h.reqItems)==1
        h.reqIdx=1;
        tagEdit.Value=h.reqItems.keywords;
    else
        if h.reqIdx<1||h.reqIdx>length(h.reqItems)
            h.reqIdx=1;
        end
        tagEdit.Value=h.reqItems(h.reqIdx).keywords;
    end
    h.tagHistory={};
    tagEdit.Entries={};
    if editable
        history=rmi.history('tags');
    else
        history={};
    end
    if~isempty(history)
        tagEdit.Entries=history;
        h.tagHistory=history;
    end
    tagEdit.MatlabMethod='feval';
    tagEdit.MatlabArgs={@tagChanged,'%source','%dialog'};

    propGroup.Type='group';
    propGroup.Tag='propGroup';
    propGroup.LayoutGrid=[6,4];
    propGroup.Items={actionsGroup,reqsListbox,...
    descLabel,descEdit,...
    typeLabel,typeEdit,bSelection,...
    docLabel,docEdit,bBrowser,...
    locBookMark,locLabel,locEdit,...
    tagLabel,tagEdit};



    contentLabel.Type='text';
    contentLabel.ColSpan=[1,1];
    contentLabel.RowSpan=[1,1];

    contentRefresh.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:Refresh'));
    contentRefresh.Type='pushbutton';
    contentRefresh.Tag='bRefresh';
    contentRefresh.ColSpan=[2,2];
    contentRefresh.RowSpan=[1,1];
    contentRefresh.MatlabMethod='feval';
    contentRefresh.MatlabArgs={@doRefreshContents,'%source','%dialog'};


    contentLabel.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:NoDocSpecified'));
    contentLabel.Enabled=false;

    if~isempty(h.reqItems)
        reqDoc=strtrim(h.reqItems(h.reqIdx).doc);
        if~isempty(reqDoc)&&~isempty(docTypeItem)
            if isempty(docTypeItem.ContentsFcn)
                contentLabel.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:NoIndexFunctionFor',docTypeItem.Label));
            elseif~h.reqItems(h.reqIdx).linked
                contentLabel.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:NoIndexForSurrogate'));
            else
                if docTypeItem.IsFile
                    reqDoc=rmi.locateFile(reqDoc,h.objectH);
                end
                if~isempty(reqDoc)
                    if docTypeItem.IsFile
                        [~,fName,fExt]=fileparts(reqDoc);
                        dispDocName=[fName,fExt];
                    else


                        if length(reqDoc)>50
                            dispDocName=['...',reqDoc(end-40:end)];
                        else
                            dispDocName=reqDoc;
                        end
                    end
                    contentLabel.Enabled=editable;
                    contentLabel.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:ContentOfFile',dispDocName));
                end
            end
        end
    end

    contentListbox.MultiSelect=false;
    contentListbox.Type='listbox';
    contentListbox.ToolTip=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:DoubleClickToUpdate'));
    contentListbox.Entries={};
    contentListbox.Tag='contentlb';
    if(~isempty(h.docContents))
        contentListbox.Entries=h.docContents{1}';
    end
    contentListbox.RowSpan=[2,2];
    contentListbox.ColSpan=[1,2];
    contentListbox.ListDoubleClickCallback=@doubleClicks;
    contentListbox.MatlabMethod='feval';
    contentListbox.MatlabArgs={@contentListboxClick,'%source','%dialog'};

    contentGroup.Type='group';
    contentGroup.Tag='contentGroup';
    contentGroup.LayoutGrid=[2,2];
    contentGroup.Items={contentLabel,contentRefresh,contentListbox};


    tab1.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:Requirements'));
    tab1.Tag='tab1';
    tab1.Items={propGroup};

    tab2.Name=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:DocumentIndex'));
    tab2.Tag='tab2';
    tab2.Items={contentGroup};
    tab2.Enabled=contentLabel.Enabled;


    tabs.Name='tabs';
    tabs.Tag='tabBar';
    tabs.Type='tab';
    tabs.LayoutGrid=[2,2];
    tabs.Tabs={tab1,tab2};
    tabs.TabChangedCallback='ReqMgr.rmidlg_switchtabs';
    tabs.ActiveTab=h.switchTab;


    dlgstruct.DialogTitle=h.title;
    dlgstruct.LayoutGrid=[1,1];
    dlgstruct.Items={tabs};
    dlgstruct.SmartApply=true;
    dlgstruct.PreApplyCallback='ReqMgr.rmidlg_preapply';
    dlgstruct.PreApplyArgs={h,'%dialog'};
    dlgstruct.PostApplyCallback='ReqMgr.rmidlg_apply';
    dlgstruct.PostApplyArgs={h,'%dialog'};
    dlgstruct.CloseCallback='ReqMgr.rmidlg_close';
    dlgstruct.CloseArgs={h,'%dialog'};
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/slrequirements/helptargets.map'],'requirements_dialog'};
    dlgstruct.DialogTag='rmiDlg';


    if~installed||~licenseAvailable
        dlgstruct.StandaloneButtonSet={'Cancel','Help'};
    end
end

function targetSummary=getLinkedTargetSummary(domain,doc,id)
    targetSummary='';
    if~strcmp(domain,'linktype_rmi_slreq')
        return;
    end
    if isempty(id)
        targetSummary=doc;
    else
        adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(domain);
        if~isempty(adapter)
            if id(1)=='@'


                id(1)=[];
            end
            targetSummary=adapter.getSummary(doc,id);
        end
    end
end

function tagChanged(dlgSrc,dialogH)

    cacheChange(dlgSrc,dialogH);

    tag=dialogH.getWidgetValue('tagEdit');
    if~isempty(strtrim(tag))
        rmi.history('tag',tag);
    end
end

function doRefreshContents(h,dialogH)
    h.updateContents(dialogH,true);
end

function doOpen(h,dialogH)

    docTypes=rmi.linktype_mgr('all');
    docLinkType=[];
    pathName='';


    if h.typeItems(h.reqIdx)>0
        docLinkType=docTypes(h.typeItems(h.reqIdx));

        if docLinkType.IsFile&&...
            (rmi.linktype_mgr('is_builtin',docLinkType)||isempty(docLinkType.BrowseFcn))

            cat_extensions=[docLinkType.Extensions{:}];
            docExt=regexprep(cat_extensions,'\.',';\*\.');
            docExt=docExt(2:end);

            [fileName,pathName]=uigetfile(...
            {docExt,[docLinkType.Label,' (',docExt,')'];...
            '*.*','All Files (*.*)'},...
            getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:SelectRequirementsDocument')));

            if isempty(fileName)||~ischar(fileName)
                return
            end


        elseif~isempty(docLinkType.BrowseFcn)


            ReqMgr.activeDlgUtil(dialogH);

            try
                fileName=feval(docLinkType.BrowseFcn);
                ReqMgr.activeDlgUtil('clear');
            catch my_exception
                errTitle=[getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),': BrowseFcn()'];
                errMessage=getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:ErrorWhileBrowse',docLinkType.Label,'BrowseFcn()',my_exception.message));
                errordlg(errMessage,errTitle);
                ReqMgr.activeDlgUtil('clear');
                return
            end
            if isempty(fileName)||~ischar(fileName)
                if~any(strcmp(docLinkType.Registration,{'linktype_rmi_simulink','linktype_rmi_matlab','linktype_rmi_data'}))
                    errordlg(getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:BrowseReturnNoString',docLinkType.Label)));
                end
                return
            end

        else
            msgbox(getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:BrowseNotDefined',docLinkType.Label)));
            return
        end

    else
        [fileName,pathName]=uigetfile({'*.*',...
        'All Files (*.*)'},...
        getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:SelectRequirementsDocument')));

        if isempty(fileName)||~ischar(fileName)
            return
        end


        [~,~,fileExt]=fileparts(fileName);
        reqTarget=rmi.linktype_mgr('resolve','other',fileExt);
        for i=1:length(docTypes)
            if docTypes(i)==reqTarget
                h.typeItems(h.reqIdx)=i;
                docLinkType=docTypes(i);

                break;
            end
        end
    end


    if isempty(docLinkType)
        errordlg(getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:FailedToFigureOutLinktype')));
        return;
    end


    if~docLinkType.IsFile
        h.reqItems(h.reqIdx).reqsys=docLinkType.Registration;


        if strcmp(docLinkType.Registration,'linktype_rmi_simulink')

            [~,docName]=fileparts(fileName);

        elseif strcmp(docLinkType.Registration,'linktype_rmi_matlab')||...
            strcmp(docLinkType.Registration,'linktype_rmi_data')

            fullFileName=fullfile(pathName,fileName);
            referencePath=rmiut.srcToPath(h.objectH);
            docName=rmi.userPreferredDocPath(fullFileName,referencePath);
        else
            docName=fileName;
        end

    elseif~isempty(pathName)&&ischar(pathName)
        fullFileName=fullfile(pathName,fileName);



        referencePath=rmiut.srcToPath(h.objectH);
        docName=rmi.userPreferredDocPath(fullFileName,referencePath);
    else
        errordlg(getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:FailedToFigureOutFilename',fileName)));
        return
    end


    if~strcmp(h.reqItems(h.reqIdx).doc,docName)
        rmi.history('add',docName,docLinkType.Registration);
        h.reqItems(h.reqIdx).doc=docName;
        h.reqItems(h.reqIdx).id='';
        dialogH.setWidgetValue('docEdit',docName);
        changeDocItem(h,dialogH);
    end
end

function initTypes(h)
    if(h.reqIdx==0)
        h.reqIdx=1;
    end
    for i=1:length(h.reqItems)
        h.typeItems(i)=getTypeIdx(h,h.reqItems(i));
    end
end

function contentListboxClick(h,dialogH)
    value=dialogH.getWidgetValue('contentlb');
    selected=value+1;
    selectedLabel=h.docContents{1}{selected};



    if strncmp(selectedLabel,'DOORS item ',length('DOORS item '))


        for count=1:25
            previous=selected-count;
            if previous==0
                break;
            end
            prevLabel=h.docContents{1}{previous};
            if strncmp(prevLabel,'DOORS item ',length('DOORS item '))
                h.docContents{1}{previous}=updateDoorsLabel(prevLabel);
            else
                break;
            end
        end
        for count=1:25
            next=selected+count;
            if next>length(h.docContents{1})
                break;
            end
            nextLabel=h.docContents{1}{next};
            if strncmp(nextLabel,'DOORS item ',length('DOORS item '))
                h.docContents{1}{next}=updateDoorsLabel(nextLabel);
            else
                break;
            end
        end

        h.docContents{1}{selected}=updateDoorsLabel(selectedLabel);

        dialogH.refresh();
    end
end

function updatedLabel=updateDoorsLabel(currentLabel)
    tokens=regexp(currentLabel,'DOORS item (\S+)#(\d+) ','tokens');
    if~isempty(tokens)
        module=tokens{1}{1};
        id=tokens{1}{2};
        try
            updatedLabel=rmidoors.customLabel(module,id);
            if isempty(updatedLabel)

                updatedLabel=rmidoors.getObjAttribute(module,id,'labelText');
            end
        catch Mex
            warning(message('Slvnv:reqmgt:LinkSet:getDialogSchema:updateDoorsLabel',id,module,Mex.message));
            updatedLabel=[getString(message('Slvnv:reqmgt:LinkSet:getDialogSchema:Unresolved')),' ',currentLabel];
        end
    else
        tokens=regexp(currentLabel,'DOORS item (\d+) ...','tokens');
        if~isempty(tokens)
            id=tokens{1}{1};
            updatedLabel=oslc.Requirement.updateDetails(id);
            if isempty(updatedLabel)
                updatedLabel=currentLabel;
            end
        else
            updatedLabel=strrep(currentLabel,'...','(title not known)');
        end
    end
end

function doubleClicks(dlgH,~,~)
    h=dlgH.getDialogSource();
    h.selectContent(dlgH);
end


function autoFillCallback(h,dialogH)

    allTypes=rmi.linktype_mgr('all');
    linkType=allTypes(h.typeItems(h.reqIdx));
    if isempty(linkType.SelectionLinkFcn)
        return;
    end

    if license_checkout_slvnv()
        make2way=rmi.settings_mgr('get','linkSettings','twoWayLink');
        if ischar(h.objectH)



            switch h.source
            case 'matlab'
                source=h.objectH;

                [artifactId,rangeInfo]=strtok(source,'|');
                [~,locationId]=rmiml.ensureBookmark(artifactId,rangeInfo(2:end));
                source=[artifactId,'|',locationId];
            case{'data','testmgr','fault','safetymanager'}
                source=h.objectH;
            otherwise
                error('Object %s does not support linking.',h.objectH);
            end
        else

            source=rmi.canlink(h.objectH);
            if isempty(source)
                return
            end
        end
        if any(strcmp(linkType.Registration,{'linktype_rmi_simulink','linktype_rmi_oslc'}))


            req=feval(linkType.SelectionLinkFcn,source,make2way,false);
            if isempty(req)


                ReqMgr.activeDlgUtil(dialogH);
            end
        else
            req=feval(linkType.SelectionLinkFcn,source,make2way);
        end
        if~isempty(req)
            if length(req)>1

                errordlg(...
                getString(message('Slvnv:reqmgt:linktype_rmi_simulink:SelectionLinkTooManyObjects')),...
                getString(message('Slvnv:reqmgt:linktype_rmi_simulink:RequirementsUseCurrent')));
                return;
            end

            h.reqItems(h.reqIdx).doc=req.doc;
            h.reqItems(h.reqIdx).id=req.id;
            h.reqItems(h.reqIdx).linked=req.linked;
            h.reqItems(h.reqIdx).description=req.description;
            h.reqItems(h.reqIdx).keywords=req.keywords;


            dialogH.enableApplyButton(true);
            dialogH.refresh();
            if ispc
                reqmgt('winFocus',h.title);
            end
        end
    end
end

function success=license_checkout_slvnv()
    invalid=builtin('_license_checkout','Simulink_Requirements','quiet');
    success=~invalid;
    if invalid
        rmi.licenseErrorDlg();
    end
end


