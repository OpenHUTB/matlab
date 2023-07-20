


classdef Spreadsheet<handle
    properties(SetAccess=private,GetAccess=public)
        m_Children;
        m_DialogSource;
        m_PortSpecHandle;
        m_hasUnappliedChanges;
        m_ChangedRows;
    end


    methods
        function aChildren=getChildren(this)
            aChildren=this.m_Children;
        end
    end


    methods
        function this=Spreadsheet(portSpec)
            import SLCC.blocks.ui.PortSpec.*;
            import SLCC.blocks.*;

            this.m_PortSpecHandle=portSpec;
            this.m_hasUnappliedChanges=false;
            this.m_Children=SpreadsheetRow.empty;
            this.m_ChangedRows=SpreadsheetRow.empty;
        end

        function setDialogSrc(this,hDlgSrc)
            this.m_DialogSource=hDlgSrc;
        end

        function hDlgSrc=getDialogSrc(this)
            hDlgSrc=this.m_DialogSource;
        end

        function updateSpreadsheet(this,portStruct,portHeuristicStruct)









            import SLCC.blocks.ui.PortSpec.*;
            numChildNew=numel(portStruct);
            numChildOld=numel(this.m_Children);
            numToRefresh=min(numChildOld,numChildNew);
            constructStartIdx=1;



            if~isempty(this.m_Children)
                for n=1:numToRefresh
                    this.m_Children(n).refreshFromPortStruct(portStruct(n),...
                    portHeuristicStruct(n));
                end


                delete(this.m_Children((numChildNew+1):end));
                this.m_Children((numChildNew+1):end)=[];
                constructStartIdx=numToRefresh+constructStartIdx;
            end



            for n=constructStartIdx:numChildNew
                this.m_Children(end+1)=SpreadsheetRow.constructFromPortStruct(...
                this,portStruct(n),portHeuristicStruct(n));
            end

            this.updateSSWidget();
        end

        function updateSSWidget(this)
            if isa(this.m_DialogSource,'Simulink.SLDialogSource')
                dlgs=DAStudio.ToolRoot.getOpenDialogs(this.m_DialogSource);

                for n=1:numel(dlgs)
                    d=dlgs(n);
                    if~isempty(d)
                        ssWidget=d.getWidgetInterface('slcc_portSpec_spreadsheet_tag');
                        if~isempty(ssWidget)
                            ssWidget.update(true);
                        end
                    end
                end
            end
        end

        function notifyRowChange(this,aSSRow)
            this.m_hasUnappliedChanges=true;

            hBlk=get(this.getDialogSrc().getBlock(),'Handle');
            hMdl=bdroot(hBlk);
            set_param(hMdl,'Dirty','on');


            if isempty(this.m_ChangedRows)
                this.m_ChangedRows=aSSRow;
            elseif~ismember(aSSRow,this.m_ChangedRows)
                this.m_ChangedRows(end+1)=aSSRow;
            end
        end

        function updateStruct=getUnappliedChanges(this)
            if this.m_hasUnappliedChanges
                updateStruct=this.m_ChangedRows(1).getDataStruct();
                for n=2:numel(this.m_ChangedRows)
                    updateStruct(end+1)=this.m_ChangedRows(n).getDataStruct();%#ok<AGROW>
                end
            else
                updateStruct=struct.empty;
            end
        end

        function clearUnappliedChanges(this)
            import SLCC.blocks.ui.PortSpec.*;
            this.m_ChangedRows=SpreadsheetRow.empty;
            this.m_hasUnappliedChanges=false;
        end

    end
end

