function testUnitBlock=findTestUnitBlock(obj)




    tmp=Simulink.SimulationData.ModelCloseUtil;
    load_system(obj);
    refBlock=find_system(obj,'SearchDepth',1,'BlockType','ModelReference');
    if length(refBlock)<1
        DAStudio.error('SDI:sdi:BlockNotFoundInHarness','Model Reference');
    elseif length(refBlock)>1
        DAStudio.error('SDI:sdi:OnlyOneMdlRefBlkAllowed');
    end
    testUnitBlock=refBlock{1};
    delete(tmp);
end

