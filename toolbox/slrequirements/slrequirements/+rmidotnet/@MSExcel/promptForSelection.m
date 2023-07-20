function[rows,cols,text]=promptForSelection(docPath,promptMessage)


    rows=[0,-1];
    cols=[0,-1];
    text={};

    if nargin<2
        promptMessage='Please select the range of interest';
    end

    rmidotnet.MSExcel.activate(docPath,true);

    [~,docName]=fileparts(docPath);
    reqmgt('winFocus',docName);

    response=questdlg(promptMessage,'Configuring Import Options',...
    'Use Current Selection','Cancel','Use Current Selection');

    if~isempty(response)&&~strcmp(response,'Cancel')
        msExcel=rmidotnet.MSExcel.application();
        msSelection=Microsoft.Office.Interop.Excel.Range(msExcel.Selection);
        cols=[msSelection.Column,msSelection.Column+msSelection.Columns.Count-1];
        rows=[msSelection.Row,msSelection.Row+msSelection.Rows.Count-1];
        if nargout>2
            totalCells=msSelection.Count;
            text=cell(1,totalCells);
            for i=1:totalCells
                text{i}=Microsoft.Office.Interop.Excel.Range(msSelection.Cells.Item(i)).Text.char;
            end
        end
    end
end

