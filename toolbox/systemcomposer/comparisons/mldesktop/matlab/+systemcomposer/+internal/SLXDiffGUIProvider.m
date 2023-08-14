classdef SLXDiffGUIProvider<comparisons.internal.DiffGUIProvider




    methods
        function bool=canHandle(obj,first,second,options)
            import comparisons.internal.dispatcherutil.isTypeCompatible
            bool=isTypeCompatible(options.Type,obj.getType())...
            &&hasModelExtension(first.Path)...
            &&hasModelExtension(second.Path)...
            &&(...
            (isSystemComposerModel(first.Path)&&isSystemComposerModel(second.Path))...
            ||...
            (isAUTOSARModel(first.Path)&&isAUTOSARModel(second.Path)));
        end

        function app=handle(~,first,second,options)
            options=comparisons.internal.dispatcherutil.extractTwoWayOptions(options);
            app=systemcomposer.internal.diff(first,second,options);
        end

        function priority=getPriority(~,~,~,~)
            priority=20;
        end

        function type=getType(~)
            type="ZC";
        end


        function str=getDisplayType(~)
            str="System Composer Model Comparison";
        end
    end

end

function bool=isSystemComposerModel(file)
    try
        mdlInfo=Simulink.MDLInfo(file);
        bool=isequal(mdlInfo.Interface.SimulinkSubDomainType,'Architecture')||...
        isequal(mdlInfo.Interface.SimulinkSubDomainType,'SoftwareArchitecture');
    catch
        bool=false;
    end
end

function bool=isAUTOSARModel(file)
    try
        mdlInfo=Simulink.MDLInfo(file);
        bool=isequal(mdlInfo.Interface.SimulinkSubDomainType,'AUTOSARArchitecture');
    catch
        bool=false;
    end
end


function bool=hasModelExtension(file)
    [~,~,ext]=fileparts(file);
    bool=".slx"==ext;
end
