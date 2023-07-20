function dumpAnalysisInformation(this,cvdata,options)





    dump_title(this,'Slvnv:simcoverage:cvhtml:AnalysisInformation');

    [tableInfo,tableTemplate]=getTemplate(options.imageSubDirectory);

    data=getCoverageDataInfo(cvdata);
    dump_section(this,data,tableTemplate,tableInfo);

    data=getModelInfo(cvdata);
    dump_section(this,data,tableTemplate,tableInfo);

    if~isempty(cvdata.modelinfo.ownerModel)
        data=getHarnessInfo(cvdata);
        dump_section(this,data,tableTemplate,tableInfo);
    end

    data=getSimOpts(cvdata);
    dump_section(this,data,tableTemplate,tableInfo);


    data=getCovOpts(this,cvdata,options);
    dump_section(this,data,tableTemplate,tableInfo);


    topSlsf=cv('get',cvdata.rootId,'.topSlsf');

    filteredBlocks_data=cvi.ReportScript.getFilteredBlocks(this,options,topSlsf,false);
    [fBD,iFBd]=separateInternal(filteredBlocks_data);
    [fBD,sFI]=separateSpecialCases(fBD);
    if~isempty(sFI)
        dumpFilteredAndReducedBlocksInfo(this,sFI,options,'Slvnv:simcoverage:cvhtml:ObjectsFiltered');
    end
    this.rationaleMap=containers.Map('KeyType','char','ValueType','any');
    if~isempty(fBD)
        fBD=setRationaleNumbers(this.rationaleMap,fBD,'J');
        dumpFilteredBlocksInfo(this,fBD,options);
    end


    reducedBlocks_data=cvi.ReportScript.getReducedBlocksInfo(cvdata);
    dumpFilteredAndReducedBlocksInfo(this,reducedBlocks_data,options,'Slvnv:simcoverage:cvhtml:BlocksEliminated');

    iFBd=setRationaleNumbers(this.rationaleMap,iFBd,'T');
    if~isempty(iFBd)&&iFBd.isInternal
        iFBd.rationale=sprintf('Unit tested in: <a href="#ref_rationale_source">%s</a>',' <b>Unit Test 1<b>');
    end

    dumpFilteredAndReducedBlocksInfo(this,iFBd,options,'Slvnv:simcoverage:cvhtml:ObjectsInternallyFiltered');


    function[filterInfo,sFI]=separateSpecialCases(filterInfo)

        sFI=[];
        if~isempty(filterInfo)
            fidx={filterInfo.uuid}=="";
            if~isempty(fidx)
                sFI=filterInfo(fidx);
                filterInfo(fidx)=[];
            end
        end

        function[fBD,iFBd]=separateInternal(infBD)
            fBD=[];
            iFBd=[];
            for idx=1:numel(infBD)
                if~infBD(idx).isInternal
                    if isempty(fBD)
                        fBD=infBD(idx);
                    else
                        fBD(end+1)=infBD(idx);
                    end
                else
                    if isempty(iFBd)
                        iFBd=infBD(idx);
                    else
                        iFBd(end+1)=infBD(idx);
                    end
                end
            end


            function filteredBlocks_data=setRationaleNumbers(rationaleMap,filteredBlocks_data,prefix)

                for idx=1:numel(filteredBlocks_data)
                    ci=filteredBlocks_data(idx);
                    if ci.mode==1
                        idxStr=[prefix,num2str(idx),'.'];
                        rationaleMap(ci.refIdStr)=idxStr;

                        filteredBlocks_data(idx).idx=sprintf('<a name="ref_rationale_%s"></a> <a href="#ref_rationale_source_%s">%s</a>',...
                        ci.refIdStr,ci.refIdStr,idxStr);
                    else
                        filteredBlocks_data(idx).idx='';
                    end
                end

                function data=getCoverageDataInfo(cvdata)

                    data.info=struct('param',{},'value',{});
                    data.info(end+1).param=getString(message('Slvnv:simcoverage:cvhtml:DatabaseVersion'));
                    data.info(end).value=cvdata.dbVersion;
                    data.msgId='Slvnv:simcoverage:cvhtml:DataInformation';
                    data.title=getString(message(data.msgId));

                    if cvdata.simMode==SlCov.CovMode.Accel
                        data.info(end+1).param=getString(message('Slvnv:simcoverage:cvhtml:SimulationMode'));
                        data.info(end).value=getString(message('Slvnv:simcoverage:cvhtml:AcceleratorMode'));
                    end



                    function data=getModelInfo(cvdata)
                        data.info=struct('param',{},'value',{});
                        if~isempty(cvdata.modelinfo.modelVersion)
                            data.info(end+1).param=getString(message('Slvnv:simcoverage:cvhtml:ModelVersion'));
                            data.info(end).value=cvdata.modelinfo.modelVersion;
                            data.msgId='Slvnv:simcoverage:cvhtml:ModelInformation';
                            data.title=getString(message(data.msgId));
                        else
                            data.msgId='Slvnv:simcoverage:cvhtml:MATLABFunctionFileInformation';
                            data.title=getString(message(data.msgId));
                        end
                        if~isempty(cvdata.modelinfo.creator)
                            data.info(end+1).param=getString(message('Slvnv:simcoverage:cvhtml:Author'));
                            data.info(end).value=cvdata.modelinfo.creator;
                        end
                        if~isempty(cvdata.modelinfo.lastModifiedDate)
                            data.info(end+1).param=getString(message('Slvnv:simcoverage:cvhtml:LastSaved'));
                            data.info(end).value=cvdata.modelinfo.lastModifiedDate;
                        end


                        function res=bool2str(value)
                            if value
                                res=getString(message('Slvnv:simcoverage:cvhtml:on'));
                            else
                                res=getString(message('Slvnv:simcoverage:cvhtml:off'));
                            end

                            function data=getSimOpts(cvdata)
                                data.msgId='Slvnv:simcoverage:cvhtml:SimulationOptimizationOptions';
                                data.title=getString(message(data.msgId));
                                data.info(1).param=getString(message('Slvnv:simcoverage:cvhtml:InlineParameters'));
                                data.info(1).value=lower(cvdata.modelinfo.defaultParameterBehavior);
                                data.info(2).param=getString(message('Slvnv:simcoverage:cvhtml:BlockReduction'));
                                data.info(2).value=cvdata.modelinfo.blockReductionStatus;
                                data.info(3).param=getString(message('Slvnv:simcoverage:cvhtml:ConditionalBranchOptimization'));
                                data.info(3).value=bool2str(cvdata.modelinfo.conditionallyExecuteInputs);


                                function data=getHarnessInfo(cvd)
                                    data.msgId='Slvnv:simcoverage:cvhtml:HarnessInformation';
                                    data.title=getString(message(data.msgId));

                                    data.info(1).param=getString(message('Slvnv:simcoverage:cvhtml:HarnessModel'));
                                    data.info(1).value=cvd.modelinfo.harnessModel;
                                    data.info(end+1).param=getString(message('Slvnv:simcoverage:cvhtml:HarnessModelOwner'));
                                    data.info(end).value=cvd.modelinfo.ownerModel;


                                    function data=getCovOpts(this,cvd,options)
                                        data.msgId='Slvnv:simcoverage:cvhtml:CoverageOptions';
                                        data.title=getString(message(data.msgId));

                                        data.info(1).param=getString(message('Slvnv:simcoverage:cvhtml:AnalyzedModel'));
                                        data.info(1).value=cvd.modelinfo.analyzedModel;

                                        data.info(end+1).param=getString(message('Slvnv:simcoverage:cvhtml:LogicBlockShortCircuiting'));
                                        data.info(end).value=bool2str(cvd.modelinfo.logicBlkShortcircuit);

                                        if~isempty(cvd.metrics.mcdc)
                                            data.info(end+1).param=getString(message('Slvnv:simcoverage:cvhtml:McdcMode'));
                                            if(cvd.modelinfo.mcdcMode==1)
                                                mcdcMode=getString(message('Slvnv:simcoverage:cvhtml:McdcModeMasking'));
                                            else
                                                mcdcMode=getString(message('Slvnv:simcoverage:cvhtml:McdcModeUniqueCause'));
                                            end
                                            data.info(end).value=mcdcMode;
                                        end

                                        if isempty(cvd.reqTestMapInfo)
                                            if cvd.scopeDataToReqs

                                                scopeToReqMsg=getString(message('Slvnv:simcoverage:cvhtml:ScopeDataToReqsValueOnMissingReqs'));
                                                scopeToReqMsg=sprintf('<font color = "red">%s</font>',scopeToReqMsg);
                                            else


                                                scopeToReqMsg=[];
                                            end
                                        else
                                            if cvd.scopeDataToReqs

                                                scopeToReqMsg=getString(message('Slvnv:simcoverage:cvhtml:ScopeDataToReqsValueOn'));
                                            else

                                                scopeToReqMsg=getString(message('Slvnv:simcoverage:cvhtml:ScopeDataToReqsValueOff'));
                                            end
                                        end
                                        if~isempty(scopeToReqMsg)
                                            data.info(end+1).param=getString(message('Slvnv:simcoverage:cvhtml:ScopeDataToReqs'));
                                            data.info(end).value=scopeToReqMsg;
                                        end

                                        if slfeature('SlCovConsistentReportingOfVariants')&&~isempty(cvd.filterData)
                                            data.info(end+1).param=getString(message('Slvnv:simcoverage:cvhtml:ExcludeInactiveVariants'));
                                            data.info(end).value=bool2str(cvd.excludeInactiveVariants);
                                        end

                                        if~isempty(cvd.filter)
                                            if~isempty(options.topModelName)
                                                modelName=options.topModelName;
                                            else
                                                modelName=cvd.modelinfo.analyzedModel;
                                                if~cvd.isExternalMATLABFile
                                                    modelName=get_param(bdroot(modelName),'Name');
                                                end
                                            end

                                            if~isempty(options.getFilterCtxId())
                                                fileNameText=getString(message('Slvnv:simcoverage:cvhtml:FilterNames'));
                                            else
                                                fileNameText=getString(message('Slvnv:simcoverage:cvhtml:FilterFilename'));
                                            end
                                            data.info(end+1).param=fileNameText;
                                            htmlStr='';

                                            appliedFilters=cvi.TopModelCov.getFilterApplied(cvd.rootID);
                                            if~isempty(appliedFilters)
                                                appliedFilters([appliedFilters.isInternal]==true)=[];
                                            end
                                            this.appliedFilters=appliedFilters;
                                            for idx=1:numel(appliedFilters)

                                                if isempty(appliedFilters(idx).err)
                                                    filterFileName=appliedFilters(idx).fileName;

                                                    [path,filterFileName]=fileparts(filterFileName);
                                                    if~isempty(path)
                                                        filterFileName=join({path,filterFileName},filesep);
                                                        filterFileName=filterFileName{1};
                                                    end

                                                    this.filterFileName=filterFileName;

                                                    filterName=appliedFilters(idx).filterName;
                                                    if isempty(filterName)
                                                        filterName=getString(message('Slvnv:simcoverage:cvresultsexplorer:UntitledFilterName'));
                                                    end
                                                    filterUUID=appliedFilters(idx).uuid;
                                                    fileName=appliedFilters(idx).fileName;
                                                    [ctxId,reportViewCmd]=options.getFilterCtxId();

                                                    openLink=sprintf('<a href="matlab: cvi.FilterExplorer.FilterExplorer.openFilterCallback(''%s'', ''%s'', %d,  ''%s'', ''%s'', ''%s'');">%s</a>',...
                                                    ctxId,filterUUID,cvd.id,reportViewCmd,options.topModelName,fileName,filterName);
                                                    this.appliedFilters(idx).openLink=openLink;
                                                    htmlStr=[htmlStr,' ',openLink];
                                                else
                                                    this.appliedFilters(idx).openLink='';
                                                    htmlStr=[htmlStr,' ',sprintf('<font color = "red">%s</font>',appliedFilters(idx).err)];
                                                end
                                            end
                                            if~isempty(this.appliedFilters)

                                                this.appliedFilters({this.appliedFilters.openLink}=="")=[];
                                            end
                                            data.info(end).value=htmlStr;
                                        end


                                        function[fn,res]=checkFilterName(fileName,modelName)
                                            fn=fileName;
                                            res=true;
                                            d=[];
                                            if~isempty(fileName)
                                                [currFile,fullFileName]=SlCov.FilterEditor.findFile(fileName,modelName);
                                                if isa(currFile,'message')
                                                    fn=currFile;
                                                    res=false;
                                                    return;
                                                end
                                                d=dir(fullFileName);
                                            end
                                            if isempty(d)
                                                fn=message('Slvnv:simcoverage:ioerrors:UnableToOpenForReading',fileName);
                                                res=false;
                                                return;
                                            end


                                            function[tableInfo,tableTemplate]=getTemplate(imageDir)
                                                persistent cTableInfo cTableTemplate
                                                if isempty(cTableInfo)
                                                    cTableInfo.table='border="0" cellpadding="5" ';
                                                    cTableInfo.cols=struct('align','"left"','width',300);

                                                    cTableInfo.imageDir=imageDir;
                                                end
                                                tableInfo=cTableInfo;

                                                if isempty(cTableTemplate)
                                                    cTableTemplate=...
                                                    {{'ForEach','#.',...
                                                    {'Cat','$&#160; ','#param'},...
                                                    {'Cat','$&#160; ','#value'},...
'\n'...
                                                    }};
                                                end
                                                tableTemplate=cTableTemplate;



                                                function dump_section(this,data,tableTemplate,tableInfo)

                                                    htmlTag=cvi.ReportScript.convertNameToHtmlTag(data.msgId);
                                                    printIt(this,'<a name="%s"></a><h3>%s</h3>\n',htmlTag,data.title);

                                                    tableStr=cvprivate('html_table',data.info,tableTemplate,tableInfo);
                                                    printIt(this,'%s',tableStr);


                                                    function dump_title(this,msgId)
                                                        htmlTag=cvi.ReportScript.convertNameToHtmlTag(msgId);
                                                        printIt(this,'<a name="%s"></a><h2>%s</h2>\n',htmlTag,getString(message(msgId)));



