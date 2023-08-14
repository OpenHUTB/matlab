classdef(Sealed)LicensedTemplateLibrary<mlreportgen.dom.LockedDocumentPart







    properties(Hidden,Constant)
        TemplateRootFolder=fullfile(fileparts(which(...
        'sltest.internal.plugins.testreport.LicensedTemplateLibrary')),'templates');
        Templates=createTemplatesStruct();
    end

    methods(Hidden)
        function templateLibrary=LicensedTemplateLibrary(documentType)
            import sltest.internal.plugins.testreport.LicensedTemplateLibrary;

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
    import sltest.internal.plugins.testreport.LicensedTemplateLibrary;

    templateRoot=LicensedTemplateLibrary.TemplateRootFolder;

    templates.DOCX=...
    fullfile(templateRoot,'docx','TemplateLibrary.dotx');
    templates.PDF=...
    fullfile(templateRoot,'pdf','TemplateLibrary.pdftx');
    templates.HTML=...
    fullfile(templateRoot,'html','TemplateLibrary.htmtx');
end


function key=getLicenseKey()













    key='E2Cpo9xwARVPDOGad74uTONIFOzWn8wrQ8hHkAZT/hj3+KgSisu/wi7ssPk9CCPBhwr4LmZya+nhQAUHkRgytylGuZLMov8jxmNqEmL5Pr/wZefURrCYqlOl0XlW6iQ5IQDDcUjFBflC7pRCviV8B5o4XlODzkcKf+lF++/47fsWnDrD+9679TYsF6hsZvFe7oC+IzSgxMSpJ1bMGbr0I58WhANsMdHBqWPV7uwniki0pZmoBJvP4oIYdrmFNIv8blxyks1YS5ganVHg';
end