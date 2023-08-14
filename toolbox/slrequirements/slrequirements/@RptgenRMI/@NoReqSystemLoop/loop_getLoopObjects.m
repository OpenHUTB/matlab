function hList=loop_getLoopObjects(this,varargin)






    hList=this.getLoopSystems(varargin{:});

    adSL=rptgen_sl.appdata_sl;


    oldCurrSys=adSL.CurrentSystem;
    oldCurrBlk=adSL.CurrentBlock;
    oldContext=adSL.Context;

    adSL.Context='System';


    filtIdx=true(1,length(hList));
    for idx=1:length(hList)
        reqs=rmi.getReqs(hList{idx});
        if~isempty(reqs)&&any([reqs.linked])
            filtIdx(idx)=false;
        end
    end
    hList=hList(filtIdx);


    adSL.CurrentSystem=oldCurrSys;
    adSL.CurrentBlock=oldCurrBlk;
    adSL.Context=oldContext;
