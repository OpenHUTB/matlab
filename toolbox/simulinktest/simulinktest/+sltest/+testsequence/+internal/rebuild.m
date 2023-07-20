function rebuild(blockpath,confirm)
    assert((nargin==1||nargin==2&&strcmp(confirm,'Yes')&&ischar(blockpath)),'%s takes only one argument: the path to the Test Sequence block',mfilename);
    try
        isTS=logical(sfprivate('is_reactive_testing_table_chart_block',blockpath));
    catch
        error('%s can only be applied to a Test Sequence block\nNot a Test Sequence block: %s',mfilename,blockpath);
    end
    assert(isTS,'%s can only be applied to a Test Sequence block\nNot a Test Sequence block: %s',mfilename,blockpath);

    chartId=sfprivate('block2chart',blockpath);
    stt=Stateflow.STT.StateEventTableMan(chartId);
    table=stt.tableModel;
    view=stt.viewManager;
    assert(~view.isViewAvailable,'Test Sequence block must be closed before calling %s',mfilename);

    if~exist('confirm','var')
        confirm=input(sprintf('Will rebuild the Test Sequence block: %s\nPlease make a backup before continuing.\nContinue? Yes/No [No]: ',blockpath),'s');
    end
    if~strcmp(confirm,'Yes')
        fprintf('Abort\n');
        return
    end

    fprintf('Rebuilding...');


    dims=size(stt.tableModel.rowHeights);
    if dims(1)==1&&dims(2)~=1
        table.rowHeights=shiftdim(table.rowHeights,1);
    end


    for k=2:table.numRows
        cell=table.getCellAtLocation(k,1);
        cell.cellText=cell.cellText;
    end


    chartData=view.jsChartData();
    function statedata=statecell2mat(statedata)
        statedata.children=cellfun(@statecell2mat,statedata.children);
        statedata.transitions=cell2mat(statedata.transitions);
        statedata=rmfield(statedata,'stateName');
    end
    statedata=cellfun(@statecell2mat,chartData.states);
    if isfield(chartData,'sessionUUID')
        [statedata.sessionUUID]=deal(chartData.sessionUUID);
    end


    view.jsNewState(-1,0);
    for k=1:length(statedata)
        view.jsDeleteState(1);
    end


    stt.rebuildTableFromStruct(stt.getTableAsStruct());
    stt.stateDiagramGenerator.insertStateAt(2);


    for k=1:length(statedata)
        view.jsAddState(-1,-1,statedata(k));
    end


    view.jsDeleteState(0);

    fprintf('done!\n');
end
