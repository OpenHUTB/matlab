classdef CopyBoard<handle

    properties(SetObservable)

        BoardName{matlab.internal.validation.mustBeASCIICharRowVector(BoardName,'BoardName')}='';

        OldBoardName{matlab.internal.validation.mustBeASCIICharRowVector(OldBoardName,'OldBoardName')}='';

        BoardFile{matlab.internal.validation.mustBeASCIICharRowVector(BoardFile,'BoardFile')}='';

        OldBoardFile{matlab.internal.validation.mustBeASCIICharRowVector(OldBoardFile,'OldBoardFile')}='';

        ParentDlg=[];
    end


    methods
        function this=CopyBoard(varargin)
            this.OldBoardName=varargin{1};
            if isempty(varargin{2})
                this.OldBoardFile='newboard';
            else
                this.OldBoardFile=varargin{2};
            end
            this.BoardName=[this.OldBoardName,' - Copy'];
            [~,name]=fileparts(this.OldBoardFile);

            fileName=fullfile(pwd,[name,' - Copy']);
            fullFileName=[fileName,'.xml'];




            for count=1:100
                if~exist(fullFileName,'file')
                    break;
                end
                fullFileName=[fileName,num2str(count),'.xml'];
            end


            if exist(fullFileName,'file')
                fullFileName=[tempname(pwd),'.xml'];
            end
            this.BoardFile=fullFileName;
        end
    end

    methods
        function set.BoardName(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.BoardName=value;
        end

        function set.OldBoardName(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.OldBoardName=value;
        end

        function set.BoardFile(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.BoardFile=value;
        end

        function set.OldBoardFile(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.OldBoardFile=value;
        end

        function set.ParentDlg(obj,value)

            validateattributes(value,{'handle'},{'scalar'},'','ParentDlg')
            obj.ParentDlg=value;
        end
    end

    methods(Hidden)

        function dlgStruct=getDialogSchema(this,~)
            BoardNameTxt.Type='text';
            BoardNameTxt.Name=[DAStudio.message('EDALink:boardmanagergui:BoardName'),':'];
            BoardNameTxt.Tag='fpgaBoardNameTxt';
            BoardNameTxt.RowSpan=[1,1];
            BoardNameTxt.ColSpan=[1,2];

            BoardNameEdt.Type='edit';
            BoardNameEdt.Tag='fpgaBoardNameEdt';
            BoardNameEdt.ObjectProperty='BoardName';
            BoardNameEdt.RowSpan=[1,1];
            BoardNameEdt.ColSpan=[3,9];
            BoardNameEdt.Mode=true;

            FileLocTxt.Type='text';
            FileLocTxt.Name=DAStudio.message('EDALink:boardmanagergui:FileLocation');
            FileLocTxt.RowSpan=[2,2];
            FileLocTxt.ColSpan=[1,2];

            FileLocEdt.Type='edit';
            FileLocEdt.Tag='fpgaFileLocationEdt';
            FileLocEdt.ObjectProperty='BoardFile';
            FileLocEdt.RowSpan=[2,2];
            FileLocEdt.ColSpan=[3,8];

            FileLocEdt.Enabled=false;

            BrowseBtn.Name=DAStudio.message('EDALink:boardmanagergui:Browse');
            BrowseBtn.Tag='fpgaBrowseBtn';
            BrowseBtn.Type='pushbutton';
            BrowseBtn.ObjectMethod='onBrowse';
            BrowseBtn.MethodArgs={'%dialog'};
            BrowseBtn.ArgDataTypes={'handle'};
            BrowseBtn.RowSpan=[2,2];
            BrowseBtn.ColSpan=[9,9];

            OkBtn.Name=DAStudio.message('EDALink:boardmanagergui:OkBtn');
            OkBtn.Tag='fpgaOkBtn';
            OkBtn.Type='pushbutton';
            OkBtn.ObjectMethod='onOK';
            OkBtn.MethodArgs={'%dialog'};
            OkBtn.ArgDataTypes={'handle'};
            OkBtn.RowSpan=[3,3];
            OkBtn.ColSpan=[7,7];

            CancelBtn.Name=DAStudio.message('EDALink:boardmanagergui:CancelBtn');
            CancelBtn.Tag='fpgaCancelBtn';
            CancelBtn.Type='pushbutton';
            CancelBtn.ObjectMethod='onCancel';
            CancelBtn.MethodArgs={'%dialog'};
            CancelBtn.ArgDataTypes={'handle'};
            CancelBtn.RowSpan=[3,3];
            CancelBtn.ColSpan=[8,8];


            dlgStruct.DialogTitle=DAStudio.message('EDALink:boardmanagergui:CreateCopy',this.OldBoardName);
            dlgStruct.Items={BoardNameTxt,BoardNameEdt,FileLocTxt,FileLocEdt,...
            BrowseBtn,OkBtn,CancelBtn};
            dlgStruct.Sticky=true;

            dlgStruct.LayoutGrid=[3,7];
            dlgStruct.ShowGrid=false;

            dlgStruct.StandaloneButtonSet={''};


            dlgStruct.DialogTag=class(this);
            dlgStruct.DisplayIcon=...
            '\toolbox\shared\eda\board\resources\MATLAB.png';
        end

        function onBrowse(this,dlg)
            [filename,pathname]=uiputfile(...
            {'*.xml','FPGA Board File (*.xml)'},...
            'Save FPGA board file as',this.BoardFile);
            if filename~=0
                filename=fullfile(pathname,filename);
                this.BoardFile=filename;
                dlg.refresh;
            end
        end


        function onCancel(this,~)
            delete(this);
        end


        function onOK(this,~)

            hManager=this.ParentDlg.getSource;
            hManager.BoardManager.validateNewBoardName(this.BoardName);
            hManager.BoardManager.validateNewBoardFile(this.BoardFile);


            oldBoardObj=hManager.BoardManager.getBoardObj(this.OldBoardName);
            boardObj=copy(oldBoardObj);
            boardObj.BoardFile=this.BoardFile;
            boardObj.BoardName=this.BoardName;
            boardObj.FILBoardClass='';
            boardObj.TurnkeyBoardClass='';
            newDlg=boardmanagergui.FPGABoardEditor(boardObj);
            newDlg.ParentDlg=this.ParentDlg;
            newDlg.OldBoardName='';

            hBoardManagerGUI=this.ParentDlg.getSource;


            hBoardManagerGUI.ChildDlg=DAStudio.Dialog(newDlg);


            pause(1);
            delete(this);
        end
    end
end

