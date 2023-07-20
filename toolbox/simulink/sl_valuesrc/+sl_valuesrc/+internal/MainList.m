classdef MainList<handle




    properties(Access=private)
        mListCmpt;
        mData;
        mSrcObj;
        mSelected;
    end


    methods(Static,Access=public)

    end


    methods(Access=public)
        function this=MainList(cmptList)
            this.mListCmpt=cmptList;
            this.mSrcObj=[];
            this.mSelected={};

            this.mListCmpt.setTitleViewSource(this);
        end

        function dlgStruct=getDialogSchema(thisObj,arg1)
            contentsTitle.Type='text';
            contentsTitle.Tag='contents';
            contentsName='';
            if~isempty(thisObj.mSrcObj)
                contentsName=thisObj.mSrcObj.getDisplayLabel();
            end
            contentsTitle.Name=message('sl_valuesrc:messages:ContentsOf',contentsName).getString();
            contentsTitle.RowSpan=[1,1];
            contentsTitle.ColSpan=[1,1];

            filterWidget.Type='spreadsheetfilter';
            filterWidget.Tag='spreadsheetfilter';
            filterWidget.PlaceholderText=DAStudio.message('Simulink:studio:DataView_default_filter');
            filterWidget.Clearable=true;
            filterWidget.RowSpan=[1,1];
            filterWidget.ColSpan=[3,3];

            dlgStruct.LayoutGrid=[1,3];
            dlgStruct.ColStretch=[0,1,0];
            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.Items={contentsTitle,filterWidget};
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end

        function children=getChildren(thisObj)
            children=[];
        end

        function doSourceChange(thisObj,srcObj,selection)
            thisObj.mSelected={};
            sortCol='';
            if isempty(selection)
                thisObj.mSrcObj=[];
                src=thisObj;
                cols={''};
            else
                thisObj.mSrcObj=selection{1};
                try
                    thisObj.mSrcObj.setListObj(thisObj);
                catch ME
                end
                src=thisObj.mSrcObj.getListSource();
                if~isempty(src)
                    [cols,sortCol]=src.getColumns();
                else
                    src=thisObj;
                    cols={''};
                end
            end
            if isvalid(thisObj.mListCmpt)
                thisObj.mListCmpt.setSource(src);
                thisObj.mListCmpt.setColumns(cols,sortCol,'',true);
                thisObj.mListCmpt.updateTitleView();
                thisObj.mListCmpt.update();
            end
        end

        function selectionChanged=setSelected(thisObj,selection)
            if isequal(selection,thisObj.mSelected)||...
                (isempty(selection)&&isempty(thisObj.mSelected))
                selectionChanged=false;
            else
                selectionChanged=true;
                thisObj.mSelected=selection;
            end
        end

        function doRemoveEntry(thisObj)
            if~isempty(thisObj.mSelected)&&~isempty(thisObj.mSrcObj)
                thisObj.mSrcObj.doRemoveEntry(thisObj.mSelected);
                thisObj.mListCmpt.update();
            end
        end

        function refresh(thisObj,full)
            thisObj.mListCmpt.update();
            if nargin>1&&isequal(full,true)&&...
                ~isempty(thisObj.mSrcObj.getListSource())
                thisObj.mListCmpt.updateTitleView();
            end
        end
    end


    methods(Access=private)
    end
end
