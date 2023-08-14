

classdef CreateDataVariantDlg<handle
    properties
        m_scopeUDI;
        m_meUDI;
        m_variantDicts;
        m_createInVariant;
    end


    methods(Access=protected)
        function obj=CreateDataVariantDlg(scopeUDI,meUDI)
            obj.m_scopeUDI=scopeUDI;
            obj.m_meUDI=meUDI;
            obj.m_variantDicts={};


            root=obj.m_scopeUDI.getParent;
            ddConn=root.getConnection;
            allDicts=ddConn.Dependencies';
            for refDict=allDicts
                tmpConn=Simulink.dd.open(refDict{1});
                [~,dictName,~]=fileparts(refDict{1});
                if~isempty(tmpConn.getVariant())
                    obj.m_variantDicts=[obj.m_variantDicts,refDict{1}];
                end
                tmpConn.close;
            end
            obj.m_createInVariant=ones(1,length(obj.m_variantDicts));
        end
    end

    methods

        function schema=getDialogSchema(thisObj)

            blank.Name=' ';
            blank.Type='text';
            blank.ColSpan=[1,1];
            blank.RowSpan=[1,1];

            instruct.Name='Select the variant dictionaries in which the variants should be created.';
            instruct.Type='text';
            instruct.ColSpan=[1,2];
            instruct.RowSpan=[2,2];

            data=buildTable(thisObj);

            table.Name='Referenced Variant Dictionaries:';
            table.Tag='refDicts_tag';
            table.Type='table';
            table.Data=data;

            table.ColHeader={'Use','Dictionary Name','Variant Condition'};
            table.ColumnCharacterWidth=[];

            count=length(table.ColHeader);
            for idx=1:count
                colWidth=length(table.ColHeader{idx});
                if isequal(idx,2)
                    colWidth=colWidth+10;
                end
                table.ColumnCharacterWidth=[table.ColumnCharacterWidth,...
                colWidth];
            end

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

            schema.Items={blank,instruct,table};
            schema.LayoutGrid=[3,3];
            schema.DialogTitle=DAStudio.message('modelexplorer:DAS:ME_CREATE_VARIANT');
            schema.DialogTag='CreateDataVariant';
            schema.StandaloneButtonSet={'OK','Cancel'};

            schema.CloseArgs={'%dialog','%closeaction'};
            schema.CloseCallback='Simulink.dd.CreateDataVariantDlg.closeCB';

        end

        function data=buildTable(obj)
            data={};
            allDicts=obj.m_variantDicts;
            rowIdx=1;
            for refDict=allDicts
                rowData={};
                tmpConn=Simulink.dd.open(refDict{1});
                [~,dictName,~]=fileparts(refDict{1});
                variantCond=tmpConn.getVariant();
                tmpConn.close;

                useForVariant.Type='checkbox';
                useForVariant.Alignment=6;
                useForVariant.Value=obj.m_createInVariant(rowIdx);

                refDictionary.Name=dictName;

                refDictionary.Type='text';
                refDictionary.Alignment=6;


                if isempty(variantCond)
                    refCondition.Editable=true;
                    refCondition.Type='edit';

                else
                    refCondition.Name=variantCond;
                    refCondition.Type='text';
                end
                refCondition.Alignment=6;

                data{rowIdx,1}=useForVariant;
                data{rowIdx,2}=refDictionary;
                data{rowIdx,3}=refCondition;
                rowIdx=rowIdx+1;
            end

            useForVariant.Type='checkbox';
            useForVariant.Alignment=6;
            useForVariant.Enabled=true;
            useForVariant.Value=false;

            refDictionary.Name='Add new...';

            refDictionary.Type='pushbutton';
            refDictionary.Alignment=6;


            refCondition.Editable=true;
            refCondition.Type='edit';
            refCondition.Alignment=6;


            data{rowIdx,1}=useForVariant;
            data{rowIdx,2}=refDictionary;
            data{rowIdx,3}=refCondition;

        end

        function variantTableChangedCallback(obj,dialogH,row,col,newVal)
            if isequal(col,0)
                if(row<=length(obj.m_createInVariant))
                    obj.m_createInVariant(row+1)=newVal;
                end
            end
        end

        function variantTableButtonCallback(obj,dialogH,row,col,newVal)
            if isequal(col,1)
                root=obj.m_scopeUDI.getParent;
                ddConn=root.getConnection;
                ddFilePath=slprivate('createVariantDict',ddConn,false);
                if~isempty(ddFilePath)
                    obj.m_variantDicts{end+1}=ddFilePath;
                    obj.m_createInVariant(end+1)=1;
                    dialogH.refresh();
                end
            end
        end

    end

    methods(Static,Access=public)
        function launch(scopeUDI,meUDI)
            obj=Simulink.dd.CreateDataVariantDlg(scopeUDI,meUDI);

            DAStudio.Dialog(obj,'','DLG_STANDALONE');
        end
    end

    methods(Static)

        function buttonCB(dialogH,btnTag)
        end

        function closeCB(dialogH,closeAction)
            if isequal(closeAction,'ok')
                obj=dialogH.getSource;
                variantDicts={};
                max=min(length(obj.m_createInVariant),...
                length(obj.m_variantDicts));
                root=obj.m_scopeUDI.getParent;
                ddConn=root.getConnection;
                refDicts=ddConn.Dependencies;
                sleep=false;

                for idx=1:max
                    if obj.m_createInVariant(idx)
                        variant=dialogH.getTableItemValue('refDicts_tag',idx-1,2);
                        if~isempty(variant)
                            if~ismember(obj.m_variantDicts(idx),refDicts)
                                ddRef=Simulink.dd.open(obj.m_variantDicts{idx});
                                ddRef.setVariant(variant);
                                ddRef.saveChanges();
                                ddRef.close();

                                if~sleep
                                    sleep=true;
                                    ed=DAStudio.EventDispatcher;
                                    broadcastEvent(ed,'MESleepEvent');
                                    cleanupWake=onCleanup(@()broadcastEvent(ed,'MEWakeEvent'));
                                end

                                [~,name,ext]=fileparts(obj.m_variantDicts{idx});
                                ddConn.addReference([name,ext]);
                            end
                            variantDicts=[variantDicts,obj.m_variantDicts(idx)];
                        end
                    end
                end
                createVariants(obj.m_scopeUDI,obj.m_meUDI,variantDicts);
            end
        end

    end

end
