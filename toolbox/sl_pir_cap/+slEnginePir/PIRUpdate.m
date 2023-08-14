

classdef PIRUpdate<Simulink.SLPIR.Creator&Simulink.SLPIR.m2mCreator


    properties(Access='public')
        updatedPIRs;
    end

    methods
        function obj=PIRUpdate(arg)
            ctx=Simulink.SLPIR.Context;
            obj@Simulink.SLPIR.Creator(ctx,arg);
            obj.updatedPIRs=containers.Map('KeyType','char','ValueType','double');
        end

        function invoke(obj,arg)
            try
                mdl=get_param(arg,'Name');
                if~(isempty(getNamedCtx(obj,mdl))||isKey(obj.updatedPIRs,mdl))
                    update(obj,arg);
                    obj.updatedPIRs(mdl)=1;
                end
            catch ME
                for i=1:length(ME.stack)
                    fprintf('%s:%d\n',ME.stack(i).file,ME.stack(i).line);
                end
                fprintf('invoke failed with error %s\n',ME.identifier);
                fprintf('%s\n',ME.message);
            end
        end
    end
end


