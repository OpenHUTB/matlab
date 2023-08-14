function t=getTitle(context,object)




    if nargin<1
        context='report';
    end

    switch context
    case 'blocktable'
        t=getString(message('Slvnv:RptgenRMI:getType:BlockTableTitle',get(rptgen_sl.appdata_sl,'CurrentSystem')));
    case 'childrenwithlinks'
        t=getString(message('Slvnv:RptgenRMI:getType:ChildrenWithLinks'));
    case 'codetable'
        t=getString(message('Slvnv:RptgenRMI:getType:CodeTableTitle',object));
    case 'colheadname'
        t=getString(message('Slvnv:RptgenRMI:getType:ColHeadName'));
    case 'colheadtype'
        t=getString(message('Slvnv:RptgenRMI:getType:ColHeadType'));
    case 'dicttable'
        t=getString(message('Slvnv:RptgenRMI:getType:DictTableTitle',object));
    case 'doctable'
        t=getString(message('Slvnv:RptgenRMI:getType:DocSummaryTableTitle'));
    case 'dvrequirements'
        t=getString(message('Slvnv:RptgenRMI:getType:DvRequirements'));
    case 'dvitem'
        t=getString(message('Slvnv:RptgenRMI:getType:DvItem'));
    case 'dviteminfo'
        t=getString(message('Slvnv:RptgenRMI:getType:DvItemInfoHeader'));
    case 'dvitemdetails'
        t=getString(message('Slvnv:RptgenRMI:getType:DvItemDetails'));
    case 'dvitems'
        t=getString(message('Slvnv:RptgenRMI:getType:DvItems',get(rptgen_sl.appdata_sl,'CurrentModel')));
    case 'filters'
        t=getString(message('Slvnv:RptgenRMI:getType:UserTagFilters'));
    case 'filtersinclude'
        t=getString(message('Slvnv:RptgenRMI:getType:UserTagFiltersInclude'));
    case 'filtersexclude'
        t=getString(message('Slvnv:RptgenRMI:getType:UserTagFiltersExclude'));
    case 'modelinfo'
        if nargin<2
            object=get(rptgen_sl.appdata_sl,'CurrentModel');
        end
        t=getString(message('Slvnv:RptgenRMI:getType:ModelInfoFor',object));
    case 'modelorsubsys'
        t=getString(message('Slvnv:RptgenRMI:getType:ModelOrSubsys'));
    case 'nolinksobj'
        if nargin<2
            object=get_param(get(rptgen_sl.appdata_sl,'CurrentSystem'),'Name');
        end
        t=getString(message('Slvnv:RptgenRMI:getType:NoLinksObj',object));
    case 'nolinkssys'
        if nargin<2
            object=get(rptgen_sl.appdata_sl,'CurrentModel');
        end
        t=getString(message('Slvnv:RptgenRMI:getType:NoLinksSys',object));
    case 'nolinkssubsys'
        if nargin<2
            object=get(rptgen_sl.appdata_sl,'CurrentModel');
        end
        t=getString(message('Slvnv:RptgenRMI:getType:NoLinksSubSys',object));
    case 'nolinkschart'
        if nargin<2
            object=get(get(rptgen_sf.appdata_sf,'CurrentObject'),'Name');
        end
        t=getString(message('Slvnv:RptgenRMI:getType:NoLinksObj',object));
    case 'nolinksnone'
        if nargin<2
            object=get(rptgen_sl.appdata_sl,'CurrentModel');
        end
        t=getString(message('Slvnv:RptgenRMI:getType:NoLinksNone',object));
    case 'objectsin'
        if nargin<2
            object=get(get(rptgen_sf.appdata_sf,'CurrentObject'),'Name');
        end
        t=getString(message('Slvnv:RptgenRMI:getType:ObjectsIn',object));
    case 'report'
        t=getString(message('Slvnv:RptgenRMI:getType:RptTitle',get(rptgen_sl.appdata_sl,'CurrentModel')));
    case 'reqtable'
        t=getString(message('Slvnv:RptgenRMI:getType:ReqTableTitle',get(rptgen_sl.appdata_sl,'CurrentSystem')));
    case 'summary'
        t=getString(message('Slvnv:RptgenRMI:getType:DocSummaryChapterTitle',get(rptgen_sl.appdata_sl,'CurrentModel')));
    case 'versioninfo'
        t=getString(message('Slvnv:RptgenRMI:getType:VersionInfo'));
    otherwise

    end
end

