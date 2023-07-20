classdef ProjectReferenceListManager<handle




    properties(SetAccess=immutable)
EventHandler
ProjectInterface
    end

    properties(SetAccess=protected,GetAccess=public)
ReferenceList
ReferenceMap
MainProject
    end

    methods
        function this=ProjectReferenceListManager(appModel)
            this.EventHandler=appModel.EventHandler;
            this.ProjectInterface=appModel.ProjectInterface;
            this.ReferenceList=[];
            this.ReferenceMap=containers.Map;
            update(this);
        end

        function update(this)
            this.ReferenceList=this.ProjectInterface.getReferenceProjects;
            if~isempty(this.ReferenceList)
                this.MainProject=this.ReferenceList(1);
            end
            populateReferenceMap(this);
            notify(this.EventHandler,'ProjectReferenceListManagerChanged');
        end

        function projectNames=getProjectFullPath(this)


            projectNames=cell.empty;
            for idx=1:numel(this.ReferenceList)
                projPath=this.ReferenceList(idx).Project.RootFolder;


                projectNames{end+1}=convertStringsToChars(projPath);%#ok<AGROW>
            end
        end


        function populateReferenceMap(this)
            this.ReferenceMap=containers.Map;
            for idx=1:numel(this.ReferenceList)
                proj=this.ReferenceList(idx);
                this.ReferenceMap(proj.Project.RootFolder)=proj;
            end
        end

        function projInfo=getProjInfo(this,projPath)
            projInfo=this.ReferenceMap(projPath);
        end
    end
end
