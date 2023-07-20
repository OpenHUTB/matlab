function relpath=computeRelativePath(abspath,projpath)






    if nargin<2
        projpath=pwd;
    end
    projpath=strip(projpath,'"');
    abspath=strip(abspath,'"');

    relpath='';

    projpath_cell=strsplit(convertStringsToChars(projpath),filesep);
    abspath_cell=strsplit(convertStringsToChars(abspath),filesep);
    if isempty(projpath_cell)||isempty(abspath_cell)
        return
    else
        if~isequal(lower(projpath_cell{1}),lower(abspath_cell{1}))
            relpath=abspath;
            if contains(relpath,' ')
                relpath=['"',relpath,'"'];
            end
            return
        end
    end

    while~isempty(projpath_cell)&&~isempty(abspath_cell)
        if isequal(lower(projpath_cell{1}),lower(abspath_cell{1}))
            projpath_cell(1)=[];
            abspath_cell(1)=[];
        else
            break
        end
    end

    for i=1:length(projpath_cell)
        if isempty(projpath_cell{i})
            projpath_cell(i)=[];
        else
            projpath_cell{i}='..';
        end
    end
    relpath=strjoin([{'.'},projpath_cell,abspath_cell],filesep);
    if contains(relpath,' ')
        relpath=['"',relpath,'"'];
    end
end
