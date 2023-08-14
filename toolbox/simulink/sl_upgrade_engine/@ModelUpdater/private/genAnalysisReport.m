function updateInfo=genAnalysisReport(h)









    append=false;

    updateInfo.Message=DAStudio.message('SimulinkUpgradeAdvisor:advisor:notification','','');
    allUpdatedBlocks={h.Transactions(:).name};
    [updateInfo.blockList,idx]=unique(allUpdatedBlocks);

    if isempty(idx)
        idx=[];
        updateInfo.blockList={};
    end
    updateInfo.blockReasons={h.Transactions(idx).reason};
    updateInfo.transactions=h.Transactions;



    try


        updateInfo.modelList=find_mdlrefs(h.MyModel,'AllLevels',true,...
        'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);

    catch e
        updateInfo.Message=DAStudio.message('SimulinkUpgradeEngine:engine:findMdlRefsFailedMessage',...
        e.identifier,e.message);
        updateInfo.modelList={};
        append=true;
    end



    try
        updateInfo.libraryList=ModelUpdater.findLibsInModel(h.MyModel);
    catch e
        if append
            updateInfo.Message=[updateInfo.Message,newline,...
            DAStudio.message('SimulinkUpgradeEngine:engine:findLibsFailedMessage',...
            e.identifier,e.message)];
        else
            updateInfo.message=DAStudio.message('SimulinkUpgradeEngine:engine:findLibsFailedMessage',...
            e.identifier,e.message);
        end
        updateInfo.libraryList={};
    end



    updateInfo.configSetList=h.UpdateMsgs;




    sfunBlks=find_system(h.MyModel,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,...
    'BlockType','S-Function');
    sfunList=cell(size(sfunBlks));

    for k=1:numel(sfunBlks)
        sfunList{k}=get_param(sfunBlks{k},'FunctionName');
    end
    sfunList=unique(sfunList);
    sfunOK=false(numel(sfunList),1);
    sfunType=repmat({'-'},numel(sfunList),1);
    factoryRoot=fullfile(matlabroot,'toolbox');
    keepInd=~sfunOK;
    for k=1:numel(sfunList)
        try
            sfunFile=which(sfunList{k});
            if isempty(sfunFile)
                sfunOK(k)=false;
                sfunType{k}='missing';
            else


                [sPath,~,sExt]=fileparts(sfunFile);
                isFactorySfun=contains(sPath,factoryRoot);
                keepInd(k)=~isFactorySfun;

                if keepInd(k)
                    if strmatch(sExt(2:end),{'m','p'})
                        sfunType{k}='m';
                    elseif strcmp(sExt(2:end),mexext)
                        sfunType{k}='mex';
                    end

                    if~isFactorySfun&&strcmp(sfunType{k},'m')

                        result=feval(sfunList{k},[],[],[],0);
                        sfunOK(k)=(numel(result)>=8);
                    else




                        sfunOK(k)=true;
                    end
                end
            end
        catch %#ok<CTCH>
            sfunOK(k)=false;
        end
    end
    updateInfo.sfunList=sfunList(keepInd);
    updateInfo.sfunOK=sfunOK(keepInd);
    updateInfo.sfunType=sfunType(keepInd);

end
