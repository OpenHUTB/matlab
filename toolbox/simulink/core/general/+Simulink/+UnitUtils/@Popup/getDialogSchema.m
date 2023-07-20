function dlgstruct=getDialogSchema(this,~)




    items=getItems(this);
    dlgstruct=getDlgStruct(this,items);
end

function items=getItems(this)
    items={};
    if this.currentRow==0
        this.currentRow=1;
    end









    items=generateDetailedRow(this);

end

function items=generateDetailedRow(this)
    fontPointSize=10;
    items=generateSummaryRow(this.currentRow,this);

    numColumns=length(items{1}.Items);


    FixGroup=getWidgetWithFixSuggestion(this.violations(this.currentRow));
    FixGroup.RowSpan=[1,1];
    FixGroup.ColSpan=[1,numColumns];


    explanation.Name=DAStudio.message('Simulink:tools:UnitsBadgeDescriptionTitle');
    explanation.Type='text';
    explanation.Tag='text_status';
    explanation.RowSpan=[2,2];
    explanation.Alignment=2;
    explanation.FontPointSize=fontPointSize;


    advisorReport.Name='Model Advisor Report';
    advisorReport.Type='hyperlink';
    advisorReport.Tag='Model_Advisor_Report';
    advisorReport.MatlabMethod='Simulink.UnitUtils.generateUnitDiagnosticReport';
    modelname=this.violations(this.currentRow).getModelName;
    advisorReport.MatlabArgs={modelname};
    advisorReport.RowSpan=[2,2];
    advisorReport.Alignment=2;
    advisorReport.FontPointSize=fontPointSize;


    help.Name='?';
    help.Type='hyperlink';
    help.Tag='Help';
    help.Bold=true;
    help.MatlabMethod='helpview';
    issueHelpTag=this.violations(this.currentRow).getIssueHelpTag;
    help.MatlabArgs={fullfile(docroot,'simulink','helptargets.map'),issueHelpTag};
    help.Alignment=10;
    help.RowSpan=[3,3];
    help.ColSpan=[1,numColumns];






    ResultGroup.Type='group';
    ResultGroup.LayoutGrid=[1,numColumns];
    ResultGroup.RowSpan=[2,2];
    ResultGroup.ColSpan=[1,numColumns];
    colStrech=zeros(1,numColumns);
    colStrech(2)=1;
    ResultGroup.ColStretch=colStrech;
    ResultGroup.RowStretch=0;
    ResultGroup.Items={FixGroup,explanation,advisorReport,help};


    items=[items,ResultGroup];
end

function items=generateSummaryRow(issueNum,this)
    oneIssueOnly=(length(this.violations)==1);
    if(~this.stackedLook)
        row=1;
    else
        row=issueNum;
    end

    column=1;
    items={};
    issueType.Type='image';
    imagepath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','private');
    if(strcmpi(this.violations(issueNum).getIssueType,'Warning'))
        issueType.FilePath=fullfile(imagepath,'task_warning.png');
    else
        issueType.FilePath=fullfile(imagepath,'task_failed.png');
    end
    issueType.Tag='issueType';
    issueType.RowSpan=[row,row];
    issueType.ColSpan=[column,column];
    issueType.DialogRefresh=true;
    issueType.ToolTip='';
    column=column+1;
    items{end+1}=issueType;


    summary.Name=this.violations(issueNum).getIssueSummary;
    summary.Type='text';
    summary.Tag='text_status';
    summary.RowSpan=[row,row];
    summary.ColSpan=[column,column];
    summary.FontPointSize=11;
    items{end+1}=summary;

    column=column+1;






























    if(this.violations(issueNum).isFixable)
        column=column+1;
        fix.Type='hyperlink';
        if row==1&&issueNum==1
            fix.Name='Fix';
        else
            fix.Name='';
        end
        fix.Tag='ShowReport';
        fix.MatlabMethod=this.violations(this.currentRow).getFixMATLABMethod;
        fix.MatlabArgs=this.violations(this.currentRow).getFixMATLABArgs;
        fix.RowSpan=[row,row];
        fix.ColSpan=[column,column];
        fix.DialogRefresh=true;
        fix.Enabled=true;

        items{end+1}=fix;
    end


    if(~oneIssueOnly)
        column=column+1;
        previous.Type='hyperlink';
        previous.Name='<<';
        previous.Tag=num2str(this.currentRow);
        previous.RowSpan=[row,row];
        previous.ColSpan=[column,column];
        previous.DialogRefresh=true;
        previous.Enabled=(this.currentRow~=1);
        previous.ObjectMethod='previousIssue';
        items{end+1}=previous;

        column=column+1;
        xOfy.Type='text';
        xOfy.Name=[num2str(this.currentRow),'/',num2str(length(this.violations))];
        xOfy.Type='text';
        xOfy.RowSpan=[row,row];
        xOfy.ColSpan=[column,column];
        items{end+1}=xOfy;

        column=column+1;
        next.ToolTip='';
        next.Type='hyperlink';
        next.Name='>>';
        next.Tag=num2str(this.currentRow);
        next.ObjectMethod='nextIssue';


        next.RowSpan=[row,row];
        next.ColSpan=[column,column];
        next.DialogRefresh=true;
        next.Enabled=(this.currentRow~=length(this.violations));
        items{end+1}=next;
    end

















    if this.groupLook
        container.Type='group';
    else
        container.Type='panel';
    end

    container.Flat=false;
    container.LayoutGrid=[1,column];
    container.RowSpan=[row,row];
    container.RowStretch=0;
    container.ColSpan=[1,column];
    colStrech=zeros(1,column);
    colStrech(2)=1;
    container.ColStretch=colStrech;
    if(this.backgroundControl)
        container.BackgroundColor=this.backgroundColor;
    end
    container.Items=items;
    items={container};
end

function dlgstruct=getDlgStruct(this,items)
    dlgstruct.DialogTitle=DAStudio.message('Simulink:tools:MAUnitInconsTaskTitle');
    dlgstruct.DialogTag=DAStudio.message('Simulink:tools:MAUnitInconsTaskTitle');
    numcolumns=length(items{1}.Items);
    colStretch=zeros(1,numcolumns);
    colStretch(2)=1;
    if~this.detailsMode
        if(~this.stackedLook)
            dlgstruct.LayoutGrid=[1,numcolumns];
        else
            dlgstruct.LayoutGrid=[length(this.uiData.keys),numcolumns];
        end
        dlgstruct.RowStretch=0;
        dlgstruct.ColStretch=colStretch;
    else
        dlgstruct.LayoutGrid=[2,numcolumns];
        dlgstruct.RowStretch=[0,1];
        dlgstruct.ColStretch=colStretch;
    end
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.IsScrollable=false;
    dlgstruct.Transient=true;
    dlgstruct.DialogStyle='frameless';
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.MinimalApply=true;
    dlgstruct.ExplicitShow=true;
    dlgstruct.Items=items;
end

function fixSuggestionWidget=getWidgetWithFixSuggestion(issue)

    switch(issue.getIssueHelpTag)
    case 'unit_mismatch_inconsistency'
        if issue.isFixable
            fixSuggestionWidget=getEmptyPanel();
            return;
        end

        fontPointSize=10;
        params=issue.getSuggestionParameters;

        suggestion.Name=DAStudio.message('Simulink:tools:UnitsMismatchFixSuggestionRow1');
        suggestion.Type='text';
        suggestion.Tag='suggestion';
        suggestion.RowSpan=[1,1];
        suggestion.ColSpan=[1,2];
        suggestion.FontPointSize=fontPointSize;

        f1.Name=DAStudio.message('Simulink:tools:UnitsMismatchFixSuggestionRow2Col1');
        f1.Type='text';
        f1.RowSpan=[2,2];
        f1.ColSpan=[1,1];
        f1.FontPointSize=fontPointSize;
        f1.Alignment=1;

        if~isempty(params{1})
            f1a.Name=DAStudio.message('Simulink:tools:UnitsMismatchFixSuggestionRow2Col2');
            f1a.Type='hyperlink';
            f1a.MatlabMethod='Simulink.UnitUtils.goToBlockOrObject';
            f1a.MatlabArgs={issue.getModelName,params{1}};
            f1a.RowSpan=[2,2];
            f1a.ColSpan=[2,2];
            f1a.FontPointSize=fontPointSize;
            f1a.Alignment=1;
        else

            f1a.Name='';
            f1a.Type='text';
        end

        f2.Name=DAStudio.message('Simulink:tools:UnitsMismatchFixSuggestionRow3Col1');
        f2.Type='text';
        f2.RowSpan=[3,3];
        f2.ColSpan=[1,1];
        f2.FontPointSize=fontPointSize;

        if~isempty(params{2})
            f2a.Name=DAStudio.message('Simulink:tools:UnitsMismatchFixSuggestionRow3Col2');
            f2a.Type='hyperlink';
            f2a.MatlabMethod='Simulink.UnitUtils.goToBlockOrObject';
            f2a.MatlabArgs={issue.getModelName,params{2}};
            f2a.RowSpan=[3,3];
            f2a.ColSpan=[2,2];
            f2a.FontPointSize=fontPointSize;
        else

            f2a.Name='';
            f2a.Type='text';
        end

        fixSuggestionWidget.Type='panel';
        if issue.hasMixedUnit
            f3.Name=DAStudio.message('Simulink:tools:UnitsMismatchFixSuggestionRow4Col1');
            f3.Type='text';
            f3.RowSpan=[4,4];
            f3.ColSpan=[1,1];
            f3.FontPointSize=fontPointSize;
            f3a.Name='';
            f3a.Type='text';
            fixSuggestionWidget.LayoutGrid=[4,2];
            fixSuggestionWidget.Items={suggestion,f1,f1a,f2,f2a,f3,f3a};
        else
            fixSuggestionWidget.LayoutGrid=[3,2];
            fixSuggestionWidget.Items={suggestion,f1,f1a,f2,f2a};
        end
    otherwise

        fixSuggestionWidget=getEmptyPanel();
    end

end


function emptyPanel=getEmptyPanel()
    emptyPanel.Type='panel';
    emptyPanel.Items={};
end
