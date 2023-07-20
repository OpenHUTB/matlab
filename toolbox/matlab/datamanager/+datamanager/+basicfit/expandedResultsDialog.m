function moreResultsDialog=expandedResultsDialog(fitname,fitIndex,currentObject,fig)




    equation=getappdata(currentObject,'Basic_Fit_Equation');
    coefficients=getappdata(currentObject,'Basic_Fit_Coefficients');
    rmse=getappdata(currentObject,'Basic_Fit_RMSE');
    r2=getappdata(currentObject,'Basic_Fit_R2');
    equation=equation{fitIndex+1};
    if isempty(equation)
        equation='';
    end
    coefficients=coefficients{fitIndex+1};
    if isempty(coefficients)
        coefficients='';
    end
    rmse=rmse{fitIndex+1};
    if isempty(rmse)
        rmse='';
    end

    r2=r2{fitIndex+1};
    if isempty(r2)
        r2='';
    end

    figPos=fig.Position(1:2);
    moreResultsDialog=uifigure('Visible','off',...
    'Internal',true,...
    'Position',[figPos(1),figPos(2),300,316],...
    'Name',fitname+" "+getString(message('MATLAB:datamanager:basicfit:FitResults')));

    uiGrid1=uigridlayout(moreResultsDialog,'Padding',[10,10,10,10]);
    uiGrid1.ColumnWidth={'1x'};
    uiGrid1.RowHeight={'fit','fit'};
    uiGrid1.RowSpacing=5;
    uiGrid1.ColumnSpacing=0;

    mainGrid=uigridlayout(uiGrid1,'Padding',[0,0,0,0]);
    mainGrid.ColumnWidth={'fit','1x'};
    mainGrid.RowHeight={'fit','fit','fit','fit'};
    mainGrid.RowSpacing=5;
    mainGrid.ColumnSpacing=5;
    mainGrid.Layout.Row=1;
    mainGrid.Layout.Column=1;


    u1=uilabel(mainGrid,...
    'Text',[getString(message('MATLAB:datamanager:basicfit:Equation')),':']);
    u1.Layout.Row=1;
    u1.Layout.Column=1;


    uit1=uitextarea(mainGrid,...
    'Editable','off',...
    'Value',{equation});
    uit1.Layout.Row=1;
    uit1.Layout.Column=2;


    u2=uilabel(mainGrid,...
    'Text',[getString(message('MATLAB:datamanager:basicfit:Coefficients')),':']);
    u2.Layout.Row=2;
    u2.Layout.Column=1;


    uit2=uitextarea(mainGrid,...
    'Editable','off',...
    'Value',{coefficients});
    uit2.Layout.Row=2;
    uit2.Layout.Column=2;


    u4=uilabel(mainGrid,...
    'Text',['R',sprintf(strrep('\u00B2','\u','\x')),':']);
    u4.Layout.Row=3;
    u4.Layout.Column=1;


    uit4=uitextarea(mainGrid,...
    'Editable','off',...
    'Value',{r2});
    uit4.Layout.Row=3;
    uit4.Layout.Column=2;


    u3=uilabel(mainGrid,...
    'Text',[getString(message('MATLAB:datamanager:basicfit:NormOfResidualsLabel')),':']);
    u3.Layout.Row=4;
    u3.Layout.Column=1;


    uit3=uitextarea(mainGrid,...
    'Editable','off',...
    'Value',{rmse});
    uit3.Layout.Row=4;
    uit3.Layout.Column=2;

    subGrid=uigridlayout(uiGrid1,'Padding',[0,0,0,0]);
    subGrid.ColumnWidth={'1x','fit'};
    subGrid.RowHeight={'fit'};
    subGrid.RowSpacing=0;
    subGrid.ColumnSpacing=5;
    subGrid.Layout.Row=2;
    subGrid.Layout.Column=1;


    ubt=uibutton(subGrid,'push',...
    'Text',getString(message('MATLAB:datamanager:basicfit:ExportToWorkspace')),...
    'ButtonPushedFcn',@(e,d)showExportResultsDialog());
    ubt.Layout.Row=1;
    ubt.Layout.Column=2;

    exportDialog=[];
    moreResultsDialog.Visible='on';

    addlistener(moreResultsDialog,'ObjectBeingDestroyed',@(e,d)deleteExportDialog());

    function showExportResultsDialog()
        if~isempty(exportDialog)
            delete(exportDialog);
        end
        exportDialog=basicfitdatastat('bfitsavefit',currentObject,fitIndex);
    end

    function deleteExportDialog()
        delete(exportDialog);
    end
end