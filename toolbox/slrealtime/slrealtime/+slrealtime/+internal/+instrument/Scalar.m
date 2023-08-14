classdef Scalar<handle






    properties
hScalar
        acquireGroupIndex int32
        acquireSignalIndex int32
acquireSignalArrayIndex
PropertyName
Callback
    end

    methods
        function obj=Scalar(~,hScalar,index,options)

            obj.hScalar=hScalar;

            obj.acquireGroupIndex=index.acquiregroupindex;
            obj.acquireSignalIndex=index.signalindex;
            obj.acquireSignalArrayIndex=index.arrayindex;

            obj.PropertyName=options.PropertyName;
            obj.Callback=options.Callback;

            assert(length(obj.acquireGroupIndex)==1);
        end

        function update(obj,time,data)
            if isempty(data)
                return;
            end

            if~isempty(obj.acquireSignalArrayIndex)
                if numel(obj.acquireSignalArrayIndex)==1

                    data=data(:,obj.acquireSignalArrayIndex);
                else

                    data=data(obj.acquireSignalArrayIndex(1),obj.acquireSignalArrayIndex(2),:);
                end
            end



            if~isempty(obj.Callback)
                data=obj.Callback(time,data);
            end




            if length(time)==1
                d=data;
            else
                if ndims(data)<=2

                    d=data(end,:);
                else

                    d=data(:,:,end);
                end
            end




            if iscell(d)
                d=d{1};
            end

            set(obj.hScalar,obj.PropertyName,d);
        end

        function clearData(obj)



            try

                v=zeros(size(obj.hScalar.(obj.PropertyName)));
                set(obj.hScalar,obj.PropertyName,v);
            catch
                try

                    set(obj.hScalar,obj.PropertyName,'');
                catch

                    set(obj.hScalar,obj.PropertyName,[]);
                end
            end
        end
    end
end

