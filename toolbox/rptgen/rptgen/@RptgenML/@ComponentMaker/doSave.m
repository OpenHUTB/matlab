function fileName=doSave(this,isSaveAs)




    fileName='';
    if nargin<2
        isSaveAs=false;
    elseif ischar(isSaveAs)
        fileName=isSaveAs;
        isSaveAs=false;
    end

    if isempty(fileName)
        try
            makePackageDir(this);
            makeClassDir(this);
            fileName=fullfile(this.ClassDir,'_componentcreator.mat');
        catch ME
            warning(ME.message);
            isSaveAs=true;
            fileName=fullfile(pwd,'componentcreator.mat');
        end
    end


    if isSaveAs
        [uiFile,uiPath]=uiputfile(fileName);

        if isequal(uiFile,0)||isequal(uiPath,0)

            fileName='';
            return;
        else
            fileName=fullfile(uiPath,uiFile);
        end
    end

    ComponentCreator=this;%#ok used by SAVE
    save(fileName,'ComponentCreator','-mat');


