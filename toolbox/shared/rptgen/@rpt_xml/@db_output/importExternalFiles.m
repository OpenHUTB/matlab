function filesImported=importExternalFiles(this,fileName)








    if nargin<2
        fileName=this.DstFileName;
    end

    filesImported=false;

    rptgen.displayMessage(getString(message('rptgen:rx_db_output:importingFilesMsg')),4);

    try
        filesImported=com.mathworks.toolbox.rptgencore.docbook.FileImporter.scanDocumentForImports(fileName);
    catch ex
        rptgen.displayMessage(ex.message,2);
    end


    [chunkPath,chunkFile,chunkExt]=fileparts(fileName);
    chunkFiles=dir(fullfile(chunkPath,[chunkFile,'-*',chunkExt]));
    for i=1:length(chunkFiles)
        try
            filesImported=max(filesImported,...
            com.mathworks.toolbox.rptgencore.docbook.FileImporter.scanDocumentForImports(fullfile(chunkPath,chunkFiles(i).name)));
        catch ex
            c.status(ex.message,2);
        end
    end




