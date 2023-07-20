
function fullFileName=findFile(this,nameWithExt)



    if exist(nameWithExt,'file')


        if exist(fullfile(pwd,nameWithExt),'file')
            fullFileName=fullfile(pwd,nameWithExt);
        else


            fullFileName=which(nameWithExt);

            if isempty(fullFileName)
                fullFileName=nameWithExt;
            end
        end
    else


        if exist(fullfile(this.OrigDir,nameWithExt),'file')
            fullFileName=fullfile(this.OrigDir,nameWithExt);
        elseif exist(fullfile(this.UserDir,nameWithExt),'file')
            fullFileName=fullfile(this.UserDir,nameWithExt);
        else
            DAStudio.error('RTW:cgv:FileNotFound',nameWithExt);
        end
    end
end
