function condition_details(this,blkEntry,cvstruct,options,conditionIdx)






    if options.elimFullCovDetails&&...
        ~isempty(blkEntry.condition)&&all(blkEntry.condition.flags.fullCoverage)
        return;
    end


    if(~isempty(blkEntry.condition)&&isfield(blkEntry.condition,'conditionIdx')&&...
        ~isempty(blkEntry.condition.conditionIdx))

        condData=cvstruct.conditions(blkEntry.condition.conditionIdx);
        if nargin<5
            conditionIdx=1:numel(blkEntry.condition.conditionIdx);
        end

    else
        return;
    end

    condData=collapse_conditions(condData);


    if options.elimFullCovDetails&&blkEntry.flags.fullCoverage
        return;
    end

    testCnt=length(cvstruct.tests);
    if testCnt==1
        coumnCnt=1;
    else
        coumnCnt=testCnt+1;
    end

    if options.cumulativeReport
        coumnCnt=coumnCnt-1;
    end
    assert(coumnCnt~=0);






    tableInfo.table='border="1" cellpadding="5"';
    tableInfo.cols=struct('align','"left"','width',300);
    tableInfo.cols(2)=struct('align','"center"','width',35);
    tableInfo.imageDir=options.imageSubDirectory;

    [notUsedMark{1:coumnCnt*2}]=deal({'Cat','$-'});
    if coumnCnt>1
        execData={{'If',{'RpnExpr','#covered','!'},'&in_startred'},...
        {'Cat','$&#160; ','#text'},...
        {'ForN',coumnCnt,...
        {'#trueCnts','@1'},...
        {'#falseCnts','@1'},...
        },...
        {'If',{'RpnExpr','#covered','!'},'&in_endred'},...
'\n'...
        };
    else
        execData={{'&in_startcolor','#startColor'},...
        {'Cat','$&#160; ','#text','$&#160; ','#linkStr'},...
        {'&in_startcolor','#trueOutcomeColor'},...
        {'If',{'RpnExpr','#isJustifiedTrue'},...
        {'Cat','#linkStrTrue'},...
        'Else',...
        {'Cat',{'&in_covJustifiedNumber','#trueCnts','#justifiedTrueCnts'},'$&#160; ','#linkStrTrue'},...
        },...
        {'&in_startcolor','#falseOutcomeColor'},...
        {'If',{'RpnExpr','#isJustifiedFalse'},...
        {'Cat','#linkStrFalse'},...
        'Else',...
        {'Cat',{'&in_covJustifiedNumber','#falseCnts','#justifiedFalseCnts'},'$&#160; ','#linkStrFalse'},...
        },...
        '\n'};

    end
    condEntry={'ForEach','#.',...
    {'If',{'RpnExpr','#isActive','!'},...
    {'&in_startcolor',options.varSizeColor},...
    {'Cat','$&#160; ','#text'},...
    notUsedMark{:},'\n',...
    'Else',...
    execData{:}...
    },...
    '&in_endcolor',...
    };

    colHead={['$<b>',getString(message('Slvnv:simcoverage:cvhtml:Description')),'</b>'],{'ForN',coumnCnt-1,{'Cat','$<b>#','@1','$ T</b>'},{'Cat','$<b>#','@1','$ F</b>'}}};
    if testCnt>1
        colHead=[colHead,{['$<b>',getString(message('Slvnv:simcoverage:cvhtml:TotalT')),'</b>'],['$<b>',getString(message('Slvnv:simcoverage:cvhtml:TotalF')),'</b>']}];
    else
        colHead=[colHead,{['$<b>',getString(message('Slvnv:simcoverage:cvhtml:True')),'</b>'],['$<b>',getString(message('Slvnv:simcoverage:cvhtml:False')),'</b>']}];
    end
    colHead=[colHead,{'\n'}];

    cTableTemplate=[colHead,{condEntry}];


    condData=filterLink(this,condData,conditionIdx,options);
    condData=traceLink(this,condData,options);

    printIt(this,'\n<br/> &#160; <b> %s </b> <br/>\n',getString(message('Slvnv:simcoverage:cvhtml:ConditionsAnalyzed')));
    tableStr=cvprivate('html_table',condData,cTableTemplate,tableInfo);
    this.printIt('%s',tableStr);


    function condData=traceLink(this,condData,options)





        for idx=1:numel(condData)
            isTrueIncidental=all(condData(idx).trueCnts==0)&&~isempty(condData(idx).trueExecutedIn);
            linkStrTrue=this.getTraceLink(condData(idx).trueExecutedIn,isTrueIncidental,options);
            condData(idx).linkStrTrue=[condData(idx).linkStrTrue,linkStrTrue];

            isFalseIncidental=all(condData(idx).falseCnts==0)&&~isempty(condData(idx).falseExecutedIn);
            linkStrFalse=this.getTraceLink(condData(idx).falseExecutedIn,isFalseIncidental,options);
            condData(idx).linkStrFalse=[condData(idx).linkStrFalse,linkStrFalse];
        end


        function condData=filterLink(this,condData,conditionIdx,options)
            whiteColor=options.whiteColor(2:end);
            redColor=options.redColor(2:end);
            ltBlueColor=options.ltBlueColor(2:end);
            for idx=1:numel(condData)
                ccd=condData(idx);
                cidx=conditionIdx(idx);
                condData(idx).trueOutcomeColor=whiteColor;
                condData(idx).falseOutcomeColor=whiteColor;
                condData(idx).startColor=whiteColor;
                if ccd.isJustifiedByParent||ccd.isFilteredByParent
                    if(0==ccd.trueCnts(1))
                        condData(idx).linkStrTrue='-';
                        condData(idx).startColor=ltBlueColor;
                        condData(idx).trueOutcomeColor=ltBlueColor;
                        condData(idx).isJustifiedTrue=true;
                    end

                    if(0==ccd.falseCnts(1))
                        condData(idx).linkStrFalse='-';
                        condData(idx).startColor=ltBlueColor;
                        condData(idx).falseOutcomeColor=ltBlueColor;
                        condData(idx).isJustifiedFalse=true;
                    end
                else
                    fullyCovered=true;
                    if~SlCov.CoverageAPI.feature('sldvfilter')
                        continue;
                    end
                    ssid='';
                    slsfCvId=cv('get',ccd.cvId,'.slsfobj');
                    try
                        ssid=cvi.TopModelCov.getSID(slsfCvId);
                    catch MEx %#ok<NASGU>
                    end
                    linkStrTrue='';

                    if ccd.isJustifiedTrue
                        condData(idx).trueOutcomeColor=ltBlueColor;
                        refIdStr=sprintf('%d_%d_%d',slsfCvId,ccd.cvId,1);
                        idxStr='*';
                        if this.rationaleMap.isKey(refIdStr)
                            idxStr=this.rationaleMap(refIdStr);
                        end
                        linkStrTrue=sprintf('<a name="ref_rationale_source_%s"></a><a href="#ref_rationale_%s"><div title="%s"/>%s</a>',...
                        refIdStr,...
                        refIdStr,...
                        getString(message('Slvnv:simcoverage:cvhtml:NavigateToJustification')),...
                        idxStr);
                    elseif ccd.trueCnts(1)==0
                        fullyCovered=false;
                        condData(idx).trueOutcomeColor=redColor;
                        descr=SlCov.FilterEditor.getMetricFilterValueDescr('condition',ccd.cvId,1);
                        linkStrTrue=this.getFilterLinkForAdd(ssid,cidx,1,'condition',descr,'',options);

                    end
                    condData(idx).linkStrTrue=linkStrTrue;

                    linkStrFalse='';

                    if ccd.isJustifiedFalse
                        condData(idx).falseOutcomeColor=ltBlueColor;
                        refIdStr=sprintf('%d_%d_%d',slsfCvId,ccd.cvId,2);
                        idxStr='*';
                        if this.rationaleMap.isKey(refIdStr)
                            idxStr=this.rationaleMap(refIdStr);
                        end
                        linkStrFalse=sprintf('<a name="ref_rationale_source_%s"></a><a href="#ref_rationale_%s"><div title="%s"/>%s</a>',...
                        refIdStr,...
                        refIdStr,...
                        getString(message('Slvnv:simcoverage:cvhtml:NavigateToJustification')),...
                        idxStr);
                    elseif ccd.falseCnts(1)==0
                        fullyCovered=false;
                        condData(idx).falseOutcomeColor=redColor;
                        descr=SlCov.FilterEditor.getMetricFilterValueDescr('condition',ccd.cvId,2);
                        linkStrFalse=this.getFilterLinkForAdd(ssid,cidx,2,'condition',descr,'',options);
                    end

                    condData(idx).linkStrFalse=linkStrFalse;

                    if ccd.isJustifiedFalse&&...
                        ccd.isJustifiedTrue
                        condData(idx).startColor=ltBlueColor;
                    elseif~fullyCovered
                        condData(idx).startColor=redColor;
                        if~ccd.isJustifiedFalse&&~ccd.isJustifiedTrue
                            condData(idx).trueOutcomeColor=redColor;
                            condData(idx).falseOutcomeColor=redColor;
                        end
                    end
                end
            end




            function condData=collapse_conditions(condData)
                [tmp{1:numel(condData)}]=deal(condData(:).isVariable);
                if~any(cell2mat(tmp))
                    return;
                end

                condData=cvi.ReportScript.collapse_text(condData);
