function failed=createModelList(this)






    [~,lGenSettings]=coder.internal.getSTFInfo...
    (this.ModelName,...
    'noTLCSettings',true,...
    'SystemTargetFile',get_param(this.ModelName,'SystemTargetFile'));
    cleanupGenSettingsCache=coder.internal.infoMATFileMgr...
    ([],[],[],[],...
    'InitializeGenSettings',lGenSettings);%#ok<NASGU>


    Simulink.filegen.internal.FolderConfiguration.clearCache();
    this.AllModels=[];
    this.BlackBoxModels=[];
    try

        folders=Simulink.filegen.internal.FolderConfiguration(this.ModelName);
        coder.internal.folders.MarkerFile.checkFolderConfiguration(folders,false);

        [this.AllModels,~,this.ProtectedModels]=slprivate...
        ('get_ordered_model_references',this.ModelName,...
        true,...
        'ModelReferenceTargetType','RTW');
        failed=0;
    catch me
        if~strncmp(me.identifier,'RTW:buildProcess',16)
            rethrow(me);
        end
        this.addCheck(this.ModelName,'Error',me);
        failed=1;
    end



    updateModelList(this);
end

function updateModelList(this)



    if numel(this.AllModels)<=1
        return;
    end



    [refMdls,mdlBlks]=find_mdlrefs(this.getStartNodeName,...
    'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem);


    isLoaded=bdIsLoaded(refMdls);
    load_system(refMdls(~isLoaded));

    currMap=containers.Map();

    for idx=1:numel(mdlBlks)
        currMdl=mdlBlks{idx};


        mdlParts=strsplit(currMdl,'/');
        mdlName=mdlParts{end};
        addtoMap(mdlName,0);

        pathStr=[];
        blackBoxFound=false;


        for ii=1:numel(mdlParts)
            if isempty(pathStr)
                pathStr=mdlParts{ii};
                continue;
            else
                pathStr=[pathStr,'/',mdlParts{ii}];%#ok<AGROW>
            end
            isBlackBox=strcmpi(hdlget_param(pathStr,'Architecture'),'BlackBox');

            if isBlackBox
                blackBoxFound=true;






                k=ii+1;
                for j=k:numel(mdlParts)
                    pathStr=[pathStr,'/',mdlParts{j}];

                    isModelReference=strcmpi(hdlget_param(pathStr,'Architecture'),'ModelReference');
                    if isModelReference

                        mdlName=get_param(pathStr,'ModelName');
                    end
                end
                break;
            end
        end

        if blackBoxFound
            addtoMap(mdlName,-1);
        else
            addtoMap(mdlName,1);
        end
    end


    close_system(refMdls(~isLoaded),0);



    modelRefInsideBlackBox=[];
    for ii=1:numel(this.AllModels)
        modelName=this.AllModels(ii).modelName;
        if currMap.isKey(modelName)
            value=currMap(modelName);
            if value==-1
                modelRefInsideBlackBox=[modelRefInsideBlackBox,ii];%#ok<AGROW>
            end
        end
    end

    for ii=numel(modelRefInsideBlackBox):-1:1
        this.AllModels(modelRefInsideBlackBox(ii))=[];
    end


    function addtoMap(modelName,value)





        if currMap.isKey(modelName)
            oldValue=currMap(modelName);
            if oldValue==1
                return;
            elseif(value==-1)
                if(oldValue==0)
                    currMap(modelName)=value;
                else
                    return;
                end
            else
                currMap(modelName)=value;
            end
        else
            currMap(modelName)=value;
        end
    end
end


