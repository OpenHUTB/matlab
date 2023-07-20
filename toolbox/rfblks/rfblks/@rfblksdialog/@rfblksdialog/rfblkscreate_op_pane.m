function[items,layout]=rfblkscreate_op_pane(this,varargin)




    opTab_Enable=varargin{1};
    create_new_dialog=varargin{2};
    multiref_filename_changed=varargin{3};
    mydata=varargin{4};


    lprompt=1;
    rprompt=4;

    rwidget=18;
    number_grid=20;
    middle=9;


    if opTab_Enable

        tempref=mydata.Reference;
        original_conditionnames=getvarnames(tempref);


        conditionTitle1=rfblksGetLeafWidgetBase('text','Conditions:',...
        'ConditionTitle1',0);
        conditionTitle1.RowSpan=[1,1];
        conditionTitle1.ColSpan=[1,middle];
        conditionTitle1.Alignment=6;
        conditionTitle2=rfblksGetLeafWidgetBase('text','Values:',...
        'ConditionTitle2',0);
        conditionTitle2.RowSpan=[1,1];
        conditionTitle2.ColSpan=[middle+1,rwidget];
        conditionTitle2.Alignment=6;

        conditionnames={};
        conditionvalues={};

        if create_new_dialog
            if~isempty(strfind(this.Block.ConditionNames,'!'))&&...
                ~isempty(strfind(this.Block.ConditionValues,'!'))
                conditionnames=str2conditions(this.Block.ConditionNames);
                conditionvalues=str2conditions(this.Block.ConditionValues);
                [isLibrary,isLocked]=this.isLibraryBlock(this.Block);
                if~isLibrary&&~isLocked
                    this.Block.UserData.ConditionNames=conditionnames;
                    this.Block.UserData.ConditionValues=conditionvalues;
                end
            end

        elseif multiref_filename_changed




            [conditionnames,conditionvalues]=getvarnames(tempref);

            this.Block.UserData.ConditionNames=conditionnames;
            this.Block.UserData.ConditionValues=conditionvalues;


        else
            if all(isfield(this.Block.UserData,...
                {'ConditionNames','ConditionValues'}))&&...
                ~isempty(this.Block.UserData.ConditionNames)&&...
                ~isempty(this.Block.UserData.ConditionValues)
                conditionnames=this.Block.UserData.ConditionNames;
                conditionvalues=this.Block.UserData.ConditionValues;
            elseif~isempty(strfind(this.Block.ConditionNames,'!'))&&...
                ~isempty(strfind(this.Block.ConditionValues,'!'))
                conditionnames=str2conditions(this.Block.ConditionNames);
                conditionvalues=str2conditions(this.Block.ConditionValues);
                if~strcmpi(get_param(bdroot,'BlockDiagramType'),'library')
                    this.Block.UserData.ConditionNames=conditionnames;
                    this.Block.UserData.ConditionValues=conditionvalues;
                end
            end
        end

        allvalues=cell(size(conditionnames));
        for ii=1:numel(conditionnames)
            allvalues{ii}=getallvalues(tempref,conditionnames{ii});
        end

        conditionwidgets=cell(size(conditionnames));
        for ii=1:numel(conditionwidgets)

            conditionwidgets{ii}=rfblksGetLeafWidgetBase('text',conditionnames{ii},...
            ['Condition',num2str(ii)],0);

            conditionwidgets{ii}.RowSpan=[ii+1,ii+1];
            conditionwidgets{ii}.ColSpan=[1,middle];
            conditionwidgets{ii}.Alignment=6;





        end


        valuewidgets=cell(size(conditionnames));
        for ii=1:numel(valuewidgets)

            valuewidgets{ii}=rfblksGetLeafWidgetBase('combobox','',...
            ['Value',num2str(ii)],this);
            valuewidgets{ii}.Entries=allvalues{ii};
            valuewidgets{ii}.RowSpan=[ii+1,ii+1];
            valuewidgets{ii}.ColSpan=[middle+1,rwidget];
            valuewidgets{ii}.Value=conditionvalues{ii};

            valuewidgets{ii}.ObjectMethod='rfblksstoreopcondition';
            valuewidgets{ii}.MethodArgs={'%dialog',original_conditionnames,allvalues};
            valuewidgets{ii}.ArgDataTypes={'handle','mxArray','mxArray'};
        end

        spacerOP=rfblksGetLeafWidgetBase('text','','',0);
        spacerOP.RowSpan=[valuewidgets{end}.RowSpan(1)+1,valuewidgets{end}.RowSpan(1)+1];
        spacerOP.ColSpan=[lprompt,rprompt];

    else

        temptxt=['Operating condition selection is only available',sprintf('\n')...
        ,'when the data source contains operating condition information'];
        conditionTitle1=rfblksGetLeafWidgetBase('text',temptxt,...
        'ConditionTitle1',0);
        conditionTitle1.RowSpan=[1,1];
        conditionTitle1.ColSpan=[1,middle];

        spacerOP=rfblksGetLeafWidgetBase('text','','',0);
        spacerOP.RowSpan=[2,2];
        spacerOP.ColSpan=[lprompt,rprompt];

    end


    if opTab_Enable
        items={conditionTitle1,conditionTitle2,...
        conditionwidgets{:},valuewidgets{:},spacerOP};
        numRows=numel(conditionwidgets)+2;
        layout.LayoutGrid=[numRows,number_grid];
        layout.RowStretch=[zeros(1,numRows-1),1];
    else
        items={conditionTitle1,spacerOP};
        layout.LayoutGrid=[2,number_grid];
        layout.RowStretch=[0,1];
    end
    layout.RowSpan=[1,1];
    layout.ColSpan=[1,1];


    function conditions=str2conditions(str)


        loc=strfind(str,'!');
        conditions=cell(numel(loc),1);
        sp=1;
        for ii=1:numel(loc)
            conditions{ii}=str(sp:loc(ii)-1);
            sp=loc(ii)+1;
        end


