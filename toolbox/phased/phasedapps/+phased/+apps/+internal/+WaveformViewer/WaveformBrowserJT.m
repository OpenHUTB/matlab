classdef WaveformBrowserJT<matlab.ui.internal.databrowser.TableDataBrowser



    properties(Access=public)
Data
getSelectedRows
    end

    properties(Access=protected)
MenuDelete
MenuDuplicate
Parent
Canvas
    end

    events
DataBrowserSelectionChanged
renameWaveform
deleteWaveform
duplicateWaveform
    end

    methods

        function this=WaveformBrowserJT(self,compName,dispName)
            this=this@matlab.ui.internal.databrowser.TableDataBrowser(compName,dispName);
            this.Parent=self.View.ListPanel;
            this.Canvas=self;
            this.SingleRowSelection=false;
            this.Table.Multiselect='on';
            buildUI(this);
            connectUI(this);
        end

        function updateUI(this)
            if~isempty(this.Data)
                this.Table.Data=this.Data;
                if~(this.Canvas.SelectIdx>size(this.Data,1))
                    selectRow(this,this.Canvas.SelectIdx);
                end
            end
            this.Table.Data=this.Data;
        end

        function selectRow(this,index)
            rows=index;
            this.Table.Selection=rows;
            SelectionCallback(this,rows);

            sData=struct('Rows',rows);
            CustomEventData=matlab.ui.internal.databrowser.GenericEventData(sData);
            notify(this,'SelectionChanged',CustomEventData)
        end
    end


    methods(Access=protected)

        function buildUI(this)

            this.GenerateValidVarName=false;

            this.Table.ColumnName={'Waveform Name','Waveform Type','Processing Type'};
            this.Table.ColumnEditable=[true,false,false];
            this.Table.ColumnWidth={'auto','auto','auto'};
            this.NameColumnIndex=1;
            this.Table.ContextMenu=uicontextmenu('parent',this.Figure);
            this.Table.ContextMenu.Tag=strcat('cmn',this.Name);
            this.MenuDelete=uimenu(this.Table.ContextMenu,'label','Delete','callback',@(src,data)cbDelete(this));
            this.MenuDuplicate=uimenu(this.Table.ContextMenu,'label','Duplicate','callback',@(src,data)cbDuplicate(this));

            this.setPreferredWidth(400);
        end

        function connectUI(this)
            lis=addlistener(this.Table.ContextMenu,'ContextMenuOpening',@(src,data)updateContextMenu(this,data));
            registerUIListeners(this,lis,'ContextMenuOpeningListener');
        end


        function cbDelete(this)
            idx=this.getSelectedRows;
            evt=phased.apps.internal.WaveformViewer.WaveformDeleteEventData(...
            idx);
            this.notify('deleteWaveform',evt);
        end
        function cbDuplicate(this)
            idx=this.getSelectedRows;
            evt=phased.apps.internal.WaveformViewer.WaveformDuplicateEventData(...
            idx);
            this.notify('duplicateWaveform',evt);
        end

        function SelectionCallback(this,rows)
            this.getSelectedRows=rows;
        end

        function RenameCallback(this,row,oldName,newName)
            this.Data{row}=newName;
            this.Table.Data{row}=newName;
            evt2=phased.apps.internal.WaveformViewer.WaveformRenameEventData(...
            row,newName,oldName);

            this.notify('renameWaveform',evt2);
        end

        function updateContextMenu(this,data)

            selection=data.ContextObjectItem;
            if strcmpi(selection.Region,'cell')

                if isempty(selection.Index)

                    this.Table.Selection=[];

                    this.MenuDelete.Visible=false;
                    this.MenuDuplicate.Visible=false;
                else

                    if~any(this.Table.Selection==selection.Index(1))
                        this.Table.Selection=selection.Index(1);
                    end

                    this.MenuDelete.Visible=true;
                    this.MenuDuplicate.Visible=true;
                end
            else

                this.MenuDelete.Visible=false;
                this.MenuDuplicate.Visible=false;
            end
        end
    end
end
