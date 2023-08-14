function result=lutXformCandidate(m2mObj,model,freeze)



    result={};
    m2mObj.identify;
    candInfos=m2mObj.getCandidateInfo();

    numGroups=length(candInfos);
    if numGroups<1
        result=[{'There is no Lookup-table transformation candidate in this model'}];
        return;
    end
    candTable=ModelAdvisor.Table(numGroups,1);
    candTable.setHeading('Candidate Groups');

    ft0=ModelAdvisor.FormatTemplate('ListTemplate');
    setSubTitle(ft0,DAStudio.message('sl_pir_cpp:creator:LutCandidateTitle'));
    setInformation(ft0,DAStudio.message('sl_pir_cpp:creator:LutCandidateTablesTitle'));

    result=[result,{ft0}];

    portIdx=0;
    for cIdx=1:length(candInfos)
        candInfo=candInfos(cIdx);

        paramTable=ModelAdvisor.Table(10,2);
        paramTable.setHeading('LUT Parameters');
        paramTable.setHeadingAlign('center');
        paramTable.setColHeading(1,'Params');
        paramTable.setColHeading(2,'Values');
        paramTable.setEntry(1,1,'BreakpointData');
        paramTable.setEntry(1,2,num2str(candInfo.Parameters.Breakpoints'));
        paramTable.setEntry(2,1,'BreakpointDataTypeStr');
        paramTable.setEntry(2,2,candInfo.Parameters.BreakpointDataTypeStr);
        paramTable.setEntry(3,1,'FractionDataTypeStr');
        paramTable.setEntry(3,2,candInfo.Parameters.FractionDataTypeStr);
        paramTable.setEntry(4,1,'InterpMethod');
        paramTable.setEntry(4,2,candInfo.Parameters.InterpMethod);
        paramTable.setEntry(5,1,'ExtrapMethod');
        paramTable.setEntry(5,2,candInfo.Parameters.ExtrapMethod);
        paramTable.setEntry(6,1,'IndexSearchMethod');
        paramTable.setEntry(6,2,candInfo.Parameters.IndexSearchMethod);
        paramTable.setEntry(7,1,'DiagnosticForOutOfRangeInput');
        paramTable.setEntry(7,2,candInfo.Parameters.DiagnosticForOutOfRangeInput);
        paramTable.setEntry(8,1,'RemoveProtectionInput');
        paramTable.setEntry(8,2,candInfo.Parameters.RemoveProtectionInput);
        paramTable.setEntry(9,1,'LockScale');
        paramTable.setEntry(9,2,candInfo.Parameters.LockScale);
        paramTable.setEntry(10,1,'RndMeth');
        paramTable.setEntry(10,2,candInfo.Parameters.RndMeth);

        numLutPorts=length(candInfo.LutPorts);
        portTable=ModelAdvisor.Table(numLutPorts,3);


        portTable.setColHeading(1,'');
        portTable.setColHeading(2,'Block');
        portTable.setColHeading(3,'Port Index');
        for pIdx=1:numLutPorts
            sid=[candInfo.LutPorts(pIdx).Block,'@',num2str(candInfo.LutPorts(pIdx).Port+1)];
            isExcluded=m2mObj.isExcludedPort(candInfo.LutPorts(pIdx).Block,candInfo.LutPorts(pIdx).Port+1);
            checkbox=insertCheckboxHtml(model,'candidate',~isExcluded,portIdx,sid,freeze);
            portTable.setEntry(pIdx,1,checkbox);
            msg=ModelAdvisor.Text(candInfo.LutPorts(pIdx).Block);
            msg.setHyperlink(['matlab: m2m_hiliteBlock(''',Simulink.ID.getSID(candInfo.LutPorts(pIdx).Block),''') ']);
            portTable.setEntry(pIdx,2,msg);
            portTable.setEntry(pIdx,3,num2str(candInfo.LutPorts(pIdx).Port+1));
            portIdx=portIdx+1;
        end

        groupTable=ModelAdvisor.Table(1,1);

        groupTable.setEntry(1,1,portTable);

        candTable.setRowHeading(cIdx,['group',num2str(cIdx)]);
        candTable.setRowHeadingAlign(cIdx,'center');
        candTable.setEntry(cIdx,1,groupTable);
    end
    result=[result,{candTable}];

    mdls=keys(m2mObj.fCandidateBlks);
    numMdls=length(mdls);
    xformTable=ModelAdvisor.Table(numMdls,2);
    xformTable.setHeading('Candidates in Models');
    xformTable.setColHeading(1,'Model');
    xformTable.setColHeading(2,'LUT Blocks');
    for mIdx=1:numMdls
        xformTable.setEntry(mIdx,1,mdls{mIdx});
        candidateBlks=m2mObj.fCandidateBlks(mdls{mIdx});
        numBlks=length(candidateBlks);
        selectTable=ModelAdvisor.Table(numBlks,2);
        for bIdx=1:length(candidateBlks)
            isExcluded=m2mObj.isExcludedBlk(candidateBlks(bIdx));
            sid=Simulink.ID.getSID(candidateBlks(bIdx));
            checkbox=insertCheckboxHtml(model,'candidate',~isExcluded,bIdx,sid,freeze);
            blkpath=getfullname(candidateBlks(bIdx));
            msg=ModelAdvisor.Text(blkpath);
            msg.setHyperlink(['matlab: m2m_hiliteBlock(''',Simulink.ID.getSID(blkpath),''')']);
            selectTable.setEntry(bIdx,1,checkbox);
            selectTable.setEntry(bIdx,2,msg);
        end
        xformTable.setEntry(mIdx,2,selectTable);
    end

end
