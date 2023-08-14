

classdef CreateDataVariantDlg2<handle
    properties
        m_scopeUDI;
        m_meUDI;
        m_variantDicts2;
        m_newConditions;
        m_baseDictName;
        m_listItems;
        m_allVariants;
        m_showExpanded;
        m_dictChoices;
    end


    methods(Access=protected)
        function obj=CreateDataVariantDlg2(scopeUDI,meUDI)
            obj.m_scopeUDI=scopeUDI;
            obj.m_meUDI=meUDI;
            obj.m_variantDicts2={};
            obj.m_showExpanded=false;

            root=obj.m_scopeUDI.getParent;
            ddConn=root.getConnection;

            [~,obj.m_baseDictName,ext]=fileparts(ddConn.filespec);
            obj.m_baseDictName=[obj.m_baseDictName,ext];

            obj.m_listItems={};
            listItems=obj.m_meUDI.getListSelection';
            for entry=listItems
                obj.m_listItems{end+1}=entry.getPropValue('Name');
            end

            obj.m_allVariants={};
            obj.m_dictChoices={obj.m_baseDictName};
            allDicts=ddConn.Dependencies';
            obj.m_allVariants=ddConn.getVariants';
            for refDict=allDicts
                [~,file,ext]=fileparts(refDict{1});
                obj.m_dictChoices{end+1}=[file,ext];
            end

            obj.m_newConditions={};

            if isequal(1,length(obj.m_listItems))
                list=findVariants(obj,obj.m_listItems{1});
                if isempty(list)
                    list={''};
                end
                obj.m_allVariants=setdiff(obj.m_allVariants,list);
            end
        end
    end

    methods

        function schema=getDialogSchema(thisObj)

            blank.Name=' ';
            blank.Type='text';
            blank.ColSpan=[1,1];
            blank.RowSpan=[1,1];

            label.Name='Create variants for ';
            label.Type='text';
            label.ColSpan=[1,2];
            label.RowSpan=[2,2];

            data=buildTable(thisObj);
            itemCount=length(thisObj.m_listItems);
            itemMax=min(itemCount,3);
            for nameIdx=1:itemMax
                if nameIdx>1
                    label.Name=[label.Name,', '];
                end
                label.Name=[label.Name,'''',thisObj.m_listItems{nameIdx},''''];
            end
            if isequal(itemCount,itemMax+1)
                label.Name=[label.Name,', and ','''',thisObj.m_listItems{itemMax+1},''':'];
            elseif itemCount>itemMax
                label.Name=[label.Name,', and ',num2str(itemCount-itemMax),' others:'];
            else
                label.Name=[label.Name,':'];
            end

            table.Tag='refDicts_tag';
            table.Type='table';
            table.Data=data;

            table.ColHeader={'Variant Condition','Dictionary Name'};
            table.ColumnCharacterWidth=[];

            count=length(table.ColHeader);
            for idx=1:count
                colWidth=length(table.ColHeader{idx});
                if isequal(idx,1)
                    colWidth=colWidth+10;
                end
                table.ColumnCharacterWidth=[table.ColumnCharacterWidth,...
                colWidth];
            end

            table.Tag='tblVariants';
            table.Size=size(data);
            table.Grid=1;
            table.HeaderVisibility=[0,1];
            table.RowSpan=[3,3];
            table.ColSpan=[1,3];
            table.DialogRefresh=1;
            table.Editable=1;
            table.ValueChangedCallback=@thisObj.variantTableChangedCallback;
            table.ItemClickedCallback=@thisObj.variantTableButtonCallback;
            table.MinimumSize=500;
            table.LastColumnStretchable=1;




            treeitems={};
            for entry=thisObj.m_listItems
                treeitems{end+1}=entry{1};
                list=findVariants(thisObj,entry{1});
                if isempty(list)
                    list={'--'};
                end
                treeitems{end+1}=list;
            end
            tree.Type='tree';
            tree.TreeItems=treeitems;
            tree.RowSpan=[3,3];
            tree.ColSpan=[4,4];
            tree.Name='Existing variant conditions:';
            tree.ExpandTree=true;

            addButton.Name='Add New';
            addButton.Type='pushbutton';
            addButton.MatlabMethod='Simulink.dd.CreateDataVariantDlg2.refresh';
            addButton.MatlabArgs={'%dialog',false};
            addButton.RowSpan=[4,4];
            addButton.ColSpan=[1,1];

            if thisObj.m_showExpanded
                expandButton.Name='<< Hide Existing Variants';
            else
                expandButton.Name='Show Existing Variants >>';
            end
            expandButton.Type='pushbutton';
            expandButton.MatlabMethod='Simulink.dd.CreateDataVariantDlg2.refresh';
            expandButton.MatlabArgs={'%dialog',true};
            expandButton.RowSpan=[2,2];
            expandButton.ColSpan=[3,3];

            if thisObj.m_showExpanded
                schema.Items={blank,label,table,addButton,expandButton,tree};
                schema.LayoutGrid=[3,5];
            else
                schema.LayoutGrid=[3,4];
                schema.Items={blank,label,table,addButton,expandButton};
            end
            schema.DialogTitle=DAStudio.message('modelexplorer:DAS:ME_CREATE_VARIANT');
            schema.DialogTag='CreateDataVariant';
            schema.StandaloneButtonSet={'OK','Cancel'};

            schema.CloseArgs={'%dialog','%closeaction'};
            schema.CloseCallback='Simulink.dd.CreateDataVariantDlg2.closeCB';

        end

        function data=buildTable(obj)
            data={};
            rowIdx=1;
            [count,~]=size(obj.m_newConditions);
            for idx=1:count

                rowData=obj.m_newConditions(idx,:);

                refDictionary.Enabled=true;
                refDictionary.Editable=false;
                refDictionary.Type='combobox';
                refDictionary.Alignment=6;
                refDictionary.Value=rowData{2};
                refDictionary.Entries=rowData(2);
                if~isequal(refDictionary.Value,obj.m_baseDictName)
                    refDictionary.Entries(end+1)={obj.m_baseDictName};
                end

                dictName=obj.m_baseDictName;


                refDictionary.Entries=[{dictName},obj.m_dictChoices];

                refDictionary.Entries=unique(refDictionary.Entries);

                refDictionary.Entries=[rowData(2),setdiff(refDictionary.Entries,rowData(2))];

                refCondition.Editable=true;
                refCondition.Type='combobox';
                refCondition.Value=rowData{1};
                refCondition.Alignment=6;

                refCondition.Entries=[rowData(1),setdiff(obj.m_allVariants,rowData(1))];

                data{rowIdx,1}=refCondition;
                data{rowIdx,2}=refDictionary;
                rowIdx=rowIdx+1;
            end



            refCondition.Alignment=6;
            refCondition.Editable=true;
            refCondition.Type='combobox';
            refCondition.Value='';
            refCondition.Alignment=6;
            refCondition.Entries={''};
            refCondition.Entries=[refCondition.Entries,obj.m_allVariants];

            refDictionary.Enabled=false;
            refDictionary.Editable=false;
            refDictionary.Type='combobox';
            refDictionary.Alignment=6;
            refDictionary.Entries=obj.m_dictChoices;

            data{rowIdx,1}=refCondition;
            data{rowIdx,2}=refDictionary;

        end

        function list=findVariants(obj,varName)
            root=obj.m_scopeUDI.getParent;
            ddConn=root.getConnection;
            list=ddConn.getVariants(varName)';
            if~isempty(list)
                list=sort(list);
            end
        end

        function variantTableChangedCallback(obj,dialogH,row,col,newVal)
            if isequal(col,0)
                [maxRow,~]=size(obj.m_newConditions);
                if(row+1)>maxRow

                    obj.m_newConditions(end+1,:)={'',obj.m_baseDictName};
                    dialogH.setTableItemEnabled('tblVariants',row,1,true);
                end
                obj.m_newConditions(row+1)={newVal};

                if(row+1)>=maxRow


                end
            elseif isequal(col,1)


                obj.m_newConditions(row+1,2)={dialogH.getTableItemValue('tblVariants',row,col)};
            end
        end

        function variantTableButtonCallback(obj,dialogH,row,col,newVal)
            if isequal(col,0)
                obj.m_newConditions(end+1,:)={'',obj.m_baseDictName};
                dialogH.refresh();
            end
        end

    end

    methods(Static,Access=public)
        function launch(scopeUDI,meUDI)
            obj=Simulink.dd.CreateDataVariantDlg2(scopeUDI,meUDI);

            DAStudio.Dialog(obj,'','DLG_STANDALONE');
        end
    end

    methods(Static)

        function refresh(dialogH,expand)
            if expand
                obj=dialogH.getSource;
                obj.m_showExpanded=~obj.m_showExpanded;
            end
            dialogH.refresh();
            if expand
                dialogH.resetSize();
            end
        end

        function closeCB(dialogH,closeAction)
            if isequal(closeAction,'ok')
                obj=dialogH.getSource;
                [max,~]=size(obj.m_newConditions);
                root=obj.m_scopeUDI.getParent;
                ddConn=root.getConnection;
                ed=DAStudio.EventDispatcher;
                broadcastEvent(ed,'MESleepEvent');
                cleanupWake=onCleanup(@()broadcastEvent(ed,'MEWakeEvent'));
                for idx=1:max
                    rowData=obj.m_newConditions(idx,:);
                    variantDictionary=rowData{2};
                    variantCondition=rowData{1};
                    for entry=obj.m_listItems

                        baseEntryID=ddConn.getEntryID(['Global.',entry{1}]);
                        Simulink.dd.createDataVariant(ddConn,variantDictionary,'Global',baseEntryID,entry{1},variantCondition);
                    end
                end


            end
        end

    end

end
