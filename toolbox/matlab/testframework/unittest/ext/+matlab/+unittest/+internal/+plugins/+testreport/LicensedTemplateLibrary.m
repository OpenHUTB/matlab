classdef(Sealed)LicensedTemplateLibrary<mlreportgen.dom.LockedDocumentPart

    properties(Hidden,Constant)
        TemplateRootFolder=fullfile(fileparts(which(...
        'matlab.unittest.internal.plugins.testreport.LicensedTemplateLibrary')),'templates');
        Templates=createTemplatesStruct();
    end

    methods(Hidden,Access={?matlab.unittest.internal.plugins.testreport.TestReportData})
        function templateLibrary=LicensedTemplateLibrary(documentType)
            import matlab.unittest.internal.plugins.testreport.LicensedTemplateLibrary;

            templateLibraryFile=LicensedTemplateLibrary.Templates.(upper(documentType));

            templateLibrary=templateLibrary@mlreportgen.dom.LockedDocumentPart(...
            documentType,templateLibraryFile);
        end

        function openSuccess=licensedOpen(templateLibrary)
            key=getLicenseKey();
            openSuccess=templateLibrary.open(key);
        end
    end

    methods
        function delete(templateLibrary)
            templateLibrary.close();
        end
    end
end


function templates=createTemplatesStruct()
    import matlab.unittest.internal.plugins.testreport.LicensedTemplateLibrary;

    templateRoot=LicensedTemplateLibrary.TemplateRootFolder;

    templates.DOCX=...
    fullfile(templateRoot,'docx','TemplateLibrary.dotx');
    templates.PDF=...
    fullfile(templateRoot,'pdf','TemplateLibrary.pdftx');
    templates.HTML=...
    fullfile(templateRoot,'html','TemplateLibrary.htmtx');
end


function key=getLicenseKey()

    key='E2Cpo8aUQQVPjNCaQyzQ38crg/5ZW9arbltqhbrHKopv9q3bCCKwj6k8rUNckCVxbvOdd3KbhaxaOIXRrqs4/e4LNfJ98SiZGYIBXYqom4YweDFD0Yg/5x7PVbrr14BUuIfAKWzWmGW5v2ND4vpx4etytnMqNv7NHzGCRCrVGnG+XEn74lAY+wMz8TKUFoW+AZSzkAHV2Q2SgbrUgmHT/iExfOiQMehaZR1V7WVZqpO0l6Y7cKpgAPsYBuTluc1Bq9PfPPWhaM8lpWPOuw3LJU0=';
end
