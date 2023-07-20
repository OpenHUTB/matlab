function decision_details_script(this,decData,decIdx,totalCol,options,metricDesc)




    if options.cumulativeReport
        totalCol=totalCol-1;
    end

    if totalCol==2
        totalCol=1;
    end

    decData=collapse_decisions(decData);

    [notUsedMark{1:totalCol}]=deal({'Cat','$-'});
    if totalCol==1
        outEntryIn={{'If',{'RpnExpr','#colorJustified'},...
        {'&in_startcolor',options.ltBlueColor},...
        {'Cat','$&#160; &#160; &#160; ','#text'},...
        {'Cat','#linkStr'},...
        {'&in_endcolor'}...
        ,'Else',...
        {'&in_startcolor',options.redColor},...
        {'Cat','$&#160; &#160; &#160; ','#text'},...
        {'Cat',{'&in_covratios','#execCount','#justifiedExecCount','#<totals'},'#linkStr'}...
        ,{'&in_endcolor'},...
        }};

    else
        outEntryIn={{'&in_startcolor',options.redColor},...
        {'Cat','$&#160; &#160; &#160; ','#text'},...
        {'&in_covratios','#execCount','#justifiedExecCount','#<totals'},...
        {'&in_endcolor'}};
    end

    outEntry={'ForEach','#outcome',...
    {'If',{'RpnExpr','#isActive','!'},...
    {'&in_startcolor',options.varSizeColor},...
    {'Cat','$&#160; &#160; &#160; ','#text'},...
    notUsedMark{:},...
    {'&in_endcolor'},...
    'Else',...
    {'If',{'RpnExpr',{'#execCount',totalCol},'!'},...
    outEntryIn{:},...
    'Else',...
    {'If',{'RpnExpr','#traced'},...
    {'Cat','$&#160; &#160; &#160; ','#text'},...
    {'Cat',{'&in_covratios','#execCount','#justifiedExecCount','#<totals'},'#linkStr'}...
    ,'Else',...
    {'Cat','$&#160; &#160; &#160; ','#text'},...
    {'&in_covratios','#execCount','#justifiedExecCount','#<totals'}...
    }...
    },...
    },...
'\n'...
    };

    decEntry={'ForEach','#.',...
    {'If',{'RpnExpr','#isActive','!'},...
    {'&in_startcolor',options.varSizeColor},...
    {'Cat','$&#160; ','#text'},...
    notUsedMark{:},'\n',...
    {'&in_endcolor'},...
    'Else',...
    {'If',{'RpnExpr','#<hasVariableOutcome'},...
    {'Cat','$&#160; ','#text','$&#160; ','#linkStr'},...
    {'&in_covpercent','#outCnts','#justifiedOutCnts','#<maxActOutcome'},...
    'Else',...
    {'Cat','$&#160; ','#text','$&#160; ','#linkStr'},...
    {'&in_covpercent','#outCnts','#justifiedOutCnts','#numOutcomes'},...
    },...
    '\n',...
    outEntry,...
    }
    };

    dTableTemplate={decEntry};




    printIt(this,'&#160; <b>%s</b><br/>\n',metricDesc);
    decData=filterLink(this,decData,decIdx,options);
    decData=traceLink(this,decData,options);



    tableInfo.table='border="1" cellpadding="5"';
    tableInfo.cols=struct('align','"left"','width',380);
    tableInfo.cols(2)=struct('align','"center"','width',60);
    tableInfo.imageDir=options.imageSubDirectory;
    tableInfo.useRowGroups=1;

    tableStr=cvprivate('html_table',decData,dTableTemplate,tableInfo);
    printIt(this,'%s',tableStr);
end

function decData=traceLink(this,decData,options)
    for idx=1:numel(decData)
        cdd=decData(idx);

        outcomes=cdd.outcome;
        for oidx=1:numel(outcomes)


            isIncidental=all(outcomes(oidx).execCount==0)&&~isempty(outcomes(oidx).executedIn);
            linkStr=this.getTraceLink(outcomes(oidx).executedIn,isIncidental,options);
            if~isempty(linkStr)
                newLinkStr=[decData(idx).outcome(oidx).linkStr,linkStr];
                decData(idx).outcome(oidx).linkStr=newLinkStr;
                decData(idx).outcome(oidx).traced=1;
            else
                decData(idx).outcome(oidx).traced=0;
            end
        end
    end
end

function decData=filterLink(this,decData,decIdx,options)
    for idx=1:numel(decData)
        cdd=decData(idx);
        objIdx=decIdx(idx);

        if cdd.isFilteredByParent
            continue;
        end
        slsfCvId=cv('get',cdd.cvId,'.slsfobj');
        cvId=cdd.cvId;
        ssid='';
        try
            ssid=cvi.TopModelCov.getSID(slsfCvId);
        catch MEx %#ok<NASGU>
        end

        parentFiltered=cdd.isJustified||cdd.isFiltered||cdd.isJustifiedByParent;

        outcomes=cdd.outcome;
        multipleColums=numel(cdd.outCnts)>1;
        for oidx=1:numel(outcomes)
            covered=outcomes(oidx).execCount>0;

            if multipleColums
                decData(idx).outcome(oidx).colorJustified=false;
                decData(idx).outcome(oidx).linkStr='';
            elseif~covered
                linkStr='';
                if SlCov.CoverageAPI.feature('sldvfilter')&&...
                    ~parentFiltered
                    if outcomes(oidx).isJustified
                        linkStr=getFilterRationaleLink(this,slsfCvId,cvId,oidx);
                        decData(idx).outcome(oidx).colorJustified=true;
                    elseif strcmpi(cdd.metricName,'decision')||...
                        strcmpi(cdd.metricName,'cvmetric_Structural_relationalop')||...
                        strcmpi(cdd.metricName,'cvmetric_Structural_saturate')
                        descr=SlCov.FilterEditor.getMetricFilterValueDescr(cdd.metricName,cvId,oidx);
                        linkStr=this.getFilterLinkForAdd(ssid,objIdx,oidx,cdd.metricName,descr,[],options);
                    end

                elseif parentFiltered
                    linkStr='-';
                    decData(idx).outcome(oidx).colorJustified=true;
                end
                decData(idx).outcome(oidx).linkStr=linkStr;
            end
        end
    end
end


function linkStr=getFilterRationaleLink(this,slsfCvId,cvId,oidx)

    refIdStr=sprintf('%d_%d_%d',slsfCvId,cvId,oidx);
    numstr='*';
    if this.rationaleMap.isKey(refIdStr)
        numstr=this.rationaleMap(refIdStr);
    end
    linkStr=sprintf('<a name="ref_rationale_source_%s"></a><a href="#ref_rationale_%s"><div title="%s"/>%s</a>',...
    refIdStr,...
    refIdStr,...
    getString(message('Slvnv:simcoverage:cvhtml:NavigateToJustification')),...
    numstr);
end

function decData=collapse_decisions(decData)
    [tmp1{1:numel(decData)}]=deal(decData(:).isVariable);
    [tmp2{1:numel(decData)}]=deal(decData(:).collapseVector);
    if~any(cell2mat(tmp1))&&~any(cell2mat(tmp2))
        return;
    end

    decData=cvi.ReportScript.collapse_text(decData);
    for i=1:numel(decData)
        decData(i).outcome=cvi.ReportScript.collapse_text(decData(i).outcome);
    end
end

