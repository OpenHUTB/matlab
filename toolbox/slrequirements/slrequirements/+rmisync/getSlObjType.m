function result=getSlObjType(objH,isAnnotation)





    if nargin<2
        isAnnotation=false(size(objH));
    end

    types=rmisl.cellGetParam(objH,'Type');
    isBd=strcmp(types,'block_diagram');

    result(isBd)={'Block Diagram'};
    if sum(~isBd)==0

    else
        blkIsSFChart=slprivate('is_stateflow_based_block',objH(~isBd));
        isSFChart=false(length(objH),1);
        isSFChart(~isBd)=blkIsSFChart;
        isGetBlockTypeSupported=~isBd&~isSFChart&~isAnnotation;
        result(isGetBlockTypeSupported)=rmisl.cellGetParam(objH(isGetBlockTypeSupported),'BlockType');
        result(isSFChart)={'Stateflow Subsystem'};
        result(isAnnotation)={'Annotation'};
    end
end
