

classdef CloneDetectionCreator


    properties
        creator;
        m2m;
    end

    methods

        function obj=CloneDetectionCreator(hook)
            ctx=Simulink.SLPIR.Context;
            ctx.sourceApi='GraphicalContextSrc';
            ctx.descendModelRef=false;







            obj.creator=Simulink.SLPIR.Creator(ctx,uint32(hook));
            obj.m2m=Simulink.SLPIR.m2mCreator(ctx);
        end


        function invoke(~,~)
        end

        function createGraphicalPir(obj,mdlList)
            try

                p=pir;
                for i=length(mdlList):-1:1

                    C=textscan(mdlList{i},'%s','Delimiter','/');
                    modelName=C{1}{1};

                    if~bdIsLoaded(modelName)
                        continue;
                    end
                    p.destroyPirCtx(modelName);
                end


                for i=length(mdlList):-1:1

                    C=textscan(mdlList{i},'%s','Delimiter','/');
                    modelName=C{1}{1};

                    if~bdIsLoaded(modelName)
                        continue;
                    end

                    mdlHandle=get_param(mdlList{i},'Handle');
                    invoke(obj.creator,mdlHandle);
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


