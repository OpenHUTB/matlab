classdef IOPortPositionSubcheck<slcheck.subcheck
    properties(Access=private)
        Mode;
        ModeBlockType;
    end
    methods
        function obj=IOPortPositionSubcheck(InitParams)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=InitParams.Name;
            obj.Mode=InitParams.Mode;
            if strcmp(obj.Mode,'source')
                obj.ModeBlockType={'Inport','InportShadow'};
            else
                obj.ModeBlockType='Outport';
            end
        end

        function result=run(this)
            result=false;

            portObj=this.getEntity();

            if~any(strcmp(get_param(portObj,'BlockType'),this.ModeBlockType))
                return;
            end


            canvasH=get_param(get_param(portObj,'parent'),'handle');



            svc=slcheck.services.PositionalMapService.instance;

            posMat=svc.getPositionalMatrixForSubsys(canvasH);

            if isempty(posMat)
                return;
            end





            [adjList,myHandles]=Advisor.Utils.Graph.getBlocksOnlyGraphFromSubsystem(canvasH,false);
            conGrps=Advisor.Utils.Graph.getConnectedComponents(adjList);

            blocksInConnSet=myHandles(conGrps==conGrps(myHandles==portObj));


            posMat=posMat(ismember(posMat(:,1),blocksInConnSet),:);



            inp=myHandles(arrayfun(@(x)strcmp(get_param(x,'type'),'block')...
            &&any(strcmp(get_param(x,'BlockType'),this.ModeBlockType)),myHandles));



            remPos=posMat(~ismember(posMat(:,1),inp),2:end);

            if isempty(remPos)
                return;
            end

            minVals=min(remPos,[],1);
            maxVals=max(remPos,[],1);

            bBox=[minVals(1:2),maxVals(3:4)];

            ioPos=get_param(portObj,'position');




            if isIOBlockOutside(ioPos,bBox,this.Mode)





                if isAboveOrBelow(ioPos,bBox)||~strcmp(get_param(portObj,'orientation'),'right')

                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'SID',portObj);
                    result=this.setResult(vObj);
                else


                    adjustBounds=true;
                    model=mf.zero.Model;
                    irGraph=SLM3I.Util.getIRGraphRepresentation(canvasH,model,adjustBounds);
                    numCrossingsPrev=diagram.layout.autolayout.signalCrossings(irGraph);



                    irGraph=translateOutOfBox(irGraph,portObj,bBox,this.Mode);



                    numCrossingsNow=diagram.layout.autolayout.signalCrossings(irGraph);

                    if numCrossingsNow>numCrossingsPrev



                        return;
                    elseif~Stateflow.SLUtils.isChildOfStateflowBlock(portObj)



                        vObj=ModelAdvisor.ResultDetail;
                        ModelAdvisor.ResultDetail.setData(vObj,'SID',portObj);
                        result=this.setResult(vObj);
                    end
                end
            end

        end
    end
end

function bResult=isIOBlockOutside(ioPos,bBox,Mode)
    if strcmpi(Mode,'source')
        bResult=ioPos(3)>bBox(1);
    else
        bResult=ioPos(1)<bBox(3);
    end
end

function bResult=isAboveOrBelow(R1,R2)
    bResult=R1(4)<=R2(2)||R1(2)>=R2(4);
end

function parentHandle=getParentHandle(element)
    if(isa(element,'diagram.layout.topology.Port'))
        parentHandle=element.parentNode.clientID;
    else
        parentHandle=element.parent.clientID;
    end
end

function irGraph=translateOutOfBox(irGraph,portObj,bBox,Mode)
    THRES=5;
    if strcmpi(Mode,'source')
        edge_arr=irGraph.edges.toArray;
        edge=edge_arr(arrayfun(@(x)x.type==diagram.layout.topology.ElementType.SEMANTIC&&getParentHandle(x.src)==portObj,edge_arr));
        if~isempty(edge)
            edgePath=edge.path;


            frontPoint=edgePath.front;
            frontPoint.setXY(bBox(1)-THRES,frontPoint.y);


            edgePath.removeFirst;
            edgePath.prependPoint(frontPoint);
            edge.path=edgePath;

        end
    else
        edge_arr=irGraph.edges.toArray;
        edge=edge_arr(arrayfun(@(x)x.type==diagram.layout.topology.ElementType.SEMANTIC&&getParentHandle(x.dst)==portObj,edge_arr));
        if~isempty(edge)
            edgePath=edge.path;

            backPoint=edgePath.back;
            backPoint.setXY(bBox(3)+THRES,backPoint.y);

            edgePath.removeLast;
            edgePath.addPoint(backPoint);
            edge.path=edgePath;
        end
    end
end
