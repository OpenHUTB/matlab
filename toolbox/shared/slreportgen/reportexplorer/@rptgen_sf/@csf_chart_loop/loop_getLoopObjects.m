function hList=loop_getLoopObjects(c)






    adSF=rptgen_sf.appdata_sf;
    switch lower(getContextType(adSF,c,false))
    case 'machine'
        machineID=get(adSF,'CurrentMachine');
        if(~isempty(machineID)&&ishandle(machineID))
            hList=find(machineID,'-isa','Stateflow.Chart','-or','Stateflow.AtomicSubchart');
        else
            hList=[];
        end
    case{'chart','state','object'}
        hList=get(adSF,'CurrentChart');
    otherwise
        hList=getLoopBlocks(c,'BlockType','SubSystem','MaskType','Stateflow');

        hList=rptgen_sf.block2chart(hList);


        if~isempty(hList)
            atomicSubcharts=find(hList,'-isa','Stateflow.AtomicSubchart','-or','-isa','Stateflow.AtomicBox');
            n=numel(atomicSubcharts);
            subcharts=cell(n,1);
            for i=1:n
                subcharts{i}=atomicSubcharts(i).Subchart;
            end
            subcharts=[subcharts{:}];
            hList=[hList(:);subcharts(:)];
        end

    end


    if~isempty(hList)
        hList=find(hList,'-depth',0,'-not','-isa','Stateflow.EMChart');%#ok
    end



    if~isempty(hList)
        hList=find(hList,'-depth',0,'-not','-isa','Stateflow.TruthTableChart');%#ok
    end


    if~isempty(hList)
        hList=find(hList,'-depth',0,'-not','-isa','Stateflow.StateTransitionTableChart');%#ok
    end


    if~isempty(hList)
        hList=find(hList,'-depth',0,'-not','-isa','Stateflow.ReactiveTestingTableChart');%#ok
    end

    if(~isempty(hList)&&c.isSFFilterList)
        filterTerms=rptgen_sf.findTerms(c.SFFilterTerms);
        try
            hList=find(hList,'-depth',0,'-regexp',filterTerms{:});%#ok

        catch ME
            c.status(sprintf(getString(message('RptgenSL:rsf_csf_chart_loop:cannotFilterLabel')),ME.message),2);
        end
    end


    hList=unique(hList,'stable');
    hList=hList(:);
