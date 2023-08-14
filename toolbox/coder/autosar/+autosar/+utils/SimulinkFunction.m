classdef SimulinkFunction<handle




    methods(Static,Access=public)

        function fcnHandles=getSimulinkFunctionsForCaller(block)
            if ischar(block)||isstring(block)
                callerH=get_param(block,'Handle');
            else
                callerH=block;
            end


            fcnHandles=Simulink.AutosarTarget.ModelMapping.lookupSimulinkFunctions(callerH);
        end

        function isSubSystemServerRunnable=isGlobalSimulinkFunction(block)

            if ischar(block)||isstring(block)
                functionH=get_param(block,'Handle');
            else
                functionH=block;
            end
            isSubSystemServerRunnable=Simulink.AutosarTarget.ModelMapping.isSubSystemServerRunnable(functionH);
        end

        function callerHandles=getGlobalFunctionCallerHandles(mdlName)

            mapping=autosar.api.Utils.modelMapping(mdlName);
            activeIndicies=[mapping.FunctionCallers.IsActive];
            activeCallers=mapping.FunctionCallers(activeIndicies);
            handles=get_param({activeCallers.Block},'Handle');
            callerHandles=[handles{:}];
        end

        function sfcnHandles=getSFunctionHandles(sys)



            rt=sfroot;
            m=rt.find('-isa','Simulink.BlockDiagram','-and','Name',sys);
            sfcns=m.find('-isa','Simulink.SFunction');

            sfcnHandles=zeros(1,length(sfcns));
            for sfcnIdx=1:length(sfcns)
                sfcnHandles(sfcnIdx)=sfcns(sfcnIdx).handle;
            end

        end

        function str=removeTrailingSFunctionStr(str)

            str=strrep(str,'/ SFunction ','');
        end

    end

end
