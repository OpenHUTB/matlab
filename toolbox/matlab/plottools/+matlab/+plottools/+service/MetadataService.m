classdef MetadataService<handle





    properties(Constant)
        PROP_KEY="FDT_Accessor";
    end

    properties
        AccessorFactory;
    end

    methods(Static,Access='public')
        function obj=getInstance()
            persistent serviceInstance;
            mlock;
            if isempty(serviceInstance)
                serviceInstance=matlab.plottools.service.MetadataService;
            end
            obj=serviceInstance;
        end
    end

    methods(Access='private')
        function obj=MetadataService()
            obj.AccessorFactory=matlab.plottools.service.AccessorFactory.getInstance();
            obj.AccessorFactory.rebuildMap();
        end

        function key=getKeyFromObject(this,hObj)

            key=class(hObj);

            if isprop(hObj,this.PROP_KEY)

                key=get(hObj,this.PROP_KEY);
            elseif isa(hObj,'matlab.graphics.chart.Chart')


                key='matlab.graphics.chart.Chart';
            else


            end
        end
    end

    methods(Access='public')
        function accessor=getMetaDataAccessor(this,hObj)
            key=this.getKeyFromObject(hObj);

            accessor=this.AccessorFactory.getAccessorForObject(key,hObj);
        end

        function result=isUnifiedChart(this,allAxes)


            result=false;

            if all(isprop(allAxes,this.PROP_KEY))
                propCell=get(allAxes,this.PROP_KEY);

                compValue=propCell{1};



                result=all(cellfun(@(x)strcmpi(x,compValue),propCell));
            end
        end
    end
end

