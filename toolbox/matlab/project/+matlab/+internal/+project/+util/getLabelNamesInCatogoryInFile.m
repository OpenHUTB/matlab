function[labelNames]=getLabelNamesInCatogoryInFile(file,categoryName)





    labelNames={};
    if(isa(file,'matlab.project.ProjectFile')||isa(file,'slproject.ProjectFile'))

        idx=arrayfun(@(x)strcmp(char(x.CategoryName),categoryName),file.Labels);
        labelNames=cellfun(@(x)char(x),{file.Labels(idx).Name},'UniformOutput',false);
    end

end

