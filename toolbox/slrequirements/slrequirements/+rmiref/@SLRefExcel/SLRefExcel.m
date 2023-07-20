


classdef SLRefExcel<rmiref.SLReference

    properties
        hDocument=''
        srcObj=[]
        hLink=[]
    end

    methods

        function reference=SLRefExcel(hDoc)
            reference=reference@rmiref.SLReference('excel');
            reference.hDocument=hDoc;
        end


        function success=upgradeActX(this)
            success=false;
            [newButtonOk,newButtonId]=rmicom.actx_installed('SLRefButtonA');
            if newButtonOk
                oldShape=this.srcObj;
                try
                    ctrlLeft=oldShape.Left;
                    ctrlTop=oldShape.Top;
                    ctrlWidth=oldShape.Width;
                    ctrlHeight=oldShape.Height;
                    newShape=hDoc.ActiveSheet.OLEObjects.Add(newButtonId,...
                    '',0,0,'',0,'',...
                    ctrlLeft,ctrlTop,ctrlWidth,ctrlHeight);
                    newObject=newShape.Object;


                    newObject.ToolTipString=this.label;
                    newObject.MLEvalString=this.command;


                    this.srcObj=newShape;
                    this.itemname=newObject.Name;


                    oldShape.Delete();
                    success=true;
                catch Mex
                    warning(message('Slvnv:rmiref:SLRefExcel:UpgradeActiveXButtonFailed',Mex.identifier,Mex.message));
                end
            else
                error(message('Slvnv:rmiref:SLRefExcel:UpgradedControlUnavailable','SLRefButtonA'));
            end
        end

        function assignDocData(this)
            this.docText='??';
            this.docId='<RANGE ID>';
            try
                this.docText=this.srcObj.TopLeftCell.Text;
            catch Mex
                warning('rmiref:DockCheckExcel:findBookmark',Mex.message);
            end
        end

        function ok=assignCmdData(this)
            btnObj=this.srcObj.Object;
            this.label=btnObj.ToolTipString;
            this.command=btnObj.MLEvalString;
            [this.cmd,args]=rmiref.SLReference.parseCommand(this.command);
            if strcmp(this.cmd,'rmiobjnavigate')
                this.model=args{1};
                this.slObj=args{2};


                if length(args)>3||...
                    (length(args)==3&&ischar(args{3}))
                    ok=false;
                else
                    ok=true;
                end
            elseif strcmp(this.cmd,rmiref.DocChecker.FIX_CALLBACK)
                try
                    data=btnObj.MLDataString;
                    skip=0;
                catch Mex %#ok<NASGU>
                    data=btnObj.MLEvalString;
                    skip=5;
                end
                this.refData=data;
                [~,args]=rmiref.SLReference.parseCommand(data);
                this.model=args{1+skip};
                this.slObj=args{2+skip};
                ok=true;
            else
                this.model='';
                this.slObj='';
                ok=false;
            end
        end

        function viewInDocument(this)
            try
                oleObj=this.srcObj;
                topLeftCell=oleObj.TopLeftCell;

                hWorksheet=topLeftCell.Worksheet;
                hWorkbook=hWorksheet.Parent;
                hWorkbook.Activate;
                if strcmpi(hWorkbook.Parent.WindowState,'xlMinimized')
                    hWorkbook.Parent.WindowState='xlNormal';
                end
                hWorkbook.Windows.Item(1).Activate;
                hWorkbook.Parent.Visible=1;

                topLeftCell.Select;

                reqmgt('winFocus',['^',this.hDocument.Name]);

            catch Mex %#ok<NASGU>
                errordlg(...
                getString(message('Slvnv:rmiref:SLRefExcel:IfDocWasClosed')),...
                getString(message('Slvnv:rmiref:SLRefExcel:FailedToView')));
            end
        end

        function deleted=deleteSrc(this)
            try
                this.srcObj.Delete();
                deleted=true;
            catch Mex %#ok<NASGU>
                deleted=false;
            end
        end

        function labelUpdated=updateLabel(this,newLabel)
            try
                docObj=this.srcObj.Object;
                docObj.ToolTipString=newLabel;
                labelUpdated=true;
            catch Mex %#ok<NASGU>
                warning(message('Slvnv:rmiref:SLRefExcel:UpdateLabelFailed',this.itemname));
                labelUpdated=false;
            end
        end

        function dataUpdated=updateData(this,newData)
            dataUpdated=false;
            try
                docObj=this.srcObj.Object;
                docObj.MLDataString=newData;
                dataUpdated=true;
            catch Mex %#ok<NASGU>


                if this.upgradeActX()
                    docObj=this.srcObj.Object;
                    docObj.MLDataString=newData;
                    dataUpdated=true;
                else
                    warning(message('Slvnv:rmiref:SLRefExcel:UpdateFailed',this.itemname));
                end
            end
        end

        function commandUpdated=updateCommand(this,newCommand)
            try
                docObj=this.srcObj.Object;
                docObj.MLEvalString=newCommand;
                commandUpdated=true;
            catch Mex %#ok<NASGU>
                warning(message('Slvnv:rmiref:SLRefExcel:CommandUpdateFailed',this.itemname));
                commandUpdated=false;
            end
        end

        function bitmapUpdated=updateBitmap(this,newIcon)
            newBitmap=rmiref.SLReference.fullIconPathName(newIcon);
            bitmapUpdated=false;
            if~isempty(newBitmap)
                try
                    docObj=this.srcObj.Object;
                    docObj.Picture=newBitmap;
                    bitmapUpdated=true;
                catch Mex %#ok<NASGU>


                    if upgradeActX(this)
                        docObj=this.srcObj.Object;
                        docObj.Picture=newBitmap;
                        bitmapUpdated=true;
                    else
                        warning(message('Slvnv:rmiref:SLRefExcel:UpgradeFailed',this.itemname));
                    end
                end
            end
        end

        function restored=restore(this)
            try
                [origCommand,origLabel]=rmiref.SLReference.parseData(this.refData);
                this.updateCommand(origCommand);
                this.updateLabel(origLabel);
                this.updateData('');
                this.updateBitmap('normal');
                restored=true;
            catch Mex
                warning(message('Slvnv:rmiref:SLRefExcel:RestoreItemFailed',this.itemname,Mex.message));
                restored=false;
            end
        end



    end

end
