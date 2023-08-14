function cleanFiles(this,tempFilesDir)




    theFormat=this.getFormat;
    if(theFormat.getCleanFiles)&&exist(tempFilesDir,'dir')





        preserveFiles=[
        dir(fullfile(tempFilesDir,'*.xfrag'))
        dir(fullfile(tempFilesDir,'*.rtf'))
        dir(fullfile(tempFilesDir,'*.doc'))
        dir(fullfile(tempFilesDir,'*.htm*'))
        ];

        if isempty(preserveFiles)
            [rmSuccess,rmMessage]=rmdir(tempFilesDir,'s');
            if~rmSuccess
                rptgen.displayMessage(rmMessage,2);
            end
        else

            allFiles=dir(tempFilesDir);
            allFiles={allFiles.name};
            preserveFiles={preserveFiles.name,'.','..'};
            delFiles=setdiff(allFiles,preserveFiles);
            for i=1:length(delFiles)
                try
                    delete(fullfile(tempFilesDir,delFiles{i}));
                catch ME
                    rptgen.displayMessage(getString(message('rptgen:rx_db_output:noDeleteMsg',delFiles{i})),2);
                    rptgen.displayMessage(ME.message,5);
                end
            end
        end
    end
