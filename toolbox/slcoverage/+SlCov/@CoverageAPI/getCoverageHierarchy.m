function cvstruct=getCoverageHierarchy(modelH)













    cvstruct=create_structured_data(modelH);


    function[cvstruct,sysCvIds]=create_structured_data(modelH)

        cvstruct=[];
        sysCvIds=[];
        rootId=SlCov.CoverageAPI.getRootId(modelH,[]);
        if isempty(rootId)
            return;
        end
        modelcovId=cv('get',rootId,'.modelcov');
        handle=cv('get',modelcovId,'.handle');
        modelName=SlCov.CoverageAPI.getModelcovName(modelcovId);
        [allMetricNames,allTOMetricNames]=cvi.MetricRegistry.getAllMetricNames;
        metricNames=[allMetricNames,allTOMetricNames];
        cvId=cv('get',rootId,'.topSlsf');
        cvstruct.model.name=modelName;
        cvstruct.model.ssid=Simulink.ID.getSID(handle);
        cvstruct.model.metrics=SlCov.CoverageAPI.getCoverageMetricsDef(cvId,metricNames);
        if isempty(cvstruct.model.metrics)
            return;
        end
        cvstruct.system=[];


        [sysCvIds,blockCvIds,~]=cv('DfsOrder',cvId);


        if isempty(sysCvIds)
            sysCvIds=[];
            return;
        end

        sysCnt=length(sysCvIds);
        blockCnt=length(blockCvIds);



        cvstruct.system=struct(...
        'name',cell(1,sysCnt),...
        'ssid',cell(1,sysCnt),...
        'metrics',cell(1,sysCnt),...
        'sysNum',num2cell(1:sysCnt),...
        'cvId',num2cell(sysCvIds),...
        'sysCvId',cell(1,sysCnt),...
        'subsystemCvId',cell(1,sysCnt),...
        'blockIdx',cell(1,sysCnt));


        if(blockCnt>0)
            cvstruct.block=struct(...
            'name',cell(1,blockCnt),...
            'ssid',cell(1,blockCnt),...
            'metrics',cell(1,blockCnt),...
            'index',num2cell(1:blockCnt),...
            'cvId',num2cell(blockCvIds),...
            'sysCvId',cell(1,blockCnt));
        end







        removeSystems=zeros(1,sysCnt);

        for i=1:sysCnt
            cvId=sysCvIds(i);
            metrics=SlCov.CoverageAPI.getCoverageMetricsDef(cvId,metricNames);
            if~isempty(metrics)
                cvstruct=addSysToCvstruct(cvId,cvstruct,i,blockCvIds,metrics);
            else
                removeSystems(i)=1;
            end
        end





        removeBlocks=zeros(1,blockCnt);
        for i=1:blockCnt
            cvId=blockCvIds(i);
            metrics=SlCov.CoverageAPI.getCoverageMetricsDef(cvId,metricNames);
            if~isempty(metrics)
                cvstruct=addBlockToCvstruct(cvId,cvstruct,i,metrics);
            else
                removeBlocks(i)=1;
            end

        end
        if~isempty(removeBlocks)
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





        removeSystems=logical(removeSystems);

        [removeSystems,cvstruct]=fix_sf_based_block_hierarchy(removeSystems,cvstruct);

        cvstruct.system(removeSystems)=[];
        keepSysCvIds=sysCvIds(~removeSystems);


        for i=1:length(cvstruct.system)
            cvstruct.system(i).subsystemCvId=intersection(cvstruct.system(i).subsystemCvId,keepSysCvIds);
        end

        function cvstruct=addSysToCvstruct(cvId,cvstruct,i,blockCvIds,metrics)

            [origin,parent]=cv('get',cvId,...
            '.origin',...
            '.treeNode.parent');
            name=cv('GetSlsfName',cvId);
            children=cv('ChildrenOf',cvId);
            children=children(children~=cvId);
            isLeaf=(cv('get',children,'.treeNode.child')==0);

            cvstruct.system(i).subsystemCvId=children(~isLeaf);
            blockIds=children(isLeaf);


            if(origin==2)
                cvstruct.system(i).name=['SF: ',name];
            else
                cvstruct.system(i).name=name;
            end


            cvstruct.system(i).ssid=cvi.TopModelCov.getSID(cvId);
            cvstruct.system(i).metrics=metrics;
            cvstruct.system(i).sysCvId=parent;
            if~isempty(blockIds)
                blkCnt=length(blockIds);
                firstChildIdx=find(blockIds(1)==blockCvIds);
                cvstruct.system(i).blockIdx=(1:blkCnt)+firstChildIdx-1;
            end





            function cvstruct=addBlockToCvstruct(cvId,cvstruct,i,metrics)
                [origin,parent]=cv('get',cvId,'.origin','.treeNode.parent');
                name=cv('GetSlsfName',cvId);

                if(origin==2)
                    cvstruct.block(i).name=['SF: ',name];
                else
                    cvstruct.block(i).name=name;
                end

                cvstruct.block(i).ssid=cvi.TopModelCov.getSID(cvId);
                cvstruct.block(i).metrics=metrics;
                cvstruct.block(i).sysCvId=parent;

                function[removeSystems,cvstruct]=fix_sf_based_block_hierarchy(removeSystems,cvstruct)


                    cfChartIsa=sf('get','default','chart.isa');

                    for sysIdx=1:length(cvstruct.system)
                        if~removeSystems(sysIdx)
                            [origin,sfId,sfIsa]=cv('get',cvstruct.system(sysIdx).cvId,'.origin','.handle','.refClass');
                            if(origin==2&&sfIsa==cfChartIsa)
                                if~sfprivate('is_sf_chart',sfId)
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

