




classdef AlteraCP_IR<BA.Parser.CP_IR
    methods


        function thisAlteraCP_IR=AlteraCP_IR(f)

            thisAlteraCP_IR.timingFile=f;
            thisAlteraCP_IR.criticalPaths=[];

        end
    end


    methods

        function printOriginalCP(thisStaInfo)
            for i=1:length(thisStaInfo.criticalPaths)
                fprintf(1,'Original Critical Path %d\n',i);
                fprintf(1,'---------------------\n');
                thisStaInfo.criticalPaths{i}.printOriginal;
                fprintf(1,'---------------------\n');
            end
        end


        function n=getNumCPs(thisAlteraCP_IR)
            n=length(thisAlteraCP_IR.criticalPaths);
        end


        function num=getNumNodes(thisAlteraCP_IR,c)
            num=thisAlteraCP_IR.criticalPaths{c}.numNodes;
        end



        function nodeName=getCPNode(thisAlteraCP_IR,c,i)
            cp=thisAlteraCP_IR.getCP(c);
            nodeName=cp.getNode(i).identifier;
        end



        function node=getEntireCPNode(thisAlteraCP_IR,c,i)
            cp=thisAlteraCP_IR.getCP(c);
            node=cp.getNode(i);
        end


        function latency=getCPNodeCumulativeLatency(thisAlteraCP_IR,c,i)
            cp=thisAlteraCP_IR.getCP(c);
            latency=cp.getNode(i).cumulativeDelay;
        end


        function startNode=getStartNode(thisAlteraCP_IR,c)
            cp=thisAlteraCP_IR.getCP(c);
            startNode=cp.getSource;
        end


        function endNode=getEndNode(thisAlteraCP_IR,c)
            cp=thisAlteraCP_IR.getCP(c);
            endNode=cp.getDestination;
        end


        function nodeName=getCPNodeType(thisAlteraCP_IR,c,i)
            cp=thisAlteraCP_IR.getCP(c);
            nodeName=cp.getNode(i).opType;
        end


        function nodeName=getCPNodeTypeName(thisAlteraCP_IR,c,i)
            cp=thisAlteraCP_IR.getCP(c);
            nodeName=cp.getNode(i).opTypeName;
        end
    end

    methods


        function cp=getCP(thisAlteraCP_IR,c)
            cp=thisAlteraCP_IR.criticalPaths{c};
        end



        function parse(thisAlteraCP_IR)

            fid=fopen(thisAlteraCP_IR.timingFile,'r');

            if(fid==-1)
                error(message('hdlcoder:backannotate:InvalidTimingFile'));
            end

            cbuf=textscan(fid,'%s','delimiter','\n');


            lines=cbuf{1};


            numCP=0;
            relevantSection=false;
            cpSection=false;
            beginCP=false;
            hasHSLP=true;

            for i=1:length(lines)
                found=false;
                currLine=lines(i);


                pat='Report Timing(.*)';
                header=regexp(currLine,pat,'ONCE');

                if~isempty(header{1})

                    relevantSection=true;
                    found=true;
                end

                if(~found)
                    pat='Path #(.*)';
                    header=regexp(currLine,pat,'ONCE');

                    if~isempty(header{1})

                        relevantSection=true;
                        found=true;

                        numCP=numCP+1;

                        thisAlteraCP_IR.criticalPaths{numCP}=BA.Parser.alteraCriticalPathInfo;
                    end
                end

                if(~found&&relevantSection)


                    pat=';(\s*)From Node(\s*);(\s*)(?<value>[a-zA-Z_0-9|.:~\[\]]+)(\s*);(.*)';
                    source=regexp(currLine,pat,'names','ONCE');

                    if~isempty(source{1})


                        BA.Parser.CP_IR.assertValidFormat(numCP);


                        thisAlteraCP_IR.criticalPaths{numCP}.setSource(BA.Main.baDriver.flattenHierarchicalNames(source{1}.value,'Altera'));

                        found=true;
                    end


                    if(~found)
                        pat=';(\s*)To Node(\s*);(\s*)(?<value>[a-zA-Z_0-9|.:~\[\]]+)(\s*);(.*)';
                        dest=regexp(currLine,pat,'names','ONCE');

                        if~isempty(dest{1})


                            BA.Parser.CP_IR.assertValidFormat(numCP);


                            thisAlteraCP_IR.criticalPaths{numCP}.setDestination(BA.Main.baDriver.flattenHierarchicalNames(dest{1}.value,'Altera'));
                            found=true;
                        end
                    end


                    if~found
                        pat=';(\s*)Data Arrival Time(\s*);(\s*)(?<value>[0-9\.]+)(\s*);(.*)';
                        delay=regexp(currLine,pat,'names','ONCE');

                        if~isempty(delay{1})
                            delayValue=str2double(delay{1}.value);
                            thisAlteraCP_IR.criticalPaths{numCP}.setOffset(delayValue);
                            thisAlteraCP_IR.criticalPaths{numCP}.setDataPathDelay(delayValue);
                            thisAlteraCP_IR.criticalPaths{numCP}.setClockPathDelay(delayValue);
                        end
                    end


                    if~found
                        pat=';(\s*)Data Arrival Path(.*)';
                        index=regexp(currLine,pat,'ONCE');
                        if~isempty(index{1})
                            found=true;
                            beginCP=true;
                        end

                    end

                    if~found&&beginCP
                        pat=';(\s*)Total(\s+);(\s+)Incr(\s+);(\s+)RF(\s+);(\s+)Type(\s+);(\s+)Fanout(\s+);(\s+)Location(\s+);(\s+)(HS/LP)(\s+);(\s+)Element(\s+);(.*)';
                        index=regexp(currLine,pat,'ONCE');

                        if~isempty(index{1})

                            cpSection=true;
                            found=true;
                            hasHSLP=true;
                        else
                            pat=';(\s*)Total(\s+);(\s+)Incr(\s+);(\s+)RF(\s+);(\s+)Type(\s+);(\s+)Fanout(\s+);(\s+)Location(\s+);(\s+)Element(\s+);(.*)';
                            index=regexp(currLine,pat,'ONCE');
                            if~isempty(index{1})

                                cpSection=true;
                                found=true;
                                hasHSLP=false;
                            end
                        end
                    end


                    if~found&&cpSection
                        pat=';(\s*)Data Required Path(.*)';
                        index=regexp(currLine,pat,'ONCE');

                        if~isempty(index{1})
                            cpSection=false;
                            beginCP=false;
                        end
                    end


                    if~found&&cpSection


                        if(~hasHSLP)
                            pat=';(\s*)(?<totaldelay>[0-9\.]+)(\s+);(\s+)(?<incrdelay>[0-9\.]+)(\s+);(\s+)(?<transitionType>[RF]*)(\s+);(\s+)(?<delayType>[a-zA-Z_]*)(\s+);(\s+)(?<fanout>[0-9]*)(\s+);(\s+)(?<location>[a-zA-Z_0-9]*)(\s+);(\s+)(?<name>[a-zA-Z_0-9|.:~\[\]]+)(\s+);(.*)';
                        else
                            pat=';(\s*)(?<totaldelay>[0-9\.]+)(\s+);(\s+)(?<incrdelay>[0-9\.]+)(\s+);(\s+)(?<transitionType>[RF]*)(\s+);(\s+)(?<delayType>[a-zA-Z_]*)(\s+);(\s+)(?<fanout>[0-9]*)(\s+);(\s+)(?<location>[a-zA-Z_0-9]*)(\s+);[^;]*;(\s+)(?<name>[a-zA-Z_0-9|.:~\[\]]+)(\s+);(.*)';
                        end
                        pathNode=regexp(currLine,pat,'names','ONCE');

                        if~isempty(pathNode{1})

                            BA.Parser.CP_IR.assertValidFormat(numCP);
                            delayValue=str2double(pathNode{1}.incrdelay);
                            cumDelayValue=str2double(pathNode{1}.totaldelay);
                            thisAlteraCP_IR.criticalPaths{numCP}.addToCriticalPath(pathNode{1}.location,pathNode{1}.delayType,delayValue,pathNode{1}.name,cumDelayValue);
                        end
                    end

                end
            end
            fclose(fid);
        end



        function abstractOutCP(this,numCP,p)
            if(numCP<this.numAbstracted)
                return;
            end

            for i=(this.numAbstracted+1):numCP
                this.abstractedCriticalPaths{i}=BA.Abstraction.abstractCPInfoByType(this,i);
                this.abstractedCriticalPaths{i}.abstractOutCP(p);
            end
            this.numAbstracted=numCP;
        end
    end
end


