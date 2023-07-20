classdef ModelInfoNoSPKG<soc.ui.ModelInfo




    properties
    end

    methods
        function this=ModelInfoNoSPKG(varargin)
            this@soc.ui.ModelInfo(varargin{:});

        end

        function screen=getPreviousScreenID(~)
            screen='soc.ui.HSPInfo';
        end
    end


end