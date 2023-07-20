function out=getLatestDiagnosticDirectory(modelName,subDir)



    bdir=RTW.getBuildDir(modelName);
    postFix=DAStudio.message('soc:scheduler:DiagFolderPostfix');
    diagDir=fullfile(bdir.CodeGenFolder,[modelName,postFix],subDir);

    a=dir(diagDir);
    if~exist(diagDir,'dir')
        out='';
        return
    end

    [~,i]=sort([a(:).datenum]);
    apr=a(i);
    for i=numel(apr):-1:1
        this=apr(i).name;
        index=regexp(this,'_','once');
        if isempty(index)
            continue;
        end
        if~apr(i).isdir||ismember(this,{'.','..'})||...
            index~=5
            continue;
        end
        out=fullfile(diagDir,this);
        break
    end
end