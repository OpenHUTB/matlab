classdef ReqIFMappingDlg<handle





    properties(Access=private)
        table=[];
        reqifAttList={};
        destAttName={};
    end

    properties(Access=public)
        caller=[];
        srcDoc=[];
        reqIfData=[];
        attributeMap=[];
        doProxy=true;
    end

    methods(Access=public)



        function dlgstruct=getDialogSchema(this)
            [~,baseName,flExt]=fileparts(this.srcDoc);

            dlgstruct.Sticky=true;
            dlgstruct.DialogTitle=getString(message('Slvnv:slreq_import:ReqifDlgTitle',[baseName,flExt]));
            dlgstruct.DialogTag='SlreqImportChildDialog';
            dlgstruct.Geometry=[400,200,830,600];
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
            dlgstruct.CloseCallback='slreq.import.ui.ReqIFMappingDlg.Close_callback';
            dlgstruct.CloseArgs={'%dialog','%closeaction'};

        end


        function setOption(this,row,option)
            this.optionValueChanged([],row,[],option);
        end
    end



    methods(Access=private)

        function table=makeTable(this)

            colHeaders={...
            getString(message('Slvnv:slreq_import:ID')),...
            getString(message('Slvnv:slreq_import:Name')),...
            getString(message('Slvnv:slreq_import:Type')),...
            getString(message('Slvnv:slreq_import:Destination'))};

            reqIfAttrs=reqif_req_atts(this.reqIfData);
            attIds={reqIfAttrs.ID};
            [~,ind]=unique(attIds);
            reqIfAttrs=reqIfAttrs(ind);
            attCnt=numel(reqIfAttrs);

            reqIfAttrs(2:(attCnt+1))=reqIfAttrs;
            reqIfAttrs(1).ID='$ID$';
            this.reqifAttList=reqIfAttrs;
            this.destAttName=cell(1,attCnt+1);
            tableData=cell(attCnt+1,4);

            grayBG=204*[1,1,1];
            reqIfIdent.Type='text';
            reqIfIdent.Name=getString(message('Slvnv:slreq_import:ReqifIdentifier'));
            reqIfIdent.Bold=true;
            reqIfIdent.BackgroundColor=grayBG;

            blank.Type='text';
            blank.Name='';
            blank.BackgroundColor=grayBG;


            for idx=1:(attCnt+1)
                if idx==1
                    tableData{idx,1}=reqIfIdent;
                    tableData{idx,2}=blank;
                    tableData{idx,3}='String';
                else
                    [id,name,type]=attr_props(reqIfAttrs(idx));
                    tableData{idx,1}=id;
                    tableData{idx,2}=name;
                    tableData{idx,3}=type;
                end

                combo.Type='combobox';
                combo.Tag=sprintf('SlreqIFEntry%d',idx);
                combo.Entries=attributeChoices();
                combo.Values=(1:numel(combo.Entries))-1;
                combo.Value=0;
                combo.Editable=true;
                tableData{idx,4}=combo;
            end


            table.Type='table';
            table.Tag='SlreqImportDlgReqifPreview';
            table.Editable=true;
            table.ColumnCharacterWidth=[20,15,6,20];
            table.HeaderVisibility=[1,1];
            table.ColHeader=colHeaders;
            table.Size=[attCnt+1,4];
            table.Data=tableData;

            table.ValueChangedCallback=@this.optionValueChanged;

        end

        function optionValueChanged(this,dlg,row,~,str)%#ok<INUSL>
            row=row+1;


            switch lower(strtrim(str))
            case 'customid'
                this.destAttName{row}='CustomId';
            case 'summary'
                this.destAttName{row}='Summary';
            case 'description'
                this.destAttName{row}='Description';
            case 'rationale'
                this.destAttName{row}='Rationale';
            case{'keywords','keyword'}
                this.destAttName{row}='Keywords';
            otherwise
                this.destAttName{row}=strtrim(str);
            end
        end

    end


    methods(Static)
        function Close_callback(dlg,action)
            this=dlg.getSource();
            switch(lower(action))
            case 'ok'
                this.attributeMap=this.build_att_map();
                if isempty(this.caller)



                    slreq.import(this.srcDoc,'attr2reqprop',this.attributeMap,'reqifdata',this.reqIfData,'AsReference',this.doProxy);
                    slreq.import.ui.attrDlg_mgr('clear');
                else
                    this.SlreqImportDlgReqIF_OK_callback();
                end
            case{'cancel','close'}
                if~isempty(this.caller)
                    this.SlreqImportDlgReqIF_Cancel_callback();
                end
            otherwise
            end
        end
    end

    methods(Access=public,Hidden=true)

        function map=build_att_map(this)
            attCnt=numel(this.destAttName);


            filt=true(1,attCnt);
            for idx=1:attCnt
                filt(idx)=isempty(this.destAttName{idx});
            end

            keys=this.reqifAttList(~filt);
            vals=this.destAttName(~filt);
            if~isempty(keys)&&~isempty(vals)
                map=containers.Map({keys.ID},vals);
            else
                map=[];
            end
        end

        function SlreqImportDlgReqIF_Cancel_callback(this)
            this.caller.getSource.setAttributesFromReqifDialog(this,false);
            slreq.import.ui.attrDlg_mgr('clear');
        end

        function SlreqImportDlgReqIF_OK_callback(this)
            this.caller.getSource.setAttributesFromReqifDialog(this,true);
            slreq.import.ui.attrDlg_mgr('clear');
        end

    end
end





function out=attributeChoices
    out={' ',...
    'CustomId',...
    'Summary',...
    'Description',...
    'Rationale',...
    'Keywords'};
end


function out=reqif_req_atts(reqIFData)

    specTypes=reqIFData.specTypes.values;
    out={};

    for idx=1:numel(specTypes)
        opeSpec=specTypes{idx};
        if strcmp(opeSpec.Type,'SPEC-OBJECT-TYPE')&&~isempty(opeSpec.Attributes)
            vals=opeSpec.Attributes.values;
            if isempty(out)
                out=vals;
            else
                out=[out,vals];%#ok<AGROW>
            end
        end
    end


    out=[out{:}];
end

function[id,name,type]=attr_props(att)

    id=att.ID;
    name=att.Name;

    switch(lower(att.BaseType))
    case 'attribute-definition-xhtml'
        type='HTML';
    case 'attribute-definition-enumeration'
        type='Enum';
    case 'attribute-definition-boolean'
        type='Bool';
    case 'attribute-definition-date'
        type='Date';
    case 'attribute-definition-integer'
        type='Int';
    case 'attribute-definition-real'
        type='Real';
    case 'attribute-definition-string'
        type='String';
    otherwise
        type='??';
    end

end
