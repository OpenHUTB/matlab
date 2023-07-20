function[names]=getCategoriesAndLabelNamesInProjectFromFile(varargin)









    names={};
    file=varargin{1};


    if(isa(file,'matlab.project.ProjectFile'))
        proj=file.evaluate(@(x)matlab.project.Project(x));
    elseif isa(file,'slproject.ProjectFile')
        projectObjects=slproject.getCurrentProjects;

        [isUnderProjRt,projectRoot]=slproject.isUnderProjectRoot(file.Path);
        if(~isempty(projectObjects)&&isUnderProjRt)

            proj=projectObjects(strcmp({projectObjects.RootFolder},projectRoot));
        else
            return
        end
    else
        return;
    end



    if(~isempty(proj))
        switch(nargin)
        case 1
            names=arrayfun(@(x)char(x.Name),proj.Categories,'UniformOutput',false);

        case 2
            categoryName=varargin{2};

            categoryName=validatestring(categoryName,cellfun(@(x)char(x),{proj.Categories.Name},'UniformOutput',false));

            names=arrayfun(@(x)char(x.Name),proj.findCategory(categoryName).LabelDefinitions,'UniformOutput',false);
        otherwise


        end
    end

end

