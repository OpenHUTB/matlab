classdef DescriptionTable<matlab.internal.project.util.ReportGenerator.ReportObjects.ReportObjectFactory




    properties(Access=private)
ProjectName
ProjectLocation
RepositoryLocation
    end

    methods(Access=public)
        function obj=DescriptionTable(projectName,projectLocation,repositoryLocation,customisation)
            obj=obj@matlab.internal.project.util.ReportGenerator.ReportObjects.ReportObjectFactory(customisation);

            obj.ProjectName=projectName;
            obj.ProjectLocation=projectLocation;
            obj.RepositoryLocation=repositoryLocation;
        end

        function reportObject=create(obj)
            metaDataCellArray=cell(5,2);


            metaDataCellArray{1,1}=getString(message('SimulinkProject:util:generatedBy'));
            metaDataCellArray{1,2}=char(java.lang.System.getProperty('user.name'));


            metaDataCellArray{2,1}=getString(message('SimulinkProject:util:projectName'));
            metaDataCellArray{2,2}=obj.ProjectName;


            metaDataCellArray{3,1}=getString(message('SimulinkProject:util:generationTime'));
            metaDataCellArray{3,2}=sprintf('%s',datetime('now'));


            metaDataCellArray{4,1}=getString(message('SimulinkProject:util:projectRoot'));
            metaDataCellArray{4,2}=obj.ProjectLocation;


            metaDataCellArray{5,1}=getString(message('SimulinkProject:util:repositoryLocation'));
            metaDataCellArray{5,2}=obj.RepositoryLocation;

            import mlreportgen.dom.Table;
            import mlreportgen.dom.OuterMargin;
            reportObject=Table(metaDataCellArray);
            reportObject.ColSep=obj.Customisation.Parameter;
            reportObject.ColSepWidth='1px';
            reportObject.TableEntriesStyle={OuterMargin('1')};
        end

    end

end

