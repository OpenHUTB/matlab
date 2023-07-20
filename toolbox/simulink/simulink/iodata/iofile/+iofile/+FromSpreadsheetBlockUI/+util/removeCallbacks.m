function removeCallbacks(blockH)






    BlockDiagram=iofile.FromSpreadsheetBlockUI.util.getBlockDiagram(blockH);


    if~isempty(BlockDiagram)

        if BlockDiagram.hasCallback('PreClose','iofile_FromSpreadsheetBlockUI_closeImportTable')
            BlockDiagram.removeCallback('PreClose','iofile_FromSpreadsheetBlockUI_closeImportTable');
        end

        if BlockDiagram.hasCallback('PostNameChange','iofile_FromSpreadsheetBlockUI_PostNameChange')
            BlockDiagram.removeCallback('PostNameChange','iofile_FromSpreadsheetBlockUI_PostNameChange');
        end

    end

end

