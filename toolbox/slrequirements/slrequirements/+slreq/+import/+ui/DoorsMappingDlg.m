classdef DoorsMappingDlg<handle





    properties(Access=private)
        table=[];
        srcAttribs={};
        destAttribs={};
        rowMap=[];
        choices={};
        values=[];
    end

    properties(Access=public)
        caller=[];
        srcDoc=[];
        attributeMap=[];
    end

    methods(Access=public)



        function dlgstruct=getDialogSchema(this)

            dlgstruct.Sticky=true;
            dlgstruct.DialogTitle=getString(message('Slvnv:slreq_import:DoorsDlgTitle',this.srcDoc));
            dlgstruct.DialogTag='SlreqImportChildDialog';
            dlgstruct.Geometry=[400,200,600,500];
            dlgstruct.LayoutGrid=[3,2];

            this.table=makeTable(this);

            instructions=getString(message('Slvnv:slreq_import:SelectBuiltinOrCustomName'));

            insText.Type='text';
            insText.Name=instructions;
            insText.WordWrap=true;


            colsGroup.Type='group';
            colsGroup.Name=getString(message('Slvnv:slreq_import:SelectAttributesForImport'));
            colsGroup.RowSpan=[2,2];
            colsGroup.ColSpan=[1,2];
            colsGroup.Items={insText,this.table};

            dlgstruct.Items={colsGroup};
            dlgstruct.StandaloneButtonSet={'OK','Cancel','Help'};
            dlgstruct.CloseCallback='slreq.import.ui.DoorsMappingDlg.Close_callback';
            dlgstruct.HelpMethod='slreq.import.ui.DoorsMappingDlg.Help_callback';
            dlgstruct.HelpArgs={'mapDoorsAttributes'};
            dlgstruct.CloseArgs={'%dialog','%closeaction'};

        end


        function setOption(this,row,option)
            this.optionValueChanged([],row,[],option);
        end
    end



    methods(Access=private)

        function table=makeTable(this)


            colHeaders={...
            getString(message('Slvnv:slreq_import:SrcAttrInDoors')),...
            getString(message('Slvnv:slreq_import:DestAttrib'))};


            this.srcAttribs=sort(keys(this.attributeMap));

            attrCount=numel(this.srcAttribs);
            for i=1:attrCount
                this.destAttribs{i}=this.attributeMap(this.srcAttribs{i});
            end

            tableData=cell(3+attrCount,2);

            mwAttributeOptions=slreq.import.propNameMap();
            tableData(1:7,1)={'Absolute Number';'Object Heading';'Object Text';...
            'Created By';'Created On';'Last Modified By';'Last Modified On'};
            tableData(1:7,2)=mwAttributeOptions([2:4,8:11]);

            nextRow=8;
            this.choices=mwAttributeOptions;
            this.values=(1:numel(this.choices))-1;


            this.choices(8:end)=[];
            this.values(8:end)=[];

            this.choices(2:4)=[];
            this.values(2:4)=[];
            for i=1:attrCount
                if isempty(this.destAttribs{i})
                    continue;
                end
                tableData{nextRow,1}=this.srcAttribs{i};
                combo.Type='combobox';
                combo.Tag=sprintf('DoorsAttrib%d',i);
                combo.Entries=this.choices;
                combo.Values=this.values;
                combo.Value=slreq.import.propNameMap('ATTR');
                combo.Editable=false;
                tableData{nextRow,2}=combo;
                this.rowMap(nextRow)=i;
                nextRow=nextRow+1;
            end
            for i=1:attrCount
                if~isempty(this.destAttribs{i})
                    continue;
                end
                if any(strcmp(this.srcAttribs{i},{'Created By','Created On','Last Modified By','Last Modified On'}))
                    continue;
                end
                tableData{nextRow,1}=this.srcAttribs{i};
                combo.Type='combobox';
                combo.Tag=sprintf('DoorsAttrib%d',i);
                combo.Entries=this.choices;
                combo.Values=this.values;
                combo.Value=slreq.import.propNameMap('SKIP');
                combo.Editable=false;
                tableData{nextRow,2}=combo;
                this.rowMap(nextRow)=i;
                nextRow=nextRow+1;
            end


            table.Type='table';
            table.Tag='SlreqImportDlgDoorsPreview';
            table.Editable=true;
            table.ColumnCharacterWidth=[21,21];
            table.HeaderVisibility=[1,1];
            table.ColHeader=colHeaders;
            table.Size=[attrCount+3,2];
            table.Data=tableData;
            table.ReadOnlyColumns=0;
            table.ReadOnlyRows=0:6;
            table.ValueChangedCallback=@this.optionValueChanged;

        end

        function optionValueChanged(this,dlg,row,col,val)%#ok<INUSL>
            row=row+1;







            if val==0
                this.destAttribs{this.rowMap(row)}='';
            elseif val==6
                this.destAttribs{this.rowMap(row)}=this.srcAttribs{this.rowMap(row)};
            else

                choice=this.choices(this.values==val);
                this.destAttribs{this.rowMap(row)}=choice{1};
            end
        end

    end


    methods(Static)
        function Close_callback(dlg,action)
            this=dlg.getSource();
            switch(lower(action))
            case 'ok'
                this.attributeMap=this.build_attr_map();
                this.SlreqImportDlgDoors_OK_callback();
            case{'cancel','close'}
                if~isempty(this.caller)
                    this.SlreqImportDlgDoors_Cancel_callback();
                end
            otherwise
            end
        end

        function Help_callback(helpTopicId)
            helpview(fullfile(docroot,'slrequirements','helptargets.map'),helpTopicId);
        end
    end

    methods(Access=public,Hidden=true)

        function mp=build_attr_map(this)
            mp=containers.Map('KeyType','char','ValueType','char');
            for i=1:length(this.srcAttribs)
                attrib=this.srcAttribs{i};
                if~isempty(this.destAttribs{i})
                    mp(attrib)=this.destAttribs{i};
                end
            end
        end

        function SlreqImportDlgDoors_Cancel_callback(this)
            this.caller.getSource.setAttributesFromDoorsDialog(this,false);
            slreq.import.ui.attrDlg_mgr('clear');
        end

        function SlreqImportDlgDoors_OK_callback(this)
            this.caller.getSource.setAttributesFromDoorsDialog(this,true);
            slreq.import.ui.attrDlg_mgr('clear');
        end

    end
end


