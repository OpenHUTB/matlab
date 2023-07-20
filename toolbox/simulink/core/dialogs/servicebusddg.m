function dlgstruct=servicebusddg(h,name,isSlidStructureType)

    rowIdx=0;



    mlock;






    rowIdx=rowIdx+1;

    if isSlidStructureType
        h=getBusStructForSlidStructureType(h);
    end

    editorbtn.Name=DAStudio.message('Simulink:dialog:BusEditorbtnName');
    editorbtn.Type='pushbutton';
    editorbtn.MatlabMethod='buseditor';


    cachedDataSource=slprivate('slUpdateDataTypeListSource','get');

    if~isempty(cachedDataSource)
        if any(strcmp(methods(class(cachedDataSource)),'hasSLDDAPISupport'))
            useBusEditor=true;
            if any(strcmp(methods(class(cachedDataSource)),'useBusEditor'))
                useBusEditor=cachedDataSource.useBusEditor;
            end
            assert(~useBusEditor);
        else
            assert(isa(cachedDataSource,'Simulink.dd.Connection'),...
            'New value should be a Simulink.dd.Connection object.');
            assert(cachedDataSource.isOpen);
            editorbtn.MatlabArgs={'Create',name,Simulink.data.DataDictionary(cachedDataSource.filespec)};
        end
    else
        editorbtn.MatlabArgs={'Create',name};
    end

    editorbtn.RowSpan=[rowIdx,rowIdx];
    editorbtn.ColSpan=[1,1];
    editorbtn.Tag='Editorbtn';
    editorbtn.UserData=name;

    editorbtn.Enabled=true;
    editorbtn.Enabled=false;

    rowIdx=rowIdx+1;

    numElems=numel(h.Elements);
    busobjectSpreadsheet.Type='spreadsheet';
    busobjectSpreadsheet.RowSpan=[1,numElems];

    busobjectSpreadsheet.Source=BusObjectSpreadsheet(h,cachedDataSource,name,isSlidStructureType);
    busobjectSpreadsheet.Tag='BusObjectSpreadsheet';

    busobjectSpreadsheet.Columns={DAStudio.message('Simulink:busEditor:PropElementName')};
    busobjectSpreadsheet.ColHeader={DAStudio.message('Simulink:busEditor:PropElementName')};
    busobjectSpreadsheet.Enabled=true;

    busobjectSpreadsheet.Config=jsonencode(struct('enablesort',false,...
    'enablegrouping',false));
    busobjectSpreadsheet.LoadingCompleteCallback=@(tag,dlg)BusObjectSpreadsheetCBHandler.onLoadingCompleteCB(tag,dlg);
    busobjectSpreadsheet.Visible=true;

    elementsgrp.Name=DAStudio.message('Simulink:dialog:FunctionElementsgrpName');
    elementsgrp.RowSpan=[rowIdx,rowIdx];
    elementsgrp.ColSpan=[1,3];
    elementsgrp.Type='group';
    elementsgrp.Flat=1;
    elementsgrp.Items={busobjectSpreadsheet};
    elementsgrp.Tag='BusElementsGrp';

    rowIdx=rowIdx+1;
    description.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
    description.Type='editarea';
    description.RowSpan=[rowIdx,rowIdx];
    description.ColSpan=[1,3];
    description.Tag='description_tag';
    description.Value=h.Description;
    description.MatlabMethod='busddg_cb';
    description.MatlabArgs={'editDescription','%dialog','%value'};

    tabDesign.Name=DAStudio.message('Simulink:dialog:DataTab1Prompt');
    tabDesign.LayoutGrid=[rowIdx,3];
    tabDesign.RowStretch=[0,0,0,0,1];
    tabDesign.ColStretch=[0,1,0];
    tabDesign.Items={elementsgrp,...
    description};
    tabDesign.Tag='TabDesign';


    dlgstruct.DialogTitle=[name];
    dlgstruct.DialogTag='BusObjectDialog';

    tabWhole.Type='tab';
    tabWhole.Tag='TabWhole';

    tabWhole.Tabs={tabDesign};
    dlgstruct.Items={editorbtn,tabWhole};


    dlgstruct.Items=remove_duplicate_widget_tags(dlgstruct.Items);
    dlgstruct.PostApplyCallback='busddg_applyrevertcbs';
    dlgstruct.PostApplyArgs={h,'postApply','%dialog'};
    dlgstruct.PostApplyArgsDT={'handle','string','handle'};

    dlgstruct.PostRevertCallback='busddg_applyrevertcbs';
    dlgstruct.PostRevertArgs={h,'postRevert','%dialog'};
    dlgstruct.PostRevertArgsDT={'handle','string','handle'};

    dlgstruct.OpenCallback=@onDialogOpen;


    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_bus'};

end

function onDialogOpen(dlg)
    dlgSrc=dlg.getDialogSource();
    if any(strcmp(methods(class(dlgSrc)),'useBusEditor'))
        dlg.setEnabled('Editorbtn',dlgSrc.useBusEditor());
        if any(strcmp(methods(class(dlgSrc)),'getUserData'))&&any(strcmp(methods(class(dlgSrc)),'setUserData'))
            dlgData=dlgSrc.getUserData;
            dlgData.Enabled.Editorbtn=dlgSrc.useBusEditor();
            dlgSrc.setUserData(dlgData);
        end
    end

end