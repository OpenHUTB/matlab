classdef AbstractSoftwareModelingTab<handle

    properties(Access=protected)
        pParentSpreadSheet;
        pChildren;
    end


    methods(Abstract)
        getColumnNames(this);
        getTabName(this);
        refreshChildren(this);
    end


    methods(Access=public)
        function this=AbstractSoftwareModelingTab(spreadSheetObj)
            this.pParentSpreadSheet=spreadSheetObj;
        end


        function requiresUpdate=processChangeReport(this,changeReport)%#ok<INUSD>

            this.refreshChildren();
            requiresUpdate=true;
        end


        function children=getChildren(this,evtData,x,y)%#ok<INUSD>
            if~isvalid(this)||~isvalid(this.getRootArchitecture())
                this.pChildren=[];
            end

            children=this.pChildren;
        end


        function initForCurrentEditor(~)
        end


        function destroyLastChild(this)
            if isempty(this.pChildren)
                return;
            end
            this.pChildren(end).get().destroy();
        end


        function delete(this)
            if~isempty(this.pChildren)
                arrayfun(@(c)c.delete(),this.pChildren);
            end
            this.pChildren=[];
        end


        function arch=getRootArchitecture(this)
            arch=this.pParentSpreadSheet.getRootArchitecture();
        end


        function arch=getBdHandle(this)
            arch=this.pParentSpreadSheet.getBdHandle();
        end


        function ss=getSpreadsheet(this)
            ss=this.pParentSpreadSheet;
        end


        function sel=getCurrentSelection(this)
            sel=this.pParentSpreadSheet.getComponent().imSpreadSheetComponent.getSelection();
            if isempty(sel)||isempty(sel{:})
                sel={};
            end
        end


        function refresh=refreshButtonsOnSelectionChange(~)
            refresh=false;
        end


        function handleSelectionChanged(~)
        end

        function[cols,sortCol,groupCol,ascending]=getColumnInfo(this)

            cols=this.getColumnNames();
            sortCol='';
            groupCol='';
            ascending=false;
        end
    end


    methods(Access=protected)

        function fullPath=getIconPath(~,fname)
            fullPath=swarch.internal.spreadsheet.getIconPath(fname);
        end

    end

end


