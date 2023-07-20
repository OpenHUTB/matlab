function result=commonSrcInterpXformCandidate(m2mObj,model,freeze)




    result={};
    m2mObj.identify;
    candInfos=m2mObj.fCandidates;

    numGroups=length(candInfos);
    if numGroups<1
        result=[{'There is no Common Source Interpolation transformation candidate in this model'}];
        return;
    end

    candTable=ModelAdvisor.Table(numGroups,3);
    candTable.setHeading('Candidate Groups');
    formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
    setSubTitle(formatTemplate,DAStudio.message('sl_pir_cpp:creator:CommonSrcInterpCandidateTitle'));
    setInformation(formatTemplate,DAStudio.message('sl_pir_cpp:creator:CommonSrcInterpCandidateTableTitle'));

    result=[result,{formatTemplate}];
    for cIdx=1:length(candInfos)
        candInfo=candInfos(cIdx);


        numInterpBlkPorts=length(candInfo.InterpolationPorts);
        portTable=ModelAdvisor.Table(numInterpBlkPorts,4);
        portTable.setColHeading(1,'Interpolation-ND block');
        portTable.setColHeading(2,'Port Index');
        portTable.setColHeading(3,'Switch block');
        portTable.setColHeading(4,'Port Index');

        candidateGrpSet=[];
        for pIdx=1:numInterpBlkPorts
            interpBlockAddress=ModelAdvisor.Text(candInfo.InterpolationPorts(pIdx).Block);
            blkSID=Simulink.ID.getSID(candInfo.InterpolationPorts(pIdx).Block);
            interpBlockAddress.setHyperlink(['matlab: m2m_hiliteBlock(''',blkSID,''')']);
            candidateGrpSet=[candidateGrpSet,' ',blkSID];
            portTable.setEntry(pIdx,1,interpBlockAddress);
            portTable.setEntry(pIdx,2,num2str(candInfo.InterpolationPorts(pIdx).Port+1));
            switchBlockAddress=ModelAdvisor.Text(candInfo.SwitchPorts(pIdx).Block);
            blkSID=Simulink.ID.getSID(candInfo.SwitchPorts(pIdx).Block);
            switchBlockAddress.setHyperlink(['matlab: m2m_hiliteBlock(''',blkSID,''')']);
            candidateGrpSet=[candidateGrpSet,' ',blkSID];
            portTable.setEntry(pIdx,3,switchBlockAddress);
            portTable.setEntry(pIdx,4,num2str(candInfo.SwitchPorts(pIdx).Port+1));
        end
        groupName=ModelAdvisor.Text(['group',num2str(cIdx)]);
        groupName.setHyperlink(['matlab: m2m_hiliteCandidateGroup(''',candidateGrpSet,''')']);
        isExcluded=m2mObj.isExcludedBlk(candInfo.SwitchPorts(1).Block);
        sid=Simulink.ID.getSID(candInfo.SwitchPorts(1).Block);
        checkbox=insertCheckboxHtml(model,'candidate',~isExcluded,cIdx,sid,freeze);
        candTable.setEntry(cIdx,1,checkbox);
        candTable.setEntry(cIdx,2,groupName);
        candTable.setEntry(cIdx,3,portTable);
    end
    result=[result,{candTable}];
end
