function varargout=registry(proj)
    persistent projects
    if isempty(projects)
        projects=containers.Map('KeyType','char','ValueType','any');
        projects('ID')='MCOS Object';
    end

    if nargin>0
        if ischar(proj)
            if strcmp(proj,'_clear_')

                varargout{1}=projects.Count-1;
                projects=[];
                return;
            elseif isKey(projects,proj)

                varargout{1}=projects(proj);
            else

                varargout{1}=[];
            end
        else

            projects(proj.name)=proj;
        end
    else

        varargout{1}=keys(projects);
    end
end
