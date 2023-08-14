function testobjective_details(this,blkEntry,cvstruct,metricName,options,testobjectiveIdx)




    if options.elimFullCovDetails&&...
        (strcmp(metricName,'cvmetric_Structural_block')||...
        (~isempty(blkEntry.(metricName))&&all(blkEntry.(metricName).flags.fullCoverage)))
        return;
    end

    if~isempty(blkEntry.(metricName))&&isfield(blkEntry.(metricName),'testobjectiveIdx')&&...
        ~isempty(blkEntry.(metricName).testobjectiveIdx)
        if nargin<6
            testobjectiveIdx=1:numel(blkEntry.(metricName).testobjectiveIdx);
        end
        testobjData=cvstruct.(metricName)(blkEntry.(metricName).testobjectiveIdx);
    else
        return;
    end
    totalCol=length(cvstruct.tests)+1;

    metricDesc=cvi.MetricRegistry.getLongMetricTxt(metricName,options);

    if~testobjData(1).showOnlyTrueOutcome
        metricDesc=getString(message('Slvnv:simcoverage:cvhtml:MetricAnalyzed',metricDesc));
        decision_details_script(this,testobjData,testobjectiveIdx,totalCol,options,metricDesc);
    else
        testobjData=traceLink(this,testobjData,options);

        if options.cumulativeReport
            totalCol=totalCol-1;
        end
        if totalCol==2
            totalCol=1;
        end

        testobjEntry={'ForEach','#.',...
        {'If',{'RpnExpr',{'#hitTrueCount',totalCol},'!'},...
        {'If',{'RpnExpr','#isJustified'},...
        {'&in_startcolor',options.ltBlueColor},...
        'Else',...
        {'&in_startcolor',options.redColor},...
        }...
        },...
        {'If',{'RpnExpr','#traced'},...
        {'Cat','$&#160; &#160; &#160; ','#text'},...
        {'Cat',{'&in_covratios','#hitTrueCount','#justifiedExecCount','#execCount'},'#linkStr'}...
        ,'Else',...
        {'Cat','$&#160; &#160; &#160; ','#text'},...
        {'&in_covratios','#hitTrueCount','#justifiedExecCount','#execCount'},...
        },...
        {'&in_endcolor'}...
        ,'\n'...
        };

        dTableTemplate={testobjEntry};





        printIt(this,['&#160; <b>',getString(message('Slvnv:simcoverage:cvhtml:MetricAnalyzed',metricDesc)),'</b><br/>\n']);




        tableInfo.table='border="1" cellpadding="5" rules="groups"';
        tableInfo.cols=struct('align','"left"','width',380);
        tableInfo.cols(2)=struct('align','"center"','width',60);
        tableInfo.imageDir=options.imageSubDirectory;
        tableInfo.useRowGroups=1;

        tableStr=cvprivate('html_table',testobjData,dTableTemplate,tableInfo);
        printIt(this,'%s',tableStr);
    end
end

function testobjData=traceLink(this,testobjData,options)
    try
        for idx=1:numel(testobjData)
            cto=testobjData(idx);



            isIncidental=cto.hitTrueCount(1)==0&&~isempty(cto.executedIn);
            linkStr=this.getTraceLink(cto.executedIn,isIncidental,options);
            if~isempty(linkStr)
                testobjData(idx).linkStr=linkStr;
                testobjData(idx).traced=1;
            else
                testobjData(idx).traced=0;
            end
        end
    catch MEx
        rethrow(MEx);
    end
end

