



function dbFile=extractDb(outputDir,dbData,zipName)
    if nargin<3
        zipName='db';
    end

    try

        zipFile=fullfile(outputDir,[zipName,'.zip']);
        polyspace.internal.makeParentDir(zipFile);

        fid=fopen(zipFile,'wb');
        fwrite(fid,dbData,'*uint8');
        fclose(fid);


        files=unzip(zipFile,outputDir);
        dbFile=files{1};


        delete(zipFile);
    catch ME
        if sldv.code.internal.feature('disableErrorRecovery',true)
            rethrow(ME);
        end
        if~isempty(zipFile)&&isfile(zipFile)
            delete(zipFile);
        end
        dbFile='';
    end


