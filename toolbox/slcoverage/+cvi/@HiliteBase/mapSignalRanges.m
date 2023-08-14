function mapSignalRanges(informerObj,modelH,covdata)







    lineHandles=find_system(modelH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'findall','on','LookUnderMasks','all','FollowLinks','on','type','line','SegmentType','trunk');
    srcBlockH=get_param(lineHandles,'SrcBlockHandle');


    if~iscell(srcBlockH)
        srcBlockH={srcBlockH};
    end

    srcBlockVectH=[srcBlockH{:}]';
    NotValid=srcBlockVectH==-1;
    lineHandles(NotValid)=[];
    srcBlockH(NotValid)=[];


    srcPortH=get_param(lineHandles,'SrcPortHandle');
    if~iscell(srcPortH)
        srcPortH={srcPortH};
    end

    srcPortIdx=get_param([srcPortH{:}]','PortNumber');
    if~iscell(srcPortIdx)
        srcPortIdx={srcPortIdx};
    end

    isVirtual=strcmp(get_param([srcBlockH{:}]','Virtual'),'on');
    isConnection=strcmp(get_param([srcPortH{:}]','PortType'),'connection');

    lineCnt=length(lineHandles);


    virtualIdx=find(isVirtual&~isConnection);
    for lineIdx=virtualIdx(:)'
        srcPorts=get_param(lineHandles(lineIdx),'NonVirtualSrcPorts');


        if~any(srcPorts==-1)
            portCnt=length(srcPorts);
            thisSrcBlock=zeros(portCnt);
            thisSrcPortIdx=zeros(portCnt);

            for i=1:portCnt
                porti=srcPorts(i);
                linei=get_param(porti,'Line');
                thisSrcBlock(i)=get_param(linei,'SrcBlockHandle');
                thisSrcPortIdx(i)=get_param(porti,'PortNumber');
            end

            srcBlockH{lineIdx}=thisSrcBlock;
            srcPortIdx{lineIdx}=thisSrcPortIdx;
        end
    end

    for i=1:lineCnt
        if~isConnection(i)
            map_single_signal_ranges(informerObj,lineHandles(i),srcBlockH{i},srcPortIdx{i},covdata,modelH);
        end
    end


    function labelstr=formatted_block_name(blockH,mdlNameLength)
        maxStrLength=45;
        maxParentLength=14;

        blkPath=getfullname(blockH);
        dispPath=blkPath((mdlNameLength+1):end);
        dispPath=strrep(dispPath,char(10),' ');



        if length(dispPath)<=maxStrLength

            labelstr=dispPath;
        else
            parentH=get_param(get_param(blockH,'Parent'),'Handle');
            if(parentH==bdroot(blockH))

                labelstr=[dispPath(1:(maxStrLength-3)),'...'];
            else
                grandParentH=get_param(get_param(parentH,'Parent'),'Handle');
                parentName=get_param(parentH,'Name');

                if(grandParentH==bdroot(blockH))
                    if(length(parentName)>maxParentLength)

                        labelstr=['/',parentName(1:(maxParentLength-3)),'.../',get_param(blockH,'Name')];
                    else

                        labelstr=dispPath;
                    end
                else
                    if(length(parentName)>maxParentLength)

                        labelstr=['/../',parentName(1:(maxParentLength-3)),'.../',get_param(blockH,'Name')];
                    else

                        labelstr=['/../',parentName,'/',get_param(blockH,'Name')];
                    end
                end

                if(length(labelstr)>maxStrLength)
                    labelstr=[labelstr(1:(maxStrLength-3)),'...'];
                end
            end
        end



        function map_single_signal_ranges(informerObj,lineHandle,blocks,ports,covdata,modelH)










            if isempty(blocks)||any(strcmp(get_param(blocks(:,1),'DisableCoverage'),'on'))
                return;
            end


            lineUdi=get_param(lineHandle,'LineOwner');

            allNames={};
            allMins=[];
            allMaxs=[];
            allVarDims=[];

            modelNameLength=length(get_param(modelH,'Name'));


            try
                for i=1:length(blocks)
                    name={formatted_block_name(blocks(i),modelNameLength)};
                    [mins,maxs]=sigrangeinfo(covdata,blocks(i),ports(i));

                    [mins,maxs]=cvi.ReportScript.convertNonEvaluatedSigRangesToNan(mins,maxs);
                    allNames=[allNames,name(ones(1,length(mins)))];
                    allMins=[allMins,mins];
                    allMaxs=[allMaxs,maxs];

                end

                tableData.allNames=allNames;
                tableData.allMins=allMins;
                tableData.allMaxs=allMaxs;
                if~isempty(allVarDims)
                    tableData.allVarDims=allVarDims;
                end
                totalWidth=length(allMins);
                dispRows=min([totalWidth,20]);

                if isempty(allVarDims)
                    template={'$<B>Idx</B>','$<B>Source Block</B>','$<B>Min</B>','$<B>Max</B>','\n',...
                    {'ForN',dispRows,...
                    '@1',{'#allNames','@1'},{'#allMins','@1'},{'#allMaxs','@1'},'\n'}...
                    };
                else
                    template={'$<B>Idx</B>','$<B>Source Block</B>','$<B>Min</B>','$<B>Max</B>','$<B>VarDims</B>','\n',...
                    {'ForN',dispRows,...
                    '@1',{'#allNames','@1'},{'#allMins','@1'},{'#allMaxs','@1'},{'#allVarDims','@1'},'\n'}...
                    };
                end

                systableInfo.cols(1).align='"left"';
                systableInfo.cols(2).align='"left"';
                if~isempty(allVarDims)
                    systableInfo.cols(3).align='"center"';
                    systableInfo.table=' cellpadding="3" cellpadding="2" ';
                else
                    systableInfo.table='  cellpadding="2"';
                end
                systableInfo.textSize=4;

                tableStr=cvprivate('html_table',tableData,template,systableInfo);
                if~isempty(informerObj)
                    informerObj.addToMap(lineUdi,tableStr);
                end
            catch MEx


            end



