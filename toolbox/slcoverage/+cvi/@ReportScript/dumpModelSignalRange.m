function dumpModelSignalRange(this,cvId,allTests,waitbarH,options)




    try

        tv.waitbarH=waitbarH;
        tv.allTests=allTests;
        tv.cvId=cvId;
        tv.this=this;


        bdH=cv('get',cvId,'.handle');
        if(bdH==bdroot(bdH))
            tv.bdId=cvId;
        else
            tv.bdId=-1;
        end

        tv=create_scriptStruct(tv);

        if~isempty(tv.sigrange)
            dump_hierarchy(tv,false,options);
        end

        if~isempty(tv.sigsize)&&tv.isVariable
            tv=delete_empty_parts(tv);
            dump_hierarchy(tv,true,options);
        end
    catch MEx
        rethrow(MEx);
    end

    function scriptStruct=empty_scriptStruct
        scriptStruct=struct('name',[],...
        'hasVarDims',[],...
        'depth',[],...
        'text',[],...
        'min',[],...
        'max',[],...
        'totalPortElem',[],...
        'sizeText',[],...
        'sizeMin',[],...
        'sizeMax',[],...
        'allocatedSize',[],...
        'numOfPorts',[],...
        'filtered',[],...
        'notActiveRange',[]);



        function scr=get_script_data(ds,tv)

            scr=empty_scriptStruct;
            scr=set_size_minmax(scr,ds,tv);
            [scr,done]=check_numOfPorts(scr,tv);
            if~done
                scr=set_minmax(scr,ds,tv);
                [scr.min,scr.max]=cvi.ReportScript.convertNonEvaluatedSigRangesToNan(scr.min,scr.max);
            end
            scr.totalPortElem=numel(scr.text);
            scr.hasVarDims=ds.hasVarDims;
            scr.filtered=ds.isFiltered;


            function scriptStruct=set_size_minmax(scriptStruct,ds,tv)

                if isempty(ds.sizeBaseIdx)||isempty(tv.sigsize)
                    return
                end

                scriptStruct.sizeText={getPortName(1,ds,[],[])};
                scriptStruct.sizeMin=tv.sigsize(ds.sizeBaseIdx,:);
                scriptStruct.sizeMax=tv.sigsize(ds.sizeBaseIdx+1,:);
                scriptStruct.allocatedSize=ds.portSizes;
                if~isempty(ds.isDynamic)&&ds.isDynamic(1)

                    scriptStruct.allocatedSize(1)=inf;
                end
                scriptStruct.numOfPorts=numel(ds.portSizes);

                if scriptStruct.numOfPorts>1
                    for portIdx=2:numel(ds.portSizes)
                        scriptStruct.sizeText{portIdx}=getPortName(portIdx,ds,[],[]);
                        scriptStruct.sizeMin(portIdx,:)=tv.sigsize(ds.sizeBaseIdx+2*portIdx-2,:);
                        scriptStruct.sizeMax(portIdx,:)=tv.sigsize(ds.sizeBaseIdx+2*portIdx-1,:);
                        if~isempty(ds.isDynamic)&&ds.isDynamic(portIdx)

                            scriptStruct.allocatedSize(portIdx)=inf;
                        end
                    end
                end


                function tv=delete_empty_parts(tv)
                    count=numel(tv.scriptStruct);
                    exceptionIdx=zeros(1,count,'like',false);
                    for idx=count:-1:1
                        if tv.scriptStruct(idx).hasVarDims||exceptionIdx(idx)

                            parentCvId=cv('get',tv.allIds(idx),'.treeNode.parent');
                            exceptionIdx(idx)=true;
                            exceptionIdx=exceptionIdx|tv.allIds==parentCvId;
                            [tv.scriptStruct(idx).sizeMin,tv.scriptStruct(idx).sizeMax]=cvi.ReportScript.convertNonEvaluatedSigRangesToNan(tv.scriptStruct(idx).sizeMin,tv.scriptStruct(idx).sizeMax);
                        end
                    end
                    tv.scriptStruct(~exceptionIdx)=[];


                    function[scriptStruct,res]=aggregate_vector(portIdx,usedSize,scriptStruct,ds,tv)

                        res=false;
                        if isempty(ds.baseIdx)||isempty(tv.sigrange)
                            return;
                        end

                        if~isempty(ds.isDynamic)&&ds.isDynamic(portIdx)
                            scriptStruct.min(end+1,:)=tv.sigrange(ds.baseIdx+2*sum(ds.portSizes(1:(portIdx-1))));
                            scriptStruct.max(end+1,:)=tv.sigrange(ds.baseIdx+2*sum(ds.portSizes(1:(portIdx-1)))+1);
                            scriptStruct.text{end+1}=sprintf('%s%s%s%s%s',...
                            getPortName(portIdx,ds,[],[]),...
                            '(:)',...
                            '<span style=''color:red''>  <i>(',...
                            getString(message('Slvnv:simcoverage:cvhtml:aggregated')),...
                            '</i>)</span>');
                            scriptStruct.notActiveRange(end+1)=false;
                            res=true;
                        elseif(usedSize>max(1,cvmaxreportsignalrange('get','vectorSize')))
                            minOut=tv.sigrange(ds.baseIdx+2*sum(ds.portSizes(1:(portIdx-1)))+(0:2:2*(usedSize-1)),:);
                            maxOut=tv.sigrange(ds.baseIdx+2*sum(ds.portSizes(1:(portIdx-1)))+(1:2:2*(usedSize-1)),:);
                            scriptStruct.min(end+1,:)=min(minOut);
                            scriptStruct.max(end+1,:)=max(maxOut);
                            scriptStruct.text{end+1}=sprintf('%s%s%d%s%s%s',...
                            getPortName(portIdx,ds,[],[]),...
                            '<span style=''color:red''>  (<i>[1-',...
                            usedSize,...
                            '], ',...
                            getString(message('Slvnv:simcoverage:cvhtml:aggregated')),...
                            '</i>)</span>');
                            scriptStruct.notActiveRange(end+1)=false;
                            res=true;
                        end

                        function[scriptStruct,res]=check_numOfPorts(scriptStruct,tv)
                            res=false;
                            if isempty(tv.sigrange)
                                return;
                            end

                            if(scriptStruct.numOfPorts>max(1,cvmaxreportsignalrange('get','modelSignals')))
                                scriptStruct.text{end+1}=sprintf('%s%s%d%s%s',...
                                scriptStruct.name,...
                                '<span style=''color:red''>  (<i>',...
                                scriptStruct.numOfPorts,...
                                getString(message('Slvnv:simcoverage:cvhtml:SignalsExceeding')),...
                                '</i>)</span>');
                                scriptStruct.min(end+1)=NaN;
                                scriptStruct.max(end+1)=NaN;
                                scriptStruct.notActiveRange(end+1)=false;
                                res=true;
                            end



                            function outStr=getPortName(portIdx,ds,fromIdx,toIdx)

                                if~isempty(ds.portLabels)
                                    outStr=ds.portLabels{portIdx};
                                elseif numel(ds.portSizes)==1&&ds.portSizes(portIdx)==1&&~isempty(ds.isDynamic)&&~ds.isDynamic(portIdx)
                                    outStr='';
                                else
                                    outStr='out';
                                    if numel(ds.portSizes)>1
                                        outStr=['out',num2str(portIdx)];
                                    end
                                end
                                if ds.portSizes(portIdx)>1&&(~isempty(fromIdx)||~isempty(toIdx))
                                    if~isempty(fromIdx)
                                        outStr=[outStr,'[',num2str(fromIdx)];
                                    end
                                    if~isempty(toIdx)&&fromIdx<toIdx
                                        outStr=[outStr,'-',num2str(toIdx)];
                                    end
                                    outStr=[outStr,']'];
                                end


                                function scriptStruct=set_minmax(scriptStruct,ds,tv)
                                    if isempty(ds.baseIdx)||isempty(tv.sigrange)
                                        return;
                                    end
                                    numOfPorts=numel(ds.portSizes);

                                    for portIdx=1:numOfPorts

                                        usedSize=Inf;
                                        if~isempty(scriptStruct.sizeMax)
                                            usedSize=scriptStruct.sizeMax(portIdx,end);
                                        end



                                        if abs(usedSize)==Inf
                                            usedSize=ds.portSizes(portIdx);
                                        end

                                        [scriptStruct,done]=aggregate_vector(portIdx,usedSize,scriptStruct,ds,tv);

                                        if~done
                                            dataIdx=ds.baseIdx+2*sum(ds.portSizes(1:(portIdx-1)));

                                            if~isempty(ds.isDynamic)&&ds.isDynamic(portIdx)
                                                scriptStruct.min(end+1,:)=tv.sigrange(dataIdx,:);
                                                scriptStruct.max(end+1,:)=tv.sigrange(dataIdx+1,:);
                                                scriptStruct.text{end+1}=getPortName(portIdx,ds,1,[]);
                                                scriptStruct.notActiveRange(end+1)=false;
                                            else
                                                for portElemIdx=1:usedSize
                                                    scriptStruct.min(end+1,:)=tv.sigrange(dataIdx+2*(portElemIdx-1),:);
                                                    scriptStruct.max(end+1,:)=tv.sigrange(dataIdx+2*(portElemIdx-1)+1,:);
                                                    scriptStruct.text{end+1}=getPortName(portIdx,ds,portElemIdx,[]);
                                                    scriptStruct.notActiveRange(end+1)=false;
                                                end
                                            end
                                        end
                                        if~isempty(scriptStruct.sizeMax)&&(scriptStruct.allocatedSize(portIdx)~=usedSize)&&(isempty(ds.isDynamic)||~ds.isDynamic(portIdx))
                                            scriptStruct.min(end+1,:)=inf;
                                            scriptStruct.max(end+1,:)=-inf;
                                            scriptStruct.text{end+1}=getPortName(portIdx,ds,usedSize+1,ds.portSizes(portIdx));
                                            scriptStruct.notActiveRange(end+1)=true;
                                        end

                                    end


                                    function dump_hierarchy(tv,reportSizes,options)

                                        if reportSizes
                                            if tv.testCnt>1
                                                minmax={
                                                {'ForN',tv.testCnt,...
                                                {'#sizeMin','@2','@1'},...
                                                {'#sizeMax','@2','@1'}
                                                }
                                                };
                                            else
                                                minmax={
                                                {'#sizeMin','@1'},...
                                                {'#sizeMax','@1'}
                                                };
                                            end


                                            dumpMinMax={
                                            {'If',{'RpnExpr',{'&isempty','#sizeMin'},'!'},...
                                            {'If',{'RpnExpr',{'#numOfPorts'},1,'>'},...
'\n'
                                            },...
                                            {'ForN',{'#numOfPorts'},...
                                            {'If',{'RpnExpr',{'#numOfPorts'},1,'>'},...
                                            {'&in_tabstr',{'Cat',{'#sizeText','@1'}},{'RpnExpr','#depth',1,'+'}},...
                                            },...
                                            minmax{:},...
                                            {'If',{'&isinf',{'#allocatedSize','@1'}},'$-','Else',{'#allocatedSize','@1'}},...
'\n'...
                                            }
                                            }
                                            };
                                        else
                                            if tv.testCnt>1
                                                minmax={
                                                {'ForN',tv.testCnt,...
                                                {'#min','@2','@1'},...
                                                {'#max','@2','@1'}
                                                }
                                                };
                                            else

                                                minmax={
                                                {'#min','@1'}...
                                                ,{'#max','@1'}
                                                };
                                            end


                                            dumpMinMax={
                                            {'If',{'RpnExpr',{'&isempty','#min'},'!'},...
                                            {'If',{'RpnExpr',{'#totalPortElem'},1,'>',{'&any',{'&isinf','#allocatedSize'}},'|'},...
'\n'
                                            },...
                                            {'ForN',{'#totalPortElem'},...
                                            {'If',{'RpnExpr',{'#notActiveRange','@1'}},{'&in_startcolor',options.varSizeColor}},...
                                            {'If',{'RpnExpr',{'#totalPortElem'},1,'>',{'&any',{'&isinf','#allocatedSize'}},'|'},...
                                            {'&in_tabstr',{'Cat',{'#text','@1'}},{'RpnExpr','#depth',1,'+'}},...
                                            },...
                                            minmax{:},...
                                            {'If',{'RpnExpr',{'#notActiveRange','@1'}},{'&in_endcolor'}},...
'\n'
                                            }
                                            }
                                            };
                                        end

                                        entryTemplate=...
                                        {
                                        {'If',{'#filtered'},{'&in_startcolor',options.varSizeColor}},...
                                        {'Cat',{'&in_tabstr','#name','#depth'},'$ &#160; '},...
                                        dumpMinMax{:},...
                                        {'If',{'#filtered'},{'&in_endcolor'}},...
                                        {'If',{'RpnExpr',{'&isempty','#min'},{'RpnExpr','#totalPortElem',0,'<='},'|'},'\n'}...
                                        };
                                        titleRows={['$<B>',getString(message('Slvnv:simcoverage:cvhtml:Min')),'</B>'],['$<B>',getString(message('Slvnv:simcoverage:cvhtml:Max')),'</B>']};
                                        allocatedTitle={};
                                        if reportSizes
                                            allocatedTitle={['$<B>',getString(message('Slvnv:simcoverage:cvhtml:Allocated')),'</B>']};
                                        end

                                        if tv.testCnt==1
                                            titleRows=[{['$<B>',getString(message('Slvnv:simcoverage:cvhtml:Hierarchy')),'</B>']},titleRows,allocatedTitle,{'\n'}];
                                        else
                                            colwidth=2;
                                            titleRows={['$<B>',getString(message('Slvnv:simcoverage:cvhtml:Hierarchy')),'</B>'],...
                                            {'ForN',tv.testCnt-1,...
                                            {'CellFormat',...
                                            {'Cat','$<B>Test ','@1','$</B>'},...
colwidth...
                                            }...
                                            },...
                                            {'CellFormat','$<B>Overall</B>',colwidth},...
                                            '\n',...
                                            '$ ',{'ForN',tv.testCnt,titleRows{:}},allocatedTitle{:},'\n'};
                                        end


                                        template={titleRows{:},...
                                        {'ForEach','#.',entryTemplate{:}}};

                                        systableInfo.cols(1).align='"left"';
                                        systableInfo.cols(2).align='"center"';

                                        systableInfo.table='cellpadding="3"';

                                        systableInfo.textSize=2;
                                        if(length(tv.scriptStruct)>max(0,cvmaxreportsignalrange('get','lineCntLimit')))
                                            tableStr=sprintf('%s%s%s',...
                                            '<a><span style=''color:red''><i>',...
                                            getString(message('Slvnv:simcoverage:cvhtml:SignalRangeInformationExceeds',max(0,cvmaxreportsignalrange('get','lineCntLimit')))),...
                                            '</i></span></a><br/>');
                                            tableStr=[tableStr,...
                                            '<a><span style=''color:red''><i>',getString(message('Slvnv:simcoverage:cvhtml:SetTheLineCount')),'</i></span></a>'];
                                        else
                                            tableStr=cvprivate('html_table',tv.scriptStruct,template,systableInfo);
                                        end

                                        if~isempty(tv.waitbarH)
                                            tv.waitbarH.setValue(100);
                                        end

                                        if reportSizes
                                            str='Slvnv:simcoverage:cvhtml:VariableSignalWidths';
                                            title=getString(message(str));
                                            htmlTag=cvi.ReportScript.convertNameToHtmlTag(str);
                                        else
                                            str='Slvnv:simcoverage:cvhtml:SignalRanges';
                                            title=getString(message(str));
                                            htmlTag=cvi.ReportScript.convertNameToHtmlTag(str);
                                        end

                                        printIt(tv.this,'<a name="%s"></a><h2>%s</h2>\n',htmlTag,title);

                                        printIt(tv.this,'%s',tableStr);


                                        function tv=collect_tests(tv,metricName)

                                            if isfield(tv.allTests{1}.metrics,metricName)&&...
                                                ~isempty(tv.allTests{1}.metrics.(metricName))
                                                tv.(metricName)=tv.allTests{1}.metrics.(metricName);




                                                for i=2:numel(tv.allTests)
                                                    tv.(metricName)=[tv.(metricName),tv.allTests{i}.metrics.(metricName)];
                                                end
                                            else
                                                tv.(metricName)=[];
                                            end


                                            function dataStruct=create_empty_dataStruct()
                                                dataStruct=struct('baseIdx',[],'sizeBaseIdx',[],'hasVarDims',false,'portLabels',[],'portSizes',[],'isDynamic',[],'objData',[]);



                                                function tv=collect_data(tv)

                                                    tv.srIsa=cv('get','default','sigranger.isa');

                                                    tv.actualMetric=cvi.MetricRegistry.getEnum('sigrange');

                                                    [tv.allIds,tv.depths]=cv('DfsOrder',tv.cvId,'require',tv.actualMetric);
                                                    tv.origins=cv('get',tv.allIds,'slsfobj.origin');


                                                    tv.testCnt=numel(tv.allTests);
                                                    tv=collect_tests(tv,'sigrange');
                                                    tv=collect_tests(tv,'sigsize');

                                                    function tv=create_scriptStruct(tv)

                                                        tv=collect_data(tv);
                                                        tv.scriptStruct={};

                                                        numOfIds=numel(tv.allIds);
                                                        if~isempty(tv.waitbarH)&&numOfIds>10
                                                            tv.waitbarH.setLabelText(getString(message('Slvnv:simcoverage:cvhtml:ReportingSignalRanges')));
                                                            tv.waitbarH.setValue(0);
                                                        else
                                                            tv.waitbarH=[];
                                                        end
                                                        tv.isVariable=false;
                                                        for idx=1:numOfIds
                                                            cId=tv.allIds(idx);
                                                            ds=create_empty_dataStruct();

                                                            [srId,isaVal]=cv('MetricGet',cId,tv.actualMetric,'.id','.isa');

                                                            isSFId=false;%#ok<NASGU> 
                                                            if isaVal==tv.srIsa

                                                                [ds.portSizes,ds.isDynamic,ds.baseIdx]=cv('get',srId,'.cov.allWidths','.cov.isDynamic','.cov.baseIdx');
                                                                ds.baseIdx=ds.baseIdx+1;

                                                                isSFId=tv.origins(idx)==2;
                                                                if isSFId


                                                                    sfChartId=cv('get',cId,'.handle');
                                                                    [dnames,dwidths,dnumbers]=cvprivate('cv_sf_chart_data',sfChartId);
                                                                    dnumbers=dnumbers+1;
                                                                    [~,sortI]=sort(dnumbers);
                                                                    startIdx=[0,cumsum(2*dwidths')];

                                                                    ds.objData=[];
                                                                    if~isempty(tv.sigrange)
                                                                        for varIdx=1:numel(dnames)
                                                                            ds.objData=[ds.objData,tv.sigrange(ds.baseIdx+startIdx(sortI(varIdx))+(0:dwidths(sortI(varIdx))),:)];
                                                                        end
                                                                    end
                                                                    ds.portLabels=dnames(sortI);
                                                                    ds.portSizes=dwidths(sortI)';
                                                                else

                                                                    if tv.actualMetric~=cvi.MetricRegistry.getEnum('sigsize')
                                                                        ssId=cv('MetricGet',cId,cvi.MetricRegistry.getEnum('sigsize'),'.id');


                                                                        if~isempty(ssId)
                                                                            ds.sizeBaseIdx=cv('get',ssId,'.cov.baseIdx')+1;
                                                                            tv.isVariable=true;
                                                                            ds.hasVarDims=true;
                                                                        end
                                                                    end
                                                                end

                                                            end

                                                            metricsIds=cv('get',cId,'.metrics');
                                                            for idxm=1:numel(metricsIds)
                                                                cmid=metricsIds(idxm);
                                                                if(cv('get',cmid,'.isa')~=tv.srIsa)
                                                                    if cv('get',cmid,'.hasVariableSize')
                                                                        ds.hasVarDims=true;
                                                                        break;
                                                                    end
                                                                end
                                                            end


                                                            ds.isFiltered=cv('get',cId,'.isDisabled');
                                                            scr=get_script_data(ds,tv);

                                                            if tv.bdId==cId
                                                                scr.name=cv('GetSlsfName',cId);
                                                            else
                                                                scr.name=cvi.ReportUtils.obj_diag_named_link(cId);
                                                            end

                                                            scr.depth=tv.depths(idx);

                                                            if isempty(tv.scriptStruct)
                                                                tv.scriptStruct=scr;
                                                            else
                                                                tv.scriptStruct(end+1)=scr;
                                                            end
                                                            if(~isempty(tv.waitbarH))
                                                                tv.waitbarH.setValue(50*idx/numOfIds);
                                                            end

                                                        end
