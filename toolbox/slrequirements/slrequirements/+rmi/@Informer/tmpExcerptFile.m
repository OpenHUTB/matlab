function htmlFilePath=tmpExcerptFile(parentDir,fileName)





    if exist(parentDir,'dir')~=7
        mkdir(parentDir);
    end




    if any(fileName==' ');
        fileName=strrep(fileName,' ','__');
    end


    htmlFilePath=fullfile(parentDir,fileName);

end
