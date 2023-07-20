function hList=getLoopSystems(c,varargin)






    if c.isFilterList
        searchTerms=[{'RegExp','on'},c.FilterTerms(:)',varargin(:)'];
    elseif~isempty(varargin)
        searchTerms=[{'RegExp','on'},varargin(:)'];
    else
        searchTerms={};
    end

    if strcmp(c.LoopType,'list')

        hList=parselist(c.ObjectList);
    else

        switch lower(getContextType(rptgen_sl.appdata_sl,c,false))
        case{'system','signal','block','annotation'}
            hList={get(rptgen_sl.appdata_sl,'CurrentSystem')};
        case 'configset'
            hList={};
            return;
        case 'model'
            hList=get(rptgen_sl.appdata_sl,'ReportedSystemList');
        otherwise
            mList=find_system('SearchDepth',1,...
            'BlockDiagramType','model');
            mList=setdiff(mList,{'temp_rptgen_model'});


            hList=find_system(mList,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'Type','block',...
            'BlockType','SubSystem');
            hList=union(mList,hList);
            hList=rptgen_sl.filterNonReportableSystem(hList);
        end
    end

    if~isempty(searchTerms)
        searchTerms=LocWashSearchTerms(searchTerms);
        hList=find_system(hList,...
        'SearchDepth',0,...
        searchTerms{:});
    end

    if~c.IncludeSLFunctions
        hList=LocOmitSLFunctions(hList);
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

            [depthList,depthIndex]=sort(depthList);
            sList=sList(depthIndex);
        otherwise

        end
        sList=sList(:);


        function newList=parselist(oldList)

            newList={};
            for i=1:length(oldList)
                currString=oldList{i};
                if isempty(currString)

                elseif strncmp(currString,'%<',2)&&strcmp(currString(end),'>')

                    currString=currString(3:end-1);
                    try
                        rezString=evalin('base',currString);
                    catch
                        rezString=[];
                    end

                    if ischar(rezString)&&size(rezString,1)==1
                        newList{end+1,1}=rezString;
                    elseif iscell(rezString)&&min(size(rezString))==1
                        newList=[newList(:);rezString(:)];
                    elseif isnumeric(rezString)&&min(size(rezString))==1
                        rezString=num2cell(rezString);
                        newList=[newList(:);rezString(:)];
                    end
                else
                    newList{end+1,1}=currString;
                end
            end



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



                function oList=LocOmitSLFunctions(iList)

                    oList={};
                    if isempty(iList)
                        return;
                    end

                    for i=1:length(iList)
                        currSys=iList{i};
                        while true
                            if strcmp(get_param(currSys,'Type'),'block_diagram')
                                oList=[oList;iList{i}];
                                break;
                            end
                            if slreportgen.utils.isSimulinkFunction(currSys)
                                break;
                            end
                            currSys=get_param(currSys,'Parent');
                        end
                    end
