classdef rowMajorIterator<handle






    properties
dims
colIdx
        idx;
        overflow;
    end

    methods
        function obj=rowMajorIterator(dimension)
            obj.dims=double(dimension);
            obj.idx=ones(1,length(dimension));

            obj.colIdx=1;
            obj.overflow=false;
        end

        function obj=increment(obj)
            if obj.overflow||isequal(obj.dims,obj.idx)
                obj.overflow=true;
                obj.colIdx=-1;
                obj.idx=zeros(1,length(obj.dims))-1;
                return;
            end

            j=length(obj.dims);
            while 1
                obj.idx(j)=obj.idx(j)+1;
                if(j==1||obj.idx(j)<=obj.dims(j))
                    break;
                end
                obj.idx(j)=1;
                j=j-1;
            end
            obj.colIdx=0;
            acc=1;
            lIdx=obj.idx-1;
            for i=1:length(obj.dims)
                obj.colIdx=obj.colIdx+lIdx(i)*acc;
                acc=acc*obj.dims(i);
            end
            obj.colIdx=obj.colIdx+1;
            return;
        end
    end
end

