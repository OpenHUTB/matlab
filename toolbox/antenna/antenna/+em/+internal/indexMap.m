function[pIdxOut,eIdxOut]=indexMap(pIdxIn,eIdxIn,pi,pf)


    pIdxOut=zeros(1,max(size(pIdxIn)));
    eIdxOut=zeros(2,max(size(eIdxIn)));
    hard_points=pi(:,pIdxIn);
    for i=1:max(size(hard_points))
        new_index=find(pf(1,:)==hard_points(1,i)&...
        pf(2,:)==hard_points(2,i)&...
        pf(3,:)==hard_points(3,i));
        pIdxOut(i)=new_index;
        e_logical_idx=(eIdxIn==new_index);
        eIdxOut(e_logical_idx)=new_index;
    end
end

