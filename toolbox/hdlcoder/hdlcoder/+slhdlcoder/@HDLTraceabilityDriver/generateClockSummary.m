function generateClockSummary(~,clock_summary_file,title,model,JavaScriptBody)



    w=hdlhtml.reportingWizard(clock_summary_file,title);
    w.setHeader(DAStudio.message('hdlcoder:report:clockReportFor',model));
    if~isempty(JavaScriptBody)
        w.setAttribute('onload',JavaScriptBody);
    end

    gp=pir;
    crd=gp.getClockReportData;


    w.addBreak(3);


    generateGlobalInfo(w,crd);

    w.addBreak(2);


    generateClockTable(w,crd);

    w.addBreak(2);


    generateOutputTable(w,crd);

    w.addBreak;

    w.dumpHTML;
end


function generateGlobalInfo(w,crd)
    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:rateInfo'));
    w.commitSection(section);
    w.addBreak(2);
    rows=2;
    if crd.overSampleRequest>1
        rows=3;
    end
    table=w.createTable(rows,2);

    table.createEntry(1,1,DAStudio.message('hdlcoder:report:modelBaseRate'));
    table.createEntry(2,1,DAStudio.message('hdlcoder:report:dutBaseRate'));
    if rows==3
        table.createEntry(3,1,DAStudio.message('hdlcoder:report:explicitOversampleRequest'));
    end

    table.createEntry(1,2,sprintf('%g',crd.modelBaseRate),'center');
    table.createEntry(2,2,sprintf('%g',crd.dutBaseRate),'center');
    if rows==3
        table.createEntry(3,2,sprintf('%d',crd.overSampleRequest),'center');
    end

    w.commitTable(table);
end


function generateClockTable(w,crd)
    multiclock=(hdlgetparameter('clockinputs')==2);
    if multiclock
        section=w.createSectionTitle(DAStudio.message('hdlcoder:report:clockTable'));
        cols=3;
    else
        section=w.createSectionTitle(DAStudio.message('hdlcoder:report:clockEnableTable'));
        cols=2;
    end
    rows=length(crd.clockData);
    if rows==0

        table=w.createTable(1,cols);
    else
        table=w.createTable(rows+1,cols);
    end
    w.commitSection(section);
    w.addBreak(2);

    if multiclock
        table.createEntry(1,1,['<b>',DAStudio.message('hdlcoder:report:clockName'),'</b>'],'left');
        table.createEntry(1,2,['<b>',DAStudio.message('hdlcoder:report:clockDomain'),'</b>'],'center');
        table.createEntry(1,3,['<b>',DAStudio.message('hdlcoder:report:description'),'</b>'],'center');
    else
        table.createEntry(1,1,['<b>',DAStudio.message('hdlcoder:report:clockEnableName'),'</b>'],'left');
        table.createEntry(1,2,['<b>',DAStudio.message('hdlcoder:report:sampleTime'),'</b>'],'center');
    end
    offset=1;
    for ii=1+offset:rows+offset
        table.createEntry(ii,1,crd.clockData(ii-offset).name);
        if~multiclock
            table.createEntry(ii,2,sprintf('%g',crd.clockData(ii-offset).sampleTime),'center');
        else
            table.createEntry(ii,2,sprintf('%d',crd.clockData(ii-offset).domain),'center');
            if crd.clockData(ii-offset).ratio==1
                relRate=DAStudio.message('hdlcoder:report:baseRateClock');
            else
                relRate=sprintf(DAStudio.message('hdlcoder:report:slowerThanBaseRateClock',crd.clockData(ii-offset).ratio));
            end
            table.createEntry(ii,3,relRate,'center');
        end
    end

    w.commitTable(table);
end


function generateOutputTable(w,crd)
    multiclock=(hdlgetparameter('clockinputs')==2);
    if multiclock
        cols=5;
    else
        cols=4;
    end

    hdlDrv=hdlcurrentdriver;
    outputPortLatency=hdlDrv.cgInfo.latency;

    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:outputSignalTable'));
    w.commitSection(section);
    w.addBreak(2);
    rows=length(crd.outData)+1;
    if rows==0

        table=w.createTable(1,cols);
    else
        table=w.createTable(rows,cols);
    end

    gp=pir;
    gp=gp.getTopPirCtx;
    lat=zeros(1,rows-1);
    if~gp.hasPhaseOffsetCRPports&&~isempty(outputPortLatency)


        lat(:)=outputPortLatency(1);
    end

    table.createEntry(1,1,['<b>',DAStudio.message('hdlcoder:report:outputSignal'),'</b>'],'left');
    if multiclock
        table.createEntry(1,2,['<b>',DAStudio.message('hdlcoder:report:clockName'),'</b>']);
        table.createEntry(1,3,['<b>',DAStudio.message('hdlcoder:report:clockDomain'),'</b>'],'center');
        table.createEntry(1,4,['<b>',DAStudio.message('hdlcoder:report:sampleTime'),'</b>'],'center');
        table.createEntry(1,5,['<b>',DAStudio.message('hdlcoder:report:latency'),'</b>'],'center');
    else
        table.createEntry(1,2,['<b>',DAStudio.message('hdlcoder:report:clockEnableName'),'</b>'],'center');
        table.createEntry(1,3,['<b>',DAStudio.message('hdlcoder:report:sampleTime'),'</b>'],'center');
        table.createEntry(1,4,['<b>',DAStudio.message('hdlcoder:report:sampleTime'),'</b>'],'center');
    end

    for ii=1:(rows-1)
        table.createEntry(1+ii,1,crd.outData(ii).signalName);
        table.createEntry(1+ii,2,crd.outData(ii).clockingName,'center');
        if~multiclock
            table.createEntry(1+ii,3,sprintf('%g',crd.outData(ii).sampleTime),'center');
            table.createEntry(1+ii,4,sprintf('%g',lat(ii)),'center');
        else
            table.createEntry(1+ii,3,sprintf('%d',crd.outData(ii).domain),'center');
            table.createEntry(1+ii,4,sprintf('%g',crd.outData(ii).sampleTime),'center');
            table.createEntry(1+ii,5,sprintf('%g',lat(ii)),'center');
        end
    end

    w.commitTable(table);
end


