


classdef SLRefWord<rmiref.SLReference

    properties
        hDocument=''
        srcShape=[]
        hLink=[]
    end

    methods

        function reference=SLRefWord(hDoc)
            reference=reference@rmiref.SLReference('word');
            reference.hDocument=hDoc;
        end

        function success=upgradeActX(this)
            success=false;
            [newButtonOk,newButtonId]=rmicom.actx_installed('SLRefButtonA');
            if newButtonOk
                oldShape=this.srcShape;
                try
                    range=oldShape.Range;
                    newShape=this.hDocument.InlineShapes.AddOLEControl(newButtonId,range);
                    newShape.Height=15;
                    newShape.Width=15;
                    newObject=newShape.OLEFormat.Object;


                    newObject.ToolTipString=this.label;
                    newObject.MLEvalString=this.command;


                    this.srcShape=newShape;
                    this.itemname=newObject.Name;


                    oldShape.Delete();
                    success=true;
                catch Mex
                    warning(message('Slvnv:rmiref:SLRefWord:UpgradeActiveCButtonFailed',Mex.identifier,Mex.message));
                end
            else
                error(message('Slvnv:rmiref:SLRefWord:UpgradedControlUnavailable','SLRefButtonA'));
            end
        end

        function assignDocData(this)
            this.docText='??';
            this.docId='';
            try
                if isempty(this.srcShape)

                    myRange=getLinkAnchorRange(this.hLink);
                else
                    myRange=this.srcShape.Range;
                end
                [this.docText,this.docId]=rmiref.WordUtil.findBookmark(myRange);
            catch Mex
                warning('rmiref:DockCheckWord:findBookmark',Mex.message);
            end

            function range=getLinkAnchorRange(hLink)
                [~,~,parentNameExt]=fileparts(hLink.Parent.Name);
                if parentNameExt(end)=='x'
                    range=hLink.Shape.Anchor.Paragraphs.Item(1).Range;
                else
                    range=hLink.Range;
                end
            end
        end

        function ok=assignCmdData(this,varargin)
            if isempty(varargin)
                btnObj=this.srcShape.OLEFormat.Object;
                this.label=btnObj.ToolTipString;
                this.command=btnObj.MLEvalString;
            else

                this.label=this.hLink.ScreenTip;
                urlCmd=strrep(varargin{1},'%22','''');
                mlCommand=strrep(strrep(urlCmd,'?arguments=[','('),']',');');
                this.command=strrep(mlCommand,'"','''');
            end
            [this.cmd,args]=rmiref.SLReference.parseCommand(this.command);
            if strcmp(this.cmd,'rmiobjnavigate')
                this.model=args{1};
                this.slObj=args{2};


                if length(args)>3||(length(args)==3&&ischar(args{3}))
                    if isempty(varargin)
                        ok=this.splitGroupReference();
                    else
                        ok=false;
                    end
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

        function result=splitGroupReference(this)
            reply=questdlg({...
            getString(message('Slvnv:rmiref:SLRefWord:DetectedMultipleRefButton')),...
            getString(message('Slvnv:rmiref:SLRefWord:YouNeedToSplitThisReference')),...
            ' ',...
            getString(message('Slvnv:rmiref:SLRefWord:SplitNowQuest'))},...
            getString(message('Slvnv:rmiref:SLRefWord:GroupReferenceIn',this.hDocument.Name)),...
            'Yes','No','Yes');
            if isempty(reply)||strcmp(reply,'Yes')
                [firstCommand,firstLabel]=rmiref.SLRefWord.splitRefs(this.srcShape);
                this.command=firstCommand;
                this.label=firstLabel;
                result=true;
            else
                result=false;
            end
        end

        function viewInDocument(this)
            try
                if isempty(this.srcShape)

                    this.hLink.Shape.Anchor.Select;
                    hTargetDoc=this.hLink.Parent;
                else
                    shapeObj=this.srcShape;
                    shapeRange=shapeObj.Range;
                    shapeRange.Expand(3);
                    shapeRange.Select;
                    hTargetDoc=shapeObj.Parent;
                end
                hDocuments=hTargetDoc.Parent;
                if(strcmpi(hDocuments.WindowState,'wdWindowStateMinimize'))

                    hDocuments.WindowState='wdWindowStateNormal';
                end
                hTargetDoc.Activate;
                if~hDocuments.Application.Visible
                    hDocuments.Application.Visible=1;
                end
                hDocuments.Parent.Activate;
            catch Mex
                errordlg(...
                getString(message('Slvnv:rmiref:SLRefWord:IfTheDocWasClosed')),...
                getString(message('Slvnv:rmiref:SLRefWord:FailedToView')));
            end
        end

        function deleted=deleteSrc(this)
            try
                this.srcShape.Delete();
                deleted=true;
            catch Mex %#ok<NASGU>
                deleted=false;
            end
        end

        function labelUpdated=updateLabel(this,newLabel)
            if isempty(this.srcShape)

                this.hLink.ScreenTip=newLabel;
                labelUpdated=true;
            else
                try
                    docObj=this.srcShape.OLEFormat.Object;
                    docObj.ToolTipString=newLabel;
                    labelUpdated=true;
                catch Mex %#ok<NASGU>
                    warning(message('Slvnv:rmiref:SLRefWord:UpdateLabelFailed',this.itemname));
                    labelUpdated=false;
                end
            end
        end

        function dataUpdated=updateData(this,newData)
            dataUpdated=false;
            if~isempty(this.srcShape)
                try
                    docObj=this.srcShape.OLEFormat.Object;
                    docObj.MLDataString=newData;
                    dataUpdated=true;
                catch Mex %#ok<NASGU>


                    if this.upgradeActX()
                        docObj=this.srcShape.OLEFormat.Object;
                        docObj.MLDataString=newData;
                        dataUpdated=true;
                    else
                        warning(message('Slvnv:rmiref:SLRefWord:UpgradeFailed',this.itemname));
                    end
                end
            else
                this.hLink.SubAddress=newData;
                dataUpdated=true;
            end
        end

        function commandUpdated=updateCommand(this,newCommand)
            try
                docObj=this.srcShape.OLEFormat.Object;
                docObj.MLEvalString=newCommand;
                commandUpdated=true;
            catch Mex %#ok<NASGU>
                warning(message('Slvnv:rmiref:SLRefWord:CommandUpdateFailed',this.itemname));
                commandUpdated=false;
            end
        end

        function bitmapUpdated=updateBitmap(this,newIcon)
            newBitmap=rmiref.SLReference.fullIconPathName(newIcon);
            bitmapUpdated=false;
            if isempty(this.srcShape)

                range=this.hLink.Shape.Anchor.Paragraphs.Item(1).Range;
                range.Start=range.End-1;
                range.InlineShapes.AddPicture(newBitmap);
            else
                if~isempty(newBitmap)
                    try
                        docObj=this.srcShape.OLEFormat.Object;
                        docObj.Picture=newBitmap;
                        bitmapUpdated=true;
                    catch Mex %#ok<NASGU>


                        if upgradeActX(this)
                            docObj=this.srcShape.OLEFormat.Object;
                            docObj.Picture=newBitmap;
                            bitmapUpdated=true;
                        else
                            warning(message('Slvnv:rmiref:SLRefWord:UpgradeFailed',this.itemname));
                        end
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
                warning(message('Slvnv:rmiref:SLRefWord:RestoreItemFailed',this.itemname,Mex.message));
                restored=false;
            end
        end

    end

    methods(Static)
        [firstCommand,firstLabel]=splitRefs(shapeObject);
    end

end
