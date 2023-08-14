classdef FPGABoardManager<handle






















    properties(SetObservable)

        Display{matlab.internal.validation.mustBeCharRowVector(Display,'Display')}='';

        SearchTxt{matlab.internal.validation.mustBeASCIICharRowVector(SearchTxt,'SearchTxt')}='';

        SearchAction=[];

        BoardManager=[];

        IsCurrBoardEditable(1,1)logical=false;

        IsCurrBoardCustom(1,1)logical=false;

        IsDisplayFilterChanged(1,1)logical=false;

        ParentDlg=[];

        ChildDlg=[];

        PrevBrowsePath=[];

        LastImportedBoard{matlab.internal.validation.mustBeASCIICharRowVector(LastImportedBoard,'LastImportedBoard')}='';
    end

    methods
        function this=FPGABoardManager(varargin)

            eda.internal.boardmanager.checkHDLProduct;
            eda.internal.boardmanager.checkFixedPointToolbox;

            this.SearchTxt='';
            this.SearchAction=false;
            this.Display=DAStudio.message('EDALink:boardmanagergui:All');
            this.BoardManager=eda.internal.boardmanager.BoardManager.getInstance;
            allBoardNames=this.BoardManager.getAllBoardNames;
            if numel(allBoardNames)>1
                this.IsCurrBoardEditable=this.BoardManager.isBoardEditable(allBoardNames{1});
                this.IsCurrBoardCustom=this.BoardManager.isCustom(allBoardNames{1});
            end
            this.PrevBrowsePath='';
            this.LastImportedBoard='';
            this.IsDisplayFilterChanged=false;
        end
    end

    methods
        function set.Display(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','Display')
            obj.Display=value;
        end

        function set.SearchTxt(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.SearchTxt=value;
        end

        function set.IsCurrBoardEditable(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','IsCurrBoardEditable')
            value=logical(value);
            obj.IsCurrBoardEditable=value;
        end

        function set.IsCurrBoardCustom(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','IsCurrBoardCustom')
            value=logical(value);
            obj.IsCurrBoardCustom=value;
        end

        function set.IsDisplayFilterChanged(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','IsDisplayFilterChanged')
            value=logical(value);
            obj.IsDisplayFilterChanged=value;
        end

        function set.LastImportedBoard(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.LastImportedBoard=value;
        end
    end

    methods(Hidden)

        function closeCB(this,~)
            boardmanagergui.updateParentGUI(this.ParentDlg);
        end


        function dlgStruct=getDialogSchema(this,~)
            DisplayCmb.Type='combobox';
            DisplayCmb.Name=DAStudio.message('EDALink:boardmanagergui:Filter');
            DisplayCmb.Tag='fpgaDisplay';
            DisplayCmb.Entries={DAStudio.message('EDALink:boardmanagergui:All'),...
            DAStudio.message('EDALink:boardmanagergui:CustomBoard'),...
            DAStudio.message('EDALink:boardmanagergui:InstalledBoard')};









            DisplayCmb.ObjectProperty='Display';
            DisplayCmb.ObjectMethod='onDisplayChange';
            DisplayCmb.MethodArgs={'%dialog'};
            DisplayCmb.ArgDataTypes={'handle'};
            DisplayCmb.Mode=true;
            DisplayCmb.RowSpan=[1,1];
            DisplayCmb.ColSpan=[1,2];
            if~ismember(this.Display,DisplayCmb.Entries)
                this.Display=DisplayCmb.Entries{1};
            end


            SearchEdt.Type='edit';
            SearchEdt.Tag='fpgaSearchEdt';
            SearchEdt.ObjectProperty='SearchTxt';
            SearchEdt.Name='';
            SearchEdt.Mode=true;
            SearchEdt.RowSpan=[1,1];
            SearchEdt.ColSpan=[5,7];

            SearchBtn.Type='pushbutton';
            SearchBtn.Name='Search';
            SearchBtn.Tag='fpgaSearchBtn';
            SearchBtn.ObjectMethod='onSearch';
            SearchBtn.MethodArgs={'%dialog'};
            SearchBtn.ArgDataTypes={'handle'};
            SearchBtn.RowSpan=[1,1];
            SearchBtn.ColSpan=[8,8];

            BoardTbl.Type='table';
            BoardTbl.Name='';
            BoardTbl.Tag='fpgaBoardTbl';
            BoardTbl.ColHeader={...
            DAStudio.message('EDALink:boardmanagergui:BoardName'),...
            DAStudio.message('EDALink:boardmanagergui:FILEnabled'),...
            DAStudio.message('EDALink:boardmanagergui:TurnkeyEnabled')};

            BoardTbl.RowSpan=[2,9];
            BoardTbl.ColSpan=[1,8];
            BoardTbl.HeaderVisibility=[0,1];
            BoardTbl.ColumnStretchable=[1,0,0];
            BoardTbl.ColumnCharacterWidth=[70,10,10];
            BoardTbl.SelectionBehavior='Row';
            BoardTbl.CurrentItemChangedCallback=@l_BoardSelectChange;

            switch this.Display
            case DAStudio.message('EDALink:boardmanagergui:CustomBoard')
                boardNames=this.BoardManager.getCustomBoardNames;
            case DAStudio.message('EDALink:boardmanagergui:InstalledBoard')
                boardNames=this.BoardManager.getPreInstalledBoardNames;
            otherwise
                boardNames=this.BoardManager.getAllBoardNames;
            end

            if this.SearchAction&&~isempty(this.SearchTxt)
                match=cell(0,2);
                for m=1:numel(boardNames)
                    if contains(lower(boardNames{m}),lower(this.SearchTxt))
                        match=[match;boardNames{m}];%#ok<AGROW>
                    end
                end
            else
                match=boardNames;
            end
            BoardTbl.Size=[numel(match),3];
            BoardTbl.Data=cell(numel(match),3);
            for m=1:numel(match)
                boardName=match{m};
                boardObj=this.BoardManager.getBoardObj(boardName);
                BoardTbl.Data{m,1}=boardName;
                if boardObj.isFILCompatible
                    BoardTbl.Data{m,2}='Yes';
                else
                    BoardTbl.Data{m,2}='No';
                end
                if boardObj.isTurnkeyCompatible
                    BoardTbl.Data{m,3}='Yes';
                else
                    BoardTbl.Data{m,3}='No';
                end
                if~isempty(this.LastImportedBoard)&&strcmp(this.LastImportedBoard,boardName)
                    BoardTbl.SelectedRow=m-1;
                    this.LastImportedBoard='';
                end
            end

            NewBtn=l_getPushButton(DAStudio.message('EDALink:boardmanagergui:CreateBtn'),'fpgaNewBoard','onNew',[1,1],[1,1]);
            ImportBtn=l_getPushButton(DAStudio.message('EDALink:boardmanagergui:ImportBtn'),'fpgaImport','onImport',[2,2],[1,1]);
            GetMoreBtn=l_getPushButton(DAStudio.message('EDALink:boardmanagergui:GetMoreBtn'),'fpgaGetMore','onGetMore',[3,3],[1,1]);
            EditBtn=l_getPushButton(DAStudio.message('EDALink:boardmanagergui:EditBtn'),'fpgaEdit','onEdit',[1,1],[1,1]);
            ViewBtn=l_getPushButton(DAStudio.message('EDALink:boardmanagergui:ViewBtn'),'fpgaView','onEdit',[2,2],[1,1]);
            RemoveBtn=l_getPushButton(DAStudio.message('EDALink:boardmanagergui:RemoveBtn'),'fpgaRemove','onDelete',[3,3],[1,1]);
            SaveAsBtn=l_getPushButton(DAStudio.message('EDALink:boardmanagergui:CopyBtn'),'fpgaCopy','onCopy',[4,4],[1,1]);
            ValidateBtn=l_getPushButton(DAStudio.message('EDALink:boardmanagergui:ValidateBtn'),'fpgaValidate','onValidate',[5,5],[1,1]);

            HasBoard=(numel(boardNames)>0);
            EditBtn.Visible=this.IsCurrBoardEditable;
            ViewBtn.Visible=~this.IsCurrBoardEditable;
            RemoveBtn.Enabled=this.IsCurrBoardCustom&&HasBoard;
            ValidateBtn.Enabled=HasBoard;
            EditBtn.Enabled=HasBoard;
            SaveAsBtn.Enabled=HasBoard;
            ViewBtn.Enabled=HasBoard;



            if this.IsDisplayFilterChanged||this.SearchAction
                this.IsDisplayFilterChanged=false;
                this.SearchAction=false;
                if numel(match)>=1
                    this.IsCurrBoardEditable=this.BoardManager.isBoardEditable(match{1});
                    this.IsCurrBoardCustom=this.BoardManager.isCustom(match{1});
                    EditBtn.Visible=this.IsCurrBoardEditable;
                    ViewBtn.Visible=~this.IsCurrBoardEditable;
                    RemoveBtn.Enabled=this.IsCurrBoardCustom;
                end
            end

            newPanel.Type='panel';
            newPanel.RowSpan=[2,3];
            newPanel.ColSpan=[9,10];
            newPanel.LayoutGrid=[3,1];
            newPanel.Items={NewBtn,ImportBtn,GetMoreBtn};

            opPanel.Type='panel';
            opPanel.RowSpan=[5,8];
            opPanel.ColSpan=[9,10];
            opPanel.LayoutGrid=[5,1];
            opPanel.Items={EditBtn,ViewBtn,RemoveBtn,SaveAsBtn,ValidateBtn};

            mainPanel.Type='group';
            mainPanel.Name=DAStudio.message('EDALink:boardmanagergui:FPGABoardList');
            mainPanel.Items={DisplayCmb,SearchEdt,SearchBtn,BoardTbl,...
            newPanel,opPanel};
            mainPanel.LayoutGrid=[9,10];
            mainPanel.RowSpan=[1,9];
            mainPanel.ColSpan=[1,10];
            mainPanel.RowStretch=[0,ones(1,8)];

            buttonWidgets=l_getButtonSet;
            buttonWidgets.RowSpan=[10,10];
            buttonWidgets.ColSpan=[8,10];


            dlgStruct.DialogTitle=DAStudio.message('EDALink:boardmanagergui:BoardManagerTitle');
            dlgStruct.Items={mainPanel,buttonWidgets};

            dlgStruct.LayoutGrid=[10,10];
            dlgStruct.RowStretch=[ones(1,9),0];
            dlgStruct.ColStretch=[0,1,1,1,1,1,1,1,1,1];
            dlgStruct.ShowGrid=false;

            dlgStruct.StandaloneButtonSet={''};

            dlgStruct.CloseMethod='closeCB';
            dlgStruct.CloseMethodArgs={'%dialog'};
            dlgStruct.CloseMethodArgsDT={'handle'};


            dlgStruct.DialogTag=class(this);
            dlgStruct.DisplayIcon=...
            '\toolbox\shared\eda\board\resources\MATLAB.png';
        end


        function onClose(this,~)
            delete(this);
        end


        function onCopy(this,dlg)
            indx=dlg.getSelectedTableRows('fpgaBoardTbl');

            if~isempty(indx)&&length(indx)==1
                boardName=dlg.getTableItemValue('fpgaBoardTbl',indx,0);
                boardObj=this.BoardManager.getBoardObj(boardName);
                if(boardObj.IsBoardCopyDisabled)
                    error(message('EDALink:boardmanagergui:BoardCannotBeCloned'));
                end
                boardFile=this.BoardManager.getBoardFile(boardName);
                newDlg=boardmanagergui.CopyBoard(boardName,boardFile);
                newDlg.ParentDlg=dlg;
                this.ChildDlg=DAStudio.Dialog(newDlg);
            end
        end


        function onDelete(this,dlg)
            indx=dlg.getSelectedTableRow('fpgaBoardTbl');

            if indx>=0
                for m=1:length(indx)
                    boardName=dlg.getTableItemValue('fpgaBoardTbl',indx(m),0);
                    this.BoardManager.removeBoard(boardName);
                end
                dlg.refresh;
            end
        end


        function onDisplayChange(this,dlg)
            this.IsDisplayFilterChanged=true;
            dlg.refresh;
        end


        function onEdit(this,dlg)
            indx=dlg.getSelectedTableRows('fpgaBoardTbl');

            if length(indx)==1
                boardName=dlg.getTableItemValue('fpgaBoardTbl',indx,0);
                boardObj=this.BoardManager.getBoardObj(boardName);
                boardObjCopy=boardObj.copy;

                isReadOnly=~this.BoardManager.isBoardEditable(boardName);
                newDlg=boardmanagergui.FPGABoardEditor(boardObjCopy,isReadOnly);
                newDlg.ParentDlg=dlg;


                this.ChildDlg=DAStudio.Dialog(newDlg);
            end
        end


        function onGetMore(~,dlg)
            eda.internal.boardmanager.updateBoardList(dlg);

            matlab.addons.supportpackage.internal.explorer.showSupportPackages({'HDLCVXILINX','HDLVALTERA','HDLCXILINX','HDLCALTERA','MICROSEMI'},'tripwire');
        end


        function onHelp(~,~)
            eda.internal.boardmanager.helpview('FPGABoard_BoardManager');
        end


        function onImport(this,dlg)
            [filenames,pathname]=uigetfile({'*.xml','FPGA Board Configuration Files (*.xml)';...
            '*.*','All Files (*.*)'},'Import FPGA Board Configuration File',...
            this.PrevBrowsePath,...
            'MultiSelect','on');
            if ischar(pathname)

                if~iscell(filenames)
                    filenames={filenames};
                end
                for m=1:numel(filenames)
                    filenames{m}=fullfile(pathname,filenames{m});
                end
                boardNames=this.BoardManager.addBoardByFileName(filenames);
                this.LastImportedBoard=boardNames{end};


                this.PrevBrowsePath=pathname;


                this.SearchAction=false;
                if strcmpi(this.Display,'Pre-installed Boards')
                    this.Display='All';
                end
                dlg.refresh;
            end
        end


        function onNew(this,dlg)
            h=boardmanagergui.NewBoardWizard(dlg);
            this.ChildDlg=DAStudio.Dialog(h);
        end


        function onSearch(this,dlg)
            this.SearchAction=true;
            dlg.refresh;
            this.SearchAction=false;
        end


        function onValidate(this,dlg)
            indx=dlg.getSelectedTableRows('fpgaBoardTbl');

            if length(indx)==1
                boardName=dlg.getTableItemValue('fpgaBoardTbl',indx,0);
                boardObj=this.BoardManager.getBoardObj(boardName);
                if boardObj.IsBoardValidateDisabled
                    error(message('EDALink:boardmanagergui:BoardCannotBeValidated'));
                end

                hValidation=boardmanagergui.BoardValidation;
                hValidation.ParentDlg=dlg;

                hValidation.setBoardObj(boardObj);
                this.ChildDlg=DAStudio.Dialog(hValidation);
            else
                error(message('EDALink:boardmanagergui:MoreThanOneBoard'));
            end

        end
    end
end

function button=l_getPushButton(Name,Tag,ObjectMethod,RowSpan,ColSpan)
    button.Name=Name;
    button.Tag=Tag;
    button.Type='pushbutton';
    button.ObjectMethod=ObjectMethod;
    button.MethodArgs={'%dialog'};
    button.ArgDataTypes={'handle'};
    button.RowSpan=RowSpan;
    button.ColSpan=ColSpan;
    button.Visible=true;
end

function ButtonSet=l_getButtonSet
    BtnClose=l_getPushButton('OK','fpgaClose','onClose',[1,1],[1,1]);
    BtnHelp=l_getPushButton('Help','fpgaHelp','onHelp',[1,1],[2,2]);

    ButtonSet.Type='panel';
    ButtonSet.Tag='edaButtonSet';
    ButtonSet.LayoutGrid=[1,2];
    ButtonSet.RowStretch=1;
    ButtonSet.Items={BtnHelp,BtnClose};
end

function l_BoardSelectChange(dlg,row,~)
    boardName=dlg.getTableItemValue('fpgaBoardTbl',row,0);
    source=dlg.getSource;
    source.IsCurrBoardEditable=source.BoardManager.isBoardEditable(boardName);
    source.IsCurrBoardCustom=source.BoardManager.isCustom(boardName);
    bobj=source.BoardManager.getBoardObj(boardName);
    isMicrosemi=strcmpi(bobj.FPGA.Vendor,'Microsemi');
    dlg.setVisible('fpgaEdit',source.IsCurrBoardEditable);
    dlg.setVisible('fpgaView',~source.IsCurrBoardEditable&&~isMicrosemi);
    dlg.setVisible('fpgaCopy',~isMicrosemi);
    dlg.setEnabled('fpgaRemove',source.IsCurrBoardCustom);
end

