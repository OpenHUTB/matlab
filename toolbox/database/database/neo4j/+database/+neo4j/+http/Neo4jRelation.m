classdef(Hidden=true,Sealed=true)Neo4jRelation<database.neo4j.Neo4jRelation










    properties(Access=private)


        Metadata_URLs;


        nodeID;



        connObj;
    end

    methods(Access={?database.neo4j.http.Neo4jConnect,?database.neo4j.http.Neo4jNode},Hidden=true)

        function relationshipinfo=Neo4jRelation(connObj,nodeid,urlortable)









            narginchk(0,3);

            if nargin==0
                return;
            end

            p=inputParser;

            p.addRequired('connObj',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'nonempty','scalar'}));
            p.addRequired('nodeid',@(x)validateattributes(x,{'numeric'},{}));
            p.addRequired('urlortable',@(x)isa(x,'table')||isa(x,'char'));

            p.parse(connObj,nodeid,urlortable);

            if isa(urlortable,'char')

                weburl=urlortable;

                validateattributes(weburl,{'char'},{'size',[1,NaN]});

                try
                    requestMethod=matlab.net.http.RequestMethod('get');
                    request=matlab.net.http.RequestMessage(requestMethod,connObj.HttpHeader);
                    response=send(request,weburl,connObj.HttpOptions);
                catch ME
                    error(message('database:neo4j:genericException',ME.message));
                end



                errorMessage=database.internal.utilities.Neo4jUtils.introspect(response);

                if~isempty(errorMessage)
                    error(message('database:neo4j:genericException',errorMessage));
                end

                reldata=response.Body.Data;

                if isempty(reldata)
                    return;
                end

                relationshipinfo(length(reldata))=database.neo4j.http.Neo4jRelation;

                for i=1:length(reldata)

                    relationshipinfo(i).connObj=connObj;
                    relationshipinfo(i).nodeID=nodeid;

                    relationshipinfo(i).Metadata_URLs=reldata(i);

                    relationshipinfo(i).RelationID=reldata(i).metadata.id;
                    relationshipinfo(i).RelationData=reldata(i).data;

                    tmp=strsplit(reldata(i).start,'/');
                    relationshipinfo(i).StartNodeID=str2double(tmp{end});

                    relationshipinfo(i).RelationType=reldata(i).metadata.type;

                    tmp=strsplit(reldata(i).end,'/');
                    relationshipinfo(i).EndNodeID=str2double(tmp{end});

                end

            else

                reldata=urlortable;

                if isempty(reldata)
                    return;
                end

                relationshipinfo(height(reldata))=database.neo4j.http.Neo4jRelation;

                for i=1:height(reldata)

                    relationshipinfo(i).connObj=connObj;
                    relationshipinfo(i).nodeID=reldata.StartNodeID(i);
                    relationshipinfo(i).Metadata_URLs=[];

                    relationshipinfo(i).RelationID=reldata.RelationID(i);

                    if isstruct(reldata.RelationData)
                        relationshipinfo(i).RelationData=reldata.RelationData(i);
                    else
                        relationshipinfo(i).RelationData=reldata.RelationData{i};
                    end

                    relationshipinfo(i).StartNodeID=reldata.StartNodeID(i);
                    relationshipinfo(i).RelationType=reldata.RelationType{i};
                    relationshipinfo(i).EndNodeID=reldata.EndNodeID(i);

                end


            end

        end

    end

end

