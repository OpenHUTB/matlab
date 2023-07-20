
classdef TriggeredSubsystemCheck<handle
    properties(SetAccess=private,GetAccess=public)
Model
System
Graph
VertexMap
RootVid
ConversionData
    end

    methods(Static,Access=public)
        function exec(params,aSystem)
            this=Simulink.ModelReference.Conversion.TriggeredSubsystemCheck(params,aSystem);
            this.check;
        end
    end

    methods(Access=public)
        function this=TriggeredSubsystemCheck(params,aSystem)
            this.System=get_param(aSystem,'Handle');
            this.Model=bdroot(this.System);
            this.Graph=matlab.internal.container.graph.Graph('Directed',true);
            this.ConversionData=params;


            ssType=Simulink.SubsystemType(this.System);
            rootNode=struct('ID',this.System,'IsTriggered',ssType.isTriggeredSubsystem,...
            'IsFunctionCall',ssType.isFunctionCallSubsystem,'Level',0);
            this.RootVid=addVertex(this.Graph,rootNode);


            this.build(this.System,this.RootVid,1);
        end

        function build(this,aSystem,parentVId,level)
            blks=find_system(aSystem,'SearchDepth',1,'LookUnderMasks','all','BlockType','SubSystem');
            N=numel(blks);
            for idx=2:N
                currentBlock=blks(idx);
                ssType=Simulink.SubsystemType(currentBlock);
                vData=struct('ID',currentBlock,'IsTriggered',ssType.isTriggeredSubsystem,...
                'IsFunctionCall',ssType.isFunctionCallSubsystem,'Level',level);
                childVId=addVertex(this.Graph,vData);
                addEdge(this.Graph,parentVId,childVId);


                if ssType.isVirtualSubsystem&&strcmpi(get_param(currentBlock,'Commented'),'off')
                    this.build(currentBlock,childVId,level+1);
                end
            end
        end

        function check(this)
            indexes=findIf(this.Graph,@(id,v,d)d.IsTriggered&&(d.Level>1),'Vertex');
            if isempty(indexes)



                rootNode=this.Graph.vertex(0);
                if this.ConversionData.MustCopySubsystem
                    if rootNode.Data.IsTriggered



                        ssName=get_param(rootNode.Data.ID,'Name');
                        this.ConversionData.addNewModelFixObj(...
                        Simulink.ModelReference.Conversion.TriggeredSubsystemFix(this.ConversionData,rootNode.Data.ID,ssName));
                    end
                else
                    searchLevel=1;
                    indexes=findIf(this.Graph,@(id,v,d)(d.Level==searchLevel)&&d.IsTriggered,'Vertex');
                    if~isempty(indexes)
                        nodes=this.Graph.vertex(indexes);
                        triggeredSubsys=arrayfun(@(aNode)aNode.Data.ID,nodes);
                        ssNames=arrayfun(@(aBlk)get_param(aBlk,'Name'),triggeredSubsys,'UniformOutput',false);
                        this.ConversionData.addNewModelFixObj(...
                        Simulink.ModelReference.Conversion.TriggeredSubsystemFix(this.ConversionData,rootNode.Data.ID,ssNames));
                    end
                end
            else
                invalidNodes=this.Graph.vertex(indexes);
                parentName=Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(...
                getfullname(this.System),this.System);
                me=MException(message('RTW:buildProcess:trigSysMustBeAtTopToExportCode',parentName));
                N=numel(invalidNodes);
                for idx=1:N
                    aNode=invalidNodes(idx);
                    childSubsys=aNode.Data.ID;
                    childName=Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(...
                    getfullname(childSubsys),childSubsys);
                    me=me.addCause(MException(...
                    message('Simulink:modelReferenceAdvisor:TriggerSubsystemMustBeAtTopLevel',childName,parentName)));
                end
                throw(me);
            end
        end
    end
end
