function powersysdomain_start(model)







    [netlist,NoCompilation]=powersysdomain_netlist('get');
    if(~isempty(NoCompilation)&&NoCompilation)||isempty(netlist)
        return
    end

    BLOCKLIST=POWERSYS.Netlist(netlist);
    sys=get_param(bdroot(netlist.BlockHandles(1)),'Name');
    Dirty=get_param(sys,'Dirty');


    RefBlock='';
    if~isempty(BLOCKLIST)
        if~isempty(BLOCKLIST.elements)
            RefBlock=getfullname(BLOCKLIST.elements(1));
        end
    end

    PowerguiInfo=getPowerguiInfo(sys,RefBlock);
    StorageBlock=get_param(PowerguiInfo.BlockName,'Handle');

    for blkList=1:numel(BLOCKLIST.elements)
        sps_rtmsupport('BlockCompile',BLOCKLIST.elements(blkList));
    end

    set_param(get(StorageBlock,'Parent'),'CurrentBlock',StorageBlock);


    LinkStatus=get_param(StorageBlock,'linkstatus');

    if strcmp(LinkStatus,'none')

        disp(' ');
        warning off backtrace;
        WarningID='SpecializedPowerSystems:FoundDisabledLinkBlock';
        Message='The library link of the powergui block is broken. We strongly recommend to restore the library link of the powergui block in order to avoid errors or warnings during the simulation.';
        warning(WarningID,Message);
        warning on backtrace;
    end

    if model==1&&strcmp(LinkStatus,'inactive')




        close_system(StorageBlock);















    end


    if isequal([1,1],size(netlist.BlockHandles))
        option=netlist.BlockHandles;
    else
        option=[];
    end


    powersolve(sys,option,PowerguiInfo,BLOCKLIST);
    set_param(sys,'Dirty',Dirty);