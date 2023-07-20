function attachCallbacks(blockH,varargin)







    clientH=varargin{1};
    BlockDiagram=iofile.FromSpreadsheetBlockUI.util.getBlockDiagram(blockH);


    if~isempty(BlockDiagram)

        if BlockDiagram.hasCallback('PreClose','iofile_FromSpreadsheetBlockUI_closeImportTable')
            BlockDiagram.removeCallback('PreClose','iofile_FromSpreadsheetBlockUI_closeImportTable');
        end

        BlockDiagram.addCallback('PreClose',...
        'iofile_FromSpreadsheetBlockUI_closeImportTable',...
        @(src,dst)iofile.FromSpreadsheetBlockUI.closeImportTableFromBlock(clientH));

        if BlockDiagram.hasCallback('PostNameChange','iofile_FromSpreadsheetBlockUI_PostNameChange')
            BlockDiagram.removeCallback('PostNameChange','iofile_FromSpreadsheetBlockUI_PostNameChange');
        end

        BlockDiagram.addCallback('PostNameChange',...
        'iofile_FromSpreadsheetBlockUI_PostNameChange',...
        @(src,dst)iofile.FromSpreadsheetBlockUI.util.attachCallbacks(blockH,clientH));
    end
end
