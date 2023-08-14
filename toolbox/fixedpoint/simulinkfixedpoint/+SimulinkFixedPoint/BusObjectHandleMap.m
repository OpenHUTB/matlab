classdef BusObjectHandleMap<handle






    properties(SetAccess=private,GetAccess=private)

map
    end

    methods
        function obj=BusObjectHandleMap()


            obj.map=Simulink.sdi.Map(char('a'),?handle);
        end
        function insert(this,key,value)

            this.map.insert(key,value);
        end
        function y=getCount(this)

            y=this.map.getCount;
        end
        function y=isKey(this,key)

            y=this.map.isKey(key);
        end
        function y=getDataByIndex(this,index)

            y=this.map.getDataByIndex(index);
        end
        function y=getKeyByIndex(this,index)

            y=this.map.getKeyByIndex(index);
        end
        function y=getDataByKey(this,key)

            if this.map.isKey(key)
                y=this.map.getDataByKey(key);
            else
                this.throwMissingKeyError(key)
            end
        end

        function deleteDataByKey(this,key)

            this.map.deleteDataByKey(key);
        end
        function Clear(this)

            this.map.Clear();
        end

    end

    methods(Access=private)
        function throwMissingKeyError(~,key)

            if strcmp(key,'pixelcontrol')
                DAStudio.error('SimulinkFixedPoint:autoscaling:UndefinedPixelControlBus');
            else
                DAStudio.error('SimulinkFixedPoint:autoscaling:UnknownBusObjectName',key);
            end
        end
    end

end


