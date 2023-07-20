function hList=loop_getLoopObjects(c)







    slad=rptgen_sl.appdata_sl;
    findList={};
    if~isempty(c.ObjectList)
        for idx=1:length(c.ObjectList)
            findList{end+1}=evalin('base',c.ObjectList{idx});%#ok<AGROW>
        end
    else
        findList={slad.CurrentModel};
    end

    bList=find_system(findList{:},...
    'SearchDepth',1,...
    'MaskType','Sigbuilder block');

    hList={};
    if~isempty(bList)

        filters=rmi.settings_mgr('get','filterSettings');
        for i=1:length(bList)
            ch=get_param(bList{i},'Handle');
            [~,~,~,groups]=signalbuilder(ch);
            for gi=1:length(groups)
                if rmi('hasrequirements',ch,filters,gi)
                    config.groupIndex=gi;
                    hg=signalbuilder(ch,'print',config,'figure');
                    set(hg,'Name',groups{gi});
                    set(hg,'Tag',sprintf('%d@%s',gi,bList{i}));
                    hList{end+1}=hg;
                end
            end
        end
    end
    hList=hList';

