classdef SessionData<handle

    properties(Access=public)
dataInterface
serializer
    end

    properties(GetAccess=public)
        enabled=true;
name
    end

    methods(Access=public)

        function this=SessionData(name,session,dataInterface)
            import mls.internal.session.*;
            this.name=name;
            this.dataInterface=dataInterface;
            this.serializer=SessionDataSerializer(session,...
            [this.name,'.mat'],['safemv_',this.name,'.sh']);
        end

        function enable(this)
            this.enabled=true;
        end

        function disable(this)
            this.enabled=false;
        end

        function load(this)
            if this.enabled
                [data,loaded]=this.serializer.load();
                if(loaded)
                    this.dataInterface.set(data);
                end
            end
        end

        function save(this)
            if this.enabled
                data=this.dataInterface.get();
                this.serializer.save(data);
            end
        end

        function saveasync(this)
            if this.enabled
                data=this.dataInterface.get();
                this.serializer.saveasync(data);
            end
        end

        function reset(this)
            if this.enabled
                this.dataInterface.reset();
            end
        end

        function clear(this)
            if this.enabled
                this.serializer.clear();
            end
        end

    end

end

