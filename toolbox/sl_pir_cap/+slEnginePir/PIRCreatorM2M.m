


classdef PIRCreatorM2M<slEnginePir.PIRCreator&Simulink.SLPIR.m2mCreator


    properties(Access='public')
        mdls;
        sucflag;
    end

    methods
        function obj=PIRCreatorM2M(arg,arg1)
            obj@slEnginePir.PIRCreator(arg);
            obj.mdls=arg1;
            obj.sucflag=false;
        end

        function wireFromGotoComps(obj,mdlname)
            pirctx=getNamedCtx(obj,mdlname);
            if~isempty(pirctx)
                hN=pirctx.getTopNetwork;
                slEnginePir.elaborateFromGotoRtwcg_m2m(hN);
                pirctx.wireFromGotoComps(true,false);
            end
        end

        function flag=isSkippedParam(~,objdp,parametername)
            flag=false;
            if~isfield(objdp,parametername)
                flag=true;
                return;
            end



            cond1=~isempty(nonzeros(strcmp('read-only',objdp.(parametername).Attributes)));
            cond2=~isempty(nonzeros(strcmp('write-only',objdp.(parametername).Attributes)));
            cond3=~isempty(nonzeros(strcmp('never-save',objdp.(parametername).Attributes)));
            if cond1||cond2||cond3
                flag=true;
            end
        end

        function invoke(obj,arg)
            try
                mdl=get_param(arg,'Name');
                if~hasNamedCtx(obj,mdl)&&(~isempty(find(strcmp(obj.mdls,mdl),1))||strcmp(get_param(arg,'ModelReferenceTargetType'),'NONE'))

                    if strcmp(get_param(arg,'ModelReferenceTargetType'),'NONE')
                        mdlHandle=get_param(obj.mdls{1},'Handle');
                    else
                        mdlHandle=get_param(mdl,'Handle');
                    end

                    invoke@Simulink.SLPIR.Creator(obj,mdlHandle);
                    wireFromGotoComps(obj,mdl);

                    if strcmp(get_param(arg,'ModelReferenceTargetType'),'NONE')
                        obj.sucflag=true;
                    end
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






