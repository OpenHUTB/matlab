function result=commonSrcInterpRefactoring(aTask)




    result=[];
    mdladvObj=aTask.MAObj;
    if~isa(mdladvObj.UserData,'slEnginePir.m2m_CommonSourceInterpolation')
        return;
    end
    m2mObj=mdladvObj.UserData;

    aTask.Check.Result=commonSrcInterpXformCandidate(m2mObj,mdladvObj.SystemName,1);
    aTask.Check.ResultInHTML=mdladvObj.formatCheckCallbackOutput(aTask.Check,{aTask.Check.Result},{''},1,false);

    inputParams=mdladvObj.getInputParameters;
    prefix=inputParams{2}.Value;

    prefix=checkfilename(prefix,'gen3_');
    if length([prefix,m2mObj.fOriMdl])>63
        DAStudio.error('sl_pir_cpp:creator:IllegalName3');
    end

    m2mObj.refactoring(prefix);

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
    txt=ModelAdvisor.Text(DAStudio.message('sl_pir_cpp:creator:BulletCommonSrcInterpXform'),{'bold'});
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.LineBreak;
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.Text(DAStudio.message('sl_pir_cpp:creator:HyperLinkToXformedBlk'));
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.LineBreak;
    result=[result,txt.emitHTML];
    txt=ModelAdvisor.LineBreak;
    result=[result,txt.emitHTML];


    resultTable=ModelAdvisor.Table(1,1);
    traceabilityMap=m2mObj.fTraceabilityMap;
    oriBlks=keys(traceabilityMap);
    mapTable=ModelAdvisor.Table(length(oriBlks),2);
    mdl=m2mObj.fXformedMdl;
    mapTable.setHeading(mdl);
    mapTable.setColHeading(1,'From');
    mapTable.setColHeading(2,'To');
    for bIdx=1:length(oriBlks)
        oriBlk=oriBlks{bIdx};
        newBlks=traceabilityMap(oriBlk);
        msg=ModelAdvisor.Text(oriBlk);
        msg.setHyperlink(['matlab: m2m_hiliteBlock(''',oriBlk,''')']);
        mapTable.setEntry(bIdx,1,msg);
        toTable=ModelAdvisor.Table(length(newBlks),1);
        for nbIdx=1:length(newBlks)
            msg=ModelAdvisor.Text(newBlks{nbIdx});
            msg.setHyperlink(['matlab: m2m_hiliteBlock(''',newBlks{nbIdx},''')']);
            toTable.setEntry(nbIdx,1,msg);
        end
        mapTable.setEntry(bIdx,2,toTable);
    end
    resultTable.setEntry(1,1,mapTable);
    result=[result,resultTable.emitHTML];
end


