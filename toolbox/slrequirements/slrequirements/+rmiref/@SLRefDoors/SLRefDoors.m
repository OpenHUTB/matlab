


classdef SLRefDoors<rmiref.SLReference

    properties
        moduleName='';
        isLink=false;
    end

    methods

        function reference=SLRefDoors(module)
            reference=reference@rmiref.SLReference('doors');
            reference.moduleName=module;
        end

        function assignDocData(this)
            [this.docText,this.docId]=rmiref.SLRefDoors.getAnchorInfo(this);
        end

        function ok=assignCmdData(this,varargin)
            if~isempty(varargin)

                this.label=varargin{3};
                this.cmd=varargin{4};
                this.model=strrep(varargin{1},'%5C%5C','/');
                this.slObj=varargin{2};
                this.command=[this.cmd,'(''',this.model,''',''',this.slObj,''');'];
                ok=true;
            else
                label=rmidoors.getObjAttribute(this.docname,this.itemname,'Object Text');
                if strncmp(label,'[Simulink reference: ',length('[Simulink reference: '))
                    this.label=label(length('[Simulink reference: ')+1:end-1);
                elseif strncmp(label,'[MATLAB reference: ',length('[MATLAB reference: '))
                    this.label=label(length('[MATLAB reference: ')+1:end-1);
                else
                    this.label=label;
                end
                this.command=rmidoors.getObjAttribute(this.docname,this.itemname,'DmiSlNavCmd');
                [this.cmd,args]=rmiref.SLReference.parseCommand(this.command);
                if any(strcmp(this.cmd,{'rmiobjnavigate','rmicodenavigate'}))
                    this.model=args{1};
                    this.slObj=args{2};


                    if length(args)>3||(length(args)==3&&ischar(args{3}))
                        ok=this.splitGroupReference();
                    else
                        ok=true;
                    end
                elseif strcmp(this.cmd,rmiref.DocChecker.FIX_CALLBACK)
                    try
                        data=rmidoors.getObjAttribute(this.docname,this.itemname,'Object Short Text');
                        skip=0;
                    catch Mex %#ok<NASGU>
                        data=rmidoors.getObjAttribute(this.docname,this.itemname,'DmiSlNavCmd');
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
        end

        function result=splitGroupReference(this)
            reply=questdlg({...
            getString(message('Slvnv:rmiref:SLRefDoors:DetectedMultipleRefButton')),...
            getString(message('Slvnv:rmiref:SLRefDoors:YouNeedToSplitThisReference')),...
            ' ',...
            getString(message('Slvnv:rmiref:SLRefDoors:SplitNowQuest'))},...
            getString(message('Slvnv:rmiref:SLRefDoors:GroupReferenceIn',this.moduleName)),...
            getString(message('Slvnv:rmiref:SLRefDoors:Yes')),...
            getString(message('Slvnv:rmiref:SLRefDoors:No')),...
            getString(message('Slvnv:rmiref:SLRefDoors:Yes')));
            if isempty(reply)||strcmp(reply,getString(message('Slvnv:rmiref:SLRefDoors:Yes')))
                [firstCommand,firstLabel]=rmiref.SLRefDoors.splitRefs(this);
                this.command=firstCommand;
                this.label=firstLabel;
                result=true;
            else
                result=false;
            end
        end

        function viewInDocument(this)
            rmidoors.show(this.docname,this.docId);
        end

        function deleted=deleteSrc(this)
            if this.isLink
                fprintf('TODO: deleteSrc() is not yet supported for External Link references\n');
                deleted=false;
                return;
            end
            try
                rmidoors.removeObject(this.docname,this.itemname);
                deleted=true;
            catch Mex %#ok<NASGU>
                deleted=false;
            end
        end

        function labelUpdated=updateLabel(this,newLabel)
            if this.isLink
                fprintf('TODO: updateLabel() is not yet supported for External Link references\n');
                labelUpdated=false;
                return;
            end
            if isempty(strfind(newLabel,'Simulink reference:'))
                newLabel=['[Simulink reference: ',newLabel,']'];
            end
            try
                rmidoors.setObjAttribute(this.docname,this.itemname,'Object Text',newLabel);
                labelUpdated=true;
            catch Mex %#ok<NASGU>
                warning(message('Slvnv:rmiref:SLRefDoors:LabelUpdateFailed',this.itemname));
                labelUpdated=false;
            end
        end

        function dataUpdated=updateData(this,newData)
            if this.isLink
                fprintf('TODO: updateData() is not yet supported for External Link references\n');
                dataUpdated=false;
                return;
            end
            try
                rmidoors.setObjAttribute(this.docname,this.itemname,'Object Short Text',newData);
                dataUpdated=true;
            catch Mex %#ok<NASGU>
                warning(message('Slvnv:rmiref:SLRefDoors:DataUpdateFailed',this.itemname));
                dataUpdated=false;
            end
        end

        function commandUpdated=updateCommand(this,newCommand)
            if this.isLink
                fprintf('TODO: updateCommand() is not yet supported for External Link references\n');
                commandUpdated=false;
                return;
            end
            try
                rmidoors.setObjAttribute(this.docname,this.itemname,'DmiSlNavCmd',newCommand);
                commandUpdated=true;
            catch Mex %#ok<NASGU>
                warning(message('Slvnv:rmiref:SLRefDoors:CommandUpdateFailed',this.itemname));
                commandUpdated=false;
            end
        end

        function bitmapUpdated=updateBitmap(this,newIcon)
            if this.isLink


                fprintf(getString(message('Slvnv:rmiref:SLRefDoors:BrokenLinkDetected',this.itemname,this.docname)));
            else
                newBitmap=rmiref.SLReference.fullIconPathName(newIcon);
                try
                    rmidoors.setObjAttribute(this.docname,this.itemname,'picture',newBitmap);
                    bitmapUpdated=true;
                catch Mex %#ok<NASGU>
                    warning(message('Slvnv:rmiref:SLRefDoors:BitmapUpdateFailed',this.itemname,this.docname));
                    bitmapUpdated=false;
                end
            end
        end

        function restored=restore(this)
            try
                [origCommand,origLabel]=rmiref.SLReference.parseData(this.refData);
                if this.updateLabel(origLabel)
                    this.label=origLabel;
                end
                if this.updateCommand(origCommand)
                    this.command=origCommand;
                end
                this.updateBitmap('normal');
                restored=true;
            catch Mex
                warning(message('Slvnv:rmiref:SLRefDoors:RestoreItemFailed',this.itemname,this.docname,Mex.message));
                restored=false;
            end
        end

    end

    methods(Static)
        [firstCommand,firstLabel]=splitRefs(refObj)
        [docTxt,bookMarkId]=getAnchorInfo(SlRefDoors)
    end

end
