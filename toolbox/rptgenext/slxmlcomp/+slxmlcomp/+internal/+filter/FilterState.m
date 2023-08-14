classdef FilterState<handle



    properties(Access=public)
        CosmeticParameters logical=true;
        Lines logical=false;
        BlockParameterDefaults logical=true;
        Show logical=false;
        CustomFilters cell={};
    end


    methods(Static)
        function state=allDisabledHide()
            state=slxmlcomp.internal.filter.FilterState;
            state.CosmeticParameters=false;
            state.Lines=false;
            state.BlockParameterDefaults=false;
        end
    end

end

