classdef TunableParameterUpdater<matlab.System






%#codegen
    properties(Nontunable)
        TunableParamName='A'
    end

    methods

        function obj=TunableParameterUpdater(varargin)
            coder.allowpcode('plain');

            setProperties(obj,nargin,varargin{:})
        end
    end

    methods(Access=protected)
        function setupImpl(obj)
            if isempty(coder.target)
                if~evalin('base',sprintf('exist(''%s'',''var'')',obj.TunableParamName))||...
                    ~evalin('base',"isa("+obj.TunableParamName+",'Simulink.Parameter')")
                    msgObj=message('soc:utils:NoTunableParameter',obj.TunableParamName);
                    me=MSLException([],msgObj);
                    throw(me);
                end
                baseVar=evalin('base',obj.TunableParamName);
                if~isequal(baseVar.CoderInfo.StorageClass,'ExportedGlobal')
                    msgObj=message('soc:utils:InvalidTunableParameter',obj.TunableParamName);
                    me=MSLException([],msgObj);
                    throw(me);
                end
            end
        end

        function stepImpl(obj,u)
            coder.extrinsic('initializerModelUpdate')
            soc.internal.updateTunableParam(obj.TunableParamName,u);
        end
    end
end
