function[M,existsM,ismatrixM,issparseM]=iterchkBasic(index,args)





    M=[];
    existsM=false;
    ismatrixM=false;
    issparseM=false;
    if length(args)>=index
        M=args{index};
        existsM=~isempty(M);
        ismatrixM=existsM&&isfloat(M);
        issparseM=ismatrixM&&issparse(M);
    end
end