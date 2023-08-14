classdef(CaseInsensitiveProperties,TruncatedProperties)...
    rfbbequiv<rfbase.rfbase


















    properties

        MaxLength=16;
    end
    methods
        function set.MaxLength(obj,value)
            if~isequal(obj.MaxLength,value)

                obj.MaxLength=setpositive(obj,value,'MaxLength',...
                false,false,false);
            end
        end
    end

    properties

        FracBW=0;
    end

    properties

        ModelDelay=0;
    end
    methods
        function set.ModelDelay(obj,value)
            if~isequal(obj.ModelDelay,value)

                obj.ModelDelay=setpositive(obj,value,'ModelDelay',...
                true,false,false);
            end
        end
    end

    properties

        Fc=1e9;
    end
    methods
        function set.Fc(obj,value)
            if~isequal(obj.Fc,value)

                obj.Fc=setpositive(obj,value,'Fc',false,false,false);
            end
        end
    end

    properties

        Ts=1e-7;
    end
    methods
        function set.Ts(obj,value)
            if~isequal(obj.Ts,value)

                obj.Ts=setpositive(obj,value,'Ts',false,false,false);
            end
        end
    end

    properties(Hidden)

        ImpulseResp=1;
    end

    properties(Hidden)

        Delay=0;
    end
    methods
        function set.Delay(obj,value)
            if~isequal(obj.Delay,value)

                obj.Delay=setpositive(obj,value,'Delay',...
                true,false,false);
            end
        end
    end

    properties(Hidden)

        Seed=67987;
    end
    methods
        function set.Seed(obj,value)
            if~isequal(obj.Seed,value)

                obj.Seed=setpositive(obj,value,'Seed',false,false,false);
            end
        end
    end

    properties(Hidden)

        NoiseFlag='off';
    end
    methods
        function set.NoiseFlag(obj,value)
            if~isequal(obj.NoiseFlag,value)

                obj.NoiseFlag=setnoiseflag(obj,value,'NoiseFlag');
            end
        end
    end

    methods
        freq=frequency(h)
        [resp,delay]=response(h,transf)
        out=setnoiseflag(h,out,prop)
    end

    methods
        function checkproperty(~)
        end
    end
    methods(Abstract)
        analyze(h,block)
    end

end