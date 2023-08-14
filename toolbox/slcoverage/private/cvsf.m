function varargout=cvsf(method,varargin)






    try
        switch(method)
        case 'InitChartInstance'
            chartId=varargin{1};
            instanceHandle=varargin{2};
            if chartId==0
                chartId=sf('Private','block2chart',instanceHandle);
            end

            [cvStateIds,cvTransIds,cvDataInd,cvChartId]=init_chart_instance(chartId,instanceHandle);

            varargout{1}=cvStateIds;
            varargout{2}=cvTransIds;
            if nargout==3
                varargout{3}=cvChartId;
            else
                varargout{3}=cvDataInd;
                varargout{4}=cvChartId;
            end
        case 'ReloadIds'
            cvChartId=varargin{1};
            reload_old_instance_ids(cvChartId);
        case 'InitScript'
            scriptNum=varargin{1};
            scriptId=varargin{2};
            instanceHandle=varargin{3};
            chartId=sf('Private','block2chart',instanceHandle);
            if isempty(sf('get',scriptId,'.name'))
                varargout{1}=[];
            else
                varargout{1}=cvi.TopModelCov.scriptInit(scriptId,scriptNum,chartId,instanceHandle);
            end
        otherwise
            error(message('Slvnv:simcoverage:cvsf:UnknownMethod',method));
        end
    catch MEx
        display(MEx.stack(1));
        error(message('Slvnv:simcoverage:cvsf:error',MEx.message));
    end


    function markOrigInited(coveng,slFullPath)
        if~isfield(coveng.multiInstanceNormaModeSf,'inited')
            coveng.multiInstanceNormaModeSf.inited=containers.Map('KeyType','char','ValueType','any');
        end
        coveng.multiInstanceNormaModeSf.inited(slFullPath)=true;




        function[origPath,origIsInitedNow,coveng]=checkMultiInstanceNormalMode(chartId,instanceHandle)




            slFullPath=getfullname(instanceHandle);
            copiedModelName=bdroot(slFullPath);

            origModelName=get_param(copiedModelName,'ModelReferenceNormalModeOriginalModelName');
            isMdlRefInstanceCovEnabled=SlCov.CoverageAPI.isModelRefInstanceCovEnabled(origModelName);
            origIsInitedNow=strcmpi(origModelName,copiedModelName)||...
            isMdlRefInstanceCovEnabled;

            coveng=cvi.TopModelCov.getInstance(origModelName);

            if~isfield(coveng.multiInstanceNormaModeSf,'map')
                coveng.multiInstanceNormaModeSf.map=containers.Map('KeyType','char','ValueType','any');
            end

            if isMdlRefInstanceCovEnabled
                origPath=[copiedModelName,slFullPath(strfind(slFullPath,'/'):end)];
            else
                origPath=[origModelName,slFullPath(strfind(slFullPath,'/'):end)];
            end
            origPath=Simulink.ID.getSID(origPath);

            ci.machineId=sf('get',chartId,'.machine');
            ci.chartId=chartId;
            ci.modelName=get_param(bdroot(slFullPath),'name');
            ci.path=origPath;
            ci.instanceHandle=instanceHandle;
            if coveng.multiInstanceNormaModeSf.map.isKey(origPath)
                coveng.multiInstanceNormaModeSf.map(origPath)=[{ci},coveng.multiInstanceNormaModeSf.map(origPath)];
            else
                coveng.multiInstanceNormaModeSf.map(origPath)={ci};

                if(origIsInitedNow)
                    markOrigInited(coveng,origPath);
                    origIsInitedNow=false;
                end
            end






            function[cvStateIds,cvTransIds,cvDataInd,cvChartId]=init_chart_instance(chartId,instanceHandle)
                cvChartId=0;
                cvStateIds=[];
                cvTransIds=[];
                cvDataInd=[];

                [origPath,origIsInitedNow,coveng]=checkMultiInstanceNormalMode(chartId,instanceHandle);

                origInited=isfield(coveng.multiInstanceNormaModeSf,'inited')&&...
                coveng.multiInstanceNormaModeSf.inited.isKey(origPath);


                if~(origInited||origIsInitedNow)
                    return;
                end
                slHandle=Simulink.ID.getHandle(origPath);
                cvChartSubsysId=get_param(slHandle,'CoverageId');


                existingCvChartId=cv('find',cv('ChildrenOf',cvChartSubsysId),'slsfobj.refClass',sf('get','default','chart.isa'));


                if~isempty(existingCvChartId)

                    if sf('ishandle',cv('get',existingCvChartId,'.handle'))
                        [cvStateIds,cvTransIds]=find_all_stateflow_ids(existingCvChartId);
                        cvChartId=existingCvChartId;
                        if~isempty(cvStateIds)||~isempty(cvTransIds)
                            [cvDataInd,~,~]=get_data_ind(chartId);
                        end
                        return;
                    else
                        cv('PruneTreeNode',existingCvChartId);
                    end
                end
                [cvStateIds,cvTransIds,cvDataInd,cvChartId]=create_sf_hierarchy(chartId,origPath,cvChartSubsysId);

                if origIsInitedNow
                    ck=coveng.multiInstanceNormaModeSf.map(origPath);
                    for idx=1:numel(ck)
                        ci=ck{idx};
                        if strcmpi(ci.path,origPath)
                            continue;
                        end

                        sfunName=[ci.modelName,'_sfun'];
                        feval(sfunName,'sf_debug_api','set_instance_cv_ids',ci.machineId,ci.chartId,ci.instanceHandle,cvStateIds,cvTransIds,cvChartId);
                    end
                    cv('RefreshSFCvIds',chartId,cvTransIds,sf('get','default','transition.isa'),cvStateIds,sf('get','default','state.isa'));
                    markOrigInited(coveng,origPath);
                end


                function[cvStateIds,cvTransIds,cvDataInd,cvChartId]=create_sf_hierarchy(chartId,origPath,cvChartSubsysId)
                    cvChartId=0;
                    cvStateIds=[];
                    cvTransIds=[];
                    cvDataInd=[];




                    if(cvChartSubsysId==0)
                        return;
                    end



                    if sfprivate('is_eml_chart',chartId)||...
                        sfprivate('is_truth_table_chart',chartId)
                        cv('set',cvChartSubsysId,'.refClass',-99);
                    end




                    modelcovId=cv('get',cvChartSubsysId,'.modelcov');
                    cvChartId=cv('new','slsfobj',1,...
                    '.origin','STATEFLOW_OBJ',...
                    '.modelcov',modelcovId,...
                    '.origPath',origPath,...
                    '.refClass',sf('get','default','chart.isa'));
                    cv('BlockAdoptChildren',cvChartSubsysId,cvChartId);
                    cv('set',cvChartId,'.handle',chartId);

                    [cvStateIds,cvTransIds]=create_sf(chartId,cvChartId,modelcovId);
                    cvDataInd=add_sigrange(chartId,cvChartId);

                    function[cvStateIds,cvTransIds]=create_sf(chartId,cvChartId,modelcovId)


                        stateIds=sf('AllSubstatesIn',chartId,false,false);
                        stateIds=sf('find',stateIds,'~state.isNoteBox',1);
                        cvStateIds=[];
                        cvTransIds=[];
                        sfMatlabChart=Stateflow.MALUtils.isMalChart(chartId);

                        if~isempty(stateIds)
                            stateNmbrs=sf('get',stateIds,'.number');
                            [~,sortI]=sort(stateNmbrs);
                            stateIds=stateIds(sortI);

                            cvStateIds=cv('new','slsfobj',length(stateIds),...
                            '.origin','STATEFLOW_OBJ',...
                            '.modelcov',modelcovId,...
                            '.refClass',sf('get','default','state.isa'));









                            if sf('Private','is_eml_chart',chartId)

                                cv('SetSlsfName',cvStateIds(1),sf('get',chartId,'.eml.name'));
                            elseif sf('Private','is_truth_table_chart',chartId)

                                cv('SetSlsfName',cvStateIds(1),sf('get',chartId,'.name'));
                            end

                            for i=1:length(stateIds)
                                cv('set',cvStateIds(i),'.handle',stateIds(i));
                                cv('SetSlsfName',cvStateIds(i),sf('get',stateIds(i),'.name'));

                                if(sf('get',stateIds(i),'.type')==3)
                                    cv('SetSlsfName',cvStateIds(i),sf('get',stateIds(i),'.labelString'));
                                end


                                if sf('Private','is_eml_based_fcn',stateIds(i))
                                    codeBlockId=cv('new','codeblock',1,'.slsfobj',cvStateIds(i));
                                    cv('SetScript',codeBlockId,sf('get',stateIds(i),'state.eml.script'));
                                    cv('CodeBloc','refresh',codeBlockId);
                                    cv('set',cvStateIds(i),'.code',codeBlockId);

                                elseif sfMatlabChart
                                    codeBlockId=cv('new','codeblock',1,'.slsfobj',cvStateIds(i));
                                    cv('SetScript',codeBlockId,sf('get',stateIds(i),'.labelString'));
                                    cv('CodeBloc','refresh',codeBlockId);
                                    cv('set',cvStateIds(i),'.code',codeBlockId);
                                end
                            end
                            create_descendent_hierarchy(chartId,cvStateIds,chartId,cvChartId);
                        end



                        transIds=sf('Private','chart_real_transitions',chartId);
                        transIds=sf('find',transIds,'~transition.dst.id',0);
                        if~isempty(transIds)
                            transNmbrs=sf('get',transIds,'.number');
                            [~,sortI]=sort(transNmbrs);
                            transIds=transIds(sortI);

                            cvTransIds=cv('new','slsfobj',length(transIds),...
                            '.origin','STATEFLOW_OBJ',...
                            '.modelcov',modelcovId,...
                            '.refClass',sf('get','default','transition.isa'));
                            for i=1:length(transIds)
                                cv('set',cvTransIds(i),'.handle',transIds(i));
                                cv('SetSlsfName',cvTransIds(i),sf('get',transIds(i),'.labelString'));
                                if sfMatlabChart
                                    codeStr=sf('get',transIds(i),'.labelString');
                                    codeBlockId=cv('new','codeblock',1,'.slsfobj',cvTransIds(i));
                                    cv('SetScript',codeBlockId,codeStr);
                                    cv('SetSlsfName',cvTransIds(i),codeStr);
                                    cv('CodeBloc','refresh',codeBlockId);
                                    cv('set',cvTransIds(i),'.code',codeBlockId);
                                end
                            end
                        end




                        for i=1:length(transIds)
                            trans=transIds(i);
                            sfParent=sf('ParentOf',trans);
                            if(sfParent==chartId)
                                cv('BlockAdoptChildren',cvChartId,cvTransIds(i));
                            else
                                cv('BlockAdoptChildren',cvStateIds(sf('get',sfParent,'state.number')+1),cvTransIds(i));
                            end
                        end

                        function[cvDataInd,sortI,dwidths]=get_data_ind(chartId)



                            cvDataInd=[];
                            sortI=[];
                            dwidths=[];
                            if sf('Private','is_eml_chart',chartId)||...
                                sf('Private','is_truth_table_chart',chartId)
                                return;
                            end
                            [~,dwidths,dnumbers]=cv_sf_chart_data(chartId);
                            cvDataInd=99999*ones(1,max(dnumbers)+1);
                            [sortNumbers,sortI]=sort(dnumbers);
                            for i=1:length(sortNumbers)
                                cvDataInd(sortNumbers(i)+1)=i-1;
                            end

                            function cvDataInd=add_sigrange(chartId,cvChartId)




                                [cvDataInd,sortI,dwidths]=get_data_ind(chartId);
                                if isempty(cvDataInd)
                                    return;
                                end
                                srId=cv('new','sigranger',1,...
                                'slsfobj',cvChartId);
                                cv('set',srId,'.cov.allWidths',dwidths(sortI)');
                                cv('set',srId,'.cov.isDynamic',zeros(1,length(dwidths)));
                                cv('set',srId,'.modelcov',cv('get',cvChartId,'.modelcov'));




                                SREnum=cvi.MetricRegistry.getEnum('sigrange');
                                cv('MetricInsert',cvChartId,SREnum,srId);







                                function create_descendent_hierarchy(sfId,stateCvIds,sfChartId,cvChartId)

                                    sfSubstates=sf('AllSubstatesOf',sfId,false,false);
                                    sfSubstates=sf('find',sfSubstates,'~state.isNoteBox',1);

                                    cvChildren=stateCvIds(sf('get',sfSubstates,'state.number')+1);

                                    if(sfId==sfChartId)
                                        cvParent=cvChartId;
                                    else
                                        cvParent=stateCvIds(sf('get',sfId,'state.number')+1);
                                    end

                                    cv('BlockAdoptChildren',cvParent,cvChildren);


                                    for child=sfSubstates(:)'
                                        create_descendent_hierarchy(child,stateCvIds,sfChartId,cvChartId);
                                    end






                                    function reload_old_instance_ids(cvChartId)
                                        modelcovId=cv('get',cvChartId,'.modelcov');
                                        modelName=SlCov.CoverageAPI.getModelcovName(modelcovId);

                                        [cvStates,cvTrans,~]=find_all_stateflow_ids(cvChartId);

                                        coveng=cvi.TopModelCov.getInstance(modelName);
                                        origPath=cv('get',cvChartId,'.origPath');

                                        ck=coveng.multiInstanceNormaModeSf.map(origPath);
                                        for idx1=1:numel(ck)
                                            ci=ck{idx1};
                                            sfunName=[ci.modelName,'_sfun'];
                                            covrtSetInstanceCvIds(ci.instanceHandle,cvChartId,cvStates,cvTrans);
                                        end
                                        coveng.multiInstanceNormaModeSf.map(origPath)={};
                                        chartId=cv('get',cvChartId,'slsfobj.handle');
                                        cv('RefreshSFCvIds',chartId,cvTrans,sf('get','default','transition.isa'),cvStates,sf('get','default','state.isa'));


                                        function[cvStates,cvTrans,cvChart]=find_all_stateflow_ids(cvChartId)
                                            sfIsa.state=sf('get','default','state.isa');
                                            sfIsa.trans=sf('get','default','transition.isa');
                                            sfIsa.chart=sf('get','default','chart.isa');

                                            mixedIds=cv('FindDescendantsUntil',cvChartId,sfIsa.chart);

                                            if~isempty(mixedIds)

                                                mixedIsa=cv('get',mixedIds,'.refClass');

                                                cvStates=mixedIds(mixedIsa==sfIsa.state);
                                                cvTrans=mixedIds(mixedIsa==sfIsa.trans);
                                                cvChart=mixedIds(mixedIsa==sfIsa.chart);
                                                if~isempty(cvStates)

                                                    sfStates=cv('get',cvStates,'.handle');


                                                    sfStates=sf('Private','filter_out_commented_objects',sfStates);
                                                    if(~isempty(sfStates))
                                                        stateNmbrs=sf('get',sfStates,'.number');
                                                        [~,sortI]=sort(stateNmbrs);
                                                        cvStates=cvStates(sortI);
                                                    else
                                                        cvStates=[];
                                                    end
                                                end

                                                if~isempty(cvTrans)

                                                    sfTrans=cv('get',cvTrans,'.handle');


                                                    sfTrans=sf('Private','filter_out_commented_objects',sfTrans);
                                                    if(~isempty(sfTrans))
                                                        transNmbrs=sf('get',sfTrans,'.number');
                                                        [~,sortI]=sort(transNmbrs);
                                                        cvTrans=cvTrans(sortI);
                                                    else
                                                        cvTrans=[];
                                                    end
                                                end
                                            else
                                                cvStates=[];
                                                cvTrans=[];
                                                cvChart=[];
                                            end



