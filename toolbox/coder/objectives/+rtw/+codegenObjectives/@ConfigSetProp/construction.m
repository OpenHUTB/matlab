function obj=construction(obj,objName,generate)






    if nargin<3
        generate=false;
    end

    if~generate
        mapFileName=fullfile(matlabroot,...
        'toolbox','coder','objectives','data','configset_dependency.mat');

        load(mapFileName);
        fields={'Parameters',...
        'ParamHash',...
        'nOfCC',...
        'CtrlCond',...
        'DAGNode',...
        'totalParamNum',...
        'seated',...
        'objName',...
        'Dependencies',...
        'nOfStateOfCC',...
        'stateOfCC',...
        };

        for i=1:length(fields)
            obj.(fields{i})=cspobj.(fields{i});
        end

        obj.objName=objName;

        return;
    end






    obj.reader();

    if obj.error>0
        return;
    end


    objectives=[];
    noObjective=false;
    if generate||strcmpi(objName{1},'_export_To_File_')
        noObjective=true;
    end

    if~noObjective
        nOfObjs=length(obj.objectives);
        objIdx=0;
        validObjIdx=0;
        objectives=cell(nOfObjs,1);

        for i=1:nOfObjs
            currentObj=obj.objectives{i};

            if~isempty(currentObj)
                objIdx=objIdx+1;
                objName{objIdx}=currentObj.name;

                if currentObj.error==0
                    validObjIdx=validObjIdx+1;
                    objectives{validObjIdx}.count=currentObj.len;
                    objectives{validObjIdx}.params=currentObj.params;
                end
            end
        end
    end


    tnOfParam=length(obj.Parameters);


    DAGList=cell(tnOfParam,1);


    dAGNode=cell(tnOfParam,1);
    seated=cell(tnOfParam,1);

    for i=1:tnOfParam
        DAGList{i}=[];

        dAGNode{i}.id=-1;
        dAGNode{i}.numOfParents=0;
        dAGNode{i}.numOfChildren=-1;
        dAGNode{i}.isDAGRoot=0;
        seated{i}=0;
    end
    obj.DAGNode=dAGNode;
    obj.seated=seated;


    Dependencies=obj.Dependencies;
    nOfDep=length(Dependencies);

    nOfDAGs=0;


    for i=1:nOfDep
        curDependency=Dependencies{i};
        if~curDependency.valid
            continue;
        end

        parentId=curDependency.idLeft;
        nOfChildren=curDependency.nOfRtP;
        valueLeft=curDependency.valueLeft;
        if strcmpi(curDependency.force,'Y')
            force=true;
        elseif strcmpi(curDependency.force,'N')
            force=false;
        else
            error('Invalid value in ''force'' field');
        end
        if strcmpi(curDependency.logic,'p')
            logic=false;
        elseif strcmpi(curDependency.logic,'n')
            logic=true;
        else
            error('Invalid value in ''logic'' field');
        end
        obj.Parameters(parentId).inDAG=obj.Parameters(parentId).inDAG+1;

        assert(nOfChildren<=1);
        for c=1:nOfChildren
            childId=curDependency.idRight{c};
            valueRight=curDependency.valueRight{c};

            obj.Parameters(childId).inDAG=obj.Parameters(childId).inDAG+1;

            if nOfDAGs==0
                obj.DAGNode{parentId}=createDAGNode(obj,parentId,'child',childId,...
                valueLeft,valueRight,...
                force,logic);

                obj.DAGNode{childId}=createDAGNode(obj,childId,'parent',parentId,...
                valueLeft,valueRight,force,logic);

                nOfDAGs=1;
                DAGList{nOfDAGs}=parentId;
                obj.DAGNode{parentId}.isDAGRoot=1;

                parameters0=obj.Parameters;
                parameters0(parentId).ancestor=parentId;
                parameters0(childId).ancestor=parentId;
                obj.Parameters=parameters0;
                continue;
            end

            parentExisted=0;
            for j=1:nOfDAGs
                if DAGList{j}<=0
                    continue;
                end

                parentExisted=searchDAG(obj.DAGNode,DAGList{j},parentId);
                if~parentExisted
                    continue;
                end


                hasLoop=searchDAG(obj.DAGNode,DAGList{j},childId);
                if hasLoop
                    circle=searchDAG(obj.DAGNode,childId,parentId);
                    if circle
                        results.error=3;
                        obj.Parameters(parentId).inDAG=obj.Parameters(parentId).inDAG-1;
                        obj.Parameters(childId).inDAG=obj.Parameters(childId).inDAG-1;
                        continue;
                    else

                        results.error=0;
                    end
                end


                obj.DAGNode{parentId}=modifyDAGNode(obj.DAGNode{parentId},'child',...
                childId,valueLeft,valueRight,...
                force,logic);


                if obj.seated{childId}
                    obj.DAGNode{childId}=modifyDAGNode(obj.DAGNode{childId},'parent',...
                    parentId,valueLeft,valueRight,...
                    force,logic);

                    if~obj.Parameters(childId).ancestor
                        results.error=4;
                        return;
                    end

                    if obj.DAGNode{childId}.isDAGRoot
                        idx=obj.DAGNode{childId}.isDAGRoot;
                        obj.DAGNode{childId}.isDAGRoot=0;

                        DAGList{idx}=-1;

                        for m=idx:nOfDAGs-1
                            obj.DAGNode{DAGList{m+1}}.isDAGRoot=m;
                            DAGList{m}=DAGList{m+1};
                        end

                        DAGList{nOfDAGs}=[];
                        nOfDAGs=nOfDAGs-1;
                    end
                else
                    obj.DAGNode{childId}=createDAGNode(obj,childId,'parent',...
                    parentId,valueLeft,valueRight,...
                    force,logic);

                    obj.Parameters(childId).ancestor=obj.Parameters(parentId).ancestor;
                end

                break;

            end


            if~parentExisted

                obj.DAGNode{parentId}=createDAGNode(obj,parentId,'child',...
                childId,valueLeft,valueRight,...
                force,logic);

                obj.Parameters(parentId).ancestor=parentId;

                childInDAG=0;
                for j=1:nOfDAGs
                    if DAGList{j}>0&&~childInDAG
                        childInDAG=searchDAG(obj.DAGNode,DAGList{j},childId);
                    end
                end

                if~childInDAG
                    obj.DAGNode{childId}=createDAGNode(obj,childId,'parent',...
                    parentId,valueLeft,valueRight,...
                    force,logic);

                    obj.Parameters(childId).ancestor=obj.Parameters(parentId).ancestor;
                else
                    obj.DAGNode{childId}=modifyDAGNode(obj.DAGNode{childId},'parent',...
                    parentId,valueLeft,valueRight,...
                    force,logic);



                    if obj.DAGNode{childId}.isDAGRoot
                        DAGList{obj.DAGNode{childId}.isDAGRoot}=-1;
                        idx=obj.DAGNode{childId}.isDAGRoot;
                        obj.DAGNode{childId}.isDAGRoot=0;

                        for m=idx:nOfDAGs-1
                            obj.DAGNode{DAGList{m+1}}.isDAGRoot=m;
                            DAGList{m}=DAGList{m+1};
                        end

                        DAGList{nOfDAGs}=[];
                        nOfDAGs=nOfDAGs-1;

                        if~obj.Parameters(childId).ancestor
                            results.error=4;
                            return;
                        end

                    else
                        obj.Parameters(childId).ancestor=obj.Parameters(parentId).ancestor;
                    end
                end

                nOfDAGs=nOfDAGs+1;
                DAGList{nOfDAGs}=parentId;
                obj.DAGNode{parentId}.isDAGRoot=nOfDAGs;

            end

        end

    end

    obj.totalParamNum=tnOfParam;
    obj.objectives=objectives;
    obj.objName=objName;
    obj.error=0;

end




function newNode=createDAGNode(obj,id,who,id2,valueLeft,valueRight,force,logic)
    obj.seated{id}=1;
    newNode.id=id;

    switch who
    case 'parent'
        parents.id=id2;
        parents.valueLeft=valueLeft;
        parents.valueRight=valueRight;
        parents.force=force;
        parents.invertParent=logic;

        newNode.parents{1}=parents;
        newNode.numOfParents=1;
        newNode.numOfChildren=0;

    case 'child'
        children.id=id2;
        children.valueLeft=valueLeft;
        children.valueRight=valueRight;
        children.force=force;
        children.invertParent=logic;

        newNode.children{1}=children;
        newNode.numOfParents=0;
        newNode.numOfChildren=1;
    end

    newNode.isDAGRoot=0;

    return;
end



function node=modifyDAGNode(nodeIn,who,id,valueLeft,valueRight,force,logic)
    node=nodeIn;

    switch who
    case 'parent'
        nOfP=node.numOfParents+1;
        node.numOfParents=nOfP;

        parents.id=id;
        parents.valueLeft=valueLeft;
        parents.valueRight=valueRight;
        parents.force=force;
        parents.invertParent=logic;
        node.parents{nOfP}=parents;

    case 'child'
        nOfC=node.numOfChildren+1;
        node.numOfChildren=nOfC;
        children.id=id;
        children.valueLeft=valueLeft;
        children.valueRight=valueRight;
        children.force=force;
        children.invertParent=logic;

        node.children{nOfC}=children;
    end

end

function result=searchDAG(DAGNode,idx,id)
    if isempty(idx)
        result=0;
        return;
    end

    node=DAGNode{idx};

    if(node.id==id)
        result=1;
        return;
    end

    numOfC=node.numOfChildren;
    if numOfC<1
        result=0;
        return;
    end

    children=node.children;
    for i=1:numOfC
        result=searchDAG(DAGNode,children{i}.id,id);
        if result
            return;
        end
    end
end


function rUpdateAncestor(obj,DAGNode,childId,parentId)
    obj.Parameters(childId).ancestor=obj.Parameters(parentId).ancestor;

    if DAGNode{childId}.numOfChildren>=1
        for i=1:DAGNode{childId}.numOfChildren
            childIdx=DAGNode{childId}.children{i}.id;
            rUpdateAncestor(obj,DAGNode,childIdx,parentId);
        end
    end
end


function printDAG(DAGNode,idx,file)



    if DAGNode{idx}.numOfParents>0
        pStr=num2str(DAGNode{idx}.parents{1}.id);
        for i=2:DAGNode{idx}.numOfParents
            pStr=[pStr,', '];%#ok<AGROW>
            pStr=[pStr,num2str(DAGNode{idx}.parents{i}.id)];%#ok<AGROW>
        end

        fprintf('     %d (p: %s)\n',DAGNode{idx}.id,pStr);
        fprintf(file,'     %d (p: %s)\n',DAGNode{idx}.id,pStr);
    else
        fprintf('     %d\n',DAGNode{idx}.id);
        fprintf(file,'     %d\n',DAGNode{idx}.id);
    end

    if DAGNode{idx}.numOfChildren>=1
        disp('      v');
        fprintf(file,'      v\n');

        for i=1:DAGNode{idx}.numOfChildren
            childIdx=DAGNode{idx}.children{i}.id;
            printDAG(DAGNode,childIdx,file);
        end
    end
end




