function displayOnModel(this,cvstruct,metricNames,toMetricNames,options,hasFilter)





    testCnt=length(cvstruct.tests);
    if testCnt>1
        if options.cumulativeReport
            totalIdx=testCnt;
        else
            totalIdx=testCnt+1;
        end
    else
        totalIdx=1;
    end

    hasCodeCov=isfield(cvstruct,'codeCovRes')&&~cvstruct.codeCovRes.isempty();





    highlightData.fullCovObjs=[];
    highlightData.justifiedCovObjs=[];
    highlightData.missingCovObjs=[];
    highlightData.filteredCovObjs=[];
    highlightData.partialCovSFObjs=[];

    if any(strcmp(metricNames,'decision'))||...
        any(strcmp(metricNames,'condition'))||...
        any(strcmp(metricNames,'mcdc'))||...
        any(strcmp(metricNames,'tableExec'))||...
        ~isempty(toMetricNames)||...
        hasFilter||...
hasCodeCov




        modelH=get_param(cvstruct.model.name,'Handle');
        covColorData=get_param(modelH,'covColorData');
        if isempty(covColorData)
            covColorData=cvi.Informer.covcolordata_struct;
        end

        chartIds=[];
        if~isempty(cvstruct.system)
            [linkInfo,chartIds,removeSys]=compute_sf_cov_display(this,cvstruct,metricNames,toMetricNames,options);

            if~isempty(linkInfo)
                covColorData.sfLinkInfo=linkInfo;
                set_param(modelH,'covColorData',covColorData);
            end

            cvstruct.system(removeSys)=[];



            for i=1:numel(cvstruct.system)
                sysEntry=cvstruct.system(i);
                highlightData=compute_sl_cov_display(this,highlightData,...
                sysEntry,cvstruct,metricNames,toMetricNames,options);
            end
        end
        topSlsf=cv('get',cvstruct.root.cvId,'.topSlsf');
        reportObj.metricNames=metricNames;
        reportObj.toMetricNames=toMetricNames;
        reportObj.cvstruct=cvstruct;
        reportObj.callFromCvmodelview=true;
        highlightData.filteredCovObjs=addFilteredItems(this,topSlsf,reportObj);

        if hasCodeCov
            highlightData=addCodeCovData(this,cvstruct,highlightData,options);
        end

        this.storeColoring(highlightData.fullCovObjs,highlightData.justifiedCovObjs,highlightData.missingCovObjs,highlightData.filteredCovObjs);
        coverage_highlight_diagram(this,cvstruct,highlightData,cvi.HiliteBase.getHighlightingColorTable);



        if~isempty(covColorData.sfLinkInfo)


            instanceH=[covColorData.sfLinkInfo.instanceH];
            for chartIdx=1:numel(instanceH)
                cvi.Informer.SFLibInstanceHighlighting_SLinSF(instanceH(chartIdx),modelH);
            end




            chartIds=unique(chartIds);
            activeInstanceH=sf('get',chartIds,'.activeInstance');
            activeInstanceH(activeInstanceH==0)=[];
            for instH=activeInstanceH(:)'




                cvi.Informer.SFLibInstanceHighlighting(instH);
            end
        end

    end



    function insertFilteredHtml(this,cvid,namedlink,rationale,isJustified)
        rationale=cvi.ReportUtils.str_to_html(rationale);
        if~isa(this,'cvi.BadgeHandler')
            if isJustified
                filtText=getString(message('Slvnv:simcoverage:cvmodelview:isjustified'));
            else
                filtText=getString(message('Slvnv:simcoverage:cvmodelview:isfiltered'));
            end
            text=['<b>',namedlink,'</b> ',filtText,'. <br />'];
        else
            filtText=getString(message('Slvnv:simcoverage:cvmodelview:Filtered'));
            text=[filtText,' <br />'];
        end
        text=[text,'<b>',getString(message('Slvnv:simcoverage:cvmodelview:Rationale')),'</b> ',rationale];
        blkEntry.namedlink=namedlink;
        blkEntry.rationale=rationale;
        blkEntry.cvId=cvid;
        blkEntry.postFix=true;
        this.insertText(blkEntry,text);


        function filteredCovObjs=addFilteredItems(this,topSlsfobj,reportObj)

            info=cvi.ReportScript.getFilteredBlocks(reportObj,[],topSlsfobj,true);
            filteredCovObjs=[];
            if isempty(info)
                return;
            end


            for idx=1:numel(info)
                d=info(idx);

                if cv('get',d.cvId,'.isJustified')
                    continue;
                end
                insertFilteredHtml(this,d.cvId,d.namedlink,d.rationale,d.mode);
                if isempty(d.metricCvIds)&&d.mode==0
                    filteredCovObjs=[filteredCovObjs,d.cvId];%#ok<AGROW>
                end
            end



            function coverage_highlight_diagram(infrmObj,cvstruct,highlightData,colorTable)

                persistent sfFullCovStyle sfNoCovStyle sfMissingCovStyle sfJustifiedCovStyle;

                sfIsa=get_sf_isa;


                if isempty(sfFullCovStyle)||~sf('ishandle',sfFullCovStyle)||...
                    sf('get',sfFullCovStyle,'.isa')~=sfIsa.style
                    sfFullCovStyle=sf('new','style');
                    sf('set',sfFullCovStyle,...
                    'style.name','Full coverage',...
                    'style.blockEdgeColor',colorTable.sfGreen,...
                    'style.wireColor',colorTable.sfGreen,...
                    'style.fontColor',colorTable.sfGreen,...
                    'style.bgColor',colorTable.lightGray);
                end

                if isempty(sfJustifiedCovStyle)||~sf('ishandle',sfJustifiedCovStyle)||...
                    sf('get',sfJustifiedCovStyle,'.isa')~=sfIsa.style
                    sfJustifiedCovStyle=sf('new','style');
                    sf('set',sfJustifiedCovStyle,...
                    'style.name','Justified coverage',...
                    'style.blockEdgeColor',colorTable.sfLightBlue,...
                    'style.wireColor',colorTable.sfLightBlue,...
                    'style.fontColor',colorTable.sfLightBlue,...
                    'style.bgColor',colorTable.lightGray);
                end

                if isempty(sfNoCovStyle)||~sf('ishandle',sfNoCovStyle)||...
                    sf('get',sfNoCovStyle,'.isa')~=sfIsa.style
                    sfNoCovStyle=sf('new','style');
                    sf('set',sfNoCovStyle,...
                    'style.name','No coverage',...
                    'style.blockEdgeColor',colorTable.sfGray,...
                    'style.wireColor',colorTable.sfGray,...
                    'style.fontColor',colorTable.sfGray,...
                    'style.bgColor',colorTable.lightGray);
                end

                if isempty(sfMissingCovStyle)||~sf('ishandle',sfMissingCovStyle)||...
                    sf('get',sfMissingCovStyle,'.isa')~=sfIsa.style
                    sfMissingCovStyle=sf('new','style');
                    sf('set',sfMissingCovStyle,...
                    'style.name','Missing coverage',...
                    'style.blockEdgeColor',colorTable.sfRed,...
                    'style.wireColor',colorTable.sfRed,...
                    'style.fontColor',colorTable.sfRed,...
                    'style.bgColor',colorTable.lightGray);
                end




                [slMissing,sfMissing]=convert_to_handle_vect(highlightData.missingCovObjs);
                [slCovered,sfCovered]=convert_to_handle_vect(highlightData.fullCovObjs);
                [slJustified,sfJustified]=convert_to_handle_vect(highlightData.justifiedCovObjs);
                [slFiltered,sfFiltered]=convert_to_handle_vect(highlightData.filteredCovObjs);

                sfMissing=collect_sublink_trans(sfMissing);
                sfCovered=collect_sublink_trans(sfCovered);
                sfFiltered=collect_sublink_trans(sfFiltered);
                sfJustified=collect_sublink_trans(sfJustified);
                allSFCovs=[sfMissing;sfCovered;sfJustified;sfFiltered];
                hasStateflow=~isempty(allSFCovs);


                if hasStateflow
                    sfChartIds=sf('get',allSFCovs,'chart.id');
                    sfMachIds=sf('get',sfChartIds,'.machine');
                    sfMachIds=unique(sfMachIds);
                    allSfStates=[];
                    allSfTrans=[];

                    for chrt=sfChartIds(:)'
                        allSfStates=[allSfStates,sf('SubstatesIn',chrt)];%#ok<AGROW>
                        allSfTrans=[allSfTrans,sf('TransitionsOf',chrt)];%#ok<AGROW>
                    end
                    for st=allSfStates(:)'
                        allSfTrans=[allSfTrans,sf('TransitionsOf',st)];%#ok<AGROW>
                    end
                    noCovTrans=setdiff(allSfTrans,allSFCovs);
                    noCovStates=setdiff(allSfStates,allSFCovs);
                else
                    sfMachIds=[];
                    noCovTrans=[];
                    noCovStates=[];
                end

                modelH=get_param(cvstruct.model.name,'Handle');
                slMissing=setdiff(slMissing,modelH);
                slCovered=setdiff(slCovered,modelH);
                slJustified=setdiff(slJustified,modelH);
                slFiltered=setdiff(slFiltered,modelH);



                slSystems=get_param(get_param([slMissing;slFiltered;slCovered;slJustified],'Parent'),'Handle');
                if iscell(slSystems)
                    slSystems=unique([slSystems{:}]);
                end


                [prevWarn,prevWarnId]=lastwarn;
                cleanup_lastwarn=onCleanup(@()lastwarn(prevWarn,prevWarnId));
                warnState=warning('query');
                cleanup_warnState=onCleanup(@()warning(warnState));
                warning('off','all');


                if~isempty(sfCovered)
                    sf('SetAltStyle',sfFullCovStyle,sfCovered);
                end
                if~isempty(sfJustified)
                    sf('SetAltStyle',sfJustifiedCovStyle,sfJustified);
                end


                if(hasStateflow)
                    sf('SetAltStyle',sfNoCovStyle,[sfFiltered(:);noCovTrans(:);noCovStates(:)]);
                end

                if~isempty(sfMissing)
                    sf('SetAltStyle',sfMissingCovStyle,sfMissing);
                end


                for mchId=sfMachIds(:)'
                    sf('Redraw',mchId);
                end

                if SlCov.CovStyle.IsFeatureEnabled()
                    covResults.modelH=modelH;
                    covResults.Systems=slSystems;
                    covResults.FullCoverage=slCovered;
                    covResults.PartialCoverage=slMissing;
                    covResults.FilteredCoverage=slFiltered;
                    covResults.JustifiedCoverage=slJustified;

                    covResults.SFCoverage.sfCovered=sfCovered;
                    covResults.SFCoverage.sfMissing=sfMissing;
                    covResults.SFCoverage.sfJustified=sfJustified;
                    covResults.SFCoverage.sfFiltered=sfFiltered;
                    covResults.SFCoverage.noCovTrans=noCovTrans;
                    covResults.SFCoverage.noCovStates=noCovStates;
                    covResults.SFCoverage.partialCovSFObjs=highlightData.partialCovSFObjs;


                    cvslhighlight('apply_style',infrmObj.covStyleSession,covResults);
                else


                    if~isempty(slFiltered)
                        cvslhighlight('apply',modelH,slFiltered,'black',colorTable.slGray);
                    end

                    if~isempty(slSystems)
                        cvslhighlight('apply',modelH,[],[],[],slSystems,colorTable.slGray);
                    end


                    if~isempty(slCovered)
                        cvslhighlight('apply',modelH,slCovered,'black',colorTable.slGreen);
                    end
                    if~isempty(slJustified)
                        cvslhighlight('apply',modelH,slJustified,'black',colorTable.slLightGreen);
                    end


                    if~isempty(slMissing)
                        cvslhighlight('apply',modelH,slMissing,'black',colorTable.slRed);
                    end
                end




                function[slVect,sfIds]=convert_to_handle_vect(idVect)

                    slcvIds=cv('find',idVect,'slsfobj.origin',1);
                    sfcvIds=cv('find',idVect,'slsfobj.origin',2);
                    slVect=cv('get',slcvIds,'slsfobj.handle');
                    sfIds=cv('get',sfcvIds,'slsfobj.handle');
                    slVect=slVect(slVect~=0);
                    sfIds=sfIds(sfIds~=0);


                    function allIds=collect_sublink_trans(mixedIds)

                        allIds=mixedIds;

                        transIsa=sf('get','default','trans.isa');
                        transIds=sf('find',allIds,'.isa',transIsa);

                        subLinks=sf('get',transIds,'.firstSubWire');
                        subLinks(subLinks==0)=[];


                        while(~isempty(subLinks))
                            allIds=[allIds;subLinks];%#ok<AGROW>
                            subLinks=sf('get',subLinks,'.subLink.next');
                            subLinks(subLinks==0)=[];
                        end


                        function out=get_sf_isa

                            persistent sfIsa;

                            if isempty(sfIsa)
                                sfIsa.machine=sf('get','default','machine.isa');
                                sfIsa.chart=sf('get','default','chart.isa');
                                sfIsa.state=sf('get','default','state.isa');
                                sfIsa.transition=sf('get','default','transition.isa');
                                sfIsa.junction=sf('get','default','junction.isa');
                                sfIsa.port=sf('get','default','port.isa');
                                sfIsa.style=sf('get','default','style.isa');
                            end

                            out=sfIsa;



                            function[cvIds,infrmStrs,allFullCov]=compute_sf_sys(this,cvstruct,metricNames,toMetricNames,sysIdx,options)

                                sysEntry=cvstruct.system(sysIdx);
                                [allFullCov,covStr]=installInformerText(this,sysEntry,cvstruct,metricNames,toMetricNames,options);
                                cvIds=sysEntry.cvId;
                                infrmStrs={covStr};


                                is_a_truth_table=0;
                                if cv('get',sysEntry.cvId,'.origin')==2
                                    sfId=cv('get',sysEntry.cvId,'.handle');
                                    if(sf('get',sfId,'.isa')==sf('get','default','state.isa'))
                                        is_a_truth_table=sf('get',sfId,'.truthTable.isTruthTable');
                                    end
                                end

                                if~is_a_truth_table
                                    for blockI=sysEntry.blockIdx(:)'
                                        blkEntry=cvstruct.block(blockI);
                                        [fullCov,covStr]=installInformerText(this,blkEntry,cvstruct,metricNames,toMetricNames,options);
                                        cvIds=[cvIds,blkEntry.cvId];%#ok<AGROW>
                                        infrmStrs=[infrmStrs,{covStr}];%#ok<AGROW>
                                        allFullCov=[allFullCov,fullCov];%#ok<AGROW>
                                    end
                                end




                                function[instStruct,chartIds,removeSys]=compute_sf_cov_display(this,cvstruct,metricNames,toMetricNames,options)

                                    sfIsa=get_sf_isa;

                                    instStruct=[];
                                    chartIds=[];
                                    removeSys=[];


                                    sysIds=[cvstruct.system.cvId];
                                    [sysHandles,sysOrigins,sysIsa]=cv('get',sysIds,'.handle','.origin','.refClass');
                                    isChartSys=(sysOrigins==2&sysIsa==sfIsa.chart);

                                    sfChrtIds=sysHandles(isChartSys);

                                    if isempty(sfChrtIds)
                                        return;
                                    end

                                    [srtIds,sortIdx]=sort(sfChrtIds);
                                    dupSys=[0;srtIds(1:(end-1))==srtIds(2:end)];
                                    dupSys=dupSys|[dupSys(2:end);0];
                                    unsortIdx=1:length(srtIds);
                                    unsortIdx(sortIdx)=unsortIdx;
                                    chartIsDup=dupSys(unsortIdx);
                                    isDupChartSys=false(1,length(sysIds));
                                    isDupChartSys(isChartSys)=chartIsDup;
                                    chartIds=sysHandles(isDupChartSys);

                                    dupChartSys=find(isDupChartSys);
                                    removeSys=dupChartSys;

                                    for dupIdx=dupChartSys

                                        [cvIds,infrmStrs,allFullCov]=compute_sf_sys(this,cvstruct,metricNames,toMetricNames,dupIdx,options);
                                        childSysIdx=descendent_sys_ind(cvstruct,dupIdx);
                                        removeSys=[removeSys,childSysIdx];%#ok<AGROW>
                                        for childIdx=childSysIdx
                                            [ids,strs,fullCov]=compute_sf_sys(this,cvstruct,metricNames,toMetricNames,childIdx,options);
                                            cvIds=[cvIds,ids];%#ok<AGROW>
                                            infrmStrs=[infrmStrs,strs];%#ok<AGROW>
                                            allFullCov=[allFullCov,fullCov];%#ok<AGROW>
                                        end



                                        [refBlockH,instanceH]=cvstruct_instance_handle(cvstruct,dupIdx);

                                        thisElm=struct('instanceH',instanceH,...
                                        'refBlockH',refBlockH,...
                                        'cvIds',cvIds,...
                                        'informerStrings',{infrmStrs},...
                                        'isFullCoverage',allFullCov);

                                        if isempty(instStruct)
                                            instStruct=thisElm;
                                        else
                                            instStruct(end+1)=thisElm;%#ok<AGROW>
                                        end
                                    end


                                    function childSysIdx=descendent_sys_ind(cvstruct,parentIdx)
                                        parentDepth=cvstruct.system(parentIdx).depth;


                                        childSysIdx=[];
                                        childIdx=parentIdx+1;
                                        while(childIdx<=length(cvstruct.system)&&cvstruct.system(childIdx).depth>parentDepth)
                                            childSysIdx=[childSysIdx,childIdx];%#ok<AGROW>
                                            childIdx=childIdx+1;
                                        end


                                        function[refBlockH,instanceH]=cvstruct_instance_handle(cvstruct,chartSysIdx)
                                            cvId=cvstruct.system(chartSysIdx).cvId;
                                            instancePath=Simulink.ID.getFullName(cv('get',cvId,'.origPath'));
                                            instanceH=get_param(instancePath,'handle');

                                            refBlockH=get_param(get_param(instanceH,'ReferenceBlock'),'Handle');

                                            function highlightData=compute_sl_missing(this,highlightData,dataEntry,cvstruct,metricNames,toMetricNames,options)
                                                [allFullCov,covTxt,partialCovSFObjs]=installInformerText(this,dataEntry,cvstruct,metricNames,toMetricNames,options);


                                                if allFullCov==-1
                                                    return
                                                end
                                                if~isempty(this)
                                                    this.insertText(dataEntry,covTxt);
                                                end

                                                cvId=dataEntry.cvId;
                                                if allFullCov==0
                                                    highlightData.missingCovObjs=[highlightData.missingCovObjs,cvId];
                                                elseif allFullCov==1
                                                    highlightData.fullCovObjs=[highlightData.fullCovObjs,cvId];
                                                elseif allFullCov==2
                                                    highlightData.justifiedCovObjs=[highlightData.justifiedCovObjs,cvId];
                                                end
                                                if(~isempty(partialCovSFObjs))
                                                    if(isempty(highlightData.partialCovSFObjs))
                                                        highlightData.partialCovSFObjs=partialCovSFObjs;
                                                    else
                                                        highlightData.partialCovSFObjs(end+1)=partialCovSFObjs;
                                                    end
                                                end


                                                function highlightData=compute_sl_cov_display(this,highlightData,sysEntry,cvstruct,metricNames,toMetricNames,options)

                                                    highlightData=compute_sl_missing(this,highlightData,sysEntry,cvstruct,metricNames,toMetricNames,options);

                                                    for blockI=sysEntry.blockIdx(:)'
                                                        blkEntry=cvstruct.block(blockI);
                                                        highlightData=compute_sl_missing(this,highlightData,blkEntry,cvstruct,metricNames,toMetricNames,options);
                                                    end

                                                    function highlightData=addCodeCovData(this,cvstruct,highlightData,options)

                                                        persistent modeStr2Label;
                                                        if isempty(modeStr2Label)
                                                            modeStr2Label=containers.Map(...
                                                            {'SIL','PIL','ModelRefSIL','ModelRefPIL'},...
                                                            {...
                                                            getString(message('Slvnv:simcoverage:cvmodelview:LabelSILShort')),...
                                                            getString(message('Slvnv:simcoverage:cvmodelview:LabelPILShort')),...
                                                            getString(message('Slvnv:simcoverage:cvmodelview:LabelSILShort')),...
                                                            getString(message('Slvnv:simcoverage:cvmodelview:LabelPILShort'))...
                                                            });
                                                        end

                                                        if options.generatWebViewReportData==1
                                                            commandType=2;
                                                        else
                                                            commandType=1;
                                                        end

                                                        persistent codeCovDefs;
                                                        if isempty(codeCovDefs)
                                                            codeCovDefs={...
                                                            internal.cxxfe.instrum.MetricKind.DECISION;...
                                                            internal.cxxfe.instrum.MetricKind.CONDITION;...
                                                            internal.cxxfe.instrum.MetricKind.MCDC;...
                                                            internal.cxxfe.instrum.MetricKind.STATEMENT;...
                                                            internal.cxxfe.instrum.MetricKind.RELATIONAL_BOUNDARY...
                                                            };
                                                        end

                                                        modes=cvstruct.codeCovRes.keys();
                                                        for ii=1:numel(modes)

                                                            if modeStr2Label.isKey(modes{ii})
                                                                modeStr=modeStr2Label(modes{ii});
                                                            else
                                                                modeStr=modes{ii};
                                                            end

                                                            covRes=cvstruct.codeCovRes(modes{ii});

                                                            res=covRes.getAggregatedResults();

                                                            slModelElements=covRes.CodeTr.getSLModelElements();
                                                            if isempty(slModelElements)
                                                                continue
                                                            end


                                                            hasCoverage=false(numel(slModelElements),1);
                                                            fullCoverage=true(numel(slModelElements),1);
                                                            fullJustifiedCoverage=true(numel(slModelElements),1);
                                                            for jj=1:size(codeCovDefs,1)
                                                                metricKind=codeCovDefs{jj};
                                                                if~covRes.isActive(metricKind)
                                                                    continue
                                                                end
                                                                for kk=1:numel(slModelElements)
                                                                    stats=res.getDeepMetricStats(slModelElements(kk),metricKind);
                                                                    if stats.numNonExcluded>0
                                                                        hasCoverage(kk)=true;
                                                                        if stats.numCovered<stats.numNonExcluded
                                                                            fullCoverage(kk)=false;
                                                                            if(stats.numCovered+stats.numJustifiedUncovered)<stats.numNonExcluded
                                                                                fullJustifiedCoverage(kk)=false;
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                            codeCovObjs=[slModelElements(hasCoverage).modelCovId];
                                                            missingCodeCovObjs=[slModelElements(~fullCoverage&~fullJustifiedCoverage).modelCovId];
                                                            fullCodeCovObjs=[slModelElements(hasCoverage&fullCoverage).modelCovId];
                                                            fullJustifiedCodeCovObjs=[slModelElements(hasCoverage&~fullCoverage&fullJustifiedCoverage).modelCovId];


                                                            blocksIdx=arrayfun(@(e)isa(e,'internal.cxxfe.instrum.SLBlock'),slModelElements);
                                                            slBlocks=slModelElements(blocksIdx);

                                                            blockHasCoverage=false(numel(slBlocks),1);
                                                            blockFullCoverage=true(numel(slBlocks),1);
                                                            blockFullJustifiedCoverage=true(numel(slBlocks),1);
                                                            for jj=1:size(codeCovDefs,1)
                                                                metricKind=codeCovDefs{jj};
                                                                if~covRes.isActive(metricKind)
                                                                    continue
                                                                end
                                                                for kk=1:numel(slBlocks)
                                                                    stats=res.getShallowMetricStats(slBlocks(kk),metricKind);
                                                                    if stats.numNonExcluded>0
                                                                        blockHasCoverage(kk)=true;
                                                                        if stats.numCovered<stats.numNonExcluded
                                                                            blockFullCoverage(kk)=false;
                                                                            if(stats.numCovered+stats.numJustifiedUncovered)<stats.numNonExcluded
                                                                                blockFullJustifiedCoverage(kk)=false;
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                            allBlockObjs=[slBlocks.modelCovId];


                                                            codeCovObjs=[codeCovObjs,allBlockObjs(blockHasCoverage)];%#ok<AGROW>
                                                            missingCodeCovObjs=[missingCodeCovObjs,allBlockObjs(~blockFullCoverage&~blockFullJustifiedCoverage)];%#ok<AGROW>
                                                            fullCodeCovObjs=[fullCodeCovObjs,allBlockObjs(blockHasCoverage&blockFullCoverage)];%#ok<AGROW>
                                                            fullJustifiedCodeCovObjs=[fullJustifiedCodeCovObjs,allBlockObjs(blockHasCoverage&~blockFullCoverage&blockFullJustifiedCoverage)];%#ok<AGROW>



                                                            codeCovObjs(codeCovObjs==0)=[];
                                                            missingCodeCovObjs(missingCodeCovObjs==0)=[];
                                                            fullCodeCovObjs(fullCodeCovObjs==0)=[];
                                                            fullJustifiedCodeCovObjs(fullJustifiedCodeCovObjs==0)=[];


                                                            highlightData.filteredCovObjs(ismember(highlightData.filteredCovObjs,codeCovObjs))=[];
                                                            highlightData.missingCovObjs=unique([highlightData.missingCovObjs,missingCodeCovObjs]);
                                                            highlightData.fullCovObjs=unique([highlightData.fullCovObjs,fullCodeCovObjs,fullJustifiedCodeCovObjs]);
                                                            highlightData.fullCovObjs(ismember(highlightData.fullCovObjs,highlightData.missingCovObjs))=[];


                                                            allObjs=[slModelElements.modelCovId];
                                                            [~,idx]=ismember([missingCodeCovObjs,fullJustifiedCodeCovObjs],allObjs);
                                                            for kk=idx(:)'
                                                                cvId=allObjs(kk);
                                                                covStr=this.getText(cvId);
                                                                if~isempty(covStr)
                                                                    covMode=getString(message('Slvnv:simcoverage:cvmodelview:LabelNormalShort'));
                                                                    covStr=['<u>',covMode,': </u>','<br/>',covStr,newline];%#ok<AGROW>
                                                                end

                                                                informerTxt=[covStr,'<u>',modeStr,': </u>',getCodeCoverageInformerText(covRes,res,slModelElements(kk))];

                                                                this.insertText(struct('cvId',cvId),informerTxt,true);
                                                            end


                                                            for cvId=fullCodeCovObjs(:)'
                                                                covStr=this.getText(cvId);
                                                                if~isempty(covStr)
                                                                    covMode=getString(message('Slvnv:simcoverage:cvmodelview:LabelNormalShort'));
                                                                    covStr=['<u>',covMode,': </u>',covStr,'<br/>',newline];%#ok<AGROW>
                                                                end
                                                                this.insertText(struct('cvId',cvId),[covStr,'<u>',modeStr,': </u>',getString(message('Slvnv:simcoverage:cvmodelview:FullCoverage'))],true);
                                                            end
                                                        end


                                                        function str=getCodeCoverageInformerText(covRes,res,slModelElement)

                                                            persistent codeCovDefs

                                                            if isempty(codeCovDefs)
                                                                codeCovDefs={...
                                                                internal.cxxfe.instrum.MetricKind.DECISION,'Decision';...
                                                                internal.cxxfe.instrum.MetricKind.CONDITION,'Condition';...
                                                                internal.cxxfe.instrum.MetricKind.MCDC,'MCDC';...
                                                                internal.cxxfe.instrum.MetricKind.STATEMENT,'Statement';...
                                                                internal.cxxfe.instrum.MetricKind.RELATIONAL_BOUNDARY,'RelationalBoundary'...
                                                                };
                                                            end

                                                            row=1;
                                                            col=1;
                                                            strTable=[];

                                                            for ii=1:size(codeCovDefs,1)

                                                                metricKind=codeCovDefs{ii,1};
                                                                if~covRes.isActive(metricKind)
                                                                    continue
                                                                end

                                                                if isa(slModelElement,'internal.cxxfe.instrum.SLSubsystem')
                                                                    stats=res.getDeepMetricStats(slModelElement,metricKind);
                                                                else
                                                                    stats=res.getShallowMetricStats(slModelElement,metricKind);
                                                                end


                                                                count=stats.numNonExcluded;
                                                                if count==0
                                                                    continue
                                                                end

                                                                hit=stats.numCovered;
                                                                justifiedHit=stats.numJustifiedUncovered;

                                                                if justifiedHit>0
                                                                    strTable{row,col}=sprintf('%s %2.0f%% ((%d+%d)/%d)',...
                                                                    getString(message(['Slvnv:simcoverage:cvmodelview:',codeCovDefs{ii,2}])),...
                                                                    100*(hit+justifiedHit)/count,hit,justifiedHit,count);%#ok<AGROW>
                                                                else
                                                                    strTable{row,col}=sprintf('%s %2.0f%% (%d/%d)',...
                                                                    getString(message(['Slvnv:simcoverage:cvmodelview:',codeCovDefs{ii,2}])),...
                                                                    100*hit/count,hit,count);%#ok<AGROW>
                                                                end


                                                                if col==2
                                                                    col=1;
                                                                    row=row+1;
                                                                else
                                                                    col=2;
                                                                end
                                                            end

                                                            if col==1
                                                                rowCnt=row-1;
                                                            else
                                                                rowCnt=row;
                                                                strTable{row,col}=' ';
                                                            end

                                                            if row==1&&col==1
                                                                str='';
                                                                return
                                                            end

                                                            tableInfo.table='  CELLPADDING="2" CELLSPACING="1"';
                                                            tableInfo.cols=struct('align','LEFT');

                                                            template={{'ForN',rowCnt,...
                                                            {'ForN',2,...
                                                            {'#.','@2','@1'},...
                                                            },...
'\n'...
                                                            }};

                                                            str=cvprivate('html_table',strTable,template,tableInfo);
