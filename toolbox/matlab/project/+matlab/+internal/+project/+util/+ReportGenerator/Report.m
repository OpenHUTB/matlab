classdef Report




    properties(Access=private,Constant=true)
        Customisations=...
        [...
        matlab.internal.project.util.ReportGenerator.HTMLReport,...
        matlab.internal.project.util.ReportGenerator.WordReport,...
        matlab.internal.project.util.ReportGenerator.PDFReport...
        ];
    end

    properties(Access=private)
ProjectName
ProjectLocation
RepositoryLocation
Results
Customisation
FilePath
ContentSpecification
    end

    methods(Access=private)
        function obj=Report(projectName,projectLocation,repositoryLocation,...
            results,docTypeString,filePath,contentSpecificationObj)
            obj.ProjectName=projectName;
            obj.ProjectLocation=projectLocation;
            obj.RepositoryLocation=repositoryLocation;
            obj.Results=results;

            docType=find(strcmp({obj.Customisations.DisplayType},docTypeString));
            if isempty(docType)
                import matlab.internal.project.util.ReportGenerator.HTMLReport;
                obj.Customisation=HTMLReport();
            else
                obj.Customisation=obj.Customisations(docType);
            end

            obj.FilePath=obj.Customisation.getFilePath(filePath);
            obj.ContentSpecification=contentSpecificationObj;
        end

        function generate(obj)
            import matlab.internal.project.util.ReportGenerator.ReportGenerator;
            rg=ReportGenerator(...
            obj.ProjectName,...
            obj.ProjectLocation,...
            obj.RepositoryLocation,...
            obj.FilePath,...
            obj.Customisation,...
            obj.Results,...
            obj.ContentSpecification);
            rg.generate();
        end
    end

    methods(Access=public)
        function displayReport(obj)
            obj.Customisation.displayReport(obj.FilePath);
        end
    end

    methods(Access=public,Static=true)
        function bjr=generateReport(projectName,projectLocation,...
            repositoryLocation,results,docTypeString,filePath,contentSpecificationObj)
            import matlab.internal.project.util.ReportGenerator.Report;
            bjr=Report(projectName,projectLocation,repositoryLocation,...
            results,docTypeString,filePath,contentSpecificationObj);
            bjr.generate();
        end
    end

end

