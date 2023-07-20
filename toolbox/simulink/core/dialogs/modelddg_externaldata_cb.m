function[status,message]=modelddg_externaldata_cb(dialogH,action,varargin)



    status=true;
    message='';

    hBD=varargin{1};
    editTag=varargin{2};
    listTag=varargin{3};

    switch action
    case 'doSetEnableBWS'
        value=varargin{4};
        resetEnableBWS(dialogH,hBD,editTag,listTag,value)
    case 'doSelectDD'
        selectSource(dialogH,hBD,editTag,listTag);
    case 'doNewDD'
        newSource(dialogH,hBD,editTag,listTag);
    case 'doRemoveDD'
        removeSource(dialogH,hBD,editTag,listTag);
    case 'doSelectExtSource'
        migrateTag=varargin{4};
        removeTag=varargin{5};
        updateDialog(dialogH,hBD,editTag,listTag,migrateTag,removeTag);
    otherwise

    end
end


function resetEnableBWS(dialogH,hBD,editTag,listTag,value)
    dialogH.clearWidgetDirtyFlag('EnableBWSAccess');
    if~isempty(hBD.DataDictionary)
        [~,~]=modelddg_data_cb(dialogH,'preapply',hBD,'migrateBtn');
    else
        externalSources=hBD.ExternalSources;
        if numel(externalSources)>0
            if value
                set_param(hBD.name,'EnableAccessToBaseWorkspace','on');
            else
                set_param(hBD.name,'EnableAccessToBaseWorkspace','off');
            end
        else

            error('Cannot remove access to the base workspace');
        end
    end
end


function selectSource(dialogH,hBD,editTag,listTag)
    exts={'*.sldd;*.mat;*.m','All supported files';};
    exts(2,:)={'*.sldd','Data Dictionary files (*.sldd)'};
    exts(3,:)={'*.m','M files (*.m)'};
    exts(4,:)={'*.mat','MAT files (*.mat)'};

    browser=DictionaryReferenceBrowser('open',exts);
    browser.browse(dialogH,editTag,false);
    filename=dialogH.getWidgetValue(editTag);
    dialogH.setWidgetValue(editTag,'');

    if~isempty(filename)
        try
            Simulink.data.externalsources.addSource(hBD.Name,filename);
            dialogH.clearWidgetDirtyFlag(editTag);
            dialogH.refresh;
        catch ex
            error(ex.message);
        end
    end

end


function newSource(dialogH,hBD,editTag,listTag)
    exts={'*.sldd;*.mat;*.m','All supported files';};
    exts(2,:)={'*.sldd','Data Dictionary files (*.sldd)'};
    exts(3,:)={'*.m','M files (*.m)'};
    exts(4,:)={'*.mat','MAT files (*.mat)'};

    browser=DictionaryReferenceBrowser('create',exts);
    browser.browse(dialogH,editTag,false);
    filename=dialogH.getWidgetValue(editTag);
    dialogH.setWidgetValue(editTag,'');
    dialogH.clearWidgetDirtyFlag(editTag);

    if~isempty(filename)
        Simulink.data.externalsources.addSource(hBD.Name,filename);
        dialogH.refresh;
    end
end



function removeSource(dialogH,hBD,editTag,listTag)
    selected=dialogH.getWidgetValue(listTag);
    values=dialogH.getUserData(listTag);

    for iter=1:numel(selected)
        Simulink.data.externalsources.removeSource(hBD.Name,values{selected(iter)+1});
    end
    dialogH.refresh;
end


function updateDialog(dialogH,hBD,editTag,listTag,migrateTag,removeTag)
    selected=dialogH.getWidgetValue(listTag);
    if numel(selected)==0
        dialogH.setEnabled(migrateTag,false);
        dialogH.setEnabled(removeTag,false);
    else
        dialogH.setEnabled(removeTag,true);
        if numel(selected)==1
            values=dialogH.getUserData(listTag);
            [~,~,ext]=fileparts(values{selected+1});
            if strcmpi(ext,'.sldd')
                dialogH.setEnabled(migrateTag,true);
            else
                dialogH.setEnabled(migrateTag,false);
            end
        else
            dialogH.setEnabled(migrateTag,false);
        end
    end

    dialogH.clearWidgetDirtyFlag(listTag);
end




