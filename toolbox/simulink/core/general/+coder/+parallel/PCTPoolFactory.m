classdef PCTPoolFactory<coder.parallel.interfaces.IPCTPoolFactory




    methods



        function[poolStarted,pool]=createPCTPool(~)


            try




                pctPool=gcp();
                poolStarted=~isempty(pctPool)&&pctPool.Connected;
                if poolStarted
                    pool=coder.parallel.Pool(pctPool);
                else
                    pool=[];
                end

            catch origEx

                errId='Simulink:slbuild:poolNotOpen';
                msg=DAStudio.message(errId);
                ex=MException(errId,msg);

                ex.addCause(origEx);
                throw(ex);
            end
        end
    end
end


