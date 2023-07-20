


classdef OutdatedProfileDialog<handle
    properties(Constant)
        OutdatedProfileDialogTag='ReqToolBox_OutdatedProfileDialog';
    end

    properties
filepath
profChecker
profNs
mdl
callbackHandler
cbinfo
    end
    methods
        function obj=OutdatedProfileDialog(filepath,profChecker,profNs,mdl,callbackHandler,cbinfo)
            obj.filepath=filepath;
            obj.mdl=mdl;
            obj.callbackHandler=callbackHandler;
            obj.profChecker=profChecker;
            obj.profNs=profNs;
            obj.cbinfo=cbinfo;
        end
        function dlg=getDialogSchema(obj)
            [~,fName,fExt]=fileparts(obj.filepath);
            desc=message('Slvnv:slreq:ReqSetProfileOutdated',[fName,fExt]).getString();
            panel=struct('Type','panel','LayoutGrid',[3,1],'RowStretch',[0,0,1]);

            instructions=struct('Type','text','Name',desc,...
            'RowSpan',[1,1],'ColSpan',[1,1]);

            deleteTxt.Type='text';
            deleteTxt.Name=message('Slvnv:slreq:ResolveOutdatedProfile').getString();
            deleteTxt.RowSpan=[1,1];
            deleteTxt.ColSpan=[1,4];

            deleteBtn.Type='pushbutton';
            deleteBtn.Name='Fix';
            deleteBtn.RowSpan=[1,1];
            deleteBtn.ColSpan=[5,5];
            deleteBtn.ObjectMethod='fixOutdatedProfile';
            deleteBtn.MethodArgs={'%dialog'};
            deleteBtn.ArgDataTypes={'handle'};

            closeText.Type='text';
            closeText.Name=message('Slvnv:slreq:FindOrignialProfile').getString();
            closeText.RowSpan=[4,4];
            closeText.ColSpan=[1,4];

            closeBtn.Type='pushbutton';
            closeBtn.Name='Fix';
            closeBtn.RowSpan=[4,4];
            closeBtn.ColSpan=[5,5];
            closeBtn.ObjectMethod='closeReqSet';
            closeBtn.MethodArgs={'%dialog'};
            closeBtn.ArgDataTypes={'handle'};

            detailPanel=obj.getDetails();

            actions.Type='group';
            actions.Name='Suggested Actions';
            actions.Items={deleteTxt,deleteBtn,detailPanel,closeText,closeBtn};
            actions.LayoutGrid=[3,4];
            actions.RowSpan=[2,1];
            actions.ColSpan=[1,1];

            helpButton.Name=getString(message('Slvnv:slreq:ExportDialogHelp'));
            helpButton.Tag='ExportDlg_Help';
            helpButton.Type='pushbutton';
            helpButton.RowSpan=[1,1];
            helpButton.ColSpan=[5,5];
            helpButton.ObjectMethod='ExportDlg_Help_callback';
            helpButton.MethodArgs={'%dialog'};
            helpButton.ArgDataTypes={'handle'};
            helpButton.Enabled=true;

            cancelButton.Name=getString(message('Slvnv:slreq_import:Cancel'));
            cancelButton.Tag='closeReqSet';
            cancelButton.Type='pushbutton';
            cancelButton.RowSpan=[1,1];
            cancelButton.ColSpan=[1,4];
            cancelButton.ObjectMethod='closeReqSet';
            cancelButton.MethodArgs={'%dialog'};
            cancelButton.ArgDataTypes={'handle'};
            cancelButton.Enabled=true;



            stdBtns.Type='panel';
            stdBtns.Name='';
            stdBtns.LayoutGrid=[1,5];
            stdBtns.Items={helpButton,cancelButton};


            panel.Items={instructions,actions};
            dlg.DialogTitle=getString(message('Slvnv:slreq:OutdatedProfileDialogTitle'));
            dlg.DialogTag=slreq.gui.OutdatedProfileDialog.OutdatedProfileDialogTag;
            dlg.StandaloneButtonSet=stdBtns;
            dlg.Items={panel};

        end

        function[panel,indIncr]=arrayPanel(~,arrayName,arr,rowIndex)
            if numel(arr)==0
                panel.Type='text';
                panel.Name=['      ',arrayName,'(0)'];
                panel.RowSpan=[rowIndex,rowIndex];
                panel.ColSpan=[1,4];
                indIncr=1;
            else
                numStr=num2str(numel(arr));
                panel=struct('Type','togglepanel','Name',[arrayName,'(',numStr,')']);
                panel.Items={};
                indIncr=1;
                for i=1:numel(arr)
                    item.Type='text';
                    item.Name=['     ',arr{i}];
                    item.RowSpan=[rowIndex+i,rowIndex+i];
                    item.ColSpan=[1,4];
                    panel.Items{end+1}=item;
                    indIncr=indIncr+1;
                end
                panel.RowSpan=[rowIndex,rowIndex+indIncr-1];
                panel.ColSpan=[1,4];
            end
        end

        function detailPanel=getDetails(this)

            ind=1;
            missingProfs=this.profChecker.p_ProfileChangeReport.p_MissingProfiles.toArray();
            [profsMissing,indIncr]=this.arrayPanel('Missing Profiles',missingProfs,ind);

            ind=ind+indIncr;
            deletedPrototypes=this.profChecker.p_ProfileChangeReport.p_DeletedPrototypes.toArray();
            [prototypesDeleted,indIncr]=this.arrayPanel('Deleted Prototypes',deletedPrototypes,ind);

            ind=ind+indIncr;
            deletedProperties=this.profChecker.p_ProfileChangeReport.p_DeletedProperties.toArray();
            [propertiesDeleted,indIncr]=this.arrayPanel('Deleted Properties',deletedProperties,ind);

            ind=ind+indIncr;
            addedPrototypes=this.profChecker.p_ProfileChangeReport.p_AddedPrototypes.toArray();
            [prototypesAdded,indIncr]=this.arrayPanel('Added Prototypes',addedPrototypes,ind);

            ind=ind+indIncr;
            addedProperties=this.profChecker.p_ProfileChangeReport.p_AddedProperties.toArray();
            [propertiesAdded,indIncr]=this.arrayPanel('Added Properties',addedProperties,ind);

            ind=ind+indIncr;
            renamedPrototypes=this.profChecker.p_ProfileChangeReport.p_RenamedPrototypes.toArray();
            [prototypesRenamed,indIncr]=this.arrayPanel('Renamed Prototypes',renamedPrototypes,ind);

            ind=ind+indIncr;
            renamedProperties=this.profChecker.p_ProfileChangeReport.p_RenamedProperties.toArray();
            [propertiesRenamed,indIncr]=this.arrayPanel('Renamed Properties',renamedProperties,ind);

            ind=ind+indIncr;
            prototypeParentChanged=this.profChecker.p_ProfileChangeReport.p_PrototypeParentChanged.toArray();
            [parentChanged,~]=this.arrayPanel('Prototype Parent Changed',prototypeParentChanged,ind);

            detailPanel=struct('Type','togglepanel','Name','Details','LayoutGrid',[8,1],'RowStretch',[0,0,0,0,0,0,0,1]);
            detailPanel.Items={profsMissing,prototypesDeleted,propertiesDeleted,prototypesAdded,propertiesAdded,prototypesRenamed,propertiesRenamed,parentChanged};

        end


        function fixOutdatedProfile(this,dlg)
            [~,~,fExt]=fileparts(this.filepath);
            if strcmp(fExt,'.slreqx')
                this.callbackHandler.resolveProfileShowReqSet(this.filepath,this.profChecker,this.profNs,this.mdl,this.cbinfo);
            elseif strcmp(fExt,'.slmx')
                this.callbackHandler.resolveProfileLoadLinkSet();
            end
            dlg.delete();
        end
        function closeReqSet(~,dlg)
            dlg.delete();
        end

        function ExportDlg_Help_callback(~,~)
            helpview(fullfile(docroot,'slrequirements','helptargets.map'),'OutdatedProfile');
        end
    end

    methods(Static)
        function closeOutdatedProfileDialog()
            dlg=findDDGByTag(slreq.gui.OutdatedProfileDialog.OutdatedProfileDialogTag);
            if~isempty(dlg)
                dlg.delete;
            end
        end
    end
end