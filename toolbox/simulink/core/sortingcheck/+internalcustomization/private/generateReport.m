function[ResultDescription]=generateReport(results,type)
















    html=genDescription();




    html=[html,genTableHeader(type)];

    for i=1:numel(results)
        dsm=results{i};

        oneReport=genReportForOneDSM(dsm);

        html=[html,oneReport];
    end

    html=[html,genTableEnd()];

    ResultDescription=html;



    function html=genDescription()

        html='<p> The following blocks have changed execution orders: </p>';


        function html=genTableHeader(type)

            nl=sprintf('\n');

            html=[nl,'<table border="1" cellpadding="2">'];


            switch type
            case 'FEATUREONOFF'
                html=[html,'<tr><td>Data store memory blocks</td><td>Tasks</td><td>Scoped systems</td><td>New execution order</td><td>Original execution order</td></tr>'];
            case 'SIMRTW'
                html=[html,'<tr><td>Data store memory blocks/ Signal objects</td><td>Tasks</td><td>Scoped systems</td><td>Normal mode execution order</td><td>Generated code execution order</td></tr>'];
            otherwise
                assert(false,'Unknown execution order comparison type')
            end


            function html=genReportForOneDSM(dsmInfo)

                html='';
                showDSM=true;
                for taskIdx=1:numel(dsmInfo.TaskInfo)
                    task=dsmInfo.TaskInfo(taskIdx);
                    showTask=true;
                    for scopedSysIdx=1:numel(task.ScopedSystemInfo)
                        scopedSys=task.ScopedSystemInfo(scopedSysIdx);
                        oneRow=genReportForOneRow(showDSM,dsmInfo.DataStoreMemoryBlock,dsmInfo.DataStoreName,showTask,task.TaskIndex,scopedSys.ParentSystem,scopedSys.ChildSystemInfo);
                        html=[html,'<tr>',oneRow,'</tr>'];

                        if showDSM
                            showDSM=false;
                        end

                        if showTask
                            showTask=false;
                        end
                    end
                end


                function html=genTableEnd()

                    html='</table>';



                    function html=genReportForOneRow(showDSM,dsmBlk,dsmName,showTask,taskIdx,scopedSys,childSysInfo)

                        dsmHtml='<td> </td>';
                        if showDSM
                            if ishandle(dsmBlk)
                                dsmHtml=['<td>',getBlockNameOrRef(dsmBlk,true),'</td>'];
                            else
                                dsmHtml=['<td>',dsmName,'</td>'];
                            end
                        end

                        taskHtml='<td> </td>';

                        if showTask
                            if(taskIdx==-2)
                                taskIdx='const';
                            else
                                taskIdx=sprintf('%d',taskIdx);
                            end
                            taskHtml=['<td>',taskIdx,'</td>'];
                        end

                        sysHtml=['<td>',getBlockNameOrRef(scopedSys,true),'</td>'];

                        [newOrderStr,oldOrderStr]=diffSystemExecOrderStr(childSysInfo);

                        newOrderHtml=['<td>',newOrderStr,'</td>'];

                        oldOrderHtml=['<td>',oldOrderStr,'</td>'];

                        html=[dsmHtml,taskHtml,sysHtml,newOrderHtml,oldOrderHtml];


                        function[newOrderStr,oldOrderStr]=diffSystemExecOrderStr(sysInfo)

                            nl=sprintf('\n');

                            newList=zeros(size(sysInfo));
                            oldOrder=zeros(size(sysInfo));

                            for idx=1:numel(sysInfo)
                                newList(idx)=sysInfo(idx).SystemHandle;
                                oldOrder(idx)=sysInfo(idx).OldSortedOrder;
                            end

                            [~,index]=sort(oldOrder);
                            oldList=newList(index);

                            newListStr='';
                            oldListStr='';


                            append=nl;

                            totalE=numel(newList);
                            for idx=1:totalE
                                blk1=getBlockNameOrRef(newList(idx),false);
                                blk2=getBlockNameOrRef(oldList(idx),false);
                                if(idx==totalE)
                                    append='';
                                end
                                newListStr=[newListStr,blk1,append];
                                oldListStr=[oldListStr,blk2,append];
                            end


                            df=comparisons_private('linediff',newListStr,oldListStr);

                            newDiffStr=df{1};
                            oldDiffStr=df{2};


                            newDiffStr=regexprep(newDiffStr,nl,'');
                            oldDiffStr=regexprep(oldDiffStr,nl,'');

                            newColorCode=getColorCode(true);
                            newOrderStr=customizeDiffStr(newList,newDiffStr,newColorCode);

                            oldColorCode=getColorCode(false);
                            oldOrderStr=customizeDiffStr(oldList,oldDiffStr,oldColorCode);


                            function customStr=customizeDiffStr(blkList,diffStr,colorCode)





                                totalE=numel(blkList);

                                outputStr=cell(1,totalE);

                                for idx=1:totalE
                                    blk=blkList(idx);

                                    blkName=getBlockNameOrRef(blk,false);


                                    pattern=['>',blkName,'<'];
                                    found=strfind(diffStr,pattern);

                                    blkRef=getBlockNameOrRef(blk,true);
                                    if isempty(found)

                                        outputStr{idx}=blkRef;
                                    else

                                        outputStr{idx}=['<span style="background: ',colorCode,';">',blkRef,'</span>'];
                                    end
                                end

                                customStr='';
                                append=', ';
                                for idx=1:totalE
                                    if(idx==totalE)
                                        append='';
                                    end
                                    customStr=[customStr,outputStr{idx},append];
                                end

