function[cvstruct,sysCvIds]=report_create_structured_data(allTests,testIds,metricNames,toMetricNames,options,waitbarH,onlyTopSystem)


    if nargin<7
        onlyTopSystem=false;
    end

    if nargin<6
        waitbarH=[];
    end

    modelcovId=cv('get',allTests{1}.rootId,'.modelcov');
    modelName=cvi.TopModelCov.getNameFromCvId(modelcovId);

    cvi.ReportData.updateDataIdx(allTests{1});

    cvstruct.root.cvId=allTests{1}.rootId;
    cvstruct.tests=testIds;
    cvstruct.allCvData=allTests;
    cvstruct.model.name=modelName;
    cvstruct.model.cvId=modelcovId;
    cvstruct.system=[];
    cvId=cv('get',allTests{1}.rootId,'.topSlsf');

    cvstruct.model.topSystemName=cvi.TopModelCov.getNameFromCvId(cvId);

    cvstruct.enabledMetricNames=[];
    cvstruct.enabledTOMetricNames=[];


    if isempty(metricNames)&&isempty(toMetricNames)
        sysCvIds=[];
        return;
    end


    allmetrics=cvi.MetricRegistry.getDDEnumVals;



    [sysCvIds,blockCvIds,depths]=cv('DfsOrder',cvId,'ignore',allmetrics.MTRC_SIGRANGE);


    if isempty(sysCvIds)
        sysCvIds=[];
        return;
    end

    reportData=cvi.ReportData(allTests);


    for i=1:length(metricNames)
        if~(strcmpi(metricNames{i},'sigrange')||...
            strcmpi(metricNames{i},'sigsize'))
            reportData.addMetricData(metricNames{i},allTests);
        end
    end

    if~isempty(toMetricNames)
        reportData.addTestobjectiveData(toMetricNames,allTests);
    end

    if~onlyTopSystem
        cvstruct.sfcnCovRes=cvi.SFunctionCov.extractResultsInfo(allTests,blockCvIds);
    end

    if(onlyTopSystem)
        sysCvIds=sysCvIds(1);
        depths=depths(1);
        blockCvIds=[];
    end
    sysCnt=length(sysCvIds);
    blockCnt=length(blockCvIds);



    waitInc=sysCnt+blockCnt;
    waitVal=0;


    metricCnt=length(metricNames);
    metricSysPreAlloc(1:2:(2*metricCnt-1))=metricNames;
    metricBlkPreAlloc=metricSysPreAlloc;

    for i=1:metricCnt
        metricSysPreAlloc{2*i}=cell(1,sysCnt);
        metricBlkPreAlloc{2*i}=cell(1,blockCnt);
    end

    cvstruct.system=struct(...
    'name',cell(1,sysCnt),...
    'sysNum',num2cell(1:sysCnt),...
    'cvId',num2cell(sysCvIds),...
    'depth',num2cell(depths),...
    'complexity',cell(1,sysCnt),...
    'sysCvId',cell(1,sysCnt),...
    'subsystemCvId',cell(1,sysCnt),...
    'blockIdx',cell(1,sysCnt),...
    'flags',cell(1,sysCnt),...
    metricSysPreAlloc{:});


    if(blockCnt>0)
        cvstruct.block=struct(...
        'name',cell(1,blockCnt),...
        'index',num2cell(1:blockCnt),...
        'cvId',num2cell(blockCvIds),...
        'complexity',cell(1,blockCnt),...
        'sysCvId',cell(1,blockCnt),...
        'flags',cell(1,blockCnt),...
        metricBlkPreAlloc{:});
    end

    [enabledMetricNames,enabledTOMetricNames,cvstruct.enabledMetrics]=...
    cvi.ReportUtils.getMetricsForSummary(allTests,metricNames,toMetricNames,options);
    assert(all(ismember(metricNames,enabledMetricNames)),'Recorded metric not found in list of enabled metrics');
    assert(all(ismember(toMetricNames,enabledTOMetricNames)),'Recorded TO metric not found in list of enabled TO metrics');

    cvstruct.enabledMetricNames=enabledMetricNames;
    cvstruct.enabledTOMetricNames=enabledTOMetricNames;

    minfo.metricNames=metricNames;
    minfo.toMetricNames=toMetricNames;
    minfo.allmetrics=allmetrics;


    minfo.metricObjs=cell(1,length(metricNames));
    minfo.metricObjsCnt=num2cell(zeros(1,length(metricNames)));
    minfo.toMetricObjs=cell(1,length(toMetricNames));
    minfo.toMetricObjsCnt=num2cell(zeros(1,length(toMetricNames)));






    removeSystems=zeros(1,sysCnt);

    for i=1:sysCnt
        cvId=sysCvIds(i);
        if~isDisabled(cvId)
            [cvstruct,minfo,noData]=addSysToCvstruct(cvId,cvstruct,i,minfo,onlyTopSystem,blockCvIds,reportData);
            removeSystems(i)=noData;
        else
            removeSystems(i)=1;
        end

        if(~isempty(waitbarH))
            waitVal=waitVal+1;
            waitbarH.setValue(waitVal/waitInc*100);
        end
    end





    removeBlocks=zeros(1,blockCnt);
    for i=1:blockCnt
        cvId=blockCvIds(i);
        if~isDisabled(cvId)
            [cvstruct,minfo,noData]=addBlockToCvstruct(cvId,cvstruct,i,minfo,reportData);
            removeBlocks(i)=noData;
        else
            removeBlocks(i)=1;
        end

        if(~isempty(waitbarH))
            waitVal=waitVal+1;
            waitbarH.setValue(waitVal/waitInc*100);
        end
    end
    if any(removeBlocks)
        removeBlocks=logical(removeBlocks);
        cvstruct.block(removeBlocks)=[];
        ol2new=(1:length(removeBlocks))-cumsum(removeBlocks);


        for i=1:sysCnt
            if~isempty(cvstruct.system(i).blockIdx)
                removeIdx=removeBlocks(cvstruct.system(i).blockIdx);
                cvstruct.system(i).blockIdx(removeIdx)=[];
                cvstruct.system(i).blockIdx=ol2new(cvstruct.system(i).blockIdx);
            end
        end
    end




    for j=1:length(minfo.metricNames)
        thisMetric=minfo.metricNames{j};
        if~isempty(minfo.metricObjs{j})
            cvstruct=reportData.getMetricInfo(cvstruct,minfo.metricObjs{j},thisMetric,options);
        end
    end
    for j=1:length(minfo.toMetricNames)
        thisMetric=minfo.toMetricNames{j};
        if~isempty(minfo.toMetricObjs{j})
            cvstruct=reportData.getTestobjectiveInfo(cvstruct,minfo.toMetricObjs{j},thisMetric);
        end
    end




    if options.elimFullCov
        fullcovSys=find_full_coverage_systems(removeSystems,cvstruct);
        removeSystems=logical(removeSystems|fullcovSys);
    else
        removeSystems=logical(removeSystems);
    end

    [removeSystems,cvstruct]=fix_sf_based_block_hierarchy(removeSystems,cvstruct);

    cvstruct.system(removeSystems)=[];
    keepSysCvIds=sysCvIds(~removeSystems);


    for i=1:length(cvstruct.system)
        cvstruct.system(i).subsystemCvId=intersection(cvstruct.system(i).subsystemCvId,keepSysCvIds);
    end



    function res=isDisabled(cvId)
        res=cv('get',cvId,'.isDisabled');


        function[cvstruct,minfo,noData]=addSysToCvstruct(cvId,cvstruct,i,minfo,onlyTopSystem,blockCvIds,reportData)

            [origin,parent]=cv('get',cvId,...
            '.origin',...
            '.treeNode.parent');
            name=cvi.TopModelCov.getNameFromCvId(cvId);
            [cmplx_ismodule,cmplx_shallow,cmplx_deep,var_cmplx_shallowIdx,var_cmplx_deepIdx,hasVariableSize]=cv('MetricGet',cvId,minfo.allmetrics.MTRC_CYCLCOMPLEX,...
            '.dataIdx.deep','.dataCnt.shallow','.dataCnt.deep','.dataCnt.varShallowIdx','.dataCnt.varDeepIdx','.hasVariableSize');

            if isempty(cmplx_ismodule)
                cmplx_ismodule=0;
                cmplx_shallow=0;
                cmplx_deep=0;
            end


            var_cmplx_deep=0;
            var_cmplx_shallow=0;
            if hasVariableSize
                if(var_cmplx_deepIdx>=0)
                    var_cmplx_deep=reportData.metricData.decision(var_cmplx_deepIdx+1,end);
                end
                if(var_cmplx_shallowIdx>=0)
                    var_cmplx_shallow=reportData.metricData.decision(var_cmplx_shallowIdx+1,end);
                end
            end


            children=cv('ChildrenOf',cvId,'ignore',minfo.allmetrics.MTRC_SIGRANGE);
            children=children(children~=cvId);
            isLeaf=(cv('get',children,'.treeNode.child')==0);

            cvstruct.system(i).subsystemCvId=children(~isLeaf);

            blockIds=children(isLeaf);


            cvstruct.system(i).complexity=struct('isModule',cmplx_ismodule,...
            'shallow',cmplx_shallow,...
            'deep',cmplx_deep,...
            'varShallow',var_cmplx_shallow,...
            'varDeep',var_cmplx_deep);


            if(origin==2)
                cvstruct.system(i).name=['SF: ',name];
            else
                cvstruct.system(i).name=name;
            end

            cvstruct.system(i).sysCvId=parent;
            if~onlyTopSystem&&~isempty(blockIds)
                blkCnt=length(blockIds);
                firstChildIdx=find(blockIds(1)==blockCvIds);
                cvstruct.system(i).blockIdx=(1:blkCnt)+firstChildIdx-1;
            end





            flags.fullCoverage=-1;
            flags.noCoverage=-1;
            flags.leafUncov=0;

            noData=1;

            for k=1:length(cvstruct.enabledMetricNames)
                thisMetric=cvstruct.enabledMetricNames{k};
                [isMetricRelevant,j]=ismember(thisMetric,minfo.metricNames);
                if isMetricRelevant
                    [data,objs]=reportData.getSystemMetric(cvstruct.system(i),minfo.metricObjsCnt{j},thisMetric);
                else
                    data=[];
                end
                cvstruct.system(i).(thisMetric)=data;
                if~isempty(data)
                    minfo.metricObjs{j}=[minfo.metricObjs{j},objs];
                    minfo.metricObjsCnt{j}=minfo.metricObjsCnt{j}+length(objs);
                    [noData,flags]=buildFlags(noData,flags,data.flags);
                end
            end
            for k=1:numel(cvstruct.enabledTOMetricNames)
                thisMetric=cvstruct.enabledTOMetricNames{k};
                [isMetricRelevant,j]=ismember(thisMetric,minfo.toMetricNames);
                if isMetricRelevant
                    [data,objs]=reportData.getSystemTestobjective(cvstruct.system(i),minfo.toMetricObjsCnt{j},thisMetric);
                else
                    data=[];
                end
                cvstruct.system(i).(thisMetric)=data;
                if~isempty(data)
                    minfo.toMetricObjs{j}=[minfo.toMetricObjs{j},objs];
                    minfo.toMetricObjsCnt{j}=minfo.toMetricObjsCnt{j}+length(objs);
                    [noData,flags]=buildFlags(noData,flags,data.flags);
                end
            end

            cvstruct.system(i).flags=flags;


            function[cvstruct,minfo,noData]=addBlockToCvstruct(cvId,cvstruct,i,minfo,reportData)
                [origin,parent]=cv('get',cvId,'.origin','.treeNode.parent');
                name=cvi.TopModelCov.getNameFromCvId(cvId);
                [cmplx_ismodule,cmplx_shallow,cmplx_deep,var_cmplx_shallowIdx,var_cmplx_deepIdx,hasVariableSize]=cv('MetricGet',cvId,minfo.allmetrics.MTRC_CYCLCOMPLEX,...
                '.dataIdx.deep','.dataCnt.shallow','.dataCnt.deep','.dataCnt.varShallowIdx','.dataCnt.varDeepIdx','.hasVariableSize');

                if isempty(cmplx_ismodule)
                    cmplx_ismodule=0;
                    cmplx_shallow=0;
                    cmplx_deep=0;
                end


                var_cmplx_deep=0;
                var_cmplx_shallow=0;
                if hasVariableSize
                    if(var_cmplx_deepIdx>=0)
                        var_cmplx_deep=reportData.metricData.decision(var_cmplx_deepIdx+1,end);
                    end
                    if(var_cmplx_shallowIdx>=0)
                        var_cmplx_shallow=reportData.metricData.decision(var_cmplx_shallowIdx+1,end);
                    end
                end



                if(origin==2)
                    cvstruct.block(i).name=['SF: ',name];
                else
                    cvstruct.block(i).name=name;
                end
                cvstruct.block(i).sysCvId=parent;
                cvstruct.block(i).complexity=struct('isModule',cmplx_ismodule,...
                'shallow',cmplx_shallow,...
                'deep',cmplx_deep,...
                'varShallow',var_cmplx_shallow,...
                'varDeep',var_cmplx_deep);






                noData=1;
                flags.fullCoverage=-1;
                flags.noCoverage=-1;
                flags.leafUncov=0;

                for j=1:length(minfo.metricNames)
                    thisMetric=minfo.metricNames{j};
                    [data,objs]=reportData.getBlockMetric(cvstruct.block(i),minfo.metricObjsCnt{j},thisMetric);
                    cvstruct.block(i).(thisMetric)=data;
                    if~isempty(data)&&isfield(data,'flags')
                        minfo.metricObjs{j}=[minfo.metricObjs{j},objs];
                        minfo.metricObjsCnt{j}=minfo.metricObjsCnt{j}+length(objs);
                        [noData,flags]=buildFlags(noData,flags,data.flags);
                    end
                end
                for metricsIdx=1:length(minfo.toMetricNames)
                    thisMetric=minfo.toMetricNames{metricsIdx};
                    [data,objs]=reportData.getBlockTestobjective(cvstruct.block(i),minfo.toMetricObjsCnt{metricsIdx},thisMetric);
                    cvstruct.block(i).(thisMetric)=data;
                    if~isempty(data)
                        minfo.toMetricObjs{metricsIdx}=[minfo.toMetricObjs{metricsIdx},objs];
                        minfo.toMetricObjsCnt{metricsIdx}=minfo.toMetricObjsCnt{metricsIdx}+length(objs);
                        [noData,flags]=buildFlags(noData,flags,data.flags);
                    end
                end


                cvstruct.block(i).flags=flags;

                function[noData,flags]=buildFlags(noData,flags,thisMetricFlags)


                    if~isempty(thisMetricFlags)
                        noData=0;
                        if(isfield(thisMetricFlags,'fullCoverage'))
                            if(thisMetricFlags.fullCoverage)
                                if(flags.fullCoverage==-1)
                                    flags.fullCoverage=1;
                                    flags.noCoverage=0;
                                end
                            else
                                flags.fullCoverage=0;
                            end
                        end

                        if(isfield(thisMetricFlags,'noCoverage'))
                            if(thisMetricFlags.noCoverage)
                                if(flags.noCoverage==-1)
                                    flags.noCoverage=1;
                                    flags.fullCoverage=0;
                                end
                            else
                                flags.noCoverage=0;
                            end
                        end

                        if(isfield(thisMetricFlags,'leafUncov')&&...
                            thisMetricFlags.leafUncov)
                            flags.leafUncov=1;
                        end
                    end



                    function[removeSystems,cvstruct]=fix_sf_based_block_hierarchy(removeSystems,cvstruct)


                        cfChartIsa=sf('get','default','chart.isa');

                        for sysIdx=1:length(cvstruct.system)
                            if~removeSystems(sysIdx)
                                [origin,sfId,sfIsa]=cv('get',cvstruct.system(sysIdx).cvId,'.origin','.handle','.refClass');
                                if(origin==2&&sfIsa==cfChartIsa)
                                    if~sf('Private','is_sf_chart',sfId)&&...
                                        ~Stateflow.STT.StateEventTableMan.isStateEventTableChart(sfId)
                                        kernelFcnBlockIdx=cvstruct.system(sysIdx).blockIdx;
                                        parentSysIdx=sysIdx-1;

                                        cvstruct.system(parentSysIdx).blockIdx=kernelFcnBlockIdx;
                                        removeSystems(sysIdx)=1;
                                    end
                                end
                            end
                        end

                        function out=intersection(s1,s2)
                            r=sort([s1(:);s2(:)]);
                            I=(r(1:(end-1))==r(2:end));
                            out=r(I);





                            function removeSystems=find_full_coverage_systems(removeSystems,cvstruct)
                                sysCnt=length(cvstruct.system);
                                for i=1:sysCnt
                                    if~isempty(cvstruct.system(i).flags)&&...
                                        ((cvstruct.system(i).flags.fullCoverage==1)&&...
                                        ~strcmpi(cvstruct.system(i).name,cvstruct.model.topSystemName))
                                        removeSystems(i)=1;
                                    end
                                end
