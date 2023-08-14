function blkEntriesSorted=sortBlocksCustomOrder(this,blockIdxs)





    try
        if isempty(blockIdxs)
            blkEntriesSorted=[];
            return;
        end

        blkEntries=this.cvstruct.block(blockIdxs);
        blkEntriesSorted=blkEntries;


        [origins,sfIds]=cv('get',[blkEntries.cvId],'.origin','.handle');
        if(origins(1)==2)
            chartId=sf('get',sfIds(1),'.chart');
            if Stateflow.ReqTable.internal.isRequirementsTable(chartId)
                model=Stateflow.ReqTable.internal.TableManager.getDataModel(chartId);
                spec=Stateflow.ReqTable.internal.TableManager.getSpecBlockFromModel(model);
                rows=spec.requirementsTable.getAllTableRowsRecursively();
                preCondSSIdArray=[rows.preConditionSSId];
                covSSIdArray=sf('get',sfIds,'.ssIdNumber');
                reqIdxs=arrayfun(@(ssid)find(preCondSSIdArray==ssid),covSSIdArray,'UniformOutput',false);
                reqs=rows([reqIdxs{:}]);
                [~,sortedIdxs]=sort(str2double({reqs.idString}));
                blkEntriesSorted=blkEntries(sortedIdxs);
            end
        end
    catch Mex
        rethrow(Mex);

    end

