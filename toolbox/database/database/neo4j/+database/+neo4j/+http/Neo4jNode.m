classdef(Sealed=true)Neo4jNode<database.neo4j.Neo4jNode





























    properties(Access=private,Hidden=true)

        Metadata_URLs;



        connObj;
    end

    methods(Access=public)

        function nodereltypes=nodeRelationTypes(nodeObj,direction)






















            p=inputParser;
            p.addRequired('nodeObj',@(x)validateattributes(x,{'database.neo4j.http.Neo4jNode'},{'scalar'},'nodeRelationTypes','NodeObj'));
            p.addRequired('direction',@(x)validateattributes(direction,{'char','string'},{'scalartext'},'nodeRelationTypes','Direction'));

            p.parse(nodeObj,direction);

            direction=char(direction);
            validateattributes(direction,{'char'},{'nonempty'},'nodeRelationTypes','Direction')
            direction=lower(validatestring(p.Results.direction,{'in','out'},'nodeRelationTypes','Direction'));

            query="MATCH (n)";
            switch direction
            case{'in'}
                query=query+"<-";
            case{'out'}
                query=query+"-";
            end
            query=query+"[r]";
            switch direction
            case{'in'}
                query=query+"-";
            case{'out'}
                query=query+"->";
            end
            query=query+"() WHERE id(n) = "+string(nodeObj.NodeID)+" RETURN type (r) AS type_r";

            resultData=executeCypher(nodeObj.connObj,query);
            nodereltypes=unique(resultData.type_r);
        end

        function degree=nodeDegree(nodeObj,direction)






















            p=inputParser;
            p.addRequired('nodeObj',@(x)validateattributes(x,{'database.neo4j.http.Neo4jNode'},{'scalar'},'nodeDegree','NodeObj'));
            p.addRequired('direction',@(x)validateattributes(direction,{'char','string'},{'scalartext'},'nodeDegree','Direction'));

            p.parse(nodeObj,direction);

            direction=char(direction);
            validateattributes(direction,{'char'},{'nonempty'},'nodeDegree','Direction');
            direction=lower(validatestring(direction,{'in','out'},'nodeDegree','Direction'));

            query="MATCH (n)";
            switch direction
            case{'in'}
                query=query+"<-";
            case{'out'}
                query=query+"-";
            end
            query=query+"[r]";
            switch direction
            case{'in'}
                query=query+"-";
            case{'out'}
                query=query+"->";
            end
            query=query+"() WHERE id(n) = "+string(nodeObj.NodeID)+" RETURN type (r) AS type_r, count(*) AS num";

            resultData=executeCypher(nodeObj.connObj,query);

            degree=struct;
            for n=1:height(resultData)
                degree.(resultData.type_r{n})=resultData.num(n);
            end
        end

    end

    methods(Access={?database.neo4j.http.Neo4jConnect},Hidden=true)

        function nodeObj=Neo4jNode(connObj,urlortable)






























            narginchk(0,2);

            if nargin==0
                return;
            end

            p=inputParser;

            p.addRequired('connObj',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'nonempty','scalar'}));
            p.addRequired('urlortable',@(x)isa(x,'table')||isa(x,'char'));

            p.parse(connObj,urlortable);

            if isa(urlortable,'char')

                weburl=urlortable;

                validateattributes(weburl,{'char'},{'size',[1,NaN]});

                try
                    requestMethod=matlab.net.http.RequestMethod('get');
                    request=matlab.net.http.RequestMessage(requestMethod,connObj.HttpHeader);
                    response=send(request,string(weburl),connObj.HttpOptions);
                catch ME
                    error(message('database:neo4j:genericException',ME.message));
                end



                errorMessage=database.internal.utilities.Neo4jUtils.introspect(response);

                if~isempty(errorMessage)
                    error(message('database:neo4j:genericException',errorMessage));
                end

                nodedata=response.Body.Data;

                if isempty(nodedata)
                    error(message('database:neo4j:searchNodeException'));
                end

                if ischar(nodedata)
                    error(message('database:neo4j:genericException',nodedata));
                end

                nodeObj(length(nodedata))=database.neo4j.http.Neo4jNode;

                for i=1:length(nodedata)
                    nodeObj(i).connObj=connObj;
                    nodeObj(i).Metadata_URLs=nodedata(i);
                    nodeObj(i).NodeID=nodedata(i).metadata.id;
                    nodeObj(i).NodeData=nodedata(i).data;

                    labels=nodedata(i).metadata.labels;
                    if isempty(labels)
                        nodeObj(i).NodeLabels=labels;
                    elseif length(labels)>1
                        nodeObj(i).NodeLabels=labels;
                    else
                        nodeObj(i).NodeLabels=labels{1};
                    end
                end


            else

                nodedata=urlortable;

                if isempty(nodedata)
                    error(message('database:neo4j:searchNodeException'));
                end

                if width(nodedata)~=3
                    error(message('database:neo4j:searchNodeException'));
                end

                nodeObj(height(nodedata))=database.neo4j.http.Neo4jNode;

                for i=1:height(nodedata)
                    nodeObj(i).connObj=connObj;
                    nodeObj(i).Metadata_URLs=[];
                    nodeObj(i).NodeID=nodedata.NodeID(i);

                    if isstruct(nodedata.NodeData)
                        nodeObj(i).NodeData=nodedata.NodeData(i);
                    else
                        nodeObj(i).NodeData=nodedata.NodeData{i};
                    end

                    if iscell(nodedata.NodeLabels{i})&&...
                        length(nodedata.NodeLabels{i})==1
                        nodeObj(i).NodeLabels=nodedata.NodeLabels{i}{:};
                    else
                        nodeObj(i).NodeLabels=nodedata.NodeLabels{i};
                    end
                end


            end

        end

    end

end

