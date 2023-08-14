function[varargout]=cv_autoscale_settings(method,modelH)



    persistent CovSettingsCache;

    switch(lower(method))
    case 'save'
        CovSettingsCache=save_autoscale(CovSettingsCache,modelH);
    case 'restore'
        CovSettingsCache=restore_autoscale(CovSettingsCache,modelH);
    case 'isforce'
        varargout{1}=is_force(CovSettingsCache,modelH);
    otherwise
        error(message('Slvnv:simcoverage:cv_autoscale_settings:UnknownMethod'));
    end

    function CovSettingsCache=save_autoscale(CovSettingsCache,modelH)


        modelIndex=model_find_index(CovSettingsCache,modelH);


        covLicensed=license('test',SlCov.CoverageAPI.getLicenseName);
        recordCoverage=strcmp(get_param(modelH,'RecordCoverage'),'on');
        covPath=get_param(modelH,'CovPath');
        covMetricSettings=get_param(modelH,'CovMetricSettings');
        rangeCovEnabled=contains(covMetricSettings,'r');
        forceCov=~covLicensed||~recordCoverage;



        if isempty(modelIndex)

            CovSettingsCache=[CovSettingsCache,struct('handle',modelH,...
            'forceCov',forceCov,...
            'enable',recordCoverage,...
            'metricString',covMetricSettings,...
            'path',covPath)];
        else

            CovSettingsCache(modelIndex).forceCov=forceCov;
            CovSettingsCache(modelIndex).enable=recordCoverage;
            CovSettingsCache(modelIndex).metricString=covMetricSettings;
            CovSettingsCache(modelIndex).path=covPath;
        end

        oldDirtyFlag=get_param(modelH,'dirty');

        if(~recordCoverage||~covLicensed)



            set_param(modelH,'RecordCoverageOverride','forceon');
            set_param(modelH,'CovMetricSettings','r');
            set_param(modelH,'CovPath',path_to_smallest_sf_model_part(modelH));
        else


            if~rangeCovEnabled
                set_param(modelH,'CovMetricSettings',[covMetricSettings,'r']);
            end
        end

        set_param(modelH,'dirty',oldDirtyFlag);


        function CovSettingsCache=restore_autoscale(CovSettingsCache,modelH)


            modelIndex=model_find_index(CovSettingsCache,modelH);


            if isempty(modelIndex)
                return;
            end


            oldDirtyFlag=get_param(modelH,'dirty');
            set_param(modelH,'RecordCoverageOverride','leavealone');
            set_param(modelH,'CovPath',CovSettingsCache(modelIndex).path);
            set_param(modelH,'CovMetricSettings',CovSettingsCache(modelIndex).metricString);
            set_param(modelH,'dirty',oldDirtyFlag);

            function result=is_force(CovSettingsCache,modelH)


                result=0;


                modelIndex=model_find_index(CovSettingsCache,modelH);


                if isempty(modelIndex)
                    return;
                end


                result=CovSettingsCache(modelIndex).forceCov;


                function index=model_find_index(CovSettingsCache,modelH)

                    if isempty(CovSettingsCache)
                        index=[];
                        return;
                    end

                    allModels=[CovSettingsCache.handle];
                    index=find(allModels==modelH);








                    function path=path_to_smallest_sf_model_part(modelH)
                        modelName=get_param(modelH,'Name');
                        blks=find_sf_logging_blocks(modelName);
                        ancH=deepest_common_ancestor(blks);
                        if(ancH==modelH)
                            path='/';
                        else
                            path=getfullname(ancH);
                            mdlNameLength=length(modelName);
                            path=path((mdlNameLength+1):end);
                        end

                        function blks=find_sf_logging_blocks(model)
                            if~ischar(model)
                                model=get_param(model,'Name');
                            end

                            blks=[];
                            rt=sfroot;
                            machine=rt.find('-isa','Stateflow.Machine','-and','Name',model);
                            if~isempty(machine)


                                chartsObjs=machine.findDeep('Chart');
                                chartIds=[];
                                for i=1:length(chartsObjs)
                                    chartIds=[chartIds,chartsObjs(i).Id];%#ok<AGROW>
                                end
                                blocks=sf('Private','chart2block',chartIds);


                                logs=get_param(blocks,'MinMaxOverflowLogging_Compiled');


                                isMinMaxOver=strcmp(logs,'MinMaxAndOverflow');
                                isOverOnly=strcmp(logs,'OverflowOnly');
                                blks=blocks(isMinMaxOver|isOverOnly);
                            end


                            function ancH=deepest_common_ancestor(blockList)
                                if length(blockList)==1
                                    ancH=blockList;
                                    return;
                                end


                                ancVect=find_all_ancestors(blockList(1));

                                for idx=2:length(blockList)
                                    ancVect=update_ancestors(ancVect,blockList(idx));
                                end

                                ancH=ancVect(end);


                                function ancVect=find_all_ancestors(blkH)
                                    modelH=bdroot(blkH);
                                    objH=blkH;
                                    ancVect=[];

                                    while(objH~=modelH)
                                        ancVect=[objH,ancVect];%#ok<AGROW>
                                        objH=get_param(get_param(objH,'Parent'),'Handle');
                                    end

                                    ancVect=[modelH,ancVect];


                                    function ancVect=update_ancestors(ancVect,blkH)
                                        modelH=bdroot(blkH);
                                        objH=blkH;

                                        while(~any(ancVect==objH)&&objH~=modelH)
                                            objH=get_param(get_param(objH,'Parent'),'Handle');
                                        end

                                        idx=find(ancVect==objH);
                                        if isempty(idx)
                                            error(message('Slvnv:simcoverage:cv_autoscale_settings:NoCommonAncestor'));
                                        end

                                        ancVect=ancVect(1:idx);

