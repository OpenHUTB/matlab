function report=generateReportForFix(succeed,changedSystems,skippedSystems,type)

    if(strcmp(type,'FEATUREONOFF'))
        if succeed
            part1=genPassedReport(changedSystems);
            part2='<p> The system have been automatically upgraded. </p>';
        else
            part1=genFailedReport(changedSystems,skippedSystems);
            part2='<p> Manual upgrade is required for the system. </p>';
        end
    else
        if succeed
            part1='<p> The relative execution orders for Data Store Read and Data Store Write blocks are now the same in normal mode simulation and generated code. The block prorities of the following blocks have been modified: </p>';
            part2=genPassedReport2(changedSystems);
        else
            part1='<p> Attempt to modify block priorities was unsuccessful.</p>';
            part2=genFailedReport2(changedSystems,skippedSystems);
        end
    end
    report=[part1,part2];


    function report=genPassedReport(changedSystems)
        html='<p> Modified priorities for the following blocks: </p>';
        body=genChangedBlockList(changedSystems);
        report=[html,body];


        function report=genFailedReport(changedSystems,skippedSystems)

            skippedAll=isempty(changedSystems);

            htmla='';

            if~skippedAll
                htmla=genPassedReport(changedSystems);
            end

            htmlb='<p> Manual update is required because the following blocks have specified priorities: </p>';

            body=genViolationBlockList(skippedSystems);

            report=[htmla,htmlb,body];


            function report=genPassedReport2(changedSystems)
                body=genChangedBlockList(changedSystems);
                report=body;


                function report=genFailedReport2(changedSystems,skippedSystems)

                    if~isempty(skippedSystems)
                        html='<p> The following blocks already have specified priorities: </p>';

                        body=genViolationBlockList(skippedSystems);

                        report=[html,body];
                    else
                        if~isempty(changedSystems)
                            modelName=bdroot(getfullname(changedSystems(1).UpdatedBlocks(1)));
                        else
                            modelName=bdroot;
                        end
                        assert(~isempty(modelName),'Model is closed');

                        html='<p> Possible reasons are: </p>';

                        html=[html,'<ul>'];

                        html=[html,'<li> The Data Store Read and Data Store Write blocks are in subsytems with multiple tasks. Consider putting the Data Store Read and Data Store Write blocks in subsystems with only one task.</li>'];

                        html=[html,'<li> The <a href="matlab: modeladvisorprivate openCSAndHighlight ',modelName,' ','OptimizationLevel','">code generation optimization level</a> is too high. Consider lowering the optimization level.</li>'];

                        html=[html,'<li> The <a href="matlab: modeladvisorprivate openCSAndHighlight ',modelName,' ','BlockReduction','">block reduction option</a> is checked. Consider unchecking the block reduction option.</li>'];

                        html=[html,'</ul>'];

                        report=html;
                    end


                    function html=genChangedBlockList(changedSystems)

                        colorCode=getColorCode(true);

                        html='<ul>';
                        for sysIdx=1:numel(changedSystems)
                            currSys=changedSystems(sysIdx);

                            listStart=[html,'<li>'];

                            listItem=getBlockNameOrRef(currSys.ParentSystem,true);
                            body=genBlockList(currSys.UpdatedBlocks,colorCode);

                            html=[listStart,listItem,body];
                            html=[html,'</li>'];
                        end

                        html=[html,'</ul>'];


                        function html=genViolationBlockList(skippedSystems)

                            colorCode=getColorCode(false);

                            html='<ul>';

                            for sysIdx=1:numel(skippedSystems)
                                currSys=skippedSystems(sysIdx);

                                listStart=[html,'<li>'];

                                listItem=getBlockNameOrRef(currSys.ParentSystem,true);
                                body=genBlockList(currSys.ViolationBlocks,colorCode);

                                html=[listStart,listItem,body];
                                html=[html,'</li>'];
                            end
                            html=[html,'</ul>'];


                            function html=genBlockList(blocks,colorCode)

                                colorHtml=['<span style="background-color:',colorCode,'">'];

                                html='<ul>';
                                for i=1:numel(blocks)
                                    html=[html,'<li>'];
                                    html=[html,colorHtml,getBlockNameOrRef(blocks(i),true),'</span>'];
                                    html=[html,'</li>'];
                                end

                                html=[html,'</ul>'];
