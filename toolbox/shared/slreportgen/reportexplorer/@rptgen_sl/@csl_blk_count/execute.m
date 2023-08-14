function out=execute(c,d,varargin)







    out='';

    switch lower(getContextType(rptgen_sl.appdata_sl,c,false));
    case 'model'
        if strcmp(c.IncludeBlocks,'all')
            mdlName=get(rptgen_sl.appdata_sl,'CurrentModel');
            if~isempty(mdlName)


                bList=find_system(mdlName,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks','on',...
                'LookUnderMasks','all',...
                'type','block');
            else
                c.status(getString(message('RptgenSL:rsl_csl_blk_count:noCurrentModelLabel')),2);
                return;
            end
        else
            bList=get(rptgen_sl.appdata_sl,'ReportedBlockList');
        end
    case 'system'
        currSys=get(rptgen_sl.appdata_sl,'CurrentSystem');
        if~isempty(currSys)
            bList=find_system(currSys,...
            'SearchDepth',1,...
            'FollowLinks','on',...
            'LookUnderMasks','all',...
            'type','block');

            bList=bList(2:end);
        else
            c.status(getString(message('RptgenSL:rsl_csl_blk_count:noCurrentSystemLabel')),2);
            return;
        end
    case 'block'
        c.status(getString(message('RptgenSL:rsl_csl_blk_count:cannotCountInsideBlockLoopLabel')),2);
        return;
    case 'signal'
        c.status(getString(message('RptgenSL:rsl_csl_blk_count:cannotCountInsideSignalLoopLabel')),2);
        return;
    case 'annotation'
        c.status(getString(message('RptgenSL:rsl_csl_blk_count:cannotCountInsideAnnotationLoopLabel')),2);
        return;
    case 'configset'
        c.status(getString(message('RptgenSL:rsl_csl_blk_count:cannotCountInsideConfigSetLoopLabel')),2);
        return;
    otherwise
        startModels=find_system('type','block_diagram',...
        'blockdiagramtype','model');
        startModels=setdiff(startModels,{'temp_rptgen_model'});


        bList=find_system(startModels,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'type','block');
    end

    if isempty(bList)
        c.status('No blocks found',2);
        return;
    end

    allTypes=rptgen.safeGet(bList,'MaskType','get_param');

    emptyMask=cellfun('isempty',allTypes);
    maskIdx=find(~emptyMask);
    if~isempty(maskIdx)
        allTypes(maskIdx)=strcat(allTypes(maskIdx),' (m)');
    end

    for i=1:length(bList)
        thisBlk=bList(i);
        if slprivate('is_stateflow_based_block',thisBlk)
            allTypes(i)=get_param(thisBlk,'SFBlockType');
        end
    end

    unfilled=cellfun('isempty',allTypes);
    unfilledIdx=find(unfilled);
    if~isempty(unfilledIdx)
        allTypes(unfilledIdx)=rptgen.safeGet(bList(unfilledIdx),'BlockType','get_param');
    end

    [uniqTypes,aIndex,bIndex]=unique(allTypes);

    for i=length(uniqTypes):-1:1
        origIndex=find(bIndex==bIndex(aIndex(i)));
        numTypes{i,1}=length(origIndex);
        typeBlocks{i,1}=bList(origIndex);
    end

    switch c.SortOrder
    case 'alpha'
        [sortedTypes,sortIndex]=sort(uniqTypes);
    case 'numblocks'
        [sortedNums,sortIndex]=sort([numTypes{:}]);

        sortIndex=sortIndex(end:-1:1);
    otherwise
        sortIndex=[1:length(uniqTypes)];
    end

    tableCells=[[{getString(message('RptgenSL:rsl_csl_blk_count:blockTypeLabelNoSpace'))};uniqTypes(sortIndex)],...
    [{getString(message('RptgenSL:rsl_csl_blk_count:countLabel'))};numTypes(sortIndex)]];

    r=rptgen.appdata_rg;
    psSL=rptgen_sl.propsrc_sl;
    if c.isBlockName
        typeBlocks=typeBlocks(sortIndex);


        colIndex=3;
        tableCells{1,colIndex}=getString(message('RptgenSL:rsl_csl_blk_count:blockNamesLabel'));

        for i=length(typeBlocks):-1:1
            tableCells{i+1,colIndex}=psSL.makeLink(typeBlocks{i},...
            '','link',d,'',', ');
        end
        cWid=[2,1,4];
    else
        cWid=[3,1];
    end

    if c.IncludeTotal
        tableCells(end+1,1:2)={getString(message('RptgenSL:rsl_csl_blk_count:totalLabel')),length(bList)};
        footerCount=1;
    else
        footerCount=0;
    end


    tm=makeNodeTable(d,...
    tableCells,...
    0,...
    true);

    tm.setColWidths(cWid);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(footerCount);
    tm.setTitle(rptgen.parseExpressionText(c.TableTitle));

    out=tm.createTable;
