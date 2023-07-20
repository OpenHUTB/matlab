



function E=CreateLoopEMatrix(HInports,HOutPorts)

    import Simulink.Structure.Utils.*

    m=length(HOutPorts);
    n=length(HInports);
    E=sparse(m,n);

    for i=1:m
        HOutPort=HOutPorts(i);
        oPObj=get(HOutPort,'Object');
        HbDst1=getGrActualDst(oPObj);

        parent=get_param(HOutPort,'parent');
        oParent=get_param(parent,'Object');







        if~oParent.isPostCompileVirtual


            HbDst2=oPObj.getBoundedDst;
            HbDst=union(HbDst1,HbDst2(:,1));
        else
            HbDst=HbDst1;
        end

        if isempty(HbDst)
            continue;
        end

        idx=arrayfun(@(HbDst)find(HInports==HbDst),HbDst,'UniformOutput',false);
        idx=idx(~cellfun(@isempty,idx));


        index=[];

        for j=1:length(idx)
            k=cell2mat(idx(j));
            index=[index,k];
        end
        E(i,index)=1;

    end
end