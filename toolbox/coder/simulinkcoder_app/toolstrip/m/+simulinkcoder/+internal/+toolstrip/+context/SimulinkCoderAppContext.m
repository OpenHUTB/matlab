classdef SimulinkCoderAppContext<coder.internal.toolstrip.CoderAppContext





    methods
        function obj=SimulinkCoderAppContext(app,cbinfo)
            assert(strcmp(app.name,'simulinkCoderApp'));
            obj@coder.internal.toolstrip.CoderAppContext(app,cbinfo);
        end

        function guardAppName=getGuardAppName(~)
            guardAppName='SimulinkCoder';
        end


        function updateTypeChain(obj)
            if slfeature('SDPToolStrip')>0
                mdl=obj.studio.App.getActiveEditor.blockDiagramHandle;
            else
                mdl=obj.studio.App.blockDiagramHandle;
            end

            type=coder.internal.toolstrip.util.getOutputType(mdl);
            switch type
            case 'grt'
                obj.OutputTypeContext='genericCCodeContext';
            case 'grt_cpp'
                obj.OutputTypeContext='genericCPlusCPlusCodeContext';
            case 'slrt'
                obj.OutputTypeContext='genericSimulinkRealTimeContext';
            case 'sldrt'
                obj.OutputTypeContext='genericDesktopRealTimeContext';
            case 'realtime'
                obj.OutputTypeContext='genericTargetHardwareContext';
            case 'rtwsfcn'
                obj.OutputTypeContext='genericSFunctionRtwContext';
            case 'rsim'
                obj.OutputTypeContext='genericRapidSimuliationRSimContext';
            case 'systemverilog_dpi_grt'
                obj.OutputTypeContext='genericSystemVerilogContext';
            case 'tlmgenerator_grt'
                obj.OutputTypeContext='genericSystemTLMContext';
            case 'asap2'
                obj.OutputTypeContext='genericASAPContext';
            otherwise
                obj.OutputTypeContext='customCodeContext';
            end

            updateTypeChain@coder.internal.toolstrip.CoderAppContext(obj);
        end

        function checkoutLicense(~)




            licenses={'Matlab_Coder','Real-Time_Workshop'};
            for i=1:length(licenses)
                builtin('_license_checkout',licenses{i},'quiet');
            end
        end
    end
end
