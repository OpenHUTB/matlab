function hList=loop_getLoopObjects(c,varargin)








    if c.isFilterList
        re={'RegExp','on'};
        ft=c.FilterTerms(:)
    elseif~isempty(varargin)
        re={'RegExp','on'};
        ft=varargin;
    else
        re={};
        ft={};
    end


    adSL=rptgen_sl.appdata_sl;
    switch lower(getContextType(adSL,c,false))
    case 'annotation'
        hList=get(rptgen_sl.appdata_sl,'CurrentAnnotation');
        if~isempty(ft)
            hList=find_system(hList,...
            re{:},...
            'SearchDepth',0,...
            ft{:});
        end
    case 'system'
        sysList=get(rptgen_sl.appdata_sl,'CurrentSystem');
        hList=find_system(sysList,...
        'SearchDepth',1,...
        'FindAll','on',...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        re{:},...
        'Type','annotation',...
        ft{:});
    case{'signal','block'}
        hList=[];
    case 'model'
        sysList=get(rptgen_sl.appdata_sl,'ReportedSystemList');
        hList=find_system(sysList,...
        'SearchDepth',1,...
        'FindAll','on',...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        re{:},...
        'Type','annotation',...
        ft{:});
    otherwise
        mdlList=find_system('SearchDepth',1,...
        'BlockDiagramType','model');
        mdlList=setdiff(mdlList,{'temp_rptgen_model'});


        hList=find_system(mdlList,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FindAll','on',...
        re{:},...
        'Type','annotation',...
        ft{:});
    end




    switch c.SortBy
    case 'alpha'
        textList=rptgen.safeGet(hList,'text','get_param');
        okEntries=find(~strcmp(textList,'N/A'));
        textList=textList(okEntries);
        hList=hList(okEntries);

        [textList,textIndex]=sort(lower(textList));
        hList=hList(textIndex);


    end




