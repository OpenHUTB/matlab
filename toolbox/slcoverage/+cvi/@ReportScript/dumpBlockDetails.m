function shortSummBlocks=dumpBlockDetails(this,shortSummBlocks,blkEntry,inReport,options)





    if options.elimFullCov&&blkEntry.flags.fullCoverage
        return;
    end
    isSFcnBlock=this.cvstruct.sfcnCovRes.covId2InstanceInfo.isKey(blkEntry.cvId);
    isShortSumm=false;
    if~isSFcnBlock&&options.elimFullCovDetails
        if~hasReqTestDetails(blkEntry,options)
            [isShortSumm,summ]=isShortSummary(this,blkEntry,options);
        end
    end
    if isShortSumm
        objTitle=sprintf('%s  %s',...
        cvi.ReportUtils.obj_anchor(blkEntry.cvId,''),...
        cvi.ReportScript.object_titleStr_and_link(blkEntry.cvId));

        tinfo.namedlink=objTitle;
        tinfo.rationale=summ;
        if isempty(shortSummBlocks)
            shortSummBlocks=tinfo;
        else
            shortSummBlocks(end+1)=tinfo;
        end
    else
        if inReport
            objTitle=sprintf('%s<h4> &#160; &#160;%s</h4>\n',...
            cvi.ReportUtils.obj_anchor(blkEntry.cvId,''),...
            cvi.ReportScript.object_titleStr_and_link(blkEntry.cvId));

            printIt(this,'%s',objTitle);
            printIt(this,'<table> <tr> <td width="25"> </td> <td>\n');
        else
            printIt(this,cvi.ReportUtils.getReportLink(blkEntry.cvId));
        end


        dumpBlockFilteringTable(this,blkEntry,options);
        dumpRequirementTable(this,blkEntry,options);

        if inReport
            produce_navigation_table(this,blkEntry,this.uncovIdArray,options);
            printIt(this,'<br/>\n\n');
        end




        skipComplexity=false;
        if cv('get',blkEntry.cvId,'.origin')==1
            blkH=cv('get',blkEntry.cvId,'.handle');
            skipComplexity=cvi.TopModelCov.isDVBlock(blkH);
        end
        skipComplexity=skipComplexity||chekcHasOnlyBlockCoverageMetric(this,blkEntry);
        fRef=[];
        if isSFcnBlock
            isSFcnBlock=true;
            [fRef,skipComplexity]=generate_sfunction_detailed_report(this,blkEntry.cvId,options);
        end

        blkSummaryScript=this.blkSummaryScript;
        if isfield(blkEntry,'cvmetric_Structural_block')&&...
            ~isempty(blkEntry.cvmetric_Structural_block)
            metricName='cvmetric_Structural_block';
            if cv('get',blkEntry.cvId,'.code')~=0
                options.alternativeMetricNameIdx=2;
                blkSummaryScript.(metricName){1}=['$',cvi.MetricRegistry.getLongMetricTxt(metricName,options)];
            end
            if options.elimFullCovDetails&&~blkEntry.cvmetric_Structural_block.flags.fullCoverage
                color=options.redColor;
                if blkEntry.cvmetric_Structural_block.flags.justified
                    color=options.ltBlueColor;
                end
                blkSummaryScript.(metricName)=[{{'&in_startcolor',color}}...
                ,blkSummaryScript.(metricName)...
                ,{{'&in_endcolor'}}];
            end
        end

        produce_summary_table(this,blkEntry,blkSummaryScript,options,skipComplexity);

        if isSFcnBlock&&~isempty(fRef)
            printIt(this,'<br/>\n');
            printIt(this,'<table>\n');
            printIt(this,'    <tr><td width="200"><b>%s:</b></td>\n',getString(message('Slvnv:simcoverage:htmlReport1')));
            [~,fname,fext]=fileparts(fRef);
            printIt(this,'    <td><a href="%s">%s%s</a></td></tr>\n',cvi.ReportUtils.file_path_2_url(fRef),fname,fext);
            printIt(this,'</table>\n');
        else
            reportMetricDetails(this,blkEntry,inReport,options);
        end
        if inReport
            printIt(this,'</td> </tr> </table>\n');
        end

        printIt(this,'<br/>\n');
    end


    function out=hasReqTestDetails(blkEntry,options)
        out=false;

        if~isfield(options.contextInfo,'Requirements')||...
            isempty(options.contextInfo.Requirements')
            return;
        end

        reqInfo=options.contextInfo.Requirements;

        blockH=getfullname(cv('get',blkEntry.cvId,'.handle'));
        sid=Simulink.ID.getSID(blockH);
        out=reqInfo.modelItemMap.isKey(sid);




        function[fRef,skipComplexity]=generate_sfunction_detailed_report(this,cvId,options)

            sfcnInfo=this.cvstruct.sfcnCovRes.covId2InstanceInfo(cvId);
            sfcnCovObj=this.allTests{1}.sfcnCovData.get(sfcnInfo.name);
            sfcnCovObj.setFilterCtx(cvi.ReportUtils.getFilterCtxForReport(options,this.allTests{1}));

            res=sfcnCovObj.getInstanceResults(sfcnInfo.instanceIdx);
            instanceSID=res.instance.sid;
            results=cell(1,numel(this.allTests));

            resObj=sfcnCovObj.extractInstance(sfcnInfo.instanceIdx);
            results{1}=resObj;
            resObj.setHtmlFile(1,'');
            cycloCplx=resObj.CodeTr.getCycloCplx(resObj.CodeTr.Root);
            skipComplexity=(cycloCplx(1)<=0);
            goodObjs=cell(numel(this.allTests),2);
            for ii=2:numel(this.allTests)
                sfcnCovObj=this.allTests{ii}.sfcnCovData.get(sfcnInfo.name);
                sfcnCovObj.setFilterCtx(cvi.ReportUtils.getFilterCtxForReport(options,this.allTests{ii}));
                if isempty(sfcnCovObj)||~hasResults(sfcnCovObj)
                    continue
                end

                idx=find(strcmp(instanceSID,sfcnCovObj.getInstanceSIDs()),1,'first');
                if isempty(idx)
                    continue
                end

                goodObjs(ii,:)={sfcnCovObj,idx(1)};
                resObj=sfcnCovObj.extractInstance(idx(1));
                results{ii}=resObj;
                resObj.setHtmlFile(1,'');
            end

            results(cellfun(@isempty,results))=[];

            metricsName={};
            if this.hasDecisionInfo
                metricsName{end+1}='decision';
            end
            if this.hasConditionInfo
                metricsName{end+1}='condition';
            end
            if this.hasMcdcInfo
                metricsName{end+1}='mcdc';
            end
            if~options.filtExecMetric
                metricsName{end+1}='statement';
            end
            if ismember('cvmetric_Structural_relationalop',this.toMetricNames)
                metricsName{end+1}='relationalop';
            end

            args=[results,{...
            options,...
            'showReport',false,...
            'outputDir',this.baseReportDir,...
            'radixName',sprintf('%s_%s_instance_%d',this.cvstruct.model.name,sfcnInfo.name,sfcnInfo.instanceIdx),...
            'metricNames',metricsName,...
            'lastIsTotal',true,...
            'scriptsection',cvi.ReportUtils.getJScriptSection(),...
            'ssid',instanceSID,...
            'covId',cvId...
            }];

            htmlFiles=codeinstrum.internal.codecov.CodeCovData.htmlReport(args{:});
            if isempty(htmlFiles)
                fRef='';
            else
                fRef=htmlFiles{1};
            end
            sfcnCovObj.setHtmlFile(sfcnInfo.instanceIdx,fRef);
            for ii=2:size(goodObjs,1)
                goodObjs{ii,1}.setHtmlFile(goodObjs{ii,2},fRef);
            end
