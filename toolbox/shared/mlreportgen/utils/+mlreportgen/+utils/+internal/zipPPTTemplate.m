function varargout=zipPPTTemplate(templateFile,varargin)





    narginchk(1,2);
    nargoutchk(0,1);


    templateFile=string(templateFile);
    svarargin=string(varargin);


    [~,templateFileName,templateExt]=fileparts(templateFile);


    if templateExt==""
        zippedTemplateFile=templateFileName+".pptx";
    else
        zippedTemplateFile=templateFile;
    end


    if isempty(svarargin)

        unzippedTemplateFolder=templateFileName;
    else
        unzippedTemplateFolder=svarargin(1);
    end

    withBrackets=fullfile(unzippedTemplateFolder,"[Content_Types].xml");
    withoutBrackets=fullfile(unzippedTemplateFolder,"Content_Types.xml");


    if exist(withoutBrackets,"file")==2
        movefile(withoutBrackets,withBrackets,"f");
    end

    [isDir,dirContents]=isDirectory(unzippedTemplateFolder);
    if~isDir
        error(message("mlreportgen:utils:error:noUnzippedTemplateFolder"))
    end


    userPWD=pwd;



    cd(unzippedTemplateFolder);


    tempzipFile=string(tempname(pwd));
    varargout=zip(tempzipFile,dirContents);


    tempzipFile=tempzipFile+".zip";


    cd(userPWD);


    if exist(withBrackets,"file")==2
        movefile(withBrackets,withoutBrackets,"f");
    end



    copyfile(tempzipFile,zippedTemplateFile,"f");
    delete(tempzipFile);
end


function[fileIsDir,dirContents]=isDirectory(filename)

    dirContents=dir(filename);
    dirContents={dirContents.name};
    fileIsDir=numel(dirContents)>1;
    if fileIsDir
        dirContents=setdiff(dirContents,{'.','..'});
    end
end
