function hList=loop_getLoopObjects(c)








    adSF=rptgen_sf.appdata_sf;
    switch lower(getContextType(adSF,c,false))
    case 'machine'
        machineID=get(adSF,'CurrentMachine');
        if~isempty(machineID)&&ishandle(machineID)
            hList=find(machineID,'-isa','Stateflow.Chart');
        else
            hList=[];
        end
    case{'chart','state','object'}
        hList=get(adSF,'CurrentChart');
    otherwise
        hList=getLoopBlocks(c,'BlockType','SubSystem','MaskType','Stateflow');

        hList=rptgen_sf.block2linkchart(hList);
    end


    if c.isSFFilterList
        filterTerms=rptgen_sf.findTerms(c.SFFilterTerms);
        try
            hList=find(hList,'-depth',0,'-regexp',filterTerms{:});

        catch
            c.status(getString(message('Sldv:RptSldv:SfLinkChartLoop:loop_getLoopObjects:CouldNotFilterStateflowCharts')),2);
        end
    end

    hList=hList(:);