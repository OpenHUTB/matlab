classdef SimModeSelectorFactory<handle




    methods


        function result=makeSelector(~,choice,obj)
            switch(lower(choice))
            case 'onlyaccel'
                result=Simulink.ModelReference.internal.GraphAnalysis.SelectOnlyAccel(obj);
            case 'onlynormal'
                result=Simulink.ModelReference.internal.GraphAnalysis.SelectOnlyNormal(obj);
            case 'anyaccel'
                result=Simulink.ModelReference.internal.GraphAnalysis.SelectAnyAccel(obj);
            case 'anynormal'
                result=Simulink.ModelReference.internal.GraphAnalysis.SelectAnyNormal(obj);
            case 'all'
                result=Simulink.ModelReference.internal.GraphAnalysis.SelectAll(obj);
            otherwise
                DAStudio.error('Simulink:modelReference:ModelRefGraphAnalyzerInvalidSimModeChoice');
            end
        end
    end
end