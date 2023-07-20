function[status,message]=modelddg_cb(dialogH,action,varargin)




    try
        status=true;
        message='';

        switch action
        case 'doAdd'
            addMethod(dialogH);

        case 'doDelete'
            deleteMethod(dialogH);

        case 'doMoveUp'
            moveUpMethod(dialogH);

        case 'doMoveDown'
            moveDownMethod(dialogH);

        case 'doGetGcb'
            getGcb(dialogH);

        case 'doReadOnly'
            readOnly(varargin{1},varargin{2});

        case 'doPreApply'
            if slfeature('SLDataDictionaryMigrateUI')>0
                [status,message]=preApply(dialogH,'link');
            else
                [status,message]=preApply(dialogH,'auto');
            end

        case 'doPostApply'


            if isempty(dialogH.getUserData('DataDictionary'))
                refreshdlg(dialogH);
            end

        case 'doSelectDataSource'
            selectDataSourceMethod(dialogH);

        case 'doSelectDD'
            tag=varargin{1};
            selectDDMethod(dialogH,tag);

        case 'doNewDD'
            tag=varargin{1};
            newDDMethod(dialogH,tag);

        case 'doOpenDD'
            tag=varargin{1};
            openDDMethod(dialogH,tag);

        case 'doChangeDDName'
            changeDDName(dialogH);

        case 'doSelectCallbackFcn'
            tag=varargin{1};
            selectCallbackFcn(dialogH,tag);

        case 'doSetEM'
            value=varargin{1};
            setEM(dialogH,value);

        case 'doSetEnableBWS'
            value=varargin{1};
            changeBWSAccess(dialogH,value);

        case 'DataMigrationBtn'
            if~isempty(dialogH.getWidgetValue('DataDictionary'))
                bdH=varargin{1};
                [status,message]=modelddg_data_cb(dialogH,'preapply',bdH,'migrateBtn');
            end

        case 'extSourcesOpen'
            bdH=varargin{1};
            listTag=varargin{2};
            openExtSource(dialogH,bdH,listTag);

        case 'extSourcesRemove'
            bdH=varargin{1};
            listTag=varargin{2};
            removeExtSource(dialogH,bdH,listTag);

        case 'extSourcesList'
            bdH=varargin{1};
            listExtSource(dialogH,bdH,action);

        case 'extSourcesBrowse'
            bdH=varargin{1};
            listTag=varargin{2};
            editTag=varargin{3};
            browseExtSource(dialogH,bdH,listTag,editTag);

        case 'extSourcesNew'
            bdH=varargin{1};
            listTag=varargin{2};
            editTag=varargin{3};
            newExtSource(dialogH,bdH,listTag,editTag);

        end
    catch E


        throwAsCaller(E);
    end


    function[status,errMsg]=preApply(dialogH,ddFunction)
        status=true;
        errMsg='';
        bdH=dialogH.getSource;
        lock=get_param(bdH.name,'Lock');
        str=get_param(bdH.name,'forwardingtablestring');
        ForwardingTableUserData=dialogH.getUserData('ForwardingTable');
        if(strcmp(lock,'off')==1)

            if(~isempty(ForwardingTableUserData)&&~isempty(ForwardingTableUserData.m_Children))||...
                (~isempty(str))
                [errOccured,errMsg]=setForwardingTable(bdH,ForwardingTableUserData.m_Children);
                status=~errOccured;
            end
        end

        [data_status,data_errMsg]=modelddg_data_cb(dialogH,'preapply',bdH,ddFunction);

        status=status&&data_status;
        if isempty(errMsg)
            errMsg=data_errMsg;
        end

    end


    function readOnly(h,readOnly)

        if readOnly
            h.EditVersionInfo='ViewCurrentValues';
        else
            h.EditVersionInfo='EditFormatStrings';
        end

    end


    function setEM(dialogH,isEM)
        bdH=dialogH.getSource;
        mdl=bdH.name;
        if isEM
            set_param(mdl,'IndependentSystem','on');
        else
            set_param(mdl,'IndependentSystem','off');
        end

    end


    function addMethod(dialogH)
        fwTable=dialogH.getUserData('ForwardingTable');


        if isempty(fwTable.m_Children)
            dialogH.setEnabled('MoveUpButton',false);
        else
            dialogH.setEnabled('MoveUpButton',true);
        end


        fwTable.addChild({DAStudio.message('Simulink:dialog:ForwardingTableDefOldBlockPath'),...
        DAStudio.message('Simulink:dialog:ForwardingTableDefnewBlockPath'),...
        DAStudio.message('Simulink:dialog:ForwardingTableDefBlockVer'),...
        DAStudio.message('Simulink:dialog:ForwardingTableDefBlockVer'),...
        DAStudio.message('Simulink:dialog:ForwardingTableDefTransformation')});


        dialogH.setUserData('ForwardingTable',fwTable);
        dialogH.refresh;
        dialogH.enableApplyButton(true);
    end


    function deleteMethod(dialogH)


        fwTable=dialogH.getUserData('ForwardingTable');
        fwTable.deleteChild();
        dialogH.setUserData('ForwardingTable',fwTable);

        if isempty(fwTable.m_Children)


            tabidx=dialogH.getActiveTab('Tabcont');
            source=dialogH.getSource;
            dialogH.setSource(source);
            dialogH.setActiveTab('Tabcont',tabidx);
            dialogH.setEnabled('DeleteButton',false);
            dialogH.setEnabled('MoveUpButton',false);
            dialogH.setEnabled('MoveDownButton',false);
            dialogH.setEnabled('GetGcb',false);
        else
            dialogH.refresh;
        end
        dialogH.enableApplyButton(true);
    end


    function moveUpMethod(dialogH)


        fwTable=dialogH.getUserData('ForwardingTable');
        fwTable.moveChildUp();
        tableSize=length(fwTable.m_Children);
        dialogH.setUserData('ForwardingTable',fwTable);
        dialogH.refresh;
        dialogH.enableApplyButton(true);


        if fwTable.m_SelectedRowIndex>1&&fwTable.m_SelectedRowIndex<tableSize
            dialogH.setEnabled('MoveUpButton',true);
            dialogH.setEnabled('MoveDownButton',true);
            dialogH.setEnabled('DeleteButton',true);
        elseif fwTable.m_SelectedRowIndex==1&&fwTable.m_SelectedRowIndex==tableSize
            dialogH.setEnabled('MoveUpButton',false);
            dialogH.setEnabled('MoveDownButton',false);
            dialogH.setEnabled('DeleteButton',true);
        elseif fwTable.m_SelectedRowIndex==1
            dialogH.setEnabled('MoveUpButton',false);
            dialogH.setEnabled('MoveDownButton',true);
            dialogH.setEnabled('DeleteButton',true);
        elseif fwTable.m_SelectedRowIndex==tableSize
            dialogH.setEnabled('MoveUpButton',true);
            dialogH.setEnabled('MoveDownButton',false);
            dialogH.setEnabled('DeleteButton',true);
        else
            dialogH.setEnabled('MoveUpButton',false);
            dialogH.setEnabled('MoveDownButton',false);
            dialogH.setEnabled('DeleteButton',false);
        end


        if fwTable.isPathProperty(fwTable.m_SelectedPropertyInRowIndex)
            dialogH.setEnabled('GetGcb',true);
        else
            dialogH.setEnabled('GetGcb',false);
        end
    end


    function moveDownMethod(dialogH)


        fwTable=dialogH.getUserData('ForwardingTable');
        fwTable.moveChildDown();
        tableSize=length(fwTable.m_Children);
        dialogH.setUserData('ForwardingTable',fwTable);
        dialogH.refresh;
        dialogH.enableApplyButton(true);


        if fwTable.m_SelectedRowIndex>1&&fwTable.m_SelectedRowIndex<tableSize
            dialogH.setEnabled('MoveUpButton',true);
            dialogH.setEnabled('MoveDownButton',true);
            dialogH.setEnabled('DeleteButton',true);
        elseif fwTable.m_SelectedRowIndex==1&&fwTable.m_SelectedRowIndex==tableSize
            dialogH.setEnabled('MoveUpButton',false);
            dialogH.setEnabled('MoveDownButton',false);
            dialogH.setEnabled('DeleteButton',true);
        elseif fwTable.m_SelectedRowIndex==1
            dialogH.setEnabled('MoveUpButton',false);
            dialogH.setEnabled('MoveDownButton',true);
            dialogH.setEnabled('DeleteButton',true);
        elseif fwTable.m_SelectedRowIndex==tableSize
            dialogH.setEnabled('MoveUpButton',true);
            dialogH.setEnabled('MoveDownButton',false);
            dialogH.setEnabled('DeleteButton',true);
        else
            dialogH.setEnabled('MoveUpButton',false);
            dialogH.setEnabled('MoveDownButton',false);
            dialogH.setEnabled('DeleteButton',false);
        end


        if fwTable.isPathProperty(fwTable.m_SelectedPropertyInRowIndex)
            dialogH.setEnabled('GetGcb',true);
        else
            dialogH.setEnabled('GetGcb',false);
        end
    end


    function getGcb(dialogH)

        blockPath=evalin('base','gcb');
        fwTable=dialogH.getUserData('ForwardingTable');


        if~fwTable.isPathProperty(fwTable.m_SelectedPropertyInRowIndex)
            return;
        end


        blockPath=strrep(blockPath,newline,' ');
        fwTable.updateChildProperty(fwTable.m_SelectedPropertyInRowIndex,blockPath);

        child=fwTable.m_Children(fwTable.m_SelectedRowIndex);
        if(strcmp(child.m_OldBlockPath,child.m_NewBlockPath)==false)

            fwTable.updateChildProperty(ForwardingTableSpreadsheet.sOldBlockVersionColumn,...
            DAStudio.message('Simulink:dialog:ForwardingTableDefBlockVer'));
            fwTable.updateChildProperty(ForwardingTableSpreadsheet.sNewBlockVersionColumn,...
            DAStudio.message('Simulink:dialog:ForwardingTableDefBlockVer'));
        else




            version=get_param(dialogH.getSource.name,'ModelVersion');
            fwTable.updateChildProperty(ForwardingTableSpreadsheet.sNewBlockVersionColumn,version);

            if fwTable.isValidMapEntry(blockPath)

                fwTable.updateChildProperty(fwTable.sOldBlockVersionColumn,fwTable.m_MapData(blockPath));
            else

                fwTable.updateChildProperty(fwTable.sOldBlockVersionColumn,'0.0');
            end


            fwTable.setMapValue(blockPath,version);
        end


        dialogH.setUserData('ForwardingTable',fwTable);
        dialogH.refresh;
        dialogH.enableApplyButton(true);
    end


    function[errOccured,errMsg]=setForwardingTable(bdH,TableData)
        errMsg='';errOccured=false;
        forwardingTableData=cell(1,length(TableData));

        for i=1:length(TableData)
            singleTableEntry={TableData(i).m_OldBlockPath,...
            TableData(i).m_OldBlockVersion,...
            TableData(i).m_NewBlockPath,...
            TableData(i).m_NewBlockVersion,...
            TableData(i).m_TransformationFcn};


            if~isempty(singleTableEntry{1,2})
                singleTableEntry{1,2}=strtrim(singleTableEntry{1,2});
            end
            if~isempty(singleTableEntry{1,4})
                singleTableEntry{1,4}=strtrim(singleTableEntry{1,4});
            end
            if~isempty(singleTableEntry{1,5})
                singleTableEntry{1,5}=strtrim(singleTableEntry{1,5});
            end



            singleTableEntry{1,1}=fliplr(deblank(fliplr(singleTableEntry{1,1})));
            singleTableEntry{1,3}=fliplr(deblank(fliplr(singleTableEntry{1,3})));

            if(strcmpi((singleTableEntry{1,1}),'<Enter old block path>')||...
                strcmpi((singleTableEntry{1,1}),'n/a'))
                singleTableEntry{1,1}=[];
            end

            if(strcmpi((singleTableEntry{1,3}),'<Enter new block path>')||...
                strcmpi((singleTableEntry{1,3}),'n/a'))
                singleTableEntry{1,3}=[];
            end

            if(strcmpi((singleTableEntry{1,5}),'<Enter Transformation name>')||...
                strcmpi((singleTableEntry{1,5}),'n/a')||strcmpi((singleTableEntry{1,5}),'No Transformation'))
                singleTableEntry{1,5}=[];
            end


            if((strcmpi((singleTableEntry{1,2}),'n/a')||strcmp((singleTableEntry{1,2}),''))&&...
                (strcmpi((singleTableEntry{1,4}),'n/a')||strcmp((singleTableEntry{1,4}),'')))

                if(isempty(singleTableEntry{1,5}))


                    temp=cell(1,2);
                    temp(1,1)=singleTableEntry(1,1);
                    temp(1,2)=singleTableEntry(1,3);
                    forwardingTableData{1,i}=temp;
                else


                    temp=cell(1,3);
                    temp(1,1)=singleTableEntry(1,1);
                    temp(1,2)=singleTableEntry(1,3);
                    temp(1,3)=singleTableEntry(1,5);
                    forwardingTableData{1,i}=temp;
                end
            else


                temp=cell(1,5);
                temp(1,1)=singleTableEntry(1,1);
                temp(1,2)=singleTableEntry(1,3);
                temp(1,3)=singleTableEntry(1,2);
                temp(1,4)=singleTableEntry(1,4);
                if(isempty(singleTableEntry{1,5}))
                    temp(1,5)={''};
                else
                    temp(1,5)=singleTableEntry(1,5);
                end
                forwardingTableData{1,i}=temp;
            end

        end

        try
            set_param(bdH.name,'ForwardingTable',forwardingTableData);
        catch ex
            errOccured=true;
            errMsg=ex.message;
            for i=1:length(ex.cause)
                errMsg=[errMsg,'. ',ex.cause{i}.message];%#ok
            end
        end
    end


end


function selectDataSourceMethod(dialogH)
    if slfeature('SLModelAllowedBaseWorkspaceAccess')<2
        selectorState=dialogH.getWidgetValue('DataSourceSelect');
        switch selectorState
        case 0
            ddControlsEnabled=false;
        case 1
            ddControlsEnabled=true;
        end

        dialogH.setEnabled('DataDictLabel',ddControlsEnabled);
        dialogH.setEnabled('DataDictionary',ddControlsEnabled);
        dialogH.setEnabled('SelectDD',ddControlsEnabled);
        dialogH.setEnabled('NewDD',ddControlsEnabled);
        enableDDOpenButton(dialogH,ddControlsEnabled);
    end
end


function selectDDMethod(dialogH,tag)
    browser=DictionaryReferenceBrowser('open',{'.sldd'});
    isSlimDialog=false;
    browser.browse(dialogH,tag,isSlimDialog);
    changeDDName(dialogH);
end


function newDDMethod(dialogH,tag)
    browser=DictionaryReferenceBrowser('create',{'.sldd'});
    try
        isSlimDialog=false;
        browser.browse(dialogH,tag,isSlimDialog);
    catch e
        errordlg(e.message,DAStudio.message('SLDD:sldd:CreateNewDataDictionary'));
    end
    changeDDName(dialogH);
end


function openDDMethod(dialogH,tag)
    ddName=dialogH.getWidgetValue(tag);

    dd=Simulink.data.dictionary.open(ddName);
    show(dd);
end


function changeDDName(dialogH)
    enableDDOpenButton(dialogH,true);
    accessToBWS=true;
    if slfeature('SLModelAllowedBaseWorkspaceAccess')>1
        if dialogH.isWidgetValid('EnableBWSAccess')

            accessToBWS=dialogH.getWidgetValue('EnableBWSAccess');
            setInheritedBWSWarning(dialogH,accessToBWS);
        elseif dialogH.isWidgetValid('EnableAccessToBaseWorkspace')

            accessToBWS=dialogH.getWidgetValue('EnableAccessToBaseWorkspace');
            setInheritedBWSWarning(dialogH,accessToBWS);
        end
    end
    enableMigrateDataBtn(dialogH,accessToBWS);
end


function changeBWSAccess(dialogH,enableBWS)
    if slfeature('SLModelAllowedBaseWorkspaceAccess')>1
        setInheritedBWSWarning(dialogH,enableBWS);
        enableMigrateDataBtn(dialogH,enableBWS);
    end
end


function setInheritedBWSWarning(dialogH,accessToBWSFromMdl)

    accessToBWSFromDD=checkBWSAccessFromDD(dialogH,accessToBWSFromMdl);
    dialogH.setVisible('inheritedBWSAccess',accessToBWSFromDD);
end


function accessToBWSFromDD=checkBWSAccessFromDD(dialogH,accessToBWSFromMdl)

    if~accessToBWSFromMdl


        ddName=dialogH.getWidgetValue('DataDictionary');
        ddName=strtrim(ddName);
        [~,~,ext]=fileparts(ddName);
        if isempty(ext)
            ddName=[ddName,'.sldd'];
        end
        try
            ddTmp=Simulink.dd.open(ddName);
            accessToBWSFromDD=ddTmp.HasAccessToBaseWorkspace;
            ddTmp.close
        catch e %#ok<NASGU>

            accessToBWSFromDD=false;


        end
    else
        accessToBWSFromDD=false;
    end
end


function selectCallbackFcn(dialogH,tag)
    dialogH.setWidgetValue(tag,[]);
end


function enableDDOpenButton(dialogH,ddControlsEnabled)
    ddName=dialogH.getWidgetValue('DataDictionary');
    enabled=ddControlsEnabled&&~isempty(ddName);

    dialogH.setEnabled('OpenDD',enabled);
end


function enableMigrateDataBtn(dialogH,accessToBWS)
    ddName=dialogH.getWidgetValue('DataDictionary');
    enabled=~isempty(ddName);
    visible=(slfeature('SLDataDictionaryMigrateUI')>0);
    if slfeature('SLModelAllowedBaseWorkspaceAccess')>1
        ddUsesBWS=checkBWSAccessFromDD(dialogH,accessToBWS);
        if(ddUsesBWS||accessToBWS)
            visible=true;
        else
            visible=false;
        end
        enabled=~isempty(ddName);
    end

    if slfeature('SLDataDictionaryMigrateUI')>0
        dialogH.setVisible('DataMigrationBtn',visible);
        dialogH.setEnabled('DataMigrationBtn',enabled);
    end
end



function openExtSource(dialogH,bdH,listTag)
    selected=dialogH.getWidgetValue(listTag);
    if isempty(selected)
        selected=0;
    else
        selected=selected+1;
    end

    sources=get_param(bdH.name,'ExternalSources');
    if(selected>0)&&(selected<=length(sources))
        open(sources{selected});
    end
end


function removeExtSource(dialogH,bdH,listTag)
    selected=dialogH.getWidgetValue(listTag);
    values=dialogH.getUserData(listTag);

    for iter=1:numel(selected)
        Simulink.data.externalsources.removeSource(bdH.Name,values{selected(iter)+1});
    end
    dialogH.refresh;
end


function addExtSource(dialogH,bdH,listTag,editTag)

    filename=dialogH.getWidgetValue(editTag);
    if~isempty(filename)
        addNewExtSource(dialogH,bdH,listTag,editTag,filename);
    end

end

function browseExtSource(dialogH,bdH,~,editTag)
    exts={'*.mat;*.m','All supported files';};
    exts(2,:)={'*.m','M files (*.m)'};
    exts(3,:)={'*.mat','MAT files (*.mat)'};

    browser=DictionaryReferenceBrowser('open',exts);
    browser.browse(dialogH,editTag,false);
    filename=dialogH.getWidgetValue(editTag);
    dialogH.setWidgetValue(editTag,'');
    dialogH.clearWidgetDirtyFlag(editTag);

    if~isempty(filename)
        try
            Simulink.data.externalsources.addSource(bdH.Name,filename);
            dialogH.refresh;
        catch ex
            error(ex.message);
        end
    end
end

function newExtSource(dialogH,bdH,~,editTag)
    isSlimDialog=false;
    exts={'*.mat;*.m','All supported files';};
    exts(2,:)={'*.m','M files (*.m)'};
    exts(3,:)={'*.mat','MAT files (*.mat)'};

    browser=DictionaryReferenceBrowser('create',exts);
    browser.browse(dialogH,editTag,isSlimDialog);
    filename=dialogH.getWidgetValue(editTag);

    dialogH.setWidgetValue(editTag,'');
    dialogH.clearWidgetDirtyFlag(editTag);

    if~isempty(filename)
        Simulink.data.externalsources.addSource(bdH.Name,filename);
        dialogH.refresh;
    end
end


function addNewExtSource(dialogH,bdH,listTag,editTag,filename)
    [~,name,extension]=fileparts(filename);
    if isempty(extension)
        filename=[name,'.sldd'];
        dialogH.setWidgetValue(editTag,filename);
    elseif~isequal(extension,'.sldd')
        dialogH.setWidgetWithError(editTag);
        return;
    end

    if isempty(which(filename))
        dialogH.setWidgetWithError(editTag);
        return;
    end

    sources=get_param(bdH.name,'ExternalSources');

    if isequal(length(sources),1)&&isempty(sources{1})
        sources={filename};
    else
        sources{end+1}=filename;
    end
    set_param(bdH.name,'ExternalSources',sources);

    dialogH.setWidgetValue(listTag,sources);
    dialogH.setWidgetValue(editTag,'');
    dialogH.clearWidgetDirtyFlag(editTag);
    dialogH.refresh;
end


function listExtSource(dialogH,~,listTag)
    dialogH.clearWidgetDirtyFlag(listTag);





    removeTag='extSourcesRemove';
    openTag='extSourcesOpen';

    selected=dialogH.getWidgetValue(listTag);
    if numel(selected)==0
        dialogH.setEnabled(removeTag,false);
        dialogH.setEnabled(openTag,false);
    else
        dialogH.setEnabled(removeTag,true);
        if numel(selected)==1
            dialogH.setEnabled(openTag,true);
        else
            dialogH.setEnabled(openTag,false);
        end
    end
end





