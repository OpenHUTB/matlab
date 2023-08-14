classdef(Sealed=true)Neo4jConnect<database.neo4j.Neo4jConnect
































    properties(GetAccess={?database.neo4j.http.Neo4jNode,?database.neo4j.http.Neo4jRelation},SetAccess=private,Hidden=true)






        HttpOptions;








        HttpHeader;
    end

    properties(GetAccess={?database.neo4j.http.Neo4jNode,?database.neo4j.http.Neo4jRelation},SetAccess=private,Hidden=true)




        MetaData_URLs;
    end

    methods(Access=private,Hidden=true)

        function f=isOpen(neo4jconn)
            if~isempty(neo4jconn.Message)
                f=false;
                return;
            end

            f=true;
        end
    end

    methods(Hidden=true)

        function neo4jconn=Neo4jConnect(url,username,password)

































            p=inputParser;
            p.addRequired('connectURL',@(x)validateattributes(x,{'char','string'},{'scalartext'},'neo4j','connectURL'));
            p.addRequired('username',@(x)validateattributes(x,{'char','string'},{'scalartext'},'neo4j','username'));
            p.addRequired('password',@(x)validateattributes(x,{'char','string'},{'scalartext'},'neo4j','password'));

            try
                p.parse(url,username,password);

                url=char(url);
                username=char(username);
                password=char(password);



                HttpURI=matlab.net.URI(string(url));
                HttpCredential=matlab.net.http.Credentials('Username',string(username),'Password',string(password),'Scope',HttpURI,'Scheme','Basic');
                neo4jconn.HttpOptions=matlab.net.http.HTTPOptions('Credentials',HttpCredential,'ConnectTimeout',600);
                HttpMediaType=matlab.net.http.MediaType('application/json; charset=UTF-8; stream=true');
                neo4jconn.HttpHeader=matlab.net.http.HeaderField('MediaType',HttpMediaType);


                requestMethod=matlab.net.http.RequestMethod('get');
                request=matlab.net.http.RequestMessage(requestMethod,neo4jconn.HttpHeader);


                response=send(request,HttpURI,neo4jconn.HttpOptions);




                errorMessage=database.internal.utilities.Neo4jUtils.introspect(response);

                if~isempty(errorMessage)
                    neo4jconn.URL=[];
                    neo4jconn.UserName=[];
                    neo4jconn.Message=errorMessage;
                    return;
                end



                if isempty(response.Body.Data)
                    neo4jconn.URL=[];
                    neo4jconn.UserName=[];
                    neo4jconn.Message=getString(message('database:neo4j:noConnectDataException'));

                end

                db=[];



                if~isempty(neo4jconn.Message)
                    neo4jconn.Message=[];
                    dbLocation=strfind(url,'db/');
                    if isempty(dbLocation)
                        neo4jconn.URL=[];
                        neo4jconn.UserName=[];
                        neo4jconn.Message=getString(message('database:neo4j:noConnectDataException'));
                        return;
                    end
                    url4=url(1:dbLocation-1);
                    db=url(dbLocation+3:end);

                    if endsWith(db,'/')
                        db=db(1:end-1);
                    end


                    response=send(request,matlab.net.URI(string(url4)),neo4jconn.HttpOptions);




                    errorMessage=database.internal.utilities.Neo4jUtils.introspect(response);

                    if~isempty(errorMessage)
                        neo4jconn.URL=[];
                        neo4jconn.UserName=[];
                        neo4jconn.Message=errorMessage;
                        return;
                    end



                    if isempty(response.Body.Data)
                        neo4jconn.URL=[];
                        neo4jconn.UserName=[];
                        neo4jconn.Message=getString(message('database:neo4j:noConnectDataException'));
                        return;
                    end
                end

                if~strcmpi(url(end),'/')
                    url(end+1)='/';
                end



                neo4jconn.URL=url;
                neo4jconn.UserName=username;





                neo4jconn.MetaData_URLs=response.Body.Data;



                if~isempty(db)&&contains(neo4jconn.MetaData_URLs.transaction,'{databaseName}')
                    neo4jconn.MetaData_URLs.transaction=strrep(neo4jconn.MetaData_URLs.transaction,'{databaseName}',db);
                end



                executeCypher(neo4jconn,'MATCH (n) RETURN n LIMIT 1');

            catch e
                neo4jconn.URL='';
                neo4jconn.UserName='';
                neo4jconn.Message=e.message;
                return;
            end

        end


        function datacount=count(neo4jconn,labelorreltype)




















            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'count','neo4jconn'));
            p.addRequired('labelorreltype',@(x)validateattributes(x,{'char','string'},{'scalartext'},'count','LabelOrRelationtype'));

            p.parse(neo4jconn,labelorreltype)

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            labelorreltype=char(labelorreltype);
            validateattributes(labelorreltype,{'char'},{'nonempty'},'count','LabelOrRelationtype');

            try

                query='';
                if ismember(labelorreltype,nodeLabels(neo4jconn))
                    query=['MATCH (n:',labelorreltype,') RETURN count(*) as count'];
                end

                if ismember(labelorreltype,relationTypes(neo4jconn))
                    query=['MATCH ()-[r:',labelorreltype,']->() RETURN count(*) as count'];
                end

                if isempty(query)
                    datacount=0;
                    return;
                end

                totalcount=executeCypher(neo4jconn,query);

                datacount=totalcount.count;

            catch ME

                rethrow(ME)
            end

        end

    end

    methods(Access=public)

        function close(neo4jconn)













            delete(neo4jconn);
        end

        function nlabels=nodeLabels(neo4jconn)





















            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            data=executeCypher(neo4jconn,"CALL db.labels()");

            if isempty(data)
                error(message('database:neo4j:nodeLabelsException'));
            end

            nlabels=data.label;
        end

        function rtypes=relationTypes(neo4jconn)






















            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            data=executeCypher(neo4jconn,"CALL db.relationshipTypes()");

            if isempty(data)
                error(message('database:neo4j:nodeLabelsException'));
            end

            rtypes=data.relationshipType;
        end

        function propkeys=propertyKeys(neo4jconn)


















            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            data=executeCypher(neo4jconn,"CALL db.propertyKeys()");

            if isempty(data)
                error(message('database:neo4j:propertyKeysException'));
            end

            propkeys=data.propertyKey;
        end

        function nodeinfo=searchNodeByID(neo4jconn,nodeid)



































            p=inputParser;

            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'searchNodeByID','neo4jconn'));
            p.addRequired('nodeid',@(x)validateattributes(x,{'numeric'},{'integer','nonnegative','vector'},'searchNodeByID','NodeID'));
            p.parse(neo4jconn,nodeid);

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            nodeid=int64(nodeid);


            nodeIDParameterName='nodeID';

            query=database.neo4j.Neo4jConnect.buildSearchNodeByIDQuery(...
            nodeIDParameterName,nodeid);
            query=query+"RETURN ID(n) AS NodeID, labels(n) AS NodeLabels, n as NodeData";

            parameter=struct(nodeIDParameterName,nodeid);


            try
                nodeObj=database.neo4j.http.Neo4jNode(neo4jconn,executeStatements(neo4jconn,query,{parameter}));
                if length(nodeObj)~=length(nodeid)
                    error(message('database:neo4j:searchNodeException'));
                end
                if length(nodeObj)>1
                    nodeinfo=neo4jconn.nodeObjToTable(nodeObj);
                else
                    nodeinfo=nodeObj;
                end
            catch Me
                rethrow(Me);
            end
        end

        function nodeinfo=searchNode(neo4jconn,label,varargin)





















































































            narginchk(2,10);

            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'searchNode','neo4jconn'));
            p.addRequired('label',@(x)validateattributes(x,{'char','string'},{'scalartext'},'searchNode','NodeLabel'));
            p.addParameter('PropertyKey','',@(x)validateattributes(x,{'char','string'},{'scalartext'},'searchNode','PropertyKey'));
            p.addParameter('PropertyValue','',@(x)validateattributes(x,{'char','string','numeric'},{'nonempty'},'searchNode','PropertyValue'));



            p.addParameter('Offset',0,@(x)validateattributes(x,{'numeric'},{'nonempty','nonnegative','nonnan','scalar','finite'},'searchNode','Offset'));
            p.addParameter('ReadSize',Inf,@(x)validateattributes(x,{'numeric'},{'nonempty','nonzero','nonnegative','nonnan','scalar'},'searchNode','ReadSize'));
            p.parse(neo4jconn,label,varargin{:});

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            label=char(label);


            in_propertykey=char(p.Results.PropertyKey);

            if isstring(p.Results.PropertyValue)
                in_propertyvalue=char(p.Results.PropertyValue);
            else
                in_propertyvalue=p.Results.PropertyValue;
            end

            if~isempty(in_propertykey)&&isempty(in_propertyvalue)
                error(message('MATLAB:narginchk:notEnoughInputs'))
            end

            if~isempty(in_propertyvalue)&&isempty(in_propertykey)
                error(message('MATLAB:narginchk:notEnoughInputs'))
            end

            try
                if~isempty(in_propertykey)
                    if ischar(in_propertyvalue)
                        validateattributes(in_propertyvalue,{'char'},{'nonempty','scalartext'},'searchNode','PropertyValue');
                    elseif isnumeric(in_propertyvalue)
                        validateattributes(in_propertyvalue,{'numeric'},{'nonnan','finite','scalar'},'searchNode','PropertyValue');
                    end
                end

                propertyParameterName='prop';
                query=database.neo4j.Neo4jConnect.buildSearchNodeQuery(label,propertyParameterName,in_propertykey);

                if~isempty(in_propertykey)&&~isempty(in_propertyvalue)
                    parameter=struct(propertyParameterName,in_propertyvalue);
                else
                    parameter=struct;
                end

                query=query+" RETURN id(n) as NodeID, n as NodeData, labels(n) as NodeLabels ORDER BY id(n)";

                if~isinf(p.Results.ReadSize)
                    if p.Results.Offset~=0
                        query=query+" SKIP "+num2str(p.Results.Offset);
                    end
                    query=query+" LIMIT "+num2str(p.Results.ReadSize);
                end

                nodetable=executeStatements(neo4jconn,string(query),{parameter});



                nodeObj=database.neo4j.http.Neo4jNode(neo4jconn,nodetable);




                if length(nodeObj)>1
                    nodeinfo=neo4jconn.nodeObjToTable(nodeObj);
                    return;
                end

                nodeinfo=nodeObj;

            catch ME
                throw(ME);
            end

        end

        function relationinfo=searchRelationByID(neo4jconn,relationid)




































            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'searchRelationByID','neo4jconn'));
            p.addRequired('relationid',@(x)validateattributes(x,{'numeric'},{'integer','nonnegative','vector'},'searchRelationByID','relationid'));
            p.parse(neo4jconn,relationid);

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            relationid=int64(relationid);



            relationIDParameterName='relID';
            query=database.neo4j.Neo4jConnect.buildSearchRelationByIDQuery(...
            relationIDParameterName,relationid);
            query=query+"RETURN ID(r) AS RelationID, ID(startNode(r)) AS StartNodeID, "+...
            "ID(endNode(r)) AS EndNodeID, type(r) AS RelationType, "+...
            "r AS RelationData";

            parameter=struct(relationIDParameterName,relationid);


            try
                relations=executeStatements(neo4jconn,query,{parameter});
                if height(relations)~=length(relationid)
                    error(message('database:neo4j:searchRelationByIDException'))
                end
                relObj=database.neo4j.http.Neo4jRelation(neo4jconn,[],...
                relations);
                if length(relObj)>1
                    relationinfo=neo4jconn.relationObjToTable(relObj);
                else
                    relationinfo=relObj;
                end
            catch Me
                rethrow(Me);
            end
        end

        function relinfo=searchRelation(neo4jconn,nodeInfo,direction,varargin)



























































































































            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'searchRelation','neo4jconn'));
            p.addRequired('nodeInfo',@(x)validateattributes(x,{'database.neo4j.http.Neo4jNode','numeric'},{'scalar'},'searchRelation','NodeInformation'));
            p.addRequired('direction',@(x)validateattributes(x,{'char','string'},{'scalartext'},'searchRelation','Direction'));
            p.addParameter('RelationTypes',string.empty,@database.internal.utilities.Neo4jUtils.fieldnamesCheck);
            p.addParameter('Distance',1,@(x)validateattributes(x,{'numeric'},{'integer','nonnegative','scalar','nonzero'},'searchRelation','Distance'));
            p.addParameter('DataReturnFormat','structure',@(x)validateattributes(x,{'char','string'},{'scalartext'},'searchRelation','DataReturnType'));



            p.addParameter('BuildNodesTable',true,@(x)validateattributes(x,{'logical'},{'nonempty'},'searchRelation','BuildNodesTable'));
            p.parse(neo4jconn,nodeInfo,direction,varargin{:});

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            try

                if strcmpi(class(nodeInfo),'database.neo4j.http.Neo4jNode')
                    nodeinfo=nodeInfo;
                else
                    validateattributes(nodeInfo,{'numeric'},{'integer','nonnegative'},'searchRelation','NodeInformation');
                    nodeinfo=searchNodeByID(neo4jconn,floor(nodeInfo));
                end

                distance=p.Results.Distance;

                inputRelTypes=string(p.Results.RelationTypes);

                direction=char(p.Results.direction);
                validateattributes(direction,{'char'},{'nonempty'},'searchRelation','Direction');
                direction=validatestring(direction,{'in','out'},'searchRelation','Direction');

                dataReturnType=p.Results.DataReturnFormat;
                dataReturnType=validatestring(dataReturnType,{'structure','digraph'},'searchRelation','DataReturnType');

                relinfo.Origin=nodeinfo.NodeID;
                relinfo.Nodes=table([],[],[],'VariableNames',{'NodeLabels','NodeData','NodeObject'});
                relinfo.Relations=table([],[],[],[],[],'VariableNames',{'StartNodeID','RelationType','EndNodeID','RelationData','RelationObject'});

                allNodes=[];






                nodetableflag=p.Results.BuildNodesTable;

                nodeIDParameterName='nodeID';

                query=database.neo4j.Neo4jConnect.buildSearchRelationQuery(direction,distance,inputRelTypes);
                query=query+"UNWIND r AS relations ";
                query=query+"RETURN ID(relations) AS RelationID, ID(startNode(relations)) AS StartNodeID, "+...
                "ID(endNode(relations)) AS EndNodeID, type(relations) AS RelationType, "+...
                "r AS RelationData";

                parameter=struct(nodeIDParameterName,int64(nodeinfo.NodeID));

                relObj=database.neo4j.http.Neo4jRelation(neo4jconn,[],executeStatements(neo4jconn,query,{parameter}));

                if length(relObj)==1&&isempty(relObj.RelationID)
                    if strcmp(dataReturnType,'digraph')
                        relinfo=neo4jStruct2Digraph(relinfo);
                    end
                    return;
                else

                    [~,uniqueIdx]=unique([relObj.RelationID]);
                    relObj=relObj(uniqueIdx);

                    relinfo.Relations=[relinfo.Relations;neo4jconn.relationObjToTable(relObj)];
                    if nodetableflag
                        allNodes=[allNodes;unique([[relinfo.Relations.StartNodeID];[relinfo.Relations.EndNodeID]])];
                        allNodes=unique(allNodes);
                        for i=1:length(allNodes)
                            nodeobj=searchNodeByID(neo4jconn,allNodes(i));
                            relinfo.Nodes=[relinfo.Nodes;table({nodeobj.NodeLabels},{nodeobj.NodeData},nodeobj,'VariableNames',{'NodeLabels','NodeData','NodeObject'},'RowNames',strtrim(cellstr(num2str(allNodes(i)))))];
                        end
                    end
                    if strcmp(dataReturnType,'digraph')
                        relinfo=neo4jStruct2Digraph(relinfo);
                    end
                end

            catch ME
                throw(ME);
            end
        end

        function result=executeCypher(neo4jconn,query)












































            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'executeCypher','neo4jconn'));
            p.addRequired('query',@(x)validateattributes(x,{'char','string'},{'scalartext'},'executeCypher','CypherQuery'));

            p.parse(neo4jconn,query);

            try
                result=executeStatements(neo4jconn,string(query));
            catch ME
                throw(ME);
            end
        end

        function graphinfo=searchGraph(neo4jconn,searchcriteria,varargin)





























































































































            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'searchGraph','neo4jconn'));
            p.addRequired('searchcriteria',@database.internal.utilities.Neo4jUtils.fieldnamesCheck);
            p.addParameter('DataReturnFormat','structure',@(x)validateattributes(x,{'char','string'},{'scalartext'},'searchGraph','DataReturnType'));




            p.addParameter('Offset',0,@(x)validateattributes(x,{'numeric'},{'nonnegative','nonnan','scalar','finite'},'searchGraph','Offset'));
            p.addParameter('ReadSize',inf,@(x)validateattributes(x,{'numeric'},{'nonzero','nonnegative','nonnan','scalar'},'searchGraph','ReadSize'));

            p.parse(neo4jconn,searchcriteria,varargin{:})




            nodedata=cellstr(p.Results.searchcriteria);
            dataReturnType=p.Results.DataReturnFormat;
            dataReturnType=validatestring(dataReturnType,{'structure','digraph'},'searchGraph','DataReturnType');

            graphdata.Nodes=table;
            graphdata.Relations=table;

            nlabels=nodeLabels(neo4jconn);
            findindex=ismember(nodedata,nlabels);
            nodelabels=nodedata(findindex==1);

            labelsearch=nodelabels;

            relationsearch=[];
            if isempty(labelsearch)
                rtypes=relationTypes(neo4jconn);
                findindex=ismember(nodedata,rtypes);
                relationtypes=nodedata(findindex==1);
                relationsearch=relationtypes;
            end

            if~isempty(labelsearch)

                incypherquery=database.neo4j.Neo4jConnect.buildSearchGraphLabelQuery(labelsearch,"in");
                incypherquery=incypherquery+"RETURN id(node2) as StartNodeID,"+...
                "type(relation) as RelationType,"+...
                "id(node1) as EndNodeID,"+...
                "id(relation) as RelationID,"+...
                "relation as RelationData,"+...
                "node1 as EndNodeData,"+...
                "node2 as StartNodeData,"+...
                "labels(node2) as StartNodeLabels,"+...
                "labels(node1) as EndNodeLabels "+...
                " ORDER BY id(node2)";

                incypherquery=incypherquery+' SKIP '+num2str(p.Results.Offset);
                if~isinf(p.Results.ReadSize)
                    incypherquery=incypherquery+' LIMIT '+num2str(p.Results.ReadSize);
                end

                inreltable=table;
                inresult=executeCypher(neo4jconn,incypherquery);

                if~isempty(inresult)
                    reldata=database.neo4j.http.Neo4jRelation(neo4jconn,[],inresult);

                    inreltable=[inreltable;neo4jconn.relationObjToTable(reldata)];
                    graphdata.Nodes=[graphdata.Nodes;convertTableToObject(neo4jconn,inresult)];
                end

                graphdata.Relations=[graphdata.Relations;inreltable];

                outcypherquery=database.neo4j.Neo4jConnect.buildSearchGraphLabelQuery(labelsearch,"out");
                outcypherquery=outcypherquery+"RETURN id(node1) as StartNodeID,"+...
                "type(relation) as RelationType,"+...
                "id(node2) as EndNodeID,"+...
                "id(relation) as RelationID,"+...
                "relation as RelationData,"+...
                "node2 as EndNodeData,"+...
                "node1 as StartNodeData,"+...
                "labels(node1) as StartNodeLabels,"+...
                "labels(node2) as EndNodeLabels "+...
                " ORDER BY id(node1)";

                outcypherquery=outcypherquery+' SKIP '+num2str(p.Results.Offset);
                if~isinf(p.Results.ReadSize)
                    outcypherquery=outcypherquery+' LIMIT '+num2str(p.Results.ReadSize);
                end


                outreltable=table;
                outnodetable=table;
                outresult=executeCypher(neo4jconn,outcypherquery);

                if~isempty(outresult)
                    reldata=database.neo4j.http.Neo4jRelation(neo4jconn,[],outresult);
                    outreltable=[outreltable;neo4jconn.relationObjToTable(reldata)];

                    outreltable(intersect(graphdata.Relations.Properties.RowNames,outreltable.Properties.RowNames),:)=[];
                    outnodetable=convertTableToObject(neo4jconn,outresult);
                    outnodetable(intersect(graphdata.Nodes.Properties.RowNames,outnodetable.Properties.RowNames),:)=[];
                end

                graphdata.Relations=[graphdata.Relations;outreltable];
                graphdata.Nodes=[graphdata.Nodes;outnodetable];



                noRelNodeCypherQuery=database.neo4j.Neo4jConnect.buildSearchGraphLabelNoRelQuery(labelsearch);
                noRelNodeCypherQuery=noRelNodeCypherQuery+"RETURN ID(node1) AS NodeID,"+...
                "labels(node1) AS NodeLabels,"+...
                "node1 as NodeData";
                noRelNodeCypherQuery=noRelNodeCypherQuery+' SKIP '+num2str(p.Results.Offset);
                if~isinf(p.Results.ReadSize)
                    noRelNodeCypherQuery=noRelNodeCypherQuery+' LIMIT '+num2str(p.Results.ReadSize);
                end

                noRelNodeTable=table;
                noRelNodeResult=executeCypher(neo4jconn,noRelNodeCypherQuery);

                if~isempty(noRelNodeResult)
                    noRelNodes=database.neo4j.http.Neo4jNode(neo4jconn,noRelNodeResult);
                    noRelNodeTable=neo4jconn.nodeObjToTable(noRelNodes);
                    noRelNodeTable(intersect(graphdata.Nodes.Properties.RowNames,noRelNodeTable.Properties.RowNames),:)=[];
                end

                graphdata.Nodes=[graphdata.Nodes;noRelNodeTable];

                if~isinf(p.Results.ReadSize)&&height(graphdata.Relations)>25
                    graphdata.Relations=graphdata.Relations(1:25,:);
                    ids=unique([graphdata.Relations.StartNodeID;graphdata.Relations.EndNodeID]);
                    graphdata.Nodes=graphdata.Nodes(strtrim(cellstr(num2str(ids))),:);
                end

            end

            if~isempty(relationsearch)

                cypherquery=database.neo4j.Neo4jConnect.buildSearchGraphTypeQuery(relationsearch);
                cypherquery=cypherquery+"RETURN id(node1) as StartNodeID,"+...
                "type(relation) as RelationType,"+...
                "id(node2) as EndNodeID,"+...
                "id(relation) as RelationID,"+...
                "relation as RelationData,"+...
                "node1 as StartNodeData,"+...
                "node2 as EndNodeData,"+...
                "labels(node1) as StartNodeLabels,"+...
                "labels(node2) as EndNodeLabels "+...
                "ORDER BY id(relation)";

                cypherquery=cypherquery+' SKIP '+num2str(p.Results.Offset);

                if~isinf(p.Results.ReadSize)
                    cypherquery=cypherquery+' LIMIT '+num2str(p.Results.ReadSize);
                end

                result=executeCypher(neo4jconn,cypherquery);

                reldata=database.neo4j.http.Neo4jRelation(neo4jconn,[],result);
                graphdata.Relations=[graphdata.Relations;neo4jconn.relationObjToTable(reldata)];

                graphdata.Nodes=convertTableToObject(neo4jconn,result);

            end

            graphinfo=graphdata;
            if strcmp(dataReturnType,'digraph')
                graphinfo=neo4jStruct2Digraph(graphinfo);
            end

        end

        function varargout=createNode(neo4jconn,varargin)



























































            nargoutchk(0,1);


            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'createNode','neo4jconn'));
            p.addParameter('Labels',"",@(x)database.neo4j.Neo4jConnect.validateStringInput(x,'Labels'));
            p.addParameter('Properties',table.empty,@(x)validateattributes(x,{'table','struct','cell'},{},'createNode','Properties'));

            p.parse(neo4jconn,varargin{:});

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            labels=p.Results.Labels;
            properties=p.Results.Properties;


            [neo4jconn,labels,properties]=convertCharsToStrings(neo4jconn,labels,properties);

            if iscell(properties)&&~all(cellfun(@isstruct,properties))
                error(message('database:neo4j:cellPropertiesMustBeStructs'));
            end

            if istable(properties)
                properties=table2struct(properties);
            end

            if isempty(properties)

                properties=struct();
            end

            [labelsToAdd,uniqueLabels,newOrder,originalOrder]=...
            database.neo4j.Neo4jConnect.getUniqueLabels(labels,properties);

            if length(properties)==1&&isempty(fieldnames(properties))
                properties=repmat(properties,length(labelsToAdd),1);
            end

            numProps=length(properties);

            if length(labelsToAdd)~=numProps
                error(message('database:neo4j:labelPropertySizeMismatch'));
            end

            labelsToAdd=labelsToAdd(newOrder);
            properties=properties(newOrder);


            statements=strings(length(uniqueLabels),1);
            parameters=cell(length(uniqueLabels),1);
            parameterName='props';

            try
                for n=1:length(uniqueLabels)
                    idx=labelsToAdd==uniqueLabels(n);
                    propsToAdd=properties(idx);
                    parameters{n}.(parameterName)=propsToAdd;

                    query=database.neo4j.Neo4jConnect.buildCreateNodeQuery(...
                    parameterName,uniqueLabels(n));

                    if nargout==1
                        query=query+"RETURN ID(n) AS NodeID, labels(n) AS NodeLabels, n as NodeData";
                    end

                    statements(n)=query;

                end

                results=executeStatements(neo4jconn,statements,parameters);

                if nargout==1
                    nodeObj=database.neo4j.http.Neo4jNode(neo4jconn,results);
                    nodeObj=nodeObj(originalOrder);
                    if length(nodeObj)>1
                        varargout{1}=neo4jconn.nodeObjToTable(nodeObj);
                    else
                        varargout{1}=nodeObj;
                    end
                end
            catch ME
                throw(ME);
            end
        end

        function varargout=createRelation(neo4jconn,startNode,endNode,relationType,varargin)















































































            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'createRelation','neo4jconn'));
            p.addRequired('startNode',@(x)validateattributes(x,{'database.neo4j.http.Neo4jNode','numeric'},{'vector'},'createRelation','startNode'));
            p.addRequired('endNode',@(x)validateattributes(x,{'database.neo4j.http.Neo4jNode','numeric'},{'vector'},'createRelation','endNode'));
            p.addRequired('relationType',@(x)validateattributes(x,{'string','cell','char'},{'vector'},'createRelation','relationType'));
            p.addParameter('Properties',table.empty,@(x)validateattributes(x,{'table','struct','cell'},{},'createNode','Properties'));

            p.parse(neo4jconn,startNode,endNode,relationType,varargin{:});
            properties=p.Results.Properties;


            [neo4jconn,startNode,endNode,relationType,properties]=...
            convertCharsToStrings(neo4jconn,startNode,endNode,relationType,properties);
            if~isstring(relationType)
                error(message('database:neo4j:invalidStringInput','relationType'));
            end
            relationType="`"+relationType+"`";

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end


            if isa(startNode,'database.neo4j.http.Neo4jNode')
                startNode=[startNode(:).NodeID];
            end
            if isrow(startNode)
                startNode=startNode';
            end


            numRels=length(startNode);

            if isa(endNode,'database.neo4j.http.Neo4jNode')
                endNode=[endNode(:).NodeID];
            end
            if isrow(endNode)
                endNode=endNode';
            end

            if iscell(properties)&&~all(cellfun(@isstruct,properties))
                error(message('database:neo4j:cellPropertiesMustBeStructs'));
            end

            if istable(properties)
                properties=table2struct(properties);
            end


            allNodes=unique([startNode;endNode]);
            try
                checkExistingNodes(neo4jconn,allNodes);
            catch Me
                throw(Me);
            end



            if length(endNode)~=numRels
                error(message('database:neo4j:nodeLengthMismatch'));
            end
            if length(relationType)~=1&&length(relationType)~=numRels
                error(message('database:neo4j:relTypeNodeLengthMismatch'));
            end
            if~isempty(properties)&&length(properties)~=numRels
                error(message('database:neo4j:propertiesRelationLengthMismatch'));
            end

            if length(relationType)==1
                relationType=repmat(relationType,numRels,1);
            end

            if isempty(properties)
                properties=struct;
                properties(numRels)=struct;
            end

            [uniqueTypes,newOrder,originalOrder]=database.neo4j.Neo4jConnect.getUniqueTypes(relationType);

            relationType=relationType(newOrder);
            properties=properties(newOrder);
            startNode=startNode(newOrder);
            endNode=endNode(newOrder);


            statements=strings(length(uniqueTypes),1);
            parameters=cell(length(uniqueTypes),1);

            try
                for n=1:length(uniqueTypes)
                    idx=relationType==uniqueTypes(n);
                    propsToAdd=properties(idx);
                    if iscell(propsToAdd)&&isscalar(propsToAdd)
                        propsToAdd=propsToAdd{:};
                    end
                    startNodesToAdd=startNode(idx);
                    endNodesToAdd=endNode(idx);

                    propsParameterName='props';
                    startNodeParameterName='startNodeID';
                    endNodeParameterName='endNodeID';

                    parameters{n}.(propsParameterName)=propsToAdd;
                    parameters{n}.(startNodeParameterName)=int64(startNodesToAdd);
                    parameters{n}.(endNodeParameterName)=int64(endNodesToAdd);


                    query=database.neo4j.Neo4jConnect.buildCreateRelationQuery(...
                    startNodeParameterName,startNodesToAdd,endNodeParameterName,...
                    uniqueTypes(n),propsParameterName);

                    if nargout==1
                        query=query+"RETURN ID(r) AS RelationID, ID(startNode(r)) AS StartNodeID, "+...
                        "ID(endNode(r)) AS EndNodeID, type(r) AS RelationType, "+...
                        "r AS RelationData";
                    end

                    statements(n)=query;
                end

                results=executeStatements(neo4jconn,statements,parameters);
                if nargout==1
                    relObj=database.neo4j.http.Neo4jRelation(neo4jconn,[],...
                    results);
                    relObj=relObj(originalOrder);
                    if length(relObj)>1
                        varargout{1}=neo4jconn.relationObjToTable(relObj);
                    else
                        varargout{1}=relObj;
                    end
                end

            catch ME
                throw(ME);
            end
        end

        function deleteNode(neo4jconn,node,varargin)































            [neo4jconn,node,varargin]=convertCharsToStrings(neo4jconn,node,varargin);


            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'deleteNode','neo4jconn'));
            p.addRequired('node',@(x)validateattributes(x,{'database.neo4j.http.Neo4jNode','numeric'},{'vector'},'deleteNode','node'));
            p.addParameter('DeleteRelations',false,@(x)validateattributes(x,{'logical'},{'scalar'}));

            p.parse(neo4jconn,node,varargin{:});

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            if isa(node,'database.neo4j.http.Neo4jNode')
                node=[node.NodeID];
            end
            node=int64(node);


            try
                checkExistingNodes(neo4jconn,node);
            catch Me
                throw(Me);
            end

            deleteRelationsFlag=p.Results.DeleteRelations();

            nodeIDParameterName='nodeID';

            query=database.neo4j.Neo4jConnect.buildDeleteNodeQuery(...
            nodeIDParameterName,node,deleteRelationsFlag);

            parameter.(nodeIDParameterName)=node;

            try
                executeStatements(neo4jconn,query,{parameter});
            catch Me
                relFlag=checkForNodesWithRelations(neo4jconn,node);
                if relFlag
                    error(message('database:neo4j:deleteNodeWithRelation'));
                else
                    rethrow(Me);
                end
            end
        end

        function deleteRelation(neo4jconn,relation)





















            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'deleteRelation','neo4jconn'));
            p.addRequired('relation',@(x)validateattributes(x,{'database.neo4j.http.Neo4jRelation','numeric'},{'vector'},'deleteRelation','relation'));

            p.parse(neo4jconn,relation);

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            if isa(relation,'database.neo4j.http.Neo4jRelation')
                relation=[relation.RelationID];
            end
            relation=int64(relation);


            try
                checkExistingRelations(neo4jconn,relation);
            catch Me
                throw(Me);
            end

            relationIDParameterName='relID';

            query=database.neo4j.Neo4jConnect.buildDeleteRelationQuery(...
            relationIDParameterName,relation);

            parameter.(relationIDParameterName)=relation;

            try
                executeStatements(neo4jconn,query,{parameter});
            catch Me
                rethrow(Me);
            end
        end

        function varargout=updateNode(neo4jconn,node,varargin)


























































            nargoutchk(0,1);


            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'updateNode','neo4jconn'));
            p.addRequired('node',@(x)validateattributes(x,{'database.neo4j.http.Neo4jNode','numeric'},{'vector'},'updateNode','node'));
            p.addParameter('Labels',[],@(x)database.neo4j.Neo4jConnect.validateStringInput(x,'Labels'));
            p.addParameter('Properties',[],@(x)validateattributes(x,{'table','struct','cell'},{},'updateNode','Properties'));

            p.parse(neo4jconn,node,varargin{:});

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            if isa(node,'database.neo4j.http.Neo4jNode')
                node=[node.NodeID];
            end
            node=int64(node);


            if length(node)~=length(unique(node))
                error(message('database:neo4j:duplicateNodesNotSupported'));
            end



            try
                oldNodes=searchNodeByID(neo4jconn,node);
                if istable(oldNodes)
                    oldNodes=oldNodes.NodeObject;
                end
            catch
                error(message('database:neo4j:nodesDoNotExist'));
            end

            labels=p.Results.Labels;
            properties=p.Results.Properties;


            [neo4jconn,node,labels,properties]=convertCharsToStrings(neo4jconn,node,labels,properties);


            if isnumeric(labels)&&isnumeric(properties)
                error(message('database:neo4j:noUpdatesProvided'));
            end

            if iscell(properties)&&~all(cellfun(@isstruct,properties))
                error(message('database:neo4j:cellPropertiesMustBeStructs'));
            end

            if istable(properties)
                properties=table2struct(properties);
            end

            if~isempty(properties)&&length(properties)~=length(node)
                error(message('database:neo4j:propertiesRelationLengthMismatch'));
            end

            [labelRemoveSection,labelSetSection,uniqueLabelSections,originalOrder,node,properties]=...
            database.neo4j.Neo4jConnect.processUpdateLabels(labels,oldNodes,node,properties);


            statements=strings(length(uniqueLabelSections),1);
            parameters=cell(length(uniqueLabelSections),1);

            try
                for n=1:length(uniqueLabelSections)
                    idx=labelSetSection==uniqueLabelSections(n);
                    nodesToAdd=node(idx);

                    nodeIDParameterName='nodeID';
                    propsParameterName='props';

                    query=database.neo4j.Neo4jConnect.buildUpdateNodeQuery(...
                    nodeIDParameterName,nodesToAdd,labelRemoveSection,...
                    uniqueLabelSections(n),propsParameterName,properties,...
                    properties);

                    parameters{n}.(nodeIDParameterName)=nodesToAdd;

                    propsToAdd=[];
                    if~isempty(properties)
                        propsToAdd=properties(idx);
                        if iscell(propsToAdd)&&isscalar(propsToAdd)
                            propsToAdd=propsToAdd{:};
                        end
                    end
                    parameters{n}.(propsParameterName)=propsToAdd;

                    if nargout==1
                        query=query+"RETURN ID(n) AS NodeID, labels(n) AS NodeLabels, n as NodeData";
                    end

                    statements(n)=query;
                end

                results=executeStatements(neo4jconn,statements,parameters);

                if nargout==1
                    nodeObj=database.neo4j.http.Neo4jNode(neo4jconn,results);
                    nodeObj=nodeObj(originalOrder);
                    if length(nodeObj)>1
                        varargout{1}=neo4jconn.nodeObjToTable(nodeObj);
                    else
                        varargout{1}=nodeObj;
                    end
                end

            catch ME
                throw(ME);
            end
        end


        function varargout=updateRelation(neo4jconn,relation,properties)





































            nargoutchk(0,1);

            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'updateRelation','neo4jconn'));
            p.addRequired('relation',@(x)validateattributes(x,{'database.neo4j.http.Neo4jRelation','numeric'},{'vector'},'updateRelation','relation'));
            p.addRequired('properties',@(x)validateattributes(x,{'struct','table','cell'},{},'updateRelation','properties'));

            p.parse(neo4jconn,relation,properties);

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            if isa(relation,'database.neo4j.http.Neo4jRelation')
                relation=[relation.RelationID];
            end
            relation=int64(relation);


            try
                checkExistingRelations(neo4jconn,relation);
            catch Me
                throw(Me);
            end

            if iscell(properties)&&~all(cellfun(@isstruct,properties))
                error(message('database:neo4j:cellPropertiesMustBeStructs'));
            end

            if istable(properties)
                properties=table2struct(properties);
            end

            if length(properties)~=length(relation)
                error(message('database:neo4j:propertiesRelationLengthMismatch'));
            end

            propsParameterName='props';
            relationIDParameterName='relID';

            query=database.neo4j.Neo4jConnect.buildUpdateRelationQuery(relationIDParameterName,relation,propsParameterName);

            if nargout==1
                query=query+"RETURN ID(r) AS RelationID, ID(startNode(r)) AS StartNodeID, "+...
                "ID(endNode(r)) AS EndNodeID, type(r) AS RelationType, "+...
                "r AS RelationData";
            end

            parameter.(propsParameterName)=properties;
            parameter.(relationIDParameterName)=relation;


            try
                results=executeStatements(neo4jconn,query,{parameter});
                if nargout==1
                    relObj=database.neo4j.http.Neo4jRelation(neo4jconn,[],...
                    results);
                    if length(relObj)>1
                        varargout{1}=neo4jconn.relationObjToTable(relObj);
                    else
                        varargout{1}=relObj;
                    end
                end
            catch ME
                throw(ME)
            end
        end


        function varargout=storeDigraph(neo4jconn,G,varargin)






























































































            nargoutchk(0,1);

            [neo4jconn,G,varargin{:}]=convertCharsToStrings(neo4jconn,G,varargin{:});


            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'storeDigraph','neo4jconn'));
            p.addRequired('G',@(x)validateattributes(x,{'digraph'},{'scalar'},'storeDigraph','G'));
            p.addParameter("NodeLabel",string.empty,@(x)validateattributes(x,{'string'},{'vector'},'storeDigraph','NodeLabelVariable'));
            p.addParameter("GlobalNodeLabel",string.empty,@(x)validateattributes(x,{'string'},{'vector'},'storeDigraph','NodeLabel'));
            p.addParameter("RelationType",string.empty,@(x)validateattributes(x,{'string'},{'scalartext'},'storeDigraph','relationTypeVariable'));
            p.addParameter("GlobalRelationType",string.empty,@(x)validateattributes(x,{'string'},{'scalartext'},'storeDigraph','relationTypeVariable'));
            p.parse(neo4jconn,G,varargin{:});

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            if G.numnodes==0||G.numedges==0
                error(message('database:neo4j:emptyDigraph'))
            end

            nodeLabelLiterals=p.Results.GlobalNodeLabel;
            if iscolumn(nodeLabelLiterals)
                nodeLabelLiterals=nodeLabelLiterals';
            end
            nodeLabelVariables=p.Results.NodeLabel;
            relationTypeLiteral=p.Results.GlobalRelationType;
            relationTypeVariable=p.Results.RelationType;

            if~isempty(relationTypeLiteral)&&~isempty(relationTypeVariable)

                error(message('database:neo4j:relationTypeLiteralAndVariable'));
            end

            [labelGroups,uniqueLabels,nodes,edges]=...
            database.neo4j.Neo4jConnect.processDigraphLabels(nodeLabelLiterals,nodeLabelVariables,G);

            relTypes=database.neo4j.Neo4jConnect.checkRelationTypeConstant(relationTypeLiteral,relationTypeVariable,edges);

            nodeStatements=strings(length(uniqueLabels),1);
            nodeParameters=cell(length(uniqueLabels),1);



            propertyParameterName="props";
            for n=1:length(uniqueLabels)

                nodeParameters{n}.(propertyParameterName)=table2struct(nodes(labelGroups==n,:));

                query=database.neo4j.Neo4jConnect.buildCreateNodeQuery(propertyParameterName,uniqueLabels(n));
                if nargout==1
                    query=query+"RETURN ID(n) AS NodeID, labels(n) AS NodeLabels, n as NodeData";
                else
                    query=query+"RETURN id(n) AS NodeID";
                end

                nodeStatements(n)=query;
            end

            [nodeResults,transactionLocation]=executeStatements(neo4jconn,nodeStatements,...
            nodeParameters,'',false);
            nodeIDs=nodeResults.NodeID;

            if nargout==1
                nodeObj=database.neo4j.http.Neo4jNode(neo4jconn,...
                nodeResults);
                graphinfo.Nodes=neo4jconn.nodeObjToTable(nodeObj);
            end

            try
                [typeGroups,uniqueTypes,edges]=database.neo4j.Neo4jConnect.processDigraphTypes(edges,relationTypeVariable,relTypes);
                [startNodeIDs,endNodeIDs]=database.neo4j.Neo4jConnect.convertDigraphNodeIDs(nodes,edges,nodeIDs);

                startNodeParameterName="startNodeID";
                endNodeParameterName="endNodeID";

                relationStatements=strings(length(uniqueTypes),1);
                relationParameters=cell(length(uniqueTypes),1);

                for n=1:length(uniqueTypes)

                    relationParameters{n}.(startNodeParameterName)=startNodeIDs(typeGroups==n);
                    relationParameters{n}.(endNodeParameterName)=endNodeIDs(typeGroups==n);
                    relationParameters{n}.(propertyParameterName)=table2struct(edges(typeGroups==n,:));

                    startNodesToAdd=relationParameters{n}.(startNodeParameterName);

                    query=database.neo4j.Neo4jConnect.buildCreateRelationQuery(...
                    startNodeParameterName,startNodesToAdd,endNodeParameterName,...
                    uniqueTypes(n),propertyParameterName);
                    if nargout==1
                        query=query+"RETURN ID(r) AS RelationID, ID(startNode(r)) AS StartNodeID, "+...
                        "ID(endNode(r)) AS EndNodeID, type(r) AS RelationType, "+...
                        "r AS RelationData";
                    end

                    relationStatements(n)=query;
                end

                relationResults=executeStatements(neo4jconn,relationStatements,...
                relationParameters,transactionLocation);

                if nargout==1
                    relObj=database.neo4j.http.Neo4jRelation(neo4jconn,[],...
                    relationResults);
                    graphinfo.Relations=neo4jconn.relationObjToTable(relObj);
                    varargout={graphinfo};
                end

            catch ME
                throw(ME);
            end
        end

        function varargout=addNodeLabel(neo4jconn,node,labels)







































            nargoutchk(0,1);

            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'addNodeLabel','neo4jconn'));
            p.addRequired('node',@(x)validateattributes(x,{'database.neo4j.http.Neo4jNode','numeric'},{'vector'},'addNodeLabel','node'));
            p.addRequired('label',@(x)neo4jconn.validateStringInput(x,'label'));
            p.parse(neo4jconn,node,labels);

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            if isa(node,'database.neo4j.http.Neo4jNode')
                node=[node.NodeID];
            end
            node=int64(node);


            try
                checkExistingNodes(neo4jconn,node);
            catch Me
                throw(Me);
            end

            nodeIDParameterName='nodeID';

            query=database.neo4j.Neo4jConnect.buildAddNodeLabelQuery(labels,nodeIDParameterName,node);

            if nargout==1
                query=query+"RETURN ID(n) AS NodeID, labels(n) AS NodeLabels, n AS NodeData";
            end

            parameter=struct(nodeIDParameterName,node);

            try

                results=executeStatements(neo4jconn,query,{parameter});
                if nargout==1


                    nodeObj=database.neo4j.http.Neo4jNode(neo4jconn,results);
                    if length(nodeObj)>1
                        varargout{1}=neo4jconn.nodeObjToTable(nodeObj);
                    else
                        varargout{1}=nodeObj;
                    end
                end
            catch Me
                rethrow(Me);
            end
        end

        function varargout=removeNodeLabel(neo4jconn,node,labels)






































            nargoutchk(0,1);

            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'removeNodeLabel','neo4jconn'));
            p.addRequired('node',@(x)validateattributes(x,{'database.neo4j.http.Neo4jNode','numeric'},{'vector'},'removeNodeLabel','node'));
            p.addRequired('label',@(x)neo4jconn.validateStringInput(x,'label'));
            p.parse(neo4jconn,node,labels);

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            if isa(node,'database.neo4j.http.Neo4jNode')
                node=[node.NodeID];
            end
            node=int64(node);


            try
                checkExistingNodes(neo4jconn,node);
            catch Me
                throw(Me);
            end

            nodeIDParameterName='nodeID';

            query=database.neo4j.Neo4jConnect.buildRemoveNodeLabelQuery(labels,nodeIDParameterName,node);

            if nargout==1
                query=query+"RETURN ID(n) AS NodeID, labels(n) AS NodeLabels, n AS NodeData";
            end

            parameter=struct(nodeIDParameterName,node);

            try

                results=executeStatements(neo4jconn,query,{parameter});
                if nargout==1


                    nodeObj=database.neo4j.http.Neo4jNode(neo4jconn,results);
                    if length(nodeObj)>1
                        varargout{1}=neo4jconn.nodeObjToTable(nodeObj);
                    else
                        varargout{1}=nodeObj;
                    end
                end
            catch Me
                rethrow(Me);
            end
        end

        function varargout=setNodeProperty(neo4jconn,node,properties)








































            nargoutchk(0,1);

            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'setNodeProperty','neo4jconn'));
            p.addRequired('node',@(x)validateattributes(x,{'database.neo4j.http.Neo4jNode','numeric'},{'vector'},'setNodeProperty','node'));
            p.addRequired('properties',@(x)validateattributes(x,{'struct','table'},{'nonempty'},'setNodeProperty','properties'));
            p.parse(neo4jconn,node,properties);

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            if isa(node,'database.neo4j.http.Neo4jNode')
                node=[node.NodeID];
            end
            node=int64(node);


            try
                checkExistingNodes(neo4jconn,node);
            catch Me
                throw(Me);
            end

            if isstruct(properties)
                if isempty(fieldnames(properties))
                    error(message('database:neo4j:propertiesNoFields'));
                end
            else
                properties=table2struct(properties);
            end

            if isscalar(properties)


                properties=repmat(properties,[length(node),1]);
            end

            if length(properties)~=length(node)
                error(message('database:neo4j:propertiesNodeLengthMismatch'));
            end

            nodeIDParameterName="nodeID";
            propsParameterName="props";

            query=database.neo4j.Neo4jConnect.buildSetNodePropertyQuery(properties,...
            propsParameterName,nodeIDParameterName,node);

            if nargout==1
                query=query+"RETURN ID(n) AS NodeID, labels(n) AS NodeLabels, n AS NodeData";
            end

            parameter.(nodeIDParameterName)=node;
            parameter.(propsParameterName)=properties;

            try

                results=executeStatements(neo4jconn,query,{parameter});
                if nargout==1


                    nodeObj=database.neo4j.http.Neo4jNode(neo4jconn,results);
                    if length(nodeObj)>1
                        varargout{1}=neo4jconn.nodeObjToTable(nodeObj);
                    else
                        varargout{1}=nodeObj;
                    end
                end
            catch Me
                rethrow(Me);
            end
        end


        function varargout=removeNodeProperty(neo4jconn,node,propertyNames)






































            nargoutchk(0,1);

            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'removeNodeProperty','neo4jconn'));
            p.addRequired('node',@(x)validateattributes(x,{'database.neo4j.http.Neo4jNode','numeric'},{'vector'},'removeNodeProperty','node'));
            p.addRequired('propertyNames',@(x)neo4jconn.validateStringInput(x,'propertyNames'));
            p.parse(neo4jconn,node,propertyNames);

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            if isa(node,'database.neo4j.http.Neo4jNode')
                node=[node.NodeID];
            end
            node=int64(node);


            try
                checkExistingNodes(neo4jconn,node);
            catch Me
                throw(Me);
            end

            nodeIDParameterName='nodeID';

            query=database.neo4j.Neo4jConnect.buildRemoveNodePropertyQuery(propertyNames,nodeIDParameterName,node);

            if nargout
                query=query+"RETURN ID(n) AS NodeID, labels(n) AS NodeLabels, n AS NodeData";
            end

            parameter=struct(nodeIDParameterName,node);


            try
                results=executeStatements(neo4jconn,query,{parameter});
                if nargout==1
                    nodeObj=database.neo4j.http.Neo4jNode(neo4jconn,results);
                    if length(nodeObj)>1
                        varargout{1}=neo4jconn.nodeObjToTable(nodeObj);
                    else
                        varargout{1}=nodeObj;
                    end
                end
            catch Me
                rethrow(Me);
            end
        end

        function varargout=setRelationProperty(neo4jconn,relation,properties)





































            nargoutchk(0,1);

            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'setRelationProperty','neo4jconn'));
            p.addRequired('relation',@(x)validateattributes(x,{'database.neo4j.http.Neo4jRelation','numeric'},{'vector'},'setRelationProperty','relation'));
            p.addRequired('properties',@(x)validateattributes(x,{'struct','table'},{'nonempty'},'setRelationProperty','properties'));
            p.parse(neo4jconn,relation,properties);

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            if isa(relation,'database.neo4j.http.Neo4jRelation')
                relation=[relation.RelationID];
            end
            relation=int64(relation);


            try
                checkExistingRelations(neo4jconn,relation);
            catch Me
                throw(Me);
            end

            if isstruct(properties)
                if isempty(fieldnames(properties))
                    error(message('database:neo4j:propertiesNoFields'));
                end
            else
                properties=table2struct(properties);
            end

            if isscalar(properties)


                properties=repmat(properties,[length(relation),1]);
            end

            if length(properties)~=length(relation)
                error(message('database:neo4j:propertiesRelationLengthMismatch'));
            end

            relationIDParameterName="relID";
            propsParameterName="props";

            query=database.neo4j.Neo4jConnect.buildSetRelationPropertyQuery(...
            properties,propsParameterName,relationIDParameterName,relation);
            if nargout==1
                query=query+"RETURN ID(r) AS RelationID, ID(startNode(r)) AS StartNodeID, "+...
                "ID(endNode(r)) AS EndNodeID, type(r) AS RelationType, "+...
                "r AS RelationData";
            end

            parameter.(relationIDParameterName)=relation;
            parameter.(propsParameterName)=properties;


            try
                results=executeStatements(neo4jconn,query,{parameter});
                if nargout==1
                    relObj=database.neo4j.http.Neo4jRelation(neo4jconn,[],...
                    results);
                    if length(relObj)>1
                        varargout{1}=neo4jconn.relationObjToTable(relObj);
                    else
                        varargout{1}=relObj;
                    end
                end
            catch ME
                throw(ME)
            end
        end

        function varargout=removeRelationProperty(neo4jconn,relation,propertyNames)



































            nargoutchk(0,1);

            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'},'removeRelationProperty','neo4jconn'));
            p.addRequired('relation',@(x)validateattributes(x,{'database.neo4j.http.Neo4jRelation','numeric'},{'vector'},'removeRelationProperty','relation'));
            p.addRequired('propertyNames',@(x)neo4jconn.validateStringInput(x,'propertyNames'));
            p.parse(neo4jconn,relation,propertyNames);

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            if isa(relation,'database.neo4j.http.Neo4jRelation')
                relation=[relation.RelationID];
            end
            relation=int64(relation);


            try
                checkExistingRelations(neo4jconn,relation);
            catch Me
                throw(Me);
            end

            relationIDParameterName='relID';

            query=database.neo4j.Neo4jConnect.buildRemoveRelationPropertyQuery(...
            propertyNames,relationIDParameterName,relation);

            if nargout==1
                query=query+"RETURN ID(r) AS RelationID, ID(startNode(r)) AS StartNodeID, "+...
                "ID(endNode(r)) AS EndNodeID, type(r) AS RelationType, "+...
                "r AS RelationData";
            end

            parameter=struct(relationIDParameterName,relation);


            try
                results=executeStatements(neo4jconn,query,{parameter});
                if nargout==1
                    relObj=database.neo4j.http.Neo4jRelation(neo4jconn,[],...
                    results);
                    if length(relObj)>1
                        varargout{1}=neo4jconn.relationObjToTable(relObj);
                    else
                        varargout{1}=relObj;
                    end
                end
            catch ME
                throw(ME)
            end
        end
    end

    methods(Access=private,Hidden=true)

        function[result,transactionLocation]=executeStatements(neo4jconn,statements,varargin)





            p=inputParser;
            p.addRequired('neo4jconn',@(x)validateattributes(x,{'database.neo4j.http.Neo4jConnect'},{'scalar'}));
            p.addRequired('statements',@(x)validateattributes(x,{'string'},{'vector'}));
            p.addOptional('parameters',cell.empty,@(x)validateattributes(x,{'cell'},{'vector','nonempty'}));
            p.addOptional('location','',@(x)validateattributes(x,{'string','char'},{'scalartext'}));
            p.addOptional('commit',true,@(x)validateattributes(x,{'logical'},{'scalar','nonempty'}));

            p.parse(neo4jconn,statements,varargin{:});

            parameters=p.Results.parameters;
            location=p.Results.location;
            commit=p.Results.commit;

            if~isOpen(neo4jconn)
                error(message('database:neo4j:invalidConnection'))
            end

            if~isfield(neo4jconn.MetaData_URLs,'transaction')
                error(message('database:neo4j:executeCypherException'));
            end

            if~isempty(parameters)

                cellfun(@(x)validateattributes(x,{'struct'},{'scalar'}),parameters);
                if length(parameters)~=length(statements)
                    error(message('database:neo4j:parameterStatmentLengthMismatch'));
                end
            else
                parameters=struct;
            end

            if isempty(location)
                queryurl=neo4jconn.MetaData_URLs.transaction;
                if commit&&~endsWith(queryurl,'/commit')
                    queryurl=[queryurl,'/commit'];
                end
            else
                queryurl=location;
            end

            cypherquery=cellstr(p.Results.statements);
            validateattributes(char(cypherquery),{'char'},{'nonempty'},'executeCypher','CypherQuery');

            queryinput=struct('statements',struct('statement',cypherquery,...
            'resultDataContents',{{'row'}},...
            'parameters',parameters));

            if isscalar(queryinput.statements)

                queryinput.statements={queryinput.statements};
            end

            try

                httpBody=matlab.net.http.MessageBody(queryinput);
                requestMethod=matlab.net.http.RequestMethod('post');
                request=matlab.net.http.RequestMessage(requestMethod,neo4jconn.HttpHeader,httpBody);

                response=send(request,queryurl,neo4jconn.HttpOptions);

            catch ME
                error(message('database:neo4j:genericException',ME.message));
            end



            errorMessage=database.internal.utilities.Neo4jUtils.introspect(response);

            if~isempty(errorMessage)
                error(message('database:neo4j:genericException',errorMessage));
            end


            result=table;
            if isempty(response.Body.Data)
                return;
            end

            if isfield(response.Body.Data,'commit')
                transactionLocation=response.Body.Data.commit;
            else
                transactionLocation='';
            end

            resultset.ColumnNames=response.Body.Data.results(1).columns';
            resultset.Rows=cell.empty;

            for n=1:length(response.Body.Data.results)
                statementResponse=response.Body.Data.results(n);

                noofcolumns=length(statementResponse.columns);
                noofrows=length(statementResponse.data);
                resultRows=cell(noofrows,noofcolumns);
                for i=1:noofcolumns
                    for j=1:noofrows
                        resultRows{j,i}='null';
                        if~isempty(statementResponse.data(j).row)
                            switch class(statementResponse.data(j).row)
                            case 'cell'

                                if length(statementResponse.data(j).row)==1
                                    resultRows{j,i}=statementResponse.data(j).row{1};
                                else
                                    resultRows{j,i}=statementResponse.data(j).row{i};
                                end

                            case 'struct'

                                resultRows{j,i}=statementResponse.data(j).row(i);

                            case 'double'

                                if length(statementResponse.data(j).row)==1||noofcolumns==1




                                    resultRows{j,i}=statementResponse.data(j).row;
                                else
                                    resultRows{j,i}=statementResponse.data(j).row(i);
                                end
                            end
                        end
                    end

                end
                resultset.Rows=[resultset.Rows;resultRows];

            end

            if isempty(resultset.Rows)
                result=cell2table(cell(0,length(resultset.ColumnNames)));
            else
                result=cell2table(resultset.Rows);
            end

            if~isempty(resultset.ColumnNames)
                result.Properties.VariableNames=matlab.lang.makeValidName(resultset.ColumnNames);
            end
        end

        function checkExistingNodes(neo4jconn,ids)
            if length(ids)~=length(unique(ids))
                error(message('database:neo4j:duplicateNodesNotSupported'));
            end

            nodeIDParameterName="nodeID";

            query="MATCH (n)"+newline;
            query=query+"WHERE id(n)";
            if length(ids)==1
                query=query+"=";
            else
                query=query+"IN";
            end
            query=query+" $"+nodeIDParameterName+newline;
            query=query+"RETURN id(n) AS NodeID";

            parameter.(nodeIDParameterName)=int64(ids);

            results=executeStatements(neo4jconn,query,{parameter});

            if length(results.NodeID)~=length(ids)
                error(message('database:neo4j:nodesDoNotExist'));
            end
        end

        function checkExistingRelations(neo4jconn,ids)
            if length(ids)~=length(unique(ids))
                error(message('database:neo4j:duplicateRelationsNotSupported'));
            end

            relationIDParameterName="relationID";

            query="MATCH ()-[r]->()"+newline;
            query=query+"WHERE id(r)";
            if length(ids)==1
                query=query+"=";
            else
                query=query+"IN";
            end
            query=query+" $"+relationIDParameterName+newline;
            query=query+"RETURN id(r) AS RelationID";

            parameter.(relationIDParameterName)=ids;

            results=executeStatements(neo4jconn,query,{parameter});

            if length(results.RelationID)~=length(ids)
                error(message('database:neo4j:relationsDoNotExist'));
            end
        end

        function nodetable=convertTableToObject(neo4jconn,result)

            nodetable=table;

            startnodetable=table([result.('StartNodeID')],result.('StartNodeLabels'),result.('StartNodeData'),'VariableNames',{'NodeID','NodeLabels','NodeData'});
            [~,ia,~]=unique(startnodetable.NodeID);
            eliminator=setdiff((1:length(startnodetable.NodeID)),ia);
            startnodetable(eliminator,:)=[];
            nodeObjs=database.neo4j.http.Neo4jNode(neo4jconn,startnodetable);

            nodetable=[nodetable;table({nodeObjs(:).NodeLabels}',{nodeObjs(:).NodeData}',nodeObjs(:),'VariableNames',{'NodeLabels','NodeData','NodeObject'},'RowNames',strtrim(cellstr(num2str([nodeObjs(:).NodeID]'))))];

            endnodetable=table([result.('EndNodeID')],result.('EndNodeLabels'),result.('EndNodeData'),'VariableNames',{'NodeID','NodeLabels','NodeData'});
            [~,ia,~]=unique(endnodetable.NodeID);
            eliminator=setdiff((1:length(endnodetable.NodeID)),ia);
            endnodetable(eliminator,:)=[];
            nodeObjs=database.neo4j.http.Neo4jNode(neo4jconn,endnodetable);

            endtable=table({nodeObjs(:).NodeLabels}',{nodeObjs(:).NodeData}',nodeObjs(:),'VariableNames',{'NodeLabels','NodeData','NodeObject'},'RowNames',strtrim(cellstr(num2str([nodeObjs(:).NodeID]'))));

            nodetable(intersect(nodetable.Properties.RowNames,endtable.Properties.RowNames),:)=[];

            nodetable=[nodetable;endtable];
        end
    end
end