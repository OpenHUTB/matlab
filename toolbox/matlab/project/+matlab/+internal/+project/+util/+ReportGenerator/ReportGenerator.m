classdef ReportGenerator





    properties(Access=private,Constant=true)
        HomeBookmark='home';
        SectionCounter='files';
    end

    properties(Access=private)
ProjectName
ProjectLocation
RepositoryLocation
Document
Customisation
Results
ContentSpecification
    end

    methods(Access=public)
        function obj=ReportGenerator(...
            projectName,...
            projectLocation,...
            repositoryLocation,...
            outputPath,...
            customisation,...
            results,...
            contentSpecification)
            obj.ProjectName=projectName;
            obj.ProjectLocation=projectLocation;
            obj.RepositoryLocation=repositoryLocation;

            obj.Document=mlreportgen.dom.Document(outputPath,customisation.FileType);
            obj.Customisation=customisation;
            obj.Results=results;
            obj.ContentSpecification=contentSpecification;
        end

        function generate(obj)
            documentParts=obj.generateDocumentParts();
            obj.populateReportFromParts(documentParts);
            obj.Document.close();
        end
    end

    methods(Access=private)
        function documentParts=generateDocumentParts(obj)
            import matlab.internal.project.util.convertJavaCollectionToCellArray;
            import matlab.internal.project.util.ReportGenerator.ReportContentSpecification;
            filesCellArray=...
            convertJavaCollectionToCellArray(obj.ContentSpecification.getFiles());
            numberOfFiles=length(filesCellArray);
            p=matlab.project.currentProject;

            documentParts=cell(numberOfFiles,3);

            for i=1:numberOfFiles
                file=filesCellArray{i};
                filePath=file.getAbsolutePath();
                rootRelativePath=obj.pathRelativeToProjectRoot(p.RootFolder,filePath);
                linkTarget=sprintf("file%d",i);

                import mlreportgen.dom.InternalLink;
                internalLink=InternalLink(linkTarget,rootRelativePath);
                documentParts{i,1}=internalLink;

                documentParts{i,2}=obj.ContentSpecification.createSummaryFileDescription(file,obj.Results);

                import mlreportgen.dom.LinkTarget;
                documentParts{i,3}=...
                obj.ContentSpecification.createFileResultsDocumentPart(...
                obj.Customisation,...
                LinkTarget(linkTarget),...
                rootRelativePath,...
                obj.Results,...
                file,...
                obj.HomeBookmark);
            end
        end

        function populateReportFromParts(obj,documentParts)
            import mlreportgen.dom.LinkTarget;
            obj.Document.append(LinkTarget(obj.HomeBookmark));

            obj.appendTitle();
            obj.appendMetadataTable();

            sectionHeading=getString(message('SimulinkProject:util:summary'));
            obj.appendSectionHeading(sectionHeading);
            [numberOfFiles,~]=size(documentParts);

            import mlreportgen.dom.OuterMargin;
            import mlreportgen.dom.Table;
            table=Table(documentParts(:,1:2));
            table.ColSep=obj.Customisation.Parameter;
            table.RowSep=obj.Customisation.Parameter;
            table.RowSepWidth='1px';
            table.ColSepWidth='1px';
            table.TableEntriesStyle={OuterMargin('1')};

            obj.Document.append(table);

            for i=1:numberOfFiles
                obj.Document.append(documentParts{i,3});
            end
        end


        function appendTitle(obj)
            import matlab.internal.project.util.ReportGenerator.ReportContentSpecification;
            title=getString(message('SimulinkProject:util:title',obj.ContentSpecification.getTitle()));
            obj.appendHeading(1,title);
        end

        function appendMetadataTable(obj)
            sectionHeading=getString(message('SimulinkProject:util:description'));
            obj.appendSectionHeading(sectionHeading);

            import matlab.internal.project.util.ReportGenerator.ReportObjects.DescriptionTable;
            descriptionTable=DescriptionTable(...
            obj.ProjectName,...
            obj.ProjectLocation,...
            obj.RepositoryLocation,...
            obj.Customisation);

            obj.Document.append(descriptionTable.create());

        end

        function relativePath=pathRelativeToProjectRoot(~,projectRoot,path)
            import com.mathworks.toolbox.slproject.project.util.file.PathUtils;
            javaFileProjectRoot=java.io.File(projectRoot);
            javaFilePath=java.io.File(path);

            javaStringRelativePath=...
            PathUtils.removeProjectRoot(...
            javaFileProjectRoot,...
javaFilePath...
            );

            relativePath=char(javaStringRelativePath);
        end

        function headingObject=appendSectionHeading(obj,text)
            headingObject=obj.appendHeading(2,text);
        end

        function headingObject=appendHeading(obj,level,text)
            import mlreportgen.dom.Heading;
            headingObject=Heading(level,text);
            obj.Document.append(headingObject);
        end

    end

end

