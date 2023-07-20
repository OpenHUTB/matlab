function bfi=create(obj,filePaths)






    numIdx=numel(filePaths);

    bfi=evolutions.model.BaseFileInfo.empty(0,numIdx);
    for idx=1:numIdx
        curFile=filePaths{idx};

        if~isempty(obj.getBaseFileInfoForFile(curFile))

            bfi(end+1)=obj.getBaseFileInfoForFile(curFile);%#ok<AGROW> 
        else
            if isempty(obj.Project.findFile(curFile))


                warningMsg=getString(message...
                ('evolutions:manage:FileNotAddedNotInProject',...
                curFile,obj.Project.Name));
                evolutions.internal.session.EventHandler.publish('Warning',...
                evolutions.internal.ui.GenericEventData(struct('msgId',...
                'evolutions:manage:NoFileAdded','msg',warningMsg)));
                continue;
            end

            mfModel=mf.zero.Model(obj.Constellation);
            baseFile=evolutions.model.BaseFileInfo.createObject(mfModel,...
            struct('Project',obj.Project,'ArtifactRootFolder',...
            convertStringsToChars(obj.ArtifactRootFolder),...
            'FilePath',convertStringsToChars(curFile)));

            bfi(end+1)=baseFile;%#ok<AGROW>
            obj.insert(baseFile);
        end
    end
end


