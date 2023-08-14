

classdef CreateDataVariantDlg3<handle
    properties
        m_ddConn;
        m_scope;
        m_listItems;
        m_allVariants;
        m_children;
        m_variedProps;
    end


    methods(Access=protected)
        function obj=CreateDataVariantDlg3(scopeUDI,meUDI,variedProp)
            if isempty(variedProp)
                obj.m_variedProps={'Value'};
            else
                obj.m_variedProps={variedProp};
            end

            root=scopeUDI.getParent;
            ddConn=root.getConnection;
            obj.m_ddConn=ddConn;

            obj.m_scope=scopeUDI.getNodeName();
            if isequal(obj.m_scope,'Design')
                obj.m_scope='Global';
            end

            obj.m_listItems={};
            listItems=meUDI.getListSelection';
            for entry=listItems
                obj.m_listItems{end+1}=entry.getPropValue('Name');
            end

            obj.m_allVariants=ddConn.getVariants';
        end
    end

    methods

        function schema=getDialogSchema(thisObj)

            blank.Name=' ';
            blank.Type='text';
            blank.ColSpan=[2,3];
            blank.RowSpan=[1,1];

            condition.Name='Condition';
            condition.Tag='Condition';
            condition.ColSpan=[1,1];
            condition.RowSpan=[2,2];
            condition.Editable=true;
            condition.Type='combobox';
            condition.Entries=thisObj.m_allVariants;
            if isempty(condition.Entries)
                condition.Value='condition==1';
            else
                condition.Value=condition.Entries{1};
            end

            spreadsheet.Type='spreadsheet';
            spreadsheet.Columns=[{'Name'},thisObj.m_variedProps];
            spreadsheet.RowSpan=[3,3];
            spreadsheet.ColSpan=[1,4];

            schema.LayoutGrid=[3,4];

            schema.Items={blank,condition,spreadsheet};

            schema.DialogTitle=DAStudio.message('modelexplorer:DAS:ME_CREATE_VARIANT');
            schema.DialogTag='CreateDataVariant';
            schema.StandaloneButtonSet={'OK','Cancel'};

            schema.Sticky=true;
            schema.CloseArgs={'%dialog','%closeaction'};
            schema.CloseCallback='Simulink.dd.CreateDataVariantDlg3.closeCB';

        end

        function children=getChildren(thisObj)
            thisObj.m_children={};

            for entry=thisObj.m_listItems
                baseEntryID=thisObj.m_ddConn.getEntryID([thisObj.m_scope,'.',entry{1}]);
                entryInfo=thisObj.m_ddConn.getEntryInfo(baseEntryID);

                newVariant=Simulink.dd.DataVariant(thisObj.m_ddConn.filespec,baseEntryID,'');
                row=Simulink.DDSpreadsheetRow;
                row.DataSource=entryInfo.DataSource;
                row.ddEntry=newVariant;
                row.baseEntryID=baseEntryID;
                row.entryName=entry{1};
                row.entryScope=thisObj.m_scope;

                row.entryID=0;
                thisObj.m_children{end+1}=row;
            end

            children=thisObj.m_children;
        end


        function list=findVariants(obj,varName)
            list=obj.m_ddConn.getVariants(varName)';

            if~isempty(list)
                list=sort(list);
            end
        end


    end

    methods(Static,Access=public)
        function launch(scopeUDI,meUDI,variedProp)
            obj=Simulink.dd.CreateDataVariantDlg3(scopeUDI,meUDI,variedProp);

            DAStudio.Dialog(obj,'','DLG_STANDALONE');
        end
    end

    methods(Static)

        function closeCB(dialogH,closeAction)
            obj=dialogH.getSource;
            if isequal(closeAction,'ok')
                ed=DAStudio.EventDispatcher;
                broadcastEvent(ed,'MESleepEvent');
                cleanupWake=onCleanup(@()broadcastEvent(ed,'MEWakeEvent'));

                variantCondition=dialogH.getWidgetValue('Condition');
                for row=obj.m_children;
                    item=row{1};
                    dd=Simulink.dd.open(item.DataSource);
                    try




                        dd.insertEntry(obj.m_scope,item.entryName,item.ddEntry,variantCondition);
                    catch E
                    end
                end
            end
            obj.m_ddConn.close();
        end

    end

end
