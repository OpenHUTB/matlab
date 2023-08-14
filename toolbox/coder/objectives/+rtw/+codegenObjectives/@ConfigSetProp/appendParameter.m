function obj=appendParameter(obj,cs)



    if nargin<2
        return;
    end

    if isempty(obj.Parameters)
        disp('The method construction needs to be run first.');
        return;
    end

    totalProp=cs.getProp;
    params=obj.Parameters;
    paramNames=cell(1,length(params));
    [paramNames{:}]=params.name;

    paramDiff=setdiff(totalProp,paramNames);

    if isempty(paramDiff)
        return;
    end

    hash=obj.ParamHash;
    dAGNode=obj.DAGNode;
    seated=obj.seated;

    emptyDAGNode.id=-1;
    emptyDAGNode.numOfParents=0;
    emptyDAGNode.numOfChildren=-1;
    emptyDAGNode.isDAGRoot=0;

    paramTemplate.name='';
    paramTemplate.id=0;
    paramTemplate.default='';
    paramTemplate.defaultComplementary='';
    paramTemplate.reversed='N';
    paramTemplate.inDAG=0;
    paramTemplate.ancestor=0;

    csdm=configset.internal.getConfigSetAdapter(cs,true);
    len=length(params);
    curIdx=len+1;
    for i=1:length(paramDiff)
        prop=paramDiff{i};

        param=paramTemplate;
        param.name=prop;
        param.id=curIdx;

        paramDM=csdm.getParamData(prop);
        param.DAGOrder=paramDM.Order;

        params(curIdx)=param;
        hash.put(prop,curIdx);

        dAGNode{curIdx}=emptyDAGNode;

        seated{curIdx}=0;

        curIdx=curIdx+1;
    end

    obj.ParamHash=hash;
    obj.Parameters=params;
    obj.totalParamNum=length(params);

    obj.DAGNode=dAGNode;
    obj.seated=seated;

end

