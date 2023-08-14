function setup(coveng)








    topModelName=get_param(coveng.topModelH,'Name');
    covPath=get_param(topModelName,'CovPath');
    topModelCovpath=cvi.TopModelCov.checkCovPath(topModelName,covPath);
    topModelCovpathSID=Simulink.ID.getSID(topModelCovpath);


    if cvi.SLCustomCodeCov.isMdlCovEnabled(coveng.topModelH)
        predicate=@(x)Simulink.ID.isDescendantOf(topModelCovpathSID,Simulink.ID.getSID(x));
        updateSFcnInfoCov(coveng,topModelCovpath,predicate);
    end



    if cvi.SLCustomCodeCov.isMdlRefCovEnabled(coveng.topModelH)
        mdlRefs=coveng.slccCov.modelRefNameMap.keys();
        predicate=@(x)true;
        for ii=1:numel(mdlRefs)
            updateSFcnInfoCov(coveng,mdlRefs{ii},predicate);
        end
    end


    function updateSFcnInfoCov(coveng,modelName,predicateFcn)


        modelH=get_param(modelName,'Handle');
        modelcovId=get_param(bdroot(modelH),'CoverageId');
        testId=cv('get',modelcovId,'.activeTest');
        fltObj=[];



        if~true&&testId~=0
            filterName=cv('get',testId,'testdata.covFilter');
            if~isempty(filterName)
                fltObj=SlCov.FilterEditor.loadFilter(coveng.topModelH,filterName);
                if isempty(fltObj)||fltObj.isEmpty()
                    fltObj=[];
                end
            end
        end



        fcnH=find_system(modelH,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'BlockType','S-Function');
        sfcnCovObj=coveng.slccCov.sfcnCov;
        sfcnName2Info=sfcnCovObj.sfcnName2Info;
        filteredSFcnSet=sfcnCovObj.filteredSFcnSet;

        for kk=1:numel(fcnH)
            fcnName=SlCov.Utils.fixSFunctionName(get_param(fcnH(kk),'FunctionName'));
            if~sfcnName2Info.isKey(fcnName)

                continue
            end

            fcnPath=getfullname(fcnH(kk));
            fcnSID=Simulink.ID.getSID(fcnH(kk));



            [rootName,id]=strtok(fcnSID,':');
            if coveng.slccCov.modelRefNameMap.isKey(rootName)
                fcnSIDForDb=[coveng.slccCov.modelRefNameMap(rootName),id];
            else
                fcnSIDForDb=fcnSID;
            end

            if predicateFcn(fcnH(kk))


                if~true&&~isempty(fltObj)&&fltObj.isFiltered(fcnSIDForDb)

                    filteredSFcnSet(fcnSIDForDb)={2};
                else

                    instDbFilePath=fullfile(coveng.slccCov.dbPath,[fcnName,'_',strrep(fcnSIDForDb,':','_'),'.db']);


                    fcnInfo=sfcnName2Info(fcnName);
                    instInfo=cvi.SLCustomCodeCov.newInstanceInfoStruct(fcnPath);
                    instInfo.dbFile=SlCov.Utils.fixLongFileName(instDbFilePath);
                    fcnInfo.instances=[fcnInfo.instances,instInfo];
                    sfcnName2Info(fcnName)=fcnInfo;
                end
            else
                filteredSFcnSet(fcnSIDForDb)={1};
            end
        end
