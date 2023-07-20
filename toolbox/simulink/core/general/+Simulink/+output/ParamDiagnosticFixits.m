classdef(Hidden)ParamDiagnosticFixits<handle











    methods(Static,Access=public)

        function actionsPerformed=fix(action,varargin)

            import Simulink.output.ParamDiagnosticFixits;

            if slfeature('RichNumericDiagnostics')<1
                msgId='ParamDiagnosticFixits:FeatureOffNoAction';
                warning(msgId,'No Action performed when feature control is OFF.')
                return;
            end

            switch action
            case 'SetParamToNone'
                callback=@ParamDiagnosticFixits.setModelParamToNone;
            case 'OpenParamQuantizeManager'
                callback=@ParamDiagnosticFixits.openParamQuantizeManager;
            otherwise
                assert(false,'Unknown fix it action: %s',action);
            end
            actionsPerformed=callback(varargin{:});
        end

    end

    methods(Static,Access=private)

        function actionsPerformed=setModelParamToNone(varargin)



            modelName=bdroot(varargin{1});

            actionsPerformed=configset.internal.fixIt(modelName,varargin{2},'none');
        end

        function actionsPerformed=openParamQuantizeManager(varargin)
            parameterquantizer.ParameterQuantizerUI.launch(varargin{1},varargin{2});
            actionsPerformed='OpenParamQuantizeManager';
        end
    end
end
