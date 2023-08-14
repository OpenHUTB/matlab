

classdef PIRCreatorGenMdl<Simulink.SLPIR.Creator



    methods
        function obj=PIRCreatorGenMdl(arg)
            ctx=Simulink.SLPIR.Context;






            obj@Simulink.SLPIR.Creator(ctx,arg);

        end

        function dumpDot(obj,mdlname,fname)
            if hasNamedCtx(obj,mdlname)
                fprintf('Sending DOT output to %s\n',fname);
                pirctx=getNamedCtx(obj,mdlname);
                pirctx.dumpDot(fname);
            end
        end

        function wireFromGotoComps(obj,mdlname)
            pirctx=getNamedCtx(obj,mdlname);
            hN=pirctx.getTopNetwork;
            slEnginePir.elaborateFromGotoRtwcg(hN);
            pirctx.wireFromGotoComps(true,false);
        end

        function eliminateDeadCode(obj,mdlname)
            killRedundantBufferComps(obj);
            pirctx=getNamedCtx(obj,mdlname);
            hdlcoder.TransformDriver.deadCodeElimination(pirctx);
        end

        function hasCtx=hasNamedCtx(obj,mdl)
            hasCtx=~isempty(getNamedCtx(obj,mdl));
        end

        function invoke(obj,arg)
            try
                mdl=get_param(arg,'Name');
                if~hasNamedCtx(obj,mdl)
                    invoke@Simulink.SLPIR.Creator(obj,arg);
                    dumpDot(obj,mdl,[mdl,'a.dot']);
                    wireFromGotoComps(obj,mdl);
                    dumpDot(obj,mdl,[mdl,'b.dot']);
                    eliminateDeadCode(obj,mdl);
                    generateModel(obj);
                    save_system(['gen_',mdl]);
                end
                dumpDot(obj,mdl,[mdl,'c.dot']);
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


