function dlgstruct=getDialogSchema(h,system)

    h.System=system;




    listUnSel.Name=DAStudio.message('RTW:traceInfo:tInfoGUIAvailCol');
    listUnSel.Tag='UnSelectedItems';
    listUnSel.Type='listbox';
    listUnSel.Enabled=1;
    listUnSel.RowSpan=[1,6];
    listUnSel.ColSpan=[1,4];
    listUnSel.MultiSelect=0;
    listUnSel.ListDoubleClickCallback=@clicklistUnSel;
    listUnSel.Entries=h.unselected;

    listSel.Name=DAStudio.message('RTW:traceInfo:tInfoGUISelectedCol');
    listSel.Tag='SelectedItems';
    listSel.Enabled=1;
    listSel.Type='listbox';
    listSel.RowSpan=[1,6];
    listSel.ColSpan=[6,10];
    listSel.MultiSelect=0;
    listSel.ListDoubleClickCallback=@clicklistSel;
    listSel.MatlabMethod='feval';
    listSel.MatlabArgs={@clickOnSel,'%source','%dialog'};
    listSel.Entries=h.selected;

    upBut.Type='pushbutton';
    upBut.Tag='Up';

    upBut.FilePath=Simulink.typeeditor.utils.getBusEditorResourceFile('up.png');

    upBut.MatlabMethod='feval';
    upBut.MatlabArgs={@UpHead,'%source','%dialog'};
    upBut.RowSpan=[3,3];
    upBut.ColSpan=[11,11];

    downBut.Type='pushbutton';
    downBut.Tag='Down';

    downBut.FilePath=Simulink.typeeditor.utils.getBusEditorResourceFile('down.png');

    downBut.MatlabMethod='feval';
    downBut.MatlabArgs={@DownHead,'%source','%dialog'};
    downBut.RowSpan=[4,4];
    downBut.ColSpan=[11,11];

    leftBut.Type='pushbutton';
    leftBut.Tag='left';

    leftBut.FilePath=Simulink.typeeditor.utils.getBusEditorResourceFile('move_left.png');

    leftBut.MatlabMethod='feval';
    leftBut.MatlabArgs={@pre_clicklistSel,'%source','%dialog'};
    leftBut.RowSpan=[4,4];
    leftBut.ColSpan=[5,5];

    rightBut.Type='pushbutton';


    rightBut.FilePath=Simulink.typeeditor.utils.getBusEditorResourceFile('addright_structelement.png');
    rightBut.Tag='right';
    rightBut.MatlabMethod='feval';
    rightBut.MatlabArgs={@pre_clicklistUnSel,'%source','%dialog'};
    rightBut.RowSpan=[3,3];
    rightBut.ColSpan=[5,5];

    desText.Type='text';
    desText.Name=DAStudio.message('RTW:traceInfo:tInfoGUIDescriptionText');
    desText.WordWrap=1;

    desText.Tag='DesText';
    desText.RowSpan=[1,1];
    desText.ColSpan=[1,10];

    descGroup.Type='group';
    descGroup.Name=DAStudio.message('RTW:traceInfo:tInfoGUIDescription');
    descGroup.Tag='DescGroup';
    descGroup.Flat=false;
    descGroup.Enabled=1;
    descGroup.Items={desText};
    descGroup.LayoutGrid=[2,12];
    descGroup.Visible=1;




    fileText.Type='edit';
    fileText.Name='';
    fileText.Tag='File';
    fileText.Value=h.fullPath;
    fileText.RowSpan=[1,1];
    fileText.ColSpan=[1,9];

    browseBut.Name=DAStudio.message('RTW:traceInfo:tInfoGUIBrowse');
    browseBut.Type='pushbutton';
    browseBut.ToolTip=DAStudio.message('RTW:traceInfo:tInfoGUIBrowseToolTip');
    browseBut.Tag='OpenNew';
    browseBut.Mode=1;
    browseBut.MatlabMethod='feval';
    browseBut.MatlabArgs={@OpenXLSFunc,'%source','%dialog'};
    browseBut.RowSpan=[1,1];
    browseBut.ColSpan=[10,11];

    generateBut.Name=DAStudio.message('RTW:traceInfo:tInfoGUIGenerate');
    generateBut.Type='pushbutton';
    generateBut.ToolTip=DAStudio.message('RTW:traceInfo:tInfoGUIGenerateToolTip');
    generateBut.Tag='generateBut';
    generateBut.Mode=1;
    generateBut.MatlabMethod='feval';
    generateBut.MatlabArgs={@generateTraceMatrix,'%source','%dialog'};
    generateBut.RowSpan=[12,12];
    generateBut.ColSpan=[1,2];

    fileGroup.Type='group';
    fileGroup.Name=DAStudio.message('RTW:traceInfo:tInfoGUIExcelFile');
    fileGroup.Tag='HeaderGroup';
    fileGroup.Flat=false;
    fileGroup.Enabled=1;
    fileGroup.Items={browseBut,fileText};
    fileGroup.LayoutGrid=[1,12];
    fileGroup.Visible=1;

    starText.Type='text';
    starText.Name=DAStudio.message('RTW:traceInfo:tInfoGUIStarText');
    starText.WordWrap=1;
    starText.RowSpan=[12,12];
    starText.ColSpan=[6,12];


    selectHead.Type='group';
    selectHead.Name='';
    selectHead.Tag='SelectGroup';
    selectHead.Flat=false;
    selectHead.Enabled=1;
    selectHead.Items={listUnSel,listSel,upBut,downBut,...
    leftBut,rightBut,starText,generateBut};

    selectHead.LayoutGrid=[6,12];
    selectHead.Visible=1;




    dlgstruct.DialogTitle=DAStudio.message('RTW:traceInfo:tInfoGUIDiagTitle');
    dlgstruct.HelpMethod='doc';


    if(license('test','Cert_Kit_IEC'))
        dlgstruct.HelpArgs={'iec.exporttracereport'};
        dlgstruct.StandaloneButtonSet={'cancel','help'};
    elseif(license('test','Qual_Kit_DO'))
        dlgstruct.HelpArgs={'do178c.exporttracereport'};
        dlgstruct.StandaloneButtonSet={'cancel','help'};
    else
        dlgstruct.StandaloneButtonSet={'cancel'};
    end

    dlgstruct.Items={descGroup,fileGroup,selectHead};
    dlgstruct.OpenCallback=@openDialog;
    dlgstruct.CloseMethod='closeCB';
    dlgstruct.CloseMethodArgs={'%dialog','%closeaction'};
    dlgstruct.CloseMethodArgsDT={'handle','string'};

end


function openDialog(dlg)
    src=dlg.getSource;
    src.fullPath=[pwd,'\',src.System,'_Trace_',datestr(now,30),'.xls'];
    src.FileLoc=pwd;
    src.FileName=[src.System,'_Trace_',datestr(now,30),'.xls'];
    dlg.refresh();
end

function clickOnSel(~,dialog)
    imd=DAStudio.imDialog.getIMWidgets(dialog);
    selList=imd.find('Tag','SelectedItems');
    allSel=selList.getListItems;
    curSel=selList.getCurrentSelections;
    if~isempty(curSel)
        curSel=allSel{curSel+1};
        if isempty((strfind(curSel,'*')))
            dialog.setEnabled('left',1)
        else
            dialog.setEnabled('left',0)
        end
    end
end
function UpHead(source,dialog)

    imd=DAStudio.imDialog.getIMWidgets(dialog);
    selList=imd.find('Tag','SelectedItems');
    allSel=selList.getListItems;

    index=1+selList.getCurrentSelections;
    if(index~=1)
        tmpStr=allSel(index-1);
        allSel(index-1)=allSel(index);
        allSel(index)=tmpStr;
        selList.unselectall;
        selList.select(index-2);

        source.selected=allSel;
        dialog.refresh();
        clickOnSel(source,dialog);
    end

end


function DownHead(source,dialog)

    imd=DAStudio.imDialog.getIMWidgets(dialog);
    selList=imd.find('Tag','SelectedItems');
    allSel=selList.getListItems;
    numSel=length(allSel);

    index=1+selList.getCurrentSelections;
    if(index~=numSel)
        tmpStr=allSel(index+1);
        allSel(index+1)=allSel(index);
        allSel(index)=tmpStr;
        selList.unselectall;
        selList.select(index);

        source.selected=allSel;
        dialog.refresh();
        clickOnSel(source,dialog);
    end

end

function OpenXLSFunc(source,dialog)

    [source.FileName,source.FileLoc]=uiputfile('*.xls;*.xlsx',DAStudio.message('RTW:traceInfo:tInfoGUIBrowseToolTip'));

    fullPath=[source.FileLoc,source.FileName];


    if((isempty(fullPath))||(strcmp(class(fullPath),'double')))
        source.fullPath='';
    else
        source.fullPath=fullPath;
        if(exist(fullPath,'file'))

            try
                [~,~,raw]=xlsread(fullPath,DAStudio.message('RTW:traceInfo:tInfoExcelReport'));
                header=raw(1,:);
                update={};
                for inx=1:length(source.AllHeaders)
                    if(~strcmp(source.AllHeaders{inx},header))
                        update{end+1}=source.AllHeaders{inx};
                    end
                end

                req={DAStudio.message('RTW:traceInfo:tInfoExcelModelCol_1'),...
                DAStudio.message('RTW:traceInfo:tInfoExcelModelCol_2'),...
                DAStudio.message('RTW:traceInfo:tInfoExcelModelCol_3'),...
                DAStudio.message('RTW:traceInfo:tInfoExcelModelCol_4'),...
                DAStudio.message('RTW:traceInfo:tInfoExcelModelCol_5'),...
                DAStudio.message('RTW:traceInfo:tInfoExcelModelCol_6'),...
                DAStudio.message('RTW:traceInfo:tInfoExcelModelCol_7'),...
                DAStudio.message('RTW:traceInfo:tInfoExcelModelCol_12'),...
                DAStudio.message('RTW:traceInfo:tInfoExcelModelCol_15'),...
                DAStudio.message('RTW:traceInfo:tInfoExcelModelCol_18')};
                for inx=1:length(req)
                    if(any(strcmpi(header{inx},req)))
                        header{inx}=[header{inx},'*'];
                    end
                end
                source.unselected=update;
                source.selected=header;
            catch

            end
        end


        dialog.refresh();
    end
end


function generateTraceMatrix(source,dialog)

    system=source.System;
    if(~bdIsLoaded(system))
        warndlg(['The model "',system,'" was not open',10,...
        'To generate the report open the model',10,...
        'and regenerate the code.']);
    else

        imd=DAStudio.imDialog.getIMWidgets(dialog);
        selList=imd.find('Tag','SelectedItems');
        header=selList.getListItems;

        header=regexprep(header,'*','');

        fileName=source.FileName;
        pathName=source.FileLoc;


        fileInfo=imd.find('Tag','File');
        [pathName2,fileName2,ext]=fileparts(fileInfo.text);
        fileName2=[fileName2,ext];
        [~,valid,~]=fileattrib(pathName2);
        if(valid.UserWrite==0)
            warndlg(DAStudio.message('RTW:traceInfo:tInfoExcelError_NoWritePer',pathName));
            return;
        end

        if((~strcmp([pathName2,'\'],pathName))||(~strcmp(fileName2,fileName)))

            if(exist(pathName2,'dir'))

                tInfo=RTW.TraceInfo.instance(system);
                if isempty(tInfo)
                    tInfo=RTW.TraceInfo(system);
                    dialog.setEnabled('HeaderGroup',1);
                    dialog.setEnabled('DescGroup',1);
                    dialog.setEnabled('SelectGroup',1);
                end

                if isempty(tInfo.BuildDir)
                    tInfo.setBuildDir('');
                    dialog.setEnabled('HeaderGroup',1);
                    dialog.setEnabled('DescGroup',1);
                    dialog.setEnabled('SelectGroup',1);
                end

                dialog.setEnabled('HeaderGroup',0);
                dialog.setEnabled('DescGroup',0);
                dialog.setEnabled('SelectGroup',0);
                tInfo.exportTraceReport(fileName2,pathName2,header,[],system)
                dialog.setEnabled('HeaderGroup',1);
                dialog.setEnabled('DescGroup',1);
                dialog.setEnabled('SelectGroup',1);


            else
                warndlg(DAStudio.message('RTW:traceInfo:tInfoExcelGUI_BadDirectory',pathName2));
            end
        else
            tInfo=RTW.TraceInfo.instance(system);
            tInfo.exportTraceReport(fileName,pathName,header,[],system)

        end
    end

end

function clicklistSel(h,~,index)
    if(~isempty(index))

        index=index+1;


        imd=DAStudio.imDialog.getIMWidgets(h);

        selList=imd.find('Tag','SelectedItems');
        allItems=selList.getListItems;
        numSel=length(selList);
        mySelect=allItems(index);
        if isempty((strfind(mySelect{1},'*')))

            unSelList=imd.find('Tag','UnSelectedItems');
            unSel=unSelList.getListItems;
            unSel(end+1)=mySelect;
            if(index==1)
                allItems=allItems(2:end);
            elseif(index==numSel)
                allItems=allItems(1:end-1);
            else
                allItems=[allItems(1:index-1),allItems(index+1:end)];
            end

            so=h.getSource;
            so.selected=allItems;
            so.unselected=unSel;
            h.refresh();
        end
    end
end

function pre_clicklistUnSel(~,dlg)

    imd=DAStudio.imDialog.getIMWidgets(dlg);
    unSelList=imd.find('Tag','UnSelectedItems');
    index=unSelList.getCurrentSelections;
    clicklistUnSel(dlg,'',index);
end

function pre_clicklistSel(~,dlg)

    imd=DAStudio.imDialog.getIMWidgets(dlg);
    SelList=imd.find('Tag','SelectedItems');
    index=SelList.getCurrentSelections;
    clicklistSel(dlg,'',index);
end

function clicklistUnSel(h,~,index)
    if(~isempty(index))


        index=index+1;

        imd=DAStudio.imDialog.getIMWidgets(h);
        unSelList=imd.find('Tag','UnSelectedItems');
        unSel=unSelList.getListItems;
        numUnSel=length(unSel);
        mySelect=unSel(index);

        selList=imd.find('Tag','SelectedItems');
        allItems=selList.getListItems;
        allItems(end+1)=mySelect;


        if(index==1)
            unSel=unSel(2:end);
        elseif(index==numUnSel)
            unSel=unSel(1:end-1);
        else
            unSel=[unSel(1:index-1),unSel(index+1:end)];
        end

        so=h.getSource;
        so.selected=allItems;
        so.unselected=unSel;
        h.refresh();
    end
end
