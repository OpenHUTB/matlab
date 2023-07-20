function retStruct=getDashboardAndBoundElementPairs(mdlH)




    mdl=get_param(mdlH,'name');
    DBcell=Simulink.HMI.getDashboardBlocksInModel(mdl);
    nDB=numel(DBcell);
    retStruct=struct('NumBlocks',nDB,'DashboardBlocks',zeros(1,nDB),'BoundElements',zeros(1,nDB));
    for i=1:nDB
        DBHdl=get_param(DBcell{i},'Handle');
        BESigSpec=Simulink.HMI.getBoundElementForDashboardBlock(DBHdl);
        if~isempty(BESigSpec)
            BEHdl=get_param(BESigSpec.BlockPath.getBlock(1),'Handle');
        else
            BEHdl=-1;
        end
        retStruct.DashboardBlocks(i)=DBHdl;
        retStruct.BoundElements(i)=BEHdl;
    end

end

