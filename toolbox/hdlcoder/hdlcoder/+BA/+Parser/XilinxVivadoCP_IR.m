




classdef XilinxVivadoCP_IR<BA.Parser.CP_IR
    methods


        function thisXilinxVivadoCP_IR=XilinxVivadoCP_IR(f)

            thisXilinxVivadoCP_IR.timingFile=f;
            thisXilinxVivadoCP_IR.criticalPaths=[];

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


        function n=getNumCPs(thisXilinxVivadoCP_IR)
            n=length(thisXilinxVivadoCP_IR.criticalPaths);
        end


        function num=getNumNodes(thisXilinxVivadoCP_IR,c)
            num=thisXilinxVivadoCP_IR.criticalPaths{c}.numNodes;
        end



        function nodeName=getCPNode(thisXilinxVivadoCP_IR,c,i)
            cp=thisXilinxVivadoCP_IR.getCP(c);
            nodeName=cp.getNode(i).identifier;
        end





        function node=getEntireCPNode(thisXilinxVivadoCP_IR,c,i)
            cp=thisXilinxVivadoCP_IR.getCP(c);
            node=cp.getNode(i);
        end

        function latency=getCPNodeCumulativeLatency(thisXilinxVivadoCP_IR,c,i)
            cp=thisXilinxVivadoCP_IR.getCP(c);
            latency=cp.getNode(i).cumulativeDelay;
        end



        function startNode=getStartNode(thisXilinxVivadoCP_IR,c)
            cp=thisXilinxVivadoCP_IR.getCP(c);
            startNode=cp.getSource;
        end



        function endNode=getEndNode(thisXilinxVivadoCP_IR,c)
            cp=thisXilinxVivadoCP_IR.getCP(c);
            endNode=cp.getDestination;
        end

    end

    methods


        function cp=getCP(thisXilinxVivadoCP_IR,c)
            cp=thisXilinxVivadoCP_IR.criticalPaths{c};
        end



        function parse(thisXilinxVivadoCP_IR,analyzeUnconstrained)

            fid=fopen(thisXilinxVivadoCP_IR.timingFile,'r');

            if(fid==-1)
                error(message('hdlcoder:backannotate:InvalidTimingFile'));
            end

            cbuf=textscan(fid,'%s','delimiter','\n');
            fclose(fid);


            lines=cbuf{1};

            sectionStarts=find(strcmp(lines,':TIMINGPATHSTART:'));
            sectionEnds=find(strcmp(lines,':TIMINGPATHEND:'));
            for i=1:length(sectionStarts)
                cp=BA.Parser.xilinxCriticalPathInfo;
                thisXilinxVivadoCP_IR.fillCriticalPath(cp,lines(sectionStarts(i)+1:sectionEnds(i)-1));
                thisXilinxVivadoCP_IR.criticalPaths{i}=cp;
            end
            if(analyzeUnconstrained)
                thisXilinxVivadoCP_IR.sortCriticalPathsWithOffsetDelay();
            end
        end

        function fillCriticalPath(this,criticalPath,lines)
            criticalPath.setSource(BA.Main.baDriver.flattenHierarchicalNames(this.acquireScalarField(':SOURCE:',lines{1},false)));
            criticalPath.setDestination(BA.Main.baDriver.flattenHierarchicalNames(this.acquireScalarField(':DESTINATION:',lines{2},false)));
            criticalPath.setDataPathDelay(this.acquireScalarField(':DATAPATHDELAY:',lines{3},true));
            criticalPath.setOffset(this.acquireScalarField(':DATAPATHDELAY:',lines{3},true));
            criticalPath.setClockPathDelay(this.acquireScalarField(':CLOCKPATHDELAY:',lines{4},true));
            criticalPath.setClockUncertainty(this.acquireScalarField(':CLOCKUNCERTAINTY:',lines{5},true));


            lineNum=6;
            line=lines{lineNum};
            field=':DATAPATHSTART:';
            assert(strcmp(line,field));
            lineNum=7;
            while(~strcmp(lines{lineNum},':DATAPATHEND:'))
                name=lines{lineNum};
                delayValue=str2double(lines{lineNum+1});
                if(~isempty(name))
                    criticalPath.addToCriticalPath('','',delayValue,name);
                end
                lineNum=lineNum+2;
            end
        end

        function value=acquireScalarField(~,field,line,isnumerical)
            assert(strcmp(line(1:length(field)),field));
            value=line(length(field)+1:end);
            if(isnumerical)
                if(isempty(value))
                    value=0;
                else
                    value=str2double(value);
                end
            end
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



