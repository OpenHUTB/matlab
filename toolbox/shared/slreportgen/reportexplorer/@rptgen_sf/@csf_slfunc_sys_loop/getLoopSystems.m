function hList=getLoopSystems(c,varargin)






    hList={};


    context=get(rptgen_sf.appdata_sf,'CurrentObject');
    if~isa(context,'Stateflow.SLFunction')
        return;
    end

    if c.isFilterList
        searchTerms=[{'RegExp','on'},c.FilterTerms(:)',varargin(:)'];
    elseif~isempty(varargin)
        searchTerms=[{'RegExp','on'},varargin(:)'];
    else
        searchTerms={};
    end

    chartInnerPath=sf('FullName',context.Id,context.Chart.Id,'.');
    chartPath=sf('FullName',context.Chart.Id,'/');
    slFuncRoot=[chartPath,'/',chartInnerPath];
    if~isempty(searchTerms)
        searchTerms=LocWashSearchTerms(searchTerms);
        hList=find_system(slFuncRoot,...
        'BlockType','SubSystem',...
        'SearchDepth',0,...
        searchTerms{:});
    else


        hList=find_system(slFuncRoot,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem');
    end

    hList=rptgen_sl.filterNonReportableSystem(hList);

    if(~c.IncludeNestedCharts)
        hList=LocOmitNestedChartSubsystems(slFuncRoot,hList);
    end

    hList=locSort(hList,c.SortBy);


    function sList=locSort(sList,sortBy)

        if isempty(sList)
            return;
        end

        switch sortBy
        case 'numBlocks'


            blockList=rptgen.safeGet(sList,'blocks','get_param');
            okEntries=find(cellfun('isclass',blockList,'cell'));
            blockList=blockList(okEntries);
            sList=sList(okEntries);

            blockList=cellfun('length',blockList);
            [~,sortIndex]=sort(blockList);
            sList=sList(sortIndex(end:-1:1));
        case{'alphabetical','systemalpha'}
            nameList=rptgen.safeGet(sList,'name','get_param');
            okEntries=find(~strcmp(nameList,'N/A'));
            nameList=nameList(okEntries);
            sList=sList(okEntries);

            [~,nameIndex]=sort(lower(nameList));
            sList=sList(nameIndex);
        case 'depth'
            depthList=getPropValue(rptgen_sl.propsrc_sl_sys,...
            sList,'Depth');

            okEntries=find(cellfun('isclass',depthList,'double'));
            depthList=[depthList{okEntries}]';
            sList=sList(okEntries);

            [~,depthIndex]=sort(depthList);
            sList=sList(depthIndex);
        otherwise

        end
        sList=sList(:);

































        function t=LocWashSearchTerms(t)

            numTerms=length(t);
            if rem(numTerms,2)>0

                t{end+1}='';
                numTerms=numTerms+1;
            end

            emptyCells=find(cellfun('isempty',t));
            emptyNames=emptyCells(1:2:end-1);
            emptyNames=emptyNames(:);

            removeCells=[emptyNames;emptyNames+1];
            okCells=setdiff([1:numTerms],removeCells);

            t=t(okCells);



            function oList=LocOmitNestedChartSubsystems(slFunc,iList)

                oList={};
                if isempty(iList)
                    return;
                end

                for i=1:length(iList)
                    currSys=iList{i};
                    while true
                        if strcmp(currSys,slFunc)
                            oList=[oList;iList{i}];
                            break;
                        end
                        if strcmp(get_param(currSys,'SFBlockType'),'Chart')
                            break;
                        end
                        currSys=get_param(currSys,'Parent');
                    end
                end
