function table=utilDataflowResultsTable(mdladvObj,allMappingData,tableName)





    table=cell(length(allMappingData),5);
    for i=1:length(allMappingData)
        mappingData=allMappingData(i);


        hSSBlk=mappingData.TopMostDataflowSubsystem;
        blkName=getfullname(hSSBlk);
        ssBlkSID=Simulink.ID.getSID(blkName);
        hlink=ModelAdvisor.Text(blkName);
        hlink.setHyperlink(['matlab: utilOpenDataflowSubsystemPI(''',ssBlkSID,''');']);
        table{i,1}=hlink;


        table{i,2}=ModelAdvisor.Text(num2str(mappingData.SpecifiedLatency));


        optLat=num2str(mappingData.OptimalLatency);
        if(mappingData.OptimalLatency>mappingData.SpecifiedLatency)
            linkText=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowAccept');
            optLatHLink=['<a href="matlab:eval(set_param(''',ssBlkSID,''', ''Latency'', ''',optLat,'''));">','',linkText,'</a>'];
            table{i,3}=ModelAdvisor.Text([optLat,' ',optLatHLink]);
        else
            table{i,3}=ModelAdvisor.Text(optLat);
        end


        table{i,4}=ModelAdvisor.Text(num2str(mappingData.NumberOfThreads));


        info=getInfoMsg(mdladvObj,mappingData);

        table{i,5}=ModelAdvisor.Text(info);
    end

    colHeading={DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowTableDomain'),...
    DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowTableLatency'),...
    DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowTableSuggestedLatency'),...
    DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowTableThreads'),...
    DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowTableInfo')};
    table=utilDrawReportTable(table,tableName,{},colHeading);
end

function infoMsg=getInfoMsg(mdladvObj,mappingData)






    if mappingData.NumberOfBlocks==0
        infoMsg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowInfoNoBlocks');
        return
    end





    if bitget(mappingData.Attributes,10)
        minExecTimeInUs=25;
        if slsvTestingHook('SLMCMinMultithreadExecTime')>0
            minExecTimeInUs=slsvTestingHook('SLMCMinMultithreadExecTime')/1e3;
        end
        infoMsg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowInfoInsufficientWork',round(minExecTimeInUs));
        return;
    end





    if bitget(mappingData.Attributes,8)
        infoMsg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowInfoSingleThread');
        return
    end




    if(mappingData.OptimalLatency>mappingData.SpecifiedLatency)
        infoMsg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowInfoAddLatency',num2str(mappingData.OptimalLatency));
        return;
    end






    if~bitget(mappingData.Attributes,12)
        tallPoleData=mappingData.getCostData.TallPoleData;
        if((tallPoleData.TallPoleRatio>0)&&~isempty(tallPoleData.TallPoleBlock))
            tallPoleName=mdladvObj.getHiliteHyperlink(tallPoleData.TallPoleBlock);
            tallPoleRatioStr=num2str(tallPoleData.TallPoleRatio,2);
            infoMsg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowInfoTallPole',tallPoleName,tallPoleRatioStr);
            return;
        end
    end


    assert(bitget(mappingData.Attributes,11)==1,'Not partitioned');
    infoMsg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataflowInfoNothingIdentified');
end

function dstString=encodeStrtoHTMLsymbol(srcString)
    EncodeTable=...
    {'<','&#60;';...
    '>','&#62;';...
    '&','&#38;';...
    '#','&#35;';...
    newline,'<br/>';...
    };

    dstString='';
    for i=1:length(srcString)
        for j=1:length(EncodeTable)
            dstSubString=strrep(srcString(i),EncodeTable(j,1),EncodeTable(j,2));
            if~strcmp(dstSubString,srcString(i))
                break
            end
        end
        dstString=[dstString,dstSubString];%#ok<AGROW>
    end
end
