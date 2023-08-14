function[blockCvId,portIdx]=find_block_cv_id(rootId,block)






























    persistent sfIsa;

    if isempty(sfIsa)
        sfIsa.state=sf('get','default','state.isa');
        sfIsa.trans=sf('get','default','transition.isa');
        sfIsa.chart=sf('get','default','chart.isa');
        sfIsa.data=sf('get','default','data.isa');
        sfIsa.script=sf('get','default','script.isa');
    end

    portIdx=-1;

    blockCvId=checkScript(rootId,block);
    if~isempty(blockCvId)
        return;
    end
    blockCvId=0;
    sfId=[];
    blockH=[];
    errormsg=[];
    [sfId,blockH,errormsg]=SlCov.CoverageAPI.getBlockIds(block,sfId,blockH,errormsg);

    if~isempty(errormsg)
        blockCvId=errormsg;
        return;
    end


    if~isempty(sfId)
        if~sf('ishandle',sfId)
            errormsg=getString(message('Slvnv:simcoverage:private:SFIdInvalid',sfId));
            blockCvId=errormsg;
            return;
        end
        sfClass=sf('get',sfId,'.isa');

        switch(sfClass)
        case sfIsa.chart
            sfChartId=sfId;
        case sfIsa.state
            sfChartId=sf('get',sfId,'.chart');
        case sfIsa.trans
            sfChartId=sf('get',sfId,'.chart');
            super=sf('get',sfId,'.subLink.parent');
            if super~=0
                sfId=super;
            end

        case sfIsa.data
            dataParent=sf('ParentOf',sfId);
            parentClass=sf('get',dataParent,'.isa');
            switch(parentClass)
            case sfIsa.chart
                sfChartId=dataParent;
            case sfIsa.state
                sfChartId=sf('get',dataParent,'.chart');
            otherwise
                errormsg=getString(message('Slvnv:simcoverage:private:SFMachineParented'));
                blockCvId=errormsg;
                return;
            end

            [~,~,dnumbers]=cvprivate('cv_sf_chart_data',sfChartId);
            dnumbers=sort(dnumbers);

            portIdx=find(dnumbers==sf('get',sfId,'data.number'));
        case sfIsa.script
            modelcovIds=cv('find','all','.isa',cv('get','default','modelcov.isa'));
            scriptModelcovIds=cv('find',modelcovIds,'.isScript',1);
            rootIds=cv('get',scriptModelcovIds,'.rootTree.child');
            scriptCvIds=cv('get',cv('get',rootIds,'.topSlsf'),'.treeNode.child');
            blockCvId=cv('find',scriptCvIds,'.handle',sfId);
            return;
        otherwise
            errormsg=getString(message('Slvnv:simcoverage:private:BlkShouldBeSFData'));
            blockCvId=errormsg;
            return;

        end
    end
    if~isempty(errormsg)
        blockCvId=errormsg;
        return;
    end


    if isempty(sfId)&&~isempty(blockH)&&Sldv.utils.isAtomicSubchartSubsystem(blockH)
        sfChartId=sfprivate('block2chart',blockH);
        sfId=sfChartId;
    end


    if~isempty(sfId)
        if isempty(blockH)
            instances=sf('get',sfChartId,'.instances');
            blockH=sf('get',instances(1),'.simulinkBlock');
            if length(instances)>1
                warning(message('Slvnv:simcoverage:find_block_cv_id:PotentialAmbiguity',sfChartId));
            end
        end
        [blockCvId,allCvIds]=getBlockCvId(rootId,blockH);
        if isempty(allCvIds)&&blockCvId~=0
            allCvIds=cv('DecendentsOf',blockCvId);
        end
        instanceCvId=cv('find',allCvIds,'slsfobj.origPath',Simulink.ID.getSID(blockH));
        if~isempty(instanceCvId)


            if cv('get',instanceCvId,'slsfobj.handle')==sfId||...
                (portIdx>=0)
                blockCvId=instanceCvId;
            else
                allCvIdsInTheInstance=cv('DecendentsOf',instanceCvId);

                blockCvId=cv('find',allCvIdsInTheInstance,'slsfobj.handle',sfId);
            end
        else
            blockCvId=0;
        end

    elseif~isempty(blockH)
        blockCvId=getBlockCvId(rootId,blockH);
    end
    if isempty(blockCvId)||blockCvId==0
        errormsg=getString(message('Slvnv:simcoverage:private:BlkNotInCoverageData'));
        blockCvId=errormsg;
        return;
    end

    function[blockCvId,allCvIds]=getBlockCvId(rootId,blockH)

        blockCvId=cv('FindBlockId',rootId,blockH);

        allCvIds=[];
        if blockCvId==0
            allCvIds=cv('get',rootId,'.topSlsf');
            allCvIds=cv('DecendentsOf',allCvIds);
            blockCvId=cv('find',allCvIds,'slsfobj.handle',blockH);
            if isempty(blockCvId)
                blockCvId=0;
            end
        end

        function cvId=checkScript(rootId,name)
            cvId=[];
            modelcovId=cv('get',rootId,'.modelcov');
            if cv('get',modelcovId,'.isScript')&&ischar(name)
                value=SlCov.CoverageAPI.getModelcovName(modelcovId);
                if endsWith(name,'.m')
                    name=name(1:end-2);
                end
                if strcmpi(value,name)
                    cvId=cv('get',cv('get',rootId,'.topSlsf'),'.treeNode.child');
                end
            end

