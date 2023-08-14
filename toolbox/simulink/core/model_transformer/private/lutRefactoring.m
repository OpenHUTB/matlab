function result=lutRefactoring(aTask)



    result=[];
    mdladvObj=aTask.MAObj;
    if~isa(mdladvObj.UserData,'slEnginePir.m2m_lut')
        return;
    end
    m2mObj=mdladvObj.UserData;

    aTask.Check.Result=lutXformCandidate(m2mObj,mdladvObj.SystemName,1);
    aTask.Check.ResultInHTML=mdladvObj.formatCheckCallbackOutput(aTask.Check,{aTask.Check.Result},{''},1,false);

    inputParams=mdladvObj.getInputParameters;
    prefix=inputParams{2}.Value;

    prefix=checkfilename(prefix,'gen3_');
    if length([prefix,m2mObj.fOriMdl])>63
        DAStudio.error('sl_pir_cpp:creator:IllegalName3');
    end

    m2mObj.refactoring(prefix);
    blks=keys(m2mObj.fTraceabilityMap);
    if length(blks)<1
        resultText=ModelAdvisor.Text('No Lookup-table block is transformed');
        result=resultText.emitHTML;
        return;
    end
    roots=bdroot(blks);
    FromToTable=[];

    txt=ModelAdvisor.Text(DAStudio.message('sl_pir_cpp:creator:XformedModel'),{'bold'});
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.LineBreak;
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.Text(DAStudio.message('sl_pir_cpp:creator:HyperLinkToXformedMdl'));
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.LineBreak;
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.LineBreak;
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.Text('                         ');
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.Text(m2mObj.fXformedMdl,{'underline'});
    txt.setHyperlink(['matlab: open_system(''',m2mObj.fXformedMdl,''')']);
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.LineBreak;
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.Text('_________________________________________________________________________________________');
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.LineBreak;
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.LineBreak;
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.Text(DAStudio.message('sl_pir_cpp:creator:Bullet_LutXform'),{'bold'});
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.LineBreak;
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.Text(DAStudio.message('sl_pir_cpp:creator:HyperLinkToXformedBlk'));
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.LineBreak;
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.LineBreak;
    result=[result,txt.emitHTML];

    resultTable=ModelAdvisor.Table(length(m2mObj.fXformedMdls),1);
    for mIdx=1:length(m2mObj.fXformedMdls)
        mdl=m2mObj.fXformedMdls{mIdx};
        blkIndices=find(strcmpi(roots,mdl));
        if isempty(blkIndices)
            continue;
        end
        mapTable=ModelAdvisor.Table(length(blkIndices),2);
        mapTable.setHeading(mdl);
        mapTable.setColHeading(1,'From');
        mapTable.setColHeading(2,'To');
        for bIdx=1:length(blkIndices)
            oriBlk=blks{blkIndices(bIdx)};
            msg=ModelAdvisor.Text(oriBlk);
            msg.setHyperlink(['matlab: m2m_hiliteBlock(''',oriBlk,''')']);
            mapTable.setEntry(bIdx,1,msg);
            newBlks=m2mObj.fTraceabilityMap(oriBlk);
            toTable=ModelAdvisor.Table(length(newBlks),1);
            for nbIdx=1:length(newBlks)
                msg=ModelAdvisor.Text(newBlks{nbIdx});
                msg.setHyperlink(['matlab: m2m_hiliteBlock(''',newBlks{nbIdx},''')']);
                toTable.setEntry(nbIdx,1,msg);
            end
            mapTable.setEntry(bIdx,2,toTable);
        end
        resultTable.setEntry(mIdx,1,mapTable);
    end

    result=[result,resultTable.emitHTML];
end

