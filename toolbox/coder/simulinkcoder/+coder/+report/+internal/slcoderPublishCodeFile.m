


classdef slcoderPublishCodeFile<mlreportgen.dom.DocumentPart
    properties
        reportInfo=[];
        data=[]
        fileName=''
        filePath=''
        sectionNumber=0
    end
    methods
        function chapter=slcoderPublishCodeFile(report,fileName,sectionNumber)
            templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath;
            template=fullfile(templatePath,'CodeFileTemplate');
            chapter=chapter@mlreportgen.dom.DocumentPart(report.Type,template);
            chapter.data=fileName;
            [p,n,e]=fileparts(fileName);
            chapter.fileName=[n,e];
            chapter.filePath=p;
            chapter.sectionNumber=sectionNumber;
        end

        function fillFileName(chapter)
            import mlreportgen.dom.*
            text=Text(chapter.fileName);
            chapter.append(text);
        end
        function fillFilePath(chapter)
            import mlreportgen.dom.*
            text=Text(chapter.filePath);
            chapter.append(text);
        end
        function fillSectionNumber(chapter)
            import mlreportgen.dom.*
            text=Text(num2str(chapter.sectionNumber));
            chapter.append(text);
        end
        function fillFileContent(chapter)
            import mlreportgen.dom.*;
            if~exist(chapter.data,'file')
                DAStudio.warning('RTW:utility:fileDoesNotExist',chapter.data);
                return;
            end
            fid=fopen(chapter.data,'r');
            tline=fgets(fid);
            p=Paragraph;
            p.StyleName='CodeStyle';
            p.Style={WhiteSpace('preserve')};
            while ischar(tline)
                t=Text(tline);
                t.StyleName='CodeStyle';
                p.append(t);
                tline=fgets(fid);
            end
            chapter.append(p);
            fclose(fid);
        end
    end
end
