




classdef XilinxCP_IR<BA.Parser.CP_IR
    methods


        function thisXilinxCP_IR=XilinxCP_IR(f)

            thisXilinxCP_IR.timingFile=f;
            thisXilinxCP_IR.criticalPaths=[];

        end
    end


    methods

        function printOriginalCP(thisTwrInfo)
            for i=1:length(thisTwrInfo.criticalPaths)
                fprintf(1,'Original Critical Path %d\n',i);
                fprintf(1,'---------------------\n');
                thisTwrInfo.criticalPaths{i}.printOriginal;
                fprintf(1,'---------------------\n');
            end
        end


        function n=getNumCPs(thisXilinxCP_IR)
            n=length(thisXilinxCP_IR.criticalPaths);
        end


        function num=getNumNodes(thisXilinxCP_IR,c)
            num=thisXilinxCP_IR.criticalPaths{c}.numNodes;
        end



        function nodeName=getCPNode(thisXilinxCP_IR,c,i)
            cp=thisXilinxCP_IR.getCP(c);
            nodeName=cp.getNode(i).identifier;
        end





        function node=getEntireCPNode(thisXilinxCP_IR,c,i)
            cp=thisXilinxCP_IR.getCP(c);
            node=cp.getNode(i);
        end

        function latency=getCPNodeCumulativeLatency(thisXilinxCP_IR,c,i)
            cp=thisXilinxCP_IR.getCP(c);
            latency=cp.getNode(i).cumulativeDelay;
        end



        function startNode=getStartNode(thisXilinxCP_IR,c)
            cp=thisXilinxCP_IR.getCP(c);
            startNode=cp.getSource;
        end



        function endNode=getEndNode(thisXilinxCP_IR,c)
            cp=thisXilinxCP_IR.getCP(c);
            endNode=cp.getDestination;
        end

    end

    methods


        function cp=getCP(thisXilinxCP_IR,c)
            cp=thisXilinxCP_IR.criticalPaths{c};
        end



        function parse(thisXilinxCP_IR,analyzeUnconstrained)

            fid=fopen(thisXilinxCP_IR.timingFile,'r');

            if(fid==-1)
                error(message('hdlcoder:backannotate:InvalidTimingFile'));
            end

            cbuf=textscan(fid,'%s','delimiter','\n');


            lines=cbuf{1};


            numCP=0;
            relevantSection=false;
            cpSection=false;
            beginCP=false;

            for i=1:length(lines)
                found=false;
                currLine=lines(i);




                pat='Timing constraint: Default period analysis(.*)';
                header=regexp(currLine,pat,'ONCE');

                if~isempty(header{1})

                    relevantSection=true;
                    found=true;
                end

                if(~found&&analyzeUnconstrained)
                    pat='Timing constraint: Default path analysis(.*)';
                    header=regexp(currLine,pat,'ONCE');

                    if~isempty(header{1})

                        relevantSection=true;
                        found=true;
                    end
                end

                if(~found)

                    pat='Timing constraint: TS_clk(.*)';
                    header=regexp(currLine,pat,'ONCE');




                    if~isempty(header{1})

                        relevantSection=true;
                        found=true;
                    end
                end

                if(~found)

                    pat='Timing constraint: TS_FPGA_CLK(.*)';
                    header=regexp(currLine,pat,'ONCE');




                    if~isempty(header{1})

                        relevantSection=true;
                        found=true;
                    end
                end

                if(~found)

                    pat='Timing constraint: Default OFFSET IN BEFORE(.*)';
                    header=regexp(currLine,pat,'ONCE');




                    if~isempty(header{1})

                        relevantSection=analyzeUnconstrained;
                        found=true;
                    end
                end

                if(~found)

                    pat='Timing constraint: Default OFFSET OUT AFTER(.*)';
                    header=regexp(currLine,pat,'ONCE');




                    if~isempty(header{1})

                        relevantSection=analyzeUnconstrained;
                        found=true;
                    end
                end

                if(~found&&relevantSection)


                    pat='^(\s*)Delay:(\s*)(-?)(?<value>[0-9\.]+)ns(.*)';
                    delay=regexp(currLine,pat,'names','ONCE');

                    if isempty(delay{1})
                        pat='^(\s*)Delay (\(setup path\))?:(\s*)(-?)(?<value>[0-9\.]+)ns(.*)';
                        delay=regexp(currLine,pat,'names','ONCE');
                    end

                    if isempty(delay{1})
                        pat='^(\s*)Delay (\(hold path\))?:(\s*)(-?)(?<value>[0-9\.]+)ns(.*)';
                        delay=regexp(currLine,pat,'names','ONCE');
                    end

                    if isempty(delay{1})
                        pat='^(\s*)Slack (\(setup path\))?:(\s*)(?<value>[-0-9\.]+)ns(.*)';
                        delay=regexp(currLine,pat,'names','ONCE');
                    end

                    if isempty(delay{1})
                        pat='^(\s*)Slack (\(hold path\))?:(\s*)(?<value>[-0-9\.]+)ns(.*)';
                        delay=regexp(currLine,pat,'names','ONCE');
                    end

                    if isempty(delay{1})
                        pat='^(\s*)Offset (\(setup paths\))?:(\s*)(-?)(?<value>[0-9\.]+)ns(.*)';
                        delay=regexp(currLine,pat,'names','ONCE');
                    end

                    if isempty(delay{1})
                        pat='^(\s*)Offset (\(slowest paths\))?:(\s*)(-?)(?<value>[0-9\.]+)ns(.*)';
                        delay=regexp(currLine,pat,'names','ONCE');
                    end

                    if~isempty(delay{1})


                        numCP=numCP+1;

                        delayValue=str2double(delay{1}.value);


                        thisXilinxCP_IR.criticalPaths{numCP}=BA.Parser.xilinxCriticalPathInfo;

                        thisXilinxCP_IR.criticalPaths{numCP}.setOffset(delayValue);
                        found=true;

                    end

                    if(~found)


                        pat='(\s*)Source:(\s*)(?<value>[a-zA-Z_<>0-9/]+)(\s*)(.*)';
                        source=regexp(currLine,pat,'names','ONCE');

                        if~isempty(source{1})


                            BA.Parser.CP_IR.assertValidFormat(numCP);


                            thisXilinxCP_IR.criticalPaths{numCP}.setSource(BA.Main.baDriver.flattenHierarchicalNames(source{1}.value));

                            found=true;
                        end
                    end


                    if(~found)
                        pat='(\s*)Destination:(\s*)(?<value>[a-zA-Z_<>0-9/]+)(\s*)(.*)';
                        dest=regexp(currLine,pat,'names','ONCE');

                        if~isempty(dest{1})


                            BA.Parser.CP_IR.assertValidFormat(numCP);


                            thisXilinxCP_IR.criticalPaths{numCP}.setDestination(BA.Main.baDriver.flattenHierarchicalNames(dest{1}.value));
                            found=true;
                        end
                    end


                    if~found
                        pat='(\s*)Requirement:(\s*)(?<value>[0-9\.]+)ns(.*)';
                        dpdelay=regexp(currLine,pat,'names','ONCE');

                        if~isempty(dpdelay{1})


                            BA.Parser.CP_IR.assertValidFormat(numCP);

                            dpdelayValue=str2double(dpdelay{1}.value);
                            thisXilinxCP_IR.criticalPaths{numCP}.setRequirement(dpdelayValue);
                            found=true;
                        end
                    end


                    if~found
                        pat='(\s*)Data Path Delay:(\s*)(?<value>[0-9\.]+)ns(.*)';
                        dpdelay=regexp(currLine,pat,'names','ONCE');

                        if~isempty(dpdelay{1})


                            BA.Parser.CP_IR.assertValidFormat(numCP);

                            dpdelayValue=str2double(dpdelay{1}.value);
                            thisXilinxCP_IR.criticalPaths{numCP}.setDataPathDelay(dpdelayValue);
                            found=true;
                        end
                    end


                    if~found
                        pat='(\s*)Clock Path Delay:(\s*)(?<value>[0-9\.]+)ns(.*)';
                        cpdelay=regexp(currLine,pat,'names','ONCE');

                        if~isempty(cpdelay{1})


                            BA.Parser.CP_IR.assertValidFormat(numCP);

                            cpdelayValue=str2double(cpdelay{1}.value);
                            thisXilinxCP_IR.criticalPaths{numCP}.setClockPathDelay(cpdelayValue);
                            found=true;
                        end
                    end

                    if~found
                        pat='(\s*)Clock Uncertainty:(\s*)(?<value>[0-9\.]+)ns(.*)';
                        cpdelay=regexp(currLine,pat,'names','ONCE');

                        if~isempty(cpdelay{1})


                            BA.Parser.CP_IR.assertValidFormat(numCP);

                            cpdelayValue=str2double(cpdelay{1}.value);
                            thisXilinxCP_IR.criticalPaths{numCP}.setClockUncertainty(cpdelayValue);
                            found=true;
                        end
                    end


                    if~found
                        pat='(\s*)Maximum Data Path(.*)';
                        index=regexp(currLine,pat,'ONCE');
                        if~isempty(index{1})
                            found=true;
                            beginCP=true;
                        end

                    end

                    if~found&&beginCP
                        pat='(\s*)Location(\s+)Delay type(\s+)Delay\(ns\)(\s+)Physical Resource(.*)';
                        index=regexp(currLine,pat,'ONCE');

                        if~isempty(index{1})

                            cpSection=true;
                            found=true;
                        end
                    end


                    if~found&&cpSection
                        pat='(\s*)Total(\s*)([0-9\.]+)ns(.*)';
                        index=regexp(currLine,pat,'ONCE');

                        if~isempty(index{1})
                            cpSection=false;
                            beginCP=false;
                        end
                    end


                    if~found&&cpSection


                        pat='(\s*)(?<location>[a-zA-Z_0-9\.]+)(\s+)net(\s*)(\(.+\))?(\s+)[e~]?(\s+)(?<delay>[0-9\.]+)(\s+)(?<name>[a-zA-Z_0-9/\.<>]+)(\s*)';
                        pathNode=regexp(currLine,pat,'names','ONCE');

                        foundExactNode=false;

                        if~isempty(pathNode{1})


                            BA.Parser.CP_IR.assertValidFormat(numCP);

                            delayValue=str2double(pathNode{1}.delay);
                            thisXilinxCP_IR.criticalPaths{numCP}.addToCriticalPath(pathNode{1}.location,'net',delayValue,pathNode{1}.name);
                            foundExactNode=true;
                        end


                        pat='(\s*)(?<location>[a-zA-Z_0-9\.]+)(\s+)(?<delayType>T(\w+))(\s+)(?<delay>[0-9\.]+)(\s+)(?<name>[a-zA-Z_0-9/\.<>]+)(\s*)';
                        pathNode=regexp(currLine,pat,'names','ONCE');

                        if~isempty(pathNode{1})


                            BA.Parser.CP_IR.assertValidFormat(numCP);

                            delayValue=str2double(pathNode{1}.delay);
                            thisXilinxCP_IR.criticalPaths{numCP}.addToCriticalPath(pathNode{1}.location,pathNode{1}.delayType,delayValue,pathNode{1}.name);
                            foundExactNode=true;
                        end

                        if~foundExactNode


                            BA.Parser.CP_IR.assertValidFormat(numCP);


                            pat='(\s*)(?<name>[a-zA-Z_0-9/\.<>]+)(\s*)';
                            pathNode=regexp(currLine,pat,'names','ONCE');

                            if~isempty(pathNode{1})&&~strcmp(pathNode{1}.name,'Logical')
                                thisXilinxCP_IR.criticalPaths{numCP}.addToCriticalPath('intermediate','intermediate',0,pathNode{1}.name);
                            end
                        end
                    end
                end
            end
            if(analyzeUnconstrained)
                thisXilinxCP_IR.sortCriticalPathsWithOffsetDelay();
            end
            fclose(fid);
        end


        function abstractOutCP(this,numCP,p)
            if(numCP<this.numAbstracted)
                return;
            end

            for i=(this.numAbstracted+1):numCP
                this.abstractedCriticalPaths{i}=BA.Abstraction.abstractCPInfoByName(this,i);
                this.abstractedCriticalPaths{i}.abstractOutCP(p);
            end
            this.numAbstracted=numCP;
        end

    end
end


