classdef EmbeddedCoderAppContext<coder.internal.toolstrip.CoderAppContext





    methods
        function obj=EmbeddedCoderAppContext(app,cbinfo)
            assert(strcmp(app.name,'embeddedCoderApp'));
            obj@coder.internal.toolstrip.CoderAppContext(app,cbinfo);
            prefFileName=simulinkcoder.internal.toolstrip.util.getPrefFileName();
            if exist(prefFileName,'file')==2
                load(prefFileName,'ShowCalAttributes');
                obj.ShowCalAttributes=ShowCalAttributes;
            else
                obj.ShowCalAttributes=true;
            end
        end

        function guardAppName=getGuardAppName(~)
            guardAppName='EmbeddedCoder';
        end

        function updateTypeChain(obj)
            if slfeature('SDPToolStrip')>0
                mdl=obj.studio.App.getActiveEditor.blockDiagramHandle;
            else
                mdl=obj.studio.App.blockDiagramHandle;
            end
            type=coder.internal.toolstrip.util.getOutputType(mdl);
            switch type
            case 'ert'
                obj.OutputTypeContext='embeddedCCodeContext';
            case 'cpp'
                obj.OutputTypeContext='embeddedCPlusPlusCodeContext';
            case 'ert_shrlib'
                obj.OutputTypeContext='embeddedSharedLibraryCodeContext';
            case 'sldrtert'
                obj.OutputTypeContext='embeddedDesktopRealTimeContext';
            case 'systemverilog_dpi_ert'
                obj.OutputTypeContext='embeddedSystemVerilogContext';
            case 'tlmgenerator_ert'
                obj.OutputTypeContext='embeddedSystemTLMContext';
            otherwise
                obj.OutputTypeContext='customCodeContext';
            end
            obj.ASAP2CDFGenContext=[];


            if slfeature('SDPToolStrip')>0
                obj.SDPContext='SDP';
                obj.PlatformContext=coder.internal.toolstrip.util.getPlatformContext(mdl);
                obj.DeployContext=coder.internal.toolstrip.util.getDeploymentTypeContext(mdl);
                obj.CodeForContext=coder.internal.toolstrip.util.getCodeForContext(obj.studio);

                if slfeature('FCPlatform')
                    obj.FPContext='FCPlatform';
                end
            end


            obj.CodeInterfaceContext=simulinkcoder.internal.toolstrip.util.getCodeInterfaceContext(mdl);


            obj.CalContext='embeddedCoderCalContext';
            updateTypeChain@coder.internal.toolstrip.CoderAppContext(obj);
        end

        function checkoutLicense(~)




            licenses={'Matlab_Coder','Real-Time_Workshop','RTW_Embedded_Coder'};
            for i=1:length(licenses)
                builtin('_license_checkout',licenses{i},'quiet');
            end
        end
    end
end


