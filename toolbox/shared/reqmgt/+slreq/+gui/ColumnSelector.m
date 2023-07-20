classdef ColumnSelector<handle




    properties

        view;
        unselectedAttrs={};
        selectedAttrs={};
        origSelectedColumns={};
        buttonStatus=struct('Add',false,'Remove',false,'MoveUp',false,'MoveDown',false);
    end


    methods
        function this=ColumnSelector(view)
            this.view=view;
            this.selectedAttrs=this.view.Columns;
            this.origSelectedColumns=this.view.Columns;
            builtinAttrs=this.view.getRoot.getAvailableAttributes();

            try
                dasReqLinkSet=this.view.getRoot.children;
                profAttrs=dasReqLinkSet.getAllProfileProperties();
            catch ME
                profAttrs=[];
            end
            all_attrs=[builtinAttrs,profAttrs];

            this.unselectedAttrs=setdiff(all_attrs,this.selectedAttrs,'stable');
        end

        function dlgstruct=getDialogSchema(this,~)

            inactiveAttrList=struct('Type','listbox','Name',getString(message('Slvnv:slreq:HiddenColumns')),'Tag','inactiveAttrList',...
            'RowSpan',[1,7],'ColSpan',[1,1],'Graphical',1,'MultiSelect',false);
            inactiveAttrList.Entries=this.unselectedAttrs;
            inactiveAttrList.ObjectMethod='inactiveAttrListCallback';
            inactiveAttrList.MethodArgs={'%dialog'};
            inactiveAttrList.ArgDataTypes={'handle'};
            inactiveAttrList.ListDoubleClickCallback=@this.inactiveAttrListDoubleClickCallback;

            activeAttrList=struct('Type','listbox','Name',getString(message('Slvnv:slreq:DisplayColumnNames')),'Tag','activeAttrList',...
            'RowSpan',[1,7],'ColSpan',[3,3],'Graphical',1,'MultiSelect',false);
            activeAttrList.Entries=this.selectedAttrs;
            activeAttrList.ObjectMethod='activeAttrListCallback';
            activeAttrList.MethodArgs={'%dialog'};
            activeAttrList.ArgDataTypes={'handle'};
            activeAttrList.ListDoubleClickCallback=@this.activeAttrListDoubleClickCallback;

            spaceBox=struct('Type','text','Name','','RowSpan',[1,1],'ColSpan',[2,2]);
            addBtn=struct('Type','pushbutton','Name',getString(message('Slvnv:slreq:AddColumn')),'Tag','addToList','RowSpan',[2,2],'ColSpan',[2,2]);
            addBtn.Enabled=this.buttonStatus.Add;
            addBtn.ToolTip=getString(message('Slvnv:slreq:AddColumnTooltip'));
            addBtn.ObjectMethod='addToList';
            addBtn.MethodArgs={'%dialog'};
            addBtn.ArgDataTypes={'handle'};

            removeBtn=struct('Type','pushbutton','Name',getString(message('Slvnv:slreq:RemoveColumn')),'Tag','removeFromList','RowSpan',[3,3],'ColSpan',[2,2]);
            removeBtn.ToolTip=getString(message('Slvnv:slreq:RemoveColumnTooltip'));
            removeBtn.Enabled=this.buttonStatus.Remove;
            removeBtn.ObjectMethod='removeFromList';
            removeBtn.MethodArgs={'%dialog'};
            removeBtn.ArgDataTypes={'handle'};

            moveUpBtn=struct('Type','pushbutton','Name',getString(message('Slvnv:slreq:MoveUp')),'Tag','moveUp','RowSpan',[5,5],'ColSpan',[2,2]);
            moveUpBtn.ToolTip=getString(message('Slvnv:slreq:MoveUpToolTip'));
            moveUpBtn.Enabled=this.buttonStatus.MoveUp;
            moveUpBtn.ObjectMethod='moveUp';
            moveUpBtn.MethodArgs={'%dialog'};
            moveUpBtn.ArgDataTypes={'handle'};

            moveDwBtn=struct('Type','pushbutton','Name',getString(message('Slvnv:slreq:MoveDown')),'Tag','moveDown','RowSpan',[6,6],'ColSpan',[2,2]);
            moveDwBtn.ToolTip=getString(message('Slvnv:slreq:MoveDownToolTip'));
            moveDwBtn.Enabled=this.buttonStatus.MoveDown;
            moveDwBtn.ObjectMethod='moveDown';
            moveDwBtn.MethodArgs={'%dialog'};
            moveDwBtn.ArgDataTypes={'handle'};

            dlgstruct.LayoutGrid=[7,3];
            dlgstruct.RowStretch=[0,0,0,0,0,0,1];
            dlgstruct.DialogTitle=getString(message('Slvnv:slreq:ColumnSelector'));
            dlgstruct.StandaloneButtonSet={'OK','Cancel'};
            dlgstruct.Items={inactiveAttrList,spaceBox,addBtn,removeBtn,moveUpBtn,moveDwBtn,activeAttrList};

            dlgstruct.CloseMethod='dlgCloseMethod';
            dlgstruct.CloseMethodArgs={'%dialog','%closeaction'};
            dlgstruct.CloseMethodArgsDT={'handle','string'};
            dlgstruct.PreApplyMethod='dlgPreApplyMethod';
            dlgstruct.PreApplyArgs={'%dialog'};
            dlgstruct.PreApplyArgsDT={'handle'};

            dlgstruct.Sticky=true;
        end

        function dlgCloseMethod(this,~,actionStr)
            if strcmp(actionStr,'ok')
                appmgr=slreq.app.MainManager.getInstance();

                prevColWidths=this.view.getCurrentColumnWidths();
                addedCols=setdiff(this.selectedAttrs,this.origSelectedColumns);
                removedCols=setdiff(this.origSelectedColumns,this.selectedAttrs);

                this.view.Columns=this.selectedAttrs;

                if contains('Verified',addedCols)
                    this.view.toggleOnVerificationStatus;
                end

                if contains('Implemented',addedCols)
                    this.view.toggleOnImplementationStatus
                end

                if contains('Verified',removedCols)
                    this.view.toggleOffVerificationStatus;
                end

                if contains('Implemented',removedCols)
                    this.view.toggleOffImplementationStatus;
                end

                if isa(this.view,'slreq.gui.ReqSpreadSheet')
                    this.view.update();
                else
                    appmgr.update;
                end
                this.view.restoreColumnWidth(prevColWidths);

                if~isempty(appmgr.getViewSettingsManager)
                    appmgr.getViewSettingsManager.saveViewSettingsFor(this.view);
                end
            end
        end

        function[tf,msg]=dlgPreApplyMethod(this,dlg)%#ok<INUSD>
            tf=true;
            msg='';
            if isempty(this.selectedAttrs)
                tf=false;
                msg=getString(message('Slvnv:slreq:NoColumnSelected'));
            end
        end

        function addToList(this,dlg)
            idx=dlg.getWidgetValue('inactiveAttrList');
            if~isempty(idx)
                moveItems=this.unselectedAttrs(idx+1);
                this.unselectedAttrs(idx+1)=[];
                this.selectedAttrs=[this.selectedAttrs,moveItems];



                if idx==length(this.unselectedAttrs)
                    dlgImd=DAStudio.imDialog.getIMWidgets(dlg);
                    listBoxImd=dlgImd.find('Tag','inactiveAttrList');
                    listBoxImd.select(idx-1);
                end
            end
            dlg.refresh;
        end

        function removeFromList(this,dlg)
            idx=dlg.getWidgetValue('activeAttrList');
            if~isempty(idx)
                removeItem=this.selectedAttrs{idx+1};
                this.selectedAttrs(idx+1)=[];

                this.unselectedAttrs=[this.unselectedAttrs,{removeItem}];


                if idx==length(this.selectedAttrs)
                    dlgImd=DAStudio.imDialog.getIMWidgets(dlg);
                    listBoxImd=dlgImd.find('Tag','activeAttrList');
                    listBoxImd.select(idx-1);
                end
            end
            dlg.refresh;
            dlg.setWidgetValue('inactiveAttrList',length(this.unselectedAttrs)-1)
        end

        function moveUp(this,dlg)
            idx=dlg.getWidgetValue('activeAttrList');
            if~isempty(idx)&&isscalar(idx)&&idx>0
                swapBefore={};
                swapAfter={};
                if idx==1&&length(this.selectedAttrs)==2

                    swapSelected=this.selectedAttrs(2);
                    swapTarget=this.selectedAttrs(1);
                else
                    swapSelected=this.selectedAttrs(idx+1);
                    swapTarget=this.selectedAttrs(idx);
                    if idx==1

                        swapAfter=this.selectedAttrs(idx+2:end);
                    elseif idx==length(this.selectedAttrs)

                        swapBefore=this.selectedAttrs(1:idx-1);
                    else

                        swapAfter=this.selectedAttrs(idx+2:end);
                        swapBefore=this.selectedAttrs(1:idx-1);
                    end
                end
                this.selectedAttrs=[swapBefore,swapSelected,swapTarget,swapAfter];
            end

            dlgImd=DAStudio.imDialog.getIMWidgets(dlg);
            listBoxImd=dlgImd.find('Tag','activeAttrList');
            listBoxImd.select(idx-1);
        end

        function moveDown(this,dlg)
            idx=dlg.getWidgetValue('activeAttrList');
            if~isempty(idx)&&isscalar(idx)&&idx<length(this.selectedAttrs)-1
                swapBefore={};
                swapAfter={};
                if idx==0&&length(this.selectedAttrs)==2

                    swapSelected=this.selectedAttrs(1);
                    swapTarget=this.selectedAttrs(2);
                else
                    swapSelected=this.selectedAttrs(idx+1);
                    swapTarget=this.selectedAttrs(idx+2);
                    if idx==0

                        swapAfter=this.selectedAttrs(idx+3:end);
                    elseif idx==length(this.selectedAttrs)-2

                        swapBefore=this.selectedAttrs(1:idx);
                    else

                        swapAfter=this.selectedAttrs(idx+3:end);
                        swapBefore=this.selectedAttrs(1:idx);
                    end
                end
                this.selectedAttrs=[swapBefore,swapTarget,swapSelected,swapAfter];
            end
            dlgImd=DAStudio.imDialog.getIMWidgets(dlg);
            listBoxImd=dlgImd.find('Tag','activeAttrList');
            listBoxImd.select(idx+1);
        end

        function inactiveAttrListCallback(this,dlg)
            idx=dlg.getWidgetValue('inactiveAttrList');
            this.buttonStatus=struct('Add',false,'Remove',false,'MoveUp',false,'MoveDown',false);
            if~isempty(idx)
                this.buttonStatus.Add=true;
            end
            dlg.refresh;
        end

        function inactiveAttrListDoubleClickCallback(this,dlg,~,idx)
            if~isempty(idx)
                moveItem=this.unselectedAttrs{idx+1};
                this.selectedAttrs{end+1}=moveItem;
                this.unselectedAttrs(idx+1)=[];
                dlg.refresh;


            end
        end

        function activeAttrListCallback(this,dlg)
            idx=dlg.getWidgetValue('activeAttrList');
            this.buttonStatus=struct('Add',false,'Remove',false,'MoveUp',false,'MoveDown',false);
            if~isempty(idx)
                if idx==0
                    this.buttonStatus.Remove=false;
                    this.buttonStatus.MoveUp=false;
                    this.buttonStatus.MoveDown=false;
                else
                    this.buttonStatus.Remove=true;
                    if idx>1
                        this.buttonStatus.MoveUp=true;
                    end
                    if idx<length(this.selectedAttrs)-1
                        this.buttonStatus.MoveDown=true;
                    end
                end

            end
            dlg.refresh;
        end

        function activeAttrListDoubleClickCallback(this,dlg,~,idx)
            if~isempty(idx)&&idx~=0
                moveItem=this.selectedAttrs{idx+1};
                this.unselectedAttrs{end+1}=moveItem;
                this.selectedAttrs(idx+1)=[];
                dlg.refresh;


            end
        end
    end

    methods(Static)
        function show(editor)
            appmgr=slreq.app.MainManager.getInstance();


            if any(strcmp(editor,{'#?#standalone#?#','#?#standalonecontext#?#'}))
                cView=appmgr.requirementsEditor;
            else

                try
                    mdlHandle=get_param(editor,'Handle');

                    cView=appmgr.getCurrentSpreadSheetObject(mdlHandle);
                    if~slreq.utils.isValidView(cView)
                        cView=appmgr.requirementsEditor;
                    end
                catch ex %#ok<NASGU>
                    cView=appmgr.requirementsEditor;
                end
            end
            dlgSource=slreq.gui.ColumnSelector(cView);
            DAStudio.Dialog(dlgSource);

        end
    end
end
