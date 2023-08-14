

















function this=addPostLoadFiles(this,filesList)
    if this.RunHasBeenCalled~=0
        DAStudio.error('RTW:cgv:RunHasBeenCalled');
    end
    if nargin<2
        DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
    end

    if~iscellstr(filesList)
        stk=dbstack;
        DAStudio.error('RTW:cgv:NotCellArray',stk(1).name);
    end
    this.PostLoadFilesList={};
    for f=1:length(filesList)
        filename=filesList{f};
        [~,~,ext]=fileparts(filename);
        if~any(strcmp(ext,{'.m','.mat','.mlx'}))
            DAStudio.error('RTW:cgv:NotValidFileType',filesList{f});
        end
        fullFile=findFile(this,filesList{f});
        this.PostLoadFilesList{end+1}=fullFile;
    end
