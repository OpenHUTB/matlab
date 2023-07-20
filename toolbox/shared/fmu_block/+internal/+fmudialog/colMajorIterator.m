classdef colMajorIterator<handle






    properties
dims
rowIdx
        idx;
        overflow;
    end

    methods
        function obj=colMajorIterator(dimension)
            obj.dims=double(dimension);
            obj.idx=ones(1,length(dimension));

            obj.rowIdx=1;
            obj.overflow=false;
        end

        function obj=increment(obj)
            if obj.overflow||isequal(obj.dims,obj.idx)
                obj.overflow=true;
                obj.rowIdx=-1;
                obj.idx=zeros(1,length(obj.dims))-1;
                return;
            end

            j=1;
            while 1
                obj.idx(j)=obj.idx(j)+1;
                if(j==length(obj.dims)||obj.idx(j)<=obj.dims(j))
                    break;
                end
                obj.idx(j)=1;
                j=j+1;
            end
            obj.rowIdx=0;
            acc=1;
            lIdx=obj.idx-1;
            for i=length(obj.dims):-1:1
                obj.rowIdx=obj.rowIdx+lIdx(i)*acc;
                acc=acc*obj.dims(i);
            end
            obj.rowIdx=obj.rowIdx+1;
            return;
        end
    end
end

