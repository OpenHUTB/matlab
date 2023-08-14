classdef(Hidden,Abstract)Neo4jConnect<handle






    properties(SetAccess=protected,GetAccess=public)


        URL;



        UserName;




        Message;
    end

    methods(Abstract)
        close(this)
        nodeLabels(this)
        relationTypes(this)
        propertyKeys(this)
        nodeinfo=searchNodeByID(this)
        nodeinfo=searchNode(this,label,varargin)
        relinfo=searchRelation(this,nodeinfo,direction,varargin)
        relationinfo=searchRelationByID(this,relationid)
        graphinfo=searchGraph(this,searchcriteria,varargin)
        nodeinfo=createNode(this,varargin)
        relationinfo=createRelation(this,startNode,endNode,relationType,varargin)
        deleteNode(this,node,varargin)
        deleteRelation(this,relation)
        nodeinfo=updateNode(this,node,varargin)
        relationinfo=updateRelation(this,relation,props)
        varargout=storeDigraph(this,G,varargin)
        result=executeCypher(this,query)
    end

    methods(Access=protected,Hidden)
        function relFlag=checkForNodesWithRelations(this,nodes)
            relFlag=false;
            for n=1:length(nodes)
                inRelInfo=searchRelation(this,nodes(n),'in');
                outRelInfo=searchRelation(this,nodes(n),'out');
                if~isempty(inRelInfo.Relations)||~isempty(outRelInfo.Relations)
                    relFlag=true;
                    break;
                end
            end
        end
    end

    methods(Access=protected,Static,Hidden)
        function nodeInfo=nodeObjToTable(nodeObj)


            nodeInfo=table({nodeObj(:).NodeLabels}',{nodeObj(:).NodeData}',nodeObj(:),'VariableNames',{'NodeLabels','NodeData','NodeObject'});
            nodeInfo.Properties.RowNames=strtrim(cellstr(num2str([nodeObj(:).NodeID]')));
        end

        function relationInfo=relationObjToTable(relationObj)


            relationInfo=table([relationObj(:).StartNodeID]',{relationObj(:).RelationType}',[relationObj(:).EndNodeID]',{relationObj(:).RelationData}',relationObj(:),...
            'VariableNames',{'StartNodeID','RelationType','EndNodeID','RelationData','RelationObject'});
            relationInfo.Properties.RowNames=strtrim(cellstr(num2str([relationObj(:).RelationID]')));
        end

        function validateStringInput(x,varName)

            if(isstring(x)||iscellstr(x)||ischar(x))&&(isvector(x)||isempty(x))
                return;
            elseif iscell(x)&&isvector(x)
                strCheck=all(cellfun(@(x)iscellstr(x)||isstring(x)||ischar(x)&&isvector(string(x)),x));
                if~strCheck
                    error(message('database:neo4j:invalidStringInput',varName));
                end
            else
                error(message('database:neo4j:invalidStringInput',varName));
            end
        end

        function query=buildSearchNodeByIDQuery(parameterName,node)


            query="MATCH(n) WHERE ID(n) ";
            if isscalar(node)
                query=query+"=";
            else
                query=query+"IN";
            end
            query=query+" $"+parameterName+newline;
        end

        function query=buildSearchNodeQuery(label,propertyParameterName,propertyKey)

            query="MATCH(n";
            if~isempty(label)

                query=query+":"+"`"+label+"`";
            end

            if~isempty(propertyKey)

                query=query+" { "+propertyKey+": $"+propertyParameterName+" }";
            end
            query=query+")"+newline;

            if isempty(label)

                query=query+"WHERE NOT labels(n)";
            end

        end

        function query=buildSearchRelationByIDQuery(relationIDParameterName,relationID)


            query="MATCH ()-[r]->()"+newline;
            query=query+"WHERE ID(r) ";
            if isscalar(relationID)
                query=query+"=";
            else
                query=query+"IN";
            end
            query=query+" $"+relationIDParameterName+newline;
        end

        function query=buildSearchRelationQuery(direction,distance,relationTypes)
            nodeIDParameterName="nodeID";

            query="MATCH(n)";
            if direction=="in"
                query=query+"<-";
            else
                query=query+"-";
            end
            query=query+"[r";
            if~isempty(relationTypes)
                relationTypes="`"+relationTypes+'`';
                query=query+":"+strjoin(relationTypes,"|");
            end
            query=query+"*1.."+string(distance)+"]";
            if direction=="in"
                query=query+"-";
            else
                query=query+"->";
            end
            query=query+"()"+newline;
            query=query+"WHERE ID(n) = $"+nodeIDParameterName+newline;
        end

        function query=buildSearchGraphLabelQuery(labelsToSearch,direction)
            labelsToSearch="`"+labelsToSearch+"`";
            query="MATCH(node1)";
            if direction=="in"
                query=query+"<";
            end
            query=query+"-[relation]-";
            if direction=="out"
                query=query+">";
            end
            query=query+"(node2)"+newline;

            searchTerms="node1:"+labelsToSearch;
            whereClause="WHERE "+strjoin(searchTerms," OR ");
            query=query+whereClause+newline;
        end

        function query=buildSearchGraphLabelNoRelQuery(labelsToSearch)

            labelsToSearch="`"+labelsToSearch+"`";
            searchTerms="node1:"+labelsToSearch;
            labelClause=strjoin(searchTerms," OR ");
            query="MATCH (node1) WHERE NOT (node1)-[]-() AND ("+labelClause+")";
        end

        function query=buildSearchGraphTypeQuery(relationTypesToSearch)


            relationTypesToSearch="`"+relationTypesToSearch+"`";
            query="MATCH(node1)-[relation:";
            query=query+strjoin(relationTypesToSearch,"|");
            query=query+"]->(node2)";
        end



        function[labelsToAdd,uniqueLabels,newOrder,originalOrder]=getUniqueLabels(labels,properties)



            if iscell(labels)


                labelsToAdd=cellfun(@(x)join(plus(plus("`",x),"`"),":"),labels);
            else

                labelsToAdd=join("`"+labels+"`",":");
                labelsToAdd=repmat(labelsToAdd,length(properties),1);
            end

            [labelGroups,uniqueLabels]=findgroups(labelsToAdd);
            [~,newOrder]=sort(labelGroups);
            [~,originalOrder]=sort(newOrder);
        end

        function query=buildCreateNodeQuery(parameterName,labels)


            query="UNWIND $"+parameterName+" AS properties"+newline;
            query=query+"CREATE(n";
            if~isempty(labels)&&labels~="``"&&~ismissing(labels)&&strlength(labels)>0
                query=query+":"+labels;
            end
            query=query+")"+newline;
            query=query+"SET n = properties"+newline;
        end

        function[uniqueTypes,newOrder,originalOrder]=getUniqueTypes(relationType)
            [typeGroups,uniqueTypes]=findgroups(relationType);
            [~,newOrder]=sort(typeGroups);
            [~,originalOrder]=sort(newOrder);
        end

        function query=buildCreateRelationQuery(startNodeParameterName,startNode,endNodeParameterName,type,propsParameterName)


            query="";
            if~isscalar(startNode)
                query=query+"WITH range(0,size($"+startNodeParameterName+")-1) AS idxList"+newline;
                query=query+"UNWIND idxList AS idx"+newline;
                subscript="[idx]";
            else
                subscript="";
            end

            query=query+"MATCH (startNode), (endNode)"+newline;
            query=query+"WHERE id(startNode) = $"+startNodeParameterName+subscript+...
            " AND id(endNode) = $"+endNodeParameterName+subscript+newline;
            query=query+"CREATE (startNode)-[r:"+type+"]->(endNode)"+newline;
            query=query+"SET r = $"+propsParameterName+subscript+newline;
        end

        function query=buildDeleteNodeQuery(nodeIDParameterName,node,deleteRelationsFlag)


            query="MATCH(n)"+newline;
            query=query+"WHERE ID(n) ";
            if isscalar(node)
                query=query+"=";
            else
                query=query+"IN";
            end
            query=query+" $"+nodeIDParameterName+newline;

            if deleteRelationsFlag
                query=query+"DETACH DELETE n";
            else
                query=query+"DELETE n";
            end
        end

        function query=buildDeleteRelationQuery(relationIDParameterName,relation)


            query="MATCH ()-[r]-()"+newline;
            query=query+"WHERE ID(r) ";
            if isscalar(relation)
                query=query+"=";
            else
                query=query+"IN";
            end
            query=query+" $"+relationIDParameterName+newline;
            query=query+"DELETE r";
        end

        function[labelRemoveSection,labelSetSection,uniqueLabelSections,originalOrder,node,properties]=processUpdateLabels(labels,oldNodes,node,properties)




            labelRemoveSection="";
            labelSetSection="";
            if~isnumeric(labels)


                oldLabels=string.empty;
                for n=1:length(oldNodes)
                    oldLabels=[oldLabels;string(oldNodes(n).NodeLabels)];%#ok<*AGROW>
                end
                if~isempty(oldLabels)
                    oldLabels="`"+oldLabels+"`";
                    oldLabels=unique(oldLabels);
                    labelRemoveSection="REMOVE n:"+join(oldLabels,":")+newline;
                end

                if iscell(labels)
                    labelsToAdd=cellfun(@(x)join(plus(plus("`",x),"`"),":"),labels);
                else
                    labelsToAdd=join("`"+labels+"`",":");
                end
                labelSetSection="SET n:"+labelsToAdd+newline;

                labelSetSection(contains(labelSetSection,"SET n:``"))="";
            end

            if length(labelSetSection)==1
                labelSetSection=repmat(labelSetSection,length(node),1);
            end

            [labelGroups,uniqueLabelSections]=findgroups(labelSetSection);
            [~,newOrder]=sort(labelGroups);
            [~,originalOrder]=sort(newOrder);

            labelSetSection=labelSetSection(newOrder);
            node=node(newOrder);
            if~isempty(properties)
                properties=properties(newOrder);
            end
        end

        function query=buildUpdateNodeQuery(nodeIDParameterName,node,labelRemoveSection,labelSetSection,propsParameterName,propertiesInitial,propertyValues)

            query="";

            if length(node)>1
                query=query+"WITH range(0,size($"+nodeIDParameterName+")-1) AS idxList"+newline;
                query=query+"UNWIND idxList AS idx"+newline;
                subscript="[idx]";
            else
                subscript="";
            end

            query=query+"MATCH(n)"+newline;
            query=query+"WHERE id(n) = $"+nodeIDParameterName+subscript+newline;
            query=query+labelRemoveSection+labelSetSection;

            if~isnumeric(propertiesInitial)
                if isempty(propertyValues)
                    query=query+"SET n = {}"+newline;
                else
                    query=query+"SET n = $"+propsParameterName+subscript+newline;
                end
            end
        end


        function query=buildUpdateRelationQuery(relationIDParameterName,relation,propsParameterName)



            query="";
            if~isscalar(relation)
                query=query+"WITH range(0,size($"+relationIDParameterName+")-1) AS idxList"+newline;
                query=query+"UNWIND idxList AS idx"+newline;
                subscript="[idx]";
            else
                subscript="";
            end

            query=query+"MATCH ()-[r]->()"+newline;
            query=query+"WHERE id(r) = $"+relationIDParameterName+subscript+newline;
            query=query+"SET r = $"+propsParameterName+subscript+newline;
        end


        function query=buildAddNodeLabelQuery(labels,nodeIDParameterName,node)


            labelsToAdd=database.neo4j.Neo4jConnect.combineLabels(labels);


            query="MATCH (n)"+newline;
            query=query+"WHERE id(n) ";
            if isscalar(node)
                query=query+"=";
            else
                query=query+"IN";
            end
            query=query+" $"+nodeIDParameterName+newline;
            query=query+"SET n"+labelsToAdd+newline;
        end

        function query=buildRemoveNodeLabelQuery(labels,nodeIDParameterName,node)


            labelsToRemove=database.neo4j.Neo4jConnect.combineLabels(labels);


            query="MATCH (n)"+newline;
            query=query+"WHERE id(n) ";
            if isscalar(node)
                query=query+"=";
            else
                query=query+"IN";
            end
            query=query+" $"+nodeIDParameterName+newline;
            query=query+"REMOVE n"+labelsToRemove+newline;
        end

        function query=buildSetNodePropertyQuery(props,propsParameterName,nodeIDParameterName,node)


            query="";
            subscript="";

            if length(node)>1
                query="WITH range(0,size($"+nodeIDParameterName+")-1) AS idxList"+newline;
                query=query+"UNWIND idxList AS idx"+newline;
                subscript="[idx]";
            end

            query=query+"MATCH(n)"+newline;
            query=query+"WHERE id(n) = $"+nodeIDParameterName+subscript+newline;

            propNames=fieldnames(props);
            propSets="n."+propNames+" = $"+propsParameterName+subscript+"."+propNames;
            query=query+"SET "+join(propSets,", ")+newline;
        end

        function query=buildRemoveNodePropertyQuery(propertyNames,nodeIDParameterName,node)


            propertyNames=database.neo4j.Neo4jConnect.processPropertyNames(propertyNames);

            query="MATCH(n)"+newline;
            query=query+"WHERE id(n) ";
            if isscalar(node)
                query=query+"=";
            else
                query=query+"IN";
            end
            query=query+" $"+nodeIDParameterName+newline;

            propSpecs="n."+propertyNames;
            propSpecs=join(propSpecs,", ");

            query=query+"REMOVE "+propSpecs+newline;
        end

        function query=buildSetRelationPropertyQuery(props,propsParameterName,relationIDParameterName,relation)



            query="";
            subscript="";

            if length(relation)>1
                query="WITH range(0,size($"+relationIDParameterName+")-1) AS idxList"+newline;
                query=query+"UNWIND idxList AS idx"+newline;
                subscript="[idx]";
            end

            query=query+"MATCH ()-[r]->()"+newline;
            query=query+"WHERE id(r) = $"+relationIDParameterName+subscript+newline;

            propNames=fieldnames(props);
            propSets="r."+propNames+" = $"+propsParameterName+subscript+"."+propNames;
            query=query+"SET "+join(propSets,", ")+newline;
        end

        function query=buildRemoveRelationPropertyQuery(propertyNames,relationIDParameterName,relation)



            propertyNames=database.neo4j.Neo4jConnect.processPropertyNames(propertyNames);

            query="MATCH ()-[r]->()"+newline;
            query=query+"WHERE id(r) ";
            if isscalar(relation)
                query=query+"=";
            else
                query=query+"IN";
            end
            query=query+" $"+relationIDParameterName+newline;

            propSpecs="r."+propertyNames;
            propSpecs=join(propSpecs,", ");

            query=query+"REMOVE "+propSpecs+newline;
        end


        function[labelGroups,uniqueLabels,nodes,edges]=processDigraphLabels(nodeLabelLiterals,nodeLabelVariables,G)



            labelsToAdd=nodeLabelLiterals;

            if~isempty(nodeLabelVariables)
                if~all(ismember(nodeLabelVariables,string(G.Nodes.Properties.VariableNames)))

                    error(message('database:neo4j:nodeLabelVariableNotInTable'))
                end
                if any(nodeLabelVariables=="Name")

                    error(message('database:neo4j:nameAsNodeLabel'));
                end


                nodeLabelData=string(table2cell(G.Nodes(:,cellstr(nodeLabelVariables))));
                labelsToAdd=[nodeLabelData,repmat(labelsToAdd,height(G.Nodes),1)];
            end

            labelsToAdd(ismissing(labelsToAdd))="";
            labelsToAdd="`"+labelsToAdd+"`";
            labelsToAdd=join(labelsToAdd,":",2);
            labelsToAdd=regexprep(labelsToAdd,"^``\:","");
            labelsToAdd=regexprep(labelsToAdd,"\:``","");
            if isempty(labelsToAdd)
                labelsToAdd="";
            end

            if~isempty(nodeLabelVariables)
                [labelGroups,uniqueLabels]=findgroups(labelsToAdd);
                [labelGroups,newNodeOrder]=sort(labelGroups);

                G=reordernodes(G,newNodeOrder);
                G.Nodes(:,cellstr(nodeLabelVariables))=[];
            else
                uniqueLabels=labelsToAdd;
                labelGroups=ones(height(G.Nodes),1);
            end

            nodes=G.Nodes;
            edges=G.Edges;
        end

        function relTypes=checkRelationTypeConstant(relationTypeLiteral,relationTypeVariable,edges)

            if isempty(relationTypeLiteral)&&isempty(relationTypeVariable)
                relTypes="Edge";
            elseif~isempty(relationTypeLiteral)
                relTypes=relationTypeLiteral;
            else
                if~ismember(relationTypeVariable,string(edges.Properties.VariableNames))


                    error(message('database:neo4j:relationTypeVariableNotInTable'))
                end
                if relationTypeVariable=="EndNodes"


                    error(message('database:neo4j:endNodesasRelationType'));
                end
                relTypes=[];
            end
        end

        function[typeGroups,uniqueTypes,edges]=processDigraphTypes(edges,relationTypeVariable,relTypes)

            if~isempty(relationTypeVariable)


                [typeGroups,uniqueTypes]=findgroups(edges.(relationTypeVariable));
                [typeGroups,newRelationOrder]=sort(typeGroups);
                edges=edges(newRelationOrder,:);
                edges(:,cellstr(relationTypeVariable))=[];
            else
                uniqueTypes=relTypes;
                typeGroups=ones(height(edges),1);
            end

            uniqueTypes="`"+uniqueTypes+"`";
        end

        function[startNodeIDs,endNodeIDs]=convertDigraphNodeIDs(nodes,edges,nodeIDs)

            relNodes=edges.EndNodes;
            edges.EndNodes=[];
            startNodes=relNodes(:,1);
            endNodes=relNodes(:,2);

            nameExists=any(strcmp(nodes.Properties.VariableNames,'Name'));
            if nameExists

                startNodes=arrayfun(@(x)find(nodes.Name==string(x)),startNodes);
                endNodes=arrayfun(@(x)find(nodes.Name==string(x)),endNodes);
            end


            startNodeIDs=int64(nodeIDs(startNodes));
            endNodeIDs=int64(nodeIDs(endNodes));
        end

    end

    methods(Access=private,Static)
        function labelSet=combineLabels(labels)


            validateattributes(char(labels),{'char'},{'nonempty'},'','label');
            labels=string(labels);

            labels(ismissing(labels)|strlength(labels)==0)=[];
            validateattributes(labels,{'string'},{'nonempty'},'','label');
            labels="`"+labels+"`";
            labelSet=":"+join(labels,":");
        end

        function processedNames=processPropertyNames(propertyNames)

            validateattributes(char(propertyNames),{'char'},{'nonempty'},'','propertyName');
            propertyNames=string(propertyNames);
            propertyNames(ismissing(propertyNames)|strlength(propertyNames)==0)=[];
            validateattributes(propertyNames,{'string'},{'nonempty'},'','propertyName');
            processedNames="`"+propertyNames+"`";
        end

    end

end