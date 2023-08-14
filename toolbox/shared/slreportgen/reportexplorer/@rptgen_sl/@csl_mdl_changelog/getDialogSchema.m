function dlgStruct=getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage(name,true);
        return;

    end

    w=this.dlgWidget;

    p=struct(findprop(this,'DateFormat'));
    p.DataType=locDateOpts;
    w.DateFormat=this.dlgWidget(p);

    dlgStruct=this.dlgMain(name,{
    this.dlgContainer({
    w.isAuthor
    w.isVersion
    w.isDate
    w.isComment
    },getString(message('RptgenSL:rsl_csl_mdl_changelog:tableColumnsLabel')))
    this.dlgContainer({
    this.dlgSet(w.isLimitRevisions,...
    'ColSpan',[1,1],...
    'RowSpan',[1,1],...
    'DialogRefresh',1)
    this.dlgSet(w.NumRevisions,...
    'ColSpan',[2,2],...
    'RowSpan',[1,1],...
    'Enabled',this.isLimitRevisions)
    this.dlgSet(w.isLimitDate,...
    'ColSpan',[1,1],...
    'RowSpan',[2,2],...
    'DialogRefresh',1)
    this.dlgSet(w.DateLimit,...
    'ColSpan',[2,2],...
    'RowSpan',[2,2],...
    'Enabled',this.isLimitDate)
    },getString(message('RptgenSL:rsl_csl_mdl_changelog:tableRowsLabel')),'LayoutGrid',[2,2])
    this.dlgContainer({
    this.dlgSet(w.TableTitle,...
    'ColSpan',[1,1],...
    'RowSpan',[1,1])
    this.dlgSet(w.SortOrder,...
    'ColSpan',[1,1],...
    'RowSpan',[2,2])
    this.dlgSet(w.DateFormat,...
    'Editable',1,...
    'ColSpan',[1,1],...
    'RowSpan',[3,3])
    },getString(message('RptgenSL:rsl_csl_mdl_changelog:tableDisplayLabel')),'LayoutGrid',[4,1],'RowStretch',[0,0,0,1])
    });


    function dateOpts=locDateOpts

        persistent DATEVALUES

        if isempty(DATEVALUES)

            DATEVALUES={
'dd-mmm-yyyy HH:MM:SS'
'dd-mmm-yyyy'
'mm/dd/yy'
'mmm'
'm'
'mm'
'mm/dd'
'dd'
'ddd'
'd'
'yyyy'
'yy'
'mmmyy'
'HH:MM:SS'
'HH:MM:SS PM'
'HH:MM'
'HH:MM PM'
'QQ-YY'
'QQ'
'dd/mm'
'dd/mm/yy'
'mmm.dd,yyyy HH:MM:SS'
'mmm.dd,yyyy'
'mm/dd/yyyy'
'dd/mm/yyyy'
'yy/mm/dd'
'yyyy/mm/dd'
'QQ-YYYY'
'mmmyyyy'
'yyyy-mm-dd'
'yyyymmddTHHMMSS'
'yyyy-mm-dd HH:MM:SS'
            };

            t=now;
            for i=1:length(DATEVALUES)
                DATEVALUES{i,2}=sprintf('%s (%s)',DATEVALUES{i,1},datestr(t,DATEVALUES{i,1}));
            end

            DATEVALUES(end+1,:)={'inherit',getString(message('RptgenSL:rsl_csl_mdl_changelog:modelFormatLabel'))};

        end

        dateOpts=DATEVALUES;

