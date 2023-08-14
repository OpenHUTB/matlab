classdef WaveformBrowser<...
    controllib.app.databrowser.internal.AbstractDataBrowserComponent



    properties(Access=public)
Data
    end

    properties(Access=protected)
        MenuListeners;
Parent
Canvas
        jcontainer;
    end

    events
renameWaveform
deleteWaveform
duplicateWaveform
    end

    methods

        function this=WaveformBrowser(self,compName,dispName)
            this@controllib.app.databrowser.internal.AbstractDataBrowserComponent(compName,dispName);

            this.Parent=self.View.ListPanel;
            this.Canvas=self;
            [~,TablePanelCONTAINER]=...
            matlab.ui.internal.JavaMigrationTools.suppressedJavaComponent(this.Panel,[0,0,1,1],...
            this.Parent);

            this.jcontainer=TablePanelCONTAINER;

            this.Parent.ResizeFcn=@(src,evt)this.resizeCb();

            this.Editable=false;

            addlistener(this,'DataBrowserSelectionChanged',...
            @(src,evt)this.selectionChangedCleaner());
        end

        function updateUI(this,forceIndSel)

            updateUI@controllib.app.databrowser.internal.AbstractDataBrowserComponent(this);

            if nargin>1&&~isempty(forceIndSel)
                this.setRowSelection(forceIndSel)
            end
        end
    end

    methods(Access=protected)

        function resizeCb(this)
            ppos=getpixelposition(this.Parent);

            pp=5;
            if ppos(3)>pp&&ppos(4)>pp
                this.jcontainer.OuterPosition=[pp,pp,ppos(3)-pp,ppos(4)-pp];
            end
        end


        function label=getLabel(this,idx)
            if isempty(this.Data)
                label={};
                return;
            end

            label=...
            cellstr(string(this.Data(:,1))+' - '+...
            '['+this.Data(:,2)+']'+' - '+...
            '['+this.Data(:,3)+']');
            if nargin>1
                label=label(idx);
            end
        end

        function data=getData(this,idx)
            if isempty(this.Data)
                data=[];
                return;
            end
            data=idx;
            if nargin<1
                data=data(idx);
            end
        end

        function PopupMenu=getPopup(this,row)

            if isempty(row)

                PopupMenu=[];
            else

                JDDButton=com.mathworks.widgets.DropdownButton('Select Here');
                import javax.swing.* java.awt.event.*
                PopupMenu=JDDButton.getPopupMenu;

                Icon=fullfile(matlabroot,...
                'toolbox','phased','phasedapps','+phased','+apps','+internal','+WaveformViewer','Delete_16.png');
                DeleteMenuItem=JMenuItem('Delete',javax.swing.ImageIcon(Icon));
                setName(DeleteMenuItem,'DeleteItem');
                PopupMenu.add(DeleteMenuItem);

                h=handle(DeleteMenuItem,'callbackproperties');
                L=handle.listener(h,'ActionPerformed',...
                @(es,ed)cbDelete(this));
                this.MenuListeners=[this.MenuListeners;L];

                Icon=fullfile(matlabroot,...
                'toolbox','phased','phasedapps','+phased','+apps','+internal','+WaveformViewer','Copy_16.png');
                DuplicateMenuItem=JMenuItem('Duplicate',javax.swing.ImageIcon(Icon));
                setName(DuplicateMenuItem,'DuplicateItem');
                PopupMenu.add(DuplicateMenuItem);

                h=handle(DuplicateMenuItem,'callbackproperties');
                L=handle.listener(h,'ActionPerformed',...
                @(es,ed)cbDuplicate(this));
                this.MenuListeners=[this.MenuListeners;L];

                Icon=fullfile(matlabroot,...
                'toolbox','phased','phasedapps','+phased','+apps','+internal','+WaveformViewer','Rename_16.png');
                RenameMenuItem=JMenuItem('Rename',javax.swing.ImageIcon(Icon));
                setName(RenameMenuItem,'RenameItem');
                if numel(this.getSelectedRows())>1
                    setEnabled(RenameMenuItem,false);
                else
                    setEnabled(RenameMenuItem,true);
                end
                PopupMenu.add(RenameMenuItem);

                h=handle(RenameMenuItem,'callbackproperties');
                L=handle.listener(h,'ActionPerformed',...
                @(es,ed)cbRenameFromContext(this));
                this.MenuListeners=[this.MenuListeners;L];
            end
        end

        function cbOpen(this)


            for ii=1:numel(this.ClickTimer)
                stop(this.ClickTimer(ii));
            end
            delete(this.ClickTimer);
            this.ClickTimer=[];
            this.editAtRow();
        end

        function cbRename(this,oldName,newName,row)
            evt2=phased.apps.internal.WaveformViewer.WaveformRenameEventData(...
            row,newName,oldName);

            this.notify('renameWaveform',evt2);
        end

        function cbDelete(this)
            idx=getSelectedRows(this);
            evt=phased.apps.internal.WaveformViewer.WaveformDeleteEventData(...
            idx);
            this.notify('deleteWaveform',evt);
        end
        function cbDuplicate(this)
            idx=getSelectedRows(this);
            evt=phased.apps.internal.WaveformViewer.WaveformDuplicateEventData(...
            idx);
            this.notify('duplicateWaveform',evt);
        end

        function cbRenameFromContext(this)
            this.editAtRow();
        end

        function editAtRow(this)
            selRow=this.Canvas.SelectIdx-1;
            selCol=0;
            name2=this.Data(selRow+1,1);

            javaMethodEDT('setValueAtWithoutEvent',...
            this.TableModel,...
            java.lang.String(name2),...
            selRow,...
            selCol);
            javaMethodEDT('repaint',this.Table);
            this.Editable=true;
            Success=this.Table.editCellAt(selRow,selCol);
            if Success
                this.Table.changeSelection(selRow,...
                selCol,false,false);
                this.Table.getCellEditor.getComponent.requestFocus();
            end

        end

        function selectionChangedCleaner(this,varargin)
            if this.Editable&&~this.Table.isEditing
                this.Editable=false;
                this.updateUI();
            end
        end
    end

    methods
        function setRowSelection(this,idx)
            if isempty(idx)
                idx=0;
            else
                idx=idx-1;
            end
            this.Table.setRowSelectionInterval(idx,idx);
            rect=this.Table.getCellRect(idx,0,true);
            this.Table.scrollRectToVisible(rect);
        end
    end
end
