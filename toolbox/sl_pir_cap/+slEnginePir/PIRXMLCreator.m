

classdef PIRXMLCreator<Simulink.SLPIR.Creator



    properties
fname
    end
    methods
        function obj=PIRXMLCreator(pluginEvent,filename)
            ctx=Simulink.SLPIR.Context;



            ctx.descendModelRef=false;

            obj@Simulink.SLPIR.Creator(ctx,pluginEvent);
            obj.fname=filename;
        end

        function hasCtx=hasNamedCtx(obj,mdl)
            hasCtx=~isempty(getNamedCtx(obj,mdl));
        end

        function invoke(obj,arg)
            try
                mdl=get_param(arg,'Name');
                if~hasNamedCtx(obj,mdl)
                    invoke@Simulink.SLPIR.Creator(obj,arg);
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


