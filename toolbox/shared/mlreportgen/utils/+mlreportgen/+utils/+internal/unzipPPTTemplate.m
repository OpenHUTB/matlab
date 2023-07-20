function unzippedFiles=unzipPPTTemplate(templateFile,varargin)





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

    unzippedFiles=unzip(zippedTemplateFile,unzippedTemplateFolder);




    withBrackets=fullfile(unzippedTemplateFolder,"[Content_Types].xml");
    if exist(withBrackets,"file")==2
        without=fullfile(unzippedTemplateFolder,"Content_Types.xml");
        movefile(withBrackets,without,"f");
    end
end
