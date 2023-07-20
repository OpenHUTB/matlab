function privateadddesktopfilestoproject(projfilename,filesToBeZipped)












    outputDir=sbiogate('sbiotempdir');
    outputDir=fullfile(outputDir,'app');

    if exist(outputDir,'dir')
        cleanupDirectories(outputDir);
    end

    if exist(projfilename,'file')

        fileNames=unzip(projfilename,outputDir);


        filesToBeZipped=horzcat(fileNames,filesToBeZipped);
    end


    tempfilename=[tempname,'.zip'];
    zip(tempfilename,filesToBeZipped);


    copyfile(tempfilename,projfilename,'f');
    deletefile(tempfilename);

    if exist(outputDir,'dir')
        cleanupDirectories(outputDir);
    end


    function deletefile(filename)


        recycle_status=recycle;


        recycle off;
        delete(filename);


        recycle(recycle_status);


        function cleanupDirectories(dirName)

            rmdir(dirName,'s');
