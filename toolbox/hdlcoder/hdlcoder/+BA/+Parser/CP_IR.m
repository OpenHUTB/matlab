



classdef CP_IR<handle
    properties(SetAccess=protected,GetAccess=protected)
timingFile
criticalPaths
    end

    properties
currAnnotationStrategy
abstractedCriticalPaths
numAbstracted
    end

    methods

        function this=CP_IR
            this.currAnnotationStrategy=[];
            this.abstractedCriticalPaths=[];
            this.numAbstracted=0;
        end


        function printAbstractCP(this)
            fprintf(1,'Number of CPs abstracted = %d\n',this.numAbstracted);
            for i=1:this.numAbstracted
                fprintf(1,'Abstract Critical Path %d\n',i);
                fprintf(1,'---------------------\n');
                this.getAbstractedCP(i).printAbstract;
                fprintf(1,'---------------------\n');
            end
        end


        function annotatePath(this,i,mdlName,unique,showdelays,showall,showends,endsonly,skipannotation,targetModel)
            this.currAnnotationStrategy.setTargetModel(targetModel);
            this.currAnnotationStrategy.applyPath(this,i,mdlName,unique,showdelays,showall,showends,endsonly,skipannotation);
        end



        function setStrategy(this,aStrategy)
            this.currAnnotationStrategy=aStrategy;
        end


        function reset(this)
            this.currAnnotationStrategy.reset;
        end


        function resetall(this)
            this.currAnnotationStrategy.resetall;
        end


        function printColoredObjects(this)
            this.currAnnotationStrategy.printColoredObjects;
        end



        function cp=getAbstractedCP(this,numCP)
            if(numCP>this.numAbstracted)
                error(message('hdlcoder:backannotate:CriticalPathNotReady'));
            end
            cp=this.abstractedCriticalPaths{numCP};
        end

        function sortCriticalPathsWithOffsetDelay(this)
            offsetDelays=zeros(1,this.getNumCPs);
            for i=1:length(offsetDelays)
                curCP=this.getCP(i);
                offset=curCP.getOffset();
                requirement=curCP.getRequirement();
                if(requirement>0)
                    offsetDelays(i)=requirement-offset;
                else
                    offsetDelays(i)=offset;
                end
            end
            [~,idx]=sort(offsetDelays,'descend');
            cpOld=this.criticalPaths;
            for i=1:length(idx)
                this.criticalPaths{i}=cpOld{idx(i)};
            end
        end

    end

    methods(Static)
        function assertValidFormat(numCP)
            if numCP==0
                error(message('hdlcoder:backannotate:ParsingUnsuccessful'));
            end
        end
    end


    methods(Abstract)


        n=getNumCPs(this);


        num=getNumNodes(this,c);



        nodeName=getCPNode(this,c,i);


        latency=getCPNodeCumulativeLatency(this,c,i);



        startNode=getStartNode(this,c);



        endNode=getEndNode(this,c);


        abstractOutCP(this,numCP,p);

    end
end


