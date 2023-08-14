classdef(Sealed)LicensedDocument<mlreportgen.dom.LockedDocument







    properties(Hidden,Constant)
        TemplateRootFolder=fullfile(fileparts(which(...
        'matlab.unittest.internal.dom.LicensedDocument')),'templates');
        Templates=createTemplatesStruct();
    end

    methods(Hidden,Access={?matlab.unittest.internal.dom.ReportDocument})
        function docObj=LicensedDocument(varargin)
            docObj=docObj@mlreportgen.dom.LockedDocument(varargin{:});
        end

        function openSuccess=licensedOpen(docObj)
            key=getLicenseKey();
            openSuccess=docObj.open(key);
        end
    end
end


function templates=createTemplatesStruct()
    templateRoot=matlab.unittest.internal.dom.LicensedDocument.TemplateRootFolder;

    templates.DOCX.LetterPortraitWithNarrowMargins=...
    fullfile(templateRoot,'docx','LetterPortraitWithNarrowMargins.dotx');
    templates.DOCX.LetterLandscapeWithNarrowMargins=...
    fullfile(templateRoot,'docx','LetterLandscapeWithNarrowMargins.dotx');
    templates.PDF.LetterPortraitWithNarrowMargins=...
    fullfile(templateRoot,'pdf','LetterPortraitWithNarrowMargins.pdftx');
    templates.PDF.LetterLandscapeWithNarrowMargins=...
    fullfile(templateRoot,'pdf','LetterLandscapeWithNarrowMargins.pdftx');
    templates.HTML.Standard=...
    fullfile(templateRoot,'html','Standard.htmtx');
end


function key=getLicenseKey()
















    key='E2BRoMC1AQVTDOGOIbnO/qTem6qn+/JuaG9Hut1zbtPbh+qFZuVEI8Hxx2UmwqQlczOkYoWiXUsdstySsSKDLnlVwpd5f2Nw9086cO0Aoh1TJm+UZduTkmnfOrR7/f9FdJifCS4hjR+elM2WFaQ2xHeY/CbKNoCGuuWg8pX1Ma9UfZ6TCGL3XmwrcAsJ8G7NviXelLKNb4rZ+4DJoMPoV7FLqqMHSy1Tqi/pwfhTT6/KHhrCZzAidoijFDDa+Pw4jplwn3FmyVnlfACz6tl/LFC1VI4EmpaHi/ksqRmZznbmJNk9SkP9d90shOvJAOjAhXCyKolm3FoGiO0rdxKnADci7lVC79m6WLUcybEZNV+IR+kdLk4tf6dMgw==';
end



