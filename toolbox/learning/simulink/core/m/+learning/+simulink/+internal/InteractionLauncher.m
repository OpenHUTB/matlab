classdef InteractionLauncher<handle



















    properties
        Release string=learning.simulink.internal.PortalUrlBuilder.serverRelease;
    end

    properties(SetAccess=protected)
        Course string="simulink";
        SectionPath string="Simulink/Simulating Models/Running Simulations/interaction1.json";
        RequestSubscriber;
    end

    methods
        function obj=InteractionLauncher()


            slTrainingInstallHelper.startInstallation();
            setupSlTraining;
            selfPacedTrainingStartup;
            slTrainingInstallHelper.endInstallation();

            obj.RequestSubscriber=learning.simulink.internal.RequestSubscriber();
        end

        function launch(obj,varargin)

            assert(nargin==1||nargin==3,"Expected no arguments, or course, sectionPath as arguments.");

            if nargin==3
                obj.Course=varargin{1};
                obj.SectionPath=varargin{2};
            end
            obj.setCourseModelDataFromProperties();
            LearningApplication.setupSimulinkStudio(char(obj.Course),char(obj.SectionPath));
        end

        function delete(obj)
            obj.RequestSubscriber.unsubscribe();
        end

    end

    methods(Access=private)

        function setCourseModelDataFromProperties(obj)

            pathParts=strsplit(obj.SectionPath,"/");
            expr="interaction[0-9]+.json";
            assert(~isempty(regexp(pathParts(end),expr,"once")),...
            "SectionPath must be a path to an interaction JSON file.");
            interactionPath=strjoin(pathParts(1:end-1),"/");













            discoveryService=string(learning.simulink.internal.getEndPoint)+...
            "?release="+obj.Release+...
            "&language="+"en"+...
            "&course="+obj.Course;

            endpoints=webread(discoveryService);



            contentRoot=learning.simulink.preferences.slacademyprefs.contentPath;
            contentUnitPath=fullfile(contentRoot,interactionPath,"contentUnit.json");
            contentUnitObject=jsondecode(fileread(contentUnitPath));

            if isfield(contentUnitObject,'title')&&~isempty(contentUnitObject.title)
                title=contentUnitObject.title;
            else
                title=pathParts(end-1);
            end

            courseModelData=struct("type","courseModelData",...
            "id",obj.SectionPath,...
            "lessonPath",endpoints.contentLocation+interactionPath,...
            "sectionHeaderText","<b>"+title+"</b>");

            obj.RequestSubscriber.setCourseModelData(courseModelData);
        end

    end

end
