classdef ModelRefGraph<handle





    properties(Access=private)
        MyGraph;
        MyNameSet;
        MyTopVertexID;
        MyInstanceGraph;
        MyInstanceTopVertexID;
    end


    methods(Access=public)

        function this=ModelRefGraph(NameSetHandle)
            resetProperties(this,NameSetHandle);
        end




        function addModel(obj,childStruct)
            if~isKey(obj.MyNameSet,childStruct.Name)
                vertexID=obj.MyGraph.addVertex(childStruct);
                obj.MyNameSet(childStruct.Name)=vertexID;
            end
        end




        function addEdgeToGraph(obj,parentModel,childModel,blockPath,simMode)

            parentID=obj.MyNameSet(parentModel);
            childID=obj.MyNameSet(childModel);

            if~obj.MyGraph.isEdge([parentID,childID])
                obj.MyGraph.addEdge(parentID,childID);
            end

            anEdge=obj.MyGraph.edge([parentID,childID]);
            anEdge.Data=[anEdge.Data,struct('BlockPath',blockPath,...
            'SimulationMode',simMode,'UserData',[])];
        end


        function addTopModel(obj,modelName,isLoaded)

            topModel.Name=modelName;
            topModel.IsProtected=false;
            topModel.IsLoaded=isLoaded;





            topModel.SimulationMode=get_param(bdroot(modelName),'SimulationMode');

            addModel(obj,topModel);

            obj.MyTopVertexID=obj.MyNameSet(topModel.Name);
        end


        function myDigraph=getGraphObject(obj)
            nodeTable=createNodeTable(obj);
            edgeTable=createEdgeTable(obj);
            myDigraph=digraph(edgeTable,nodeTable);
        end


        function graph=getInstanceGraphObject(obj)
            graph=obj.MyInstanceGraph;
        end


        function idType=getVertexIDType(obj)
            idType=obj.MyGraph.VertexIdType;
        end


        function idType=getInstanceVertexIDType(obj)
            idType=obj.MyInstanceGraph.VertexIdType;
        end


        function id=getTopVertexID(obj)
            id=obj.MyTopVertexID;
        end


        function id=getInstanceTopVertexID(obj)
            id=obj.MyInstanceTopVertexID;
        end


        function v=getVertex(obj,anID)
            v=obj.MyGraph.vertex(anID);
        end


        function v=getInstanceVertex(obj,anID)
            v=obj.MyInstanceGraph.vertex(anID);
        end


        function result=getEdges(obj,anID,option)
            vertex=obj.MyGraph.vertex(anID);
            result=obj.getEdgesFromVertex(anID,vertex,option);
        end


        function result=getInstanceEdges(obj,anID,option)
            vertex=obj.MyInstanceGraph.vertex(anID);
            result=obj.getEdgesFromVertex(anID,vertex,option);
        end


        function result=getAllVertexIDs(obj)
            result=obj.MyGraph.VertexIDs();
        end


        function result=getAllInstanceVertexIDs(obj)
            result=obj.MyInstanceGraph.VertexIDs();
        end


        function setIsModelLoaded(obj,anID,isLoaded)
            obj.MyGraph.vertex(anID).Data.IsLoaded=isLoaded;
        end




        function createInstanceGraph(obj)

            if~isempty(obj.MyInstanceGraph)
                return;
            end


            import Simulink.ModelReference.internal.GraphAnalysis.SimulationMode;
            obj.MyInstanceGraph=matlab.internal.container.graph.Graph('Directed',true);



            myFVStack=Simulink.ModelReference.internal.Stack();
            myIVStack=Simulink.ModelReference.internal.Stack();


            obj.addInstanceTopModel();



            myFVStack.push(obj.MyTopVertexID);
            myIVStack.push(obj.MyInstanceTopVertexID);




            while~myFVStack.empty()

                fvParentID=myFVStack.pop();
                ivParentID=myIVStack.pop();


                ivParentTag=obj.getInstanceVertex(ivParentID).Data.Tag;



                fvEdges=obj.getEdges(fvParentID,'outbound');


                for i=1:length(fvEdges)
                    fvChildID=fvEdges(i).TargetID;
                    fvChildStruct=fvEdges(i).Data;




                    for j=1:length(fvChildStruct)

                        ivChildID=obj.addInstanceNode(fvChildID,fvChildStruct(j),...
                        ivParentTag);


                        obj.MyInstanceGraph.addEdge(ivParentID,ivChildID);


                        myFVStack.push(fvChildID);
                        myIVStack.push(ivChildID);
                    end
                end
            end

        end

    end


    methods(Access=private)

        function resetProperties(obj,NameSetHandle)
            obj.MyGraph=matlab.internal.container.graph.Graph('Directed',true);
            obj.MyNameSet=NameSetHandle;
            obj.MyInstanceGraph=[];
        end


        function result=getEdgesFromVertex(~,anID,vertex,option)
            result=vertex.edges();

            switch(option)
            case 'inbound'
                result=result([result.TargetID]==anID);
            case 'outbound'
                result=result([result.SourceID]==anID);
            otherwise

            end
        end


        function addInstanceTopModel(obj)
            aStructPrime=obj.createStructFromID(obj.MyTopVertexID);
            obj.MyInstanceTopVertexID=obj.MyInstanceGraph.addVertex(aStructPrime);
        end



        function ivChildID=addInstanceNode(obj,fvChildID,fvChildStruct,ivParentTag)
            import Simulink.ModelReference.internal.GraphAnalysis.SimulationMode;


            ivChildStruct=obj.createStructFromID(fvChildID);
            ivChildStruct.BlockPath=fvChildStruct.BlockPath;
            ivChildStruct.SimulationMode=fvChildStruct.SimulationMode;



            if ivParentTag==SimulationMode.Accel||...
                ~strcmpi(ivChildStruct.SimulationMode,'Normal')
                ivChildStruct.Tag=SimulationMode.Accel;
            end


            ivChildID=obj.MyInstanceGraph.addVertex(ivChildStruct);
        end



        function result=createStructFromID(obj,anID)
            import Simulink.ModelReference.internal.GraphAnalysis.SimulationMode;
            aVertex=obj.getVertex(anID);
            result=aVertex.Data;

            if~isfield(result,'SimulationMode')
                result.SimulationMode=[];
            end
            if~isfield(result,'BlockPath')
                result.BlockPath='';
            end
            if~isfield(result,'Tag')
                result.Tag=SimulationMode.Normal;
            end
        end



        function nodeTable=createNodeTable(obj)
            allVertexIDs=obj.MyGraph.VertexIDs()';
            [~,numOfVertices]=size(allVertexIDs);
            nodeVarNames={'ID','Value','EdgeCount'};
            nodeVarTypes={obj.MyGraph.VertexIdType,'double','uint64'};
            numOfVars=3;


            nodeTable=table('Size',[numOfVertices,numOfVars],'VariableTypes',nodeVarTypes...
            ,'VariableNames',nodeVarNames);

            varData=struct('Name','','IsProtected',false,'IsLoaded',false,'SimulationMode','');
            varDataColumn=repmat(varData,numOfVertices,1);
            nodeTable.Data=varDataColumn;

            for currVertexID=allVertexIDs
                currVertex=obj.MyGraph.vertex(currVertexID);


                if~isfield(currVertex.Data,'SimulationMode')
                    currVertex.Data.SimulationMode='';
                end

                idx=currVertexID+1;
                nodeTable{idx,'Data'}=currVertex.Data;
                nodeTable{idx,'ID'}=idx;
                nodeTable{idx,'Value'}=currVertex.Value;
                nodeTable{idx,'EdgeCount'}=currVertex.EdgeCount;
            end
        end



        function edgeTable=createEdgeTable(obj)
            edgeTable=table;
            totalEdges=obj.MyGraph.EdgeCount;



            edgeTable.EndNodes=zeros(totalEdges,2);
            vertexIDType=obj.MyGraph.VertexIdType;
            edgeVarTypes={vertexIDType,vertexIDType,'double'};
            edgeVarNames={'SourceID','TargetID','Weight'};
            numOfVars=3;


            edgeTable=[edgeTable,table('Size',[totalEdges,numOfVars]...
            ,'VariableTypes',edgeVarTypes,'VariableNames',edgeVarNames)];
            varData=struct('BlockPath','','SimulationMode','','UserData',[]);
            varDataColumn=repmat(varData,totalEdges,1);
            edgeTable.Data=varDataColumn;

            idx=1;
            allVertexIDs=obj.MyGraph.VertexIDs()';
            for currVertexID=allVertexIDs
                currVertex=obj.MyGraph.vertex(currVertexID);
                allEdges=currVertex.edges();


                outboundEdges=allEdges([allEdges.SourceID]==currVertexID);
                if~isempty(outboundEdges)
                    [~,numOfEdges]=size(outboundEdges);
                    for currEdgeID=1:numOfEdges
                        currEdge=outboundEdges(currEdgeID);
                        edgeTable{idx,'EndNodes'}=[currEdge.SourceID+1,currEdge.TargetID+1];
                        edgeTable{idx,'SourceID'}=currEdge.SourceID+1;
                        edgeTable{idx,'TargetID'}=currEdge.TargetID+1;
                        edgeTable{idx,'Weight'}=currEdge.Value;
                        edgeTable{idx,'Data'}=currEdge.Data;
                        idx=idx+1;
                    end
                end
            end
        end
    end
end
