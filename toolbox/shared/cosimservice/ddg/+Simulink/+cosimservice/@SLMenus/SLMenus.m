classdef SLMenus





    methods(Static)
        schema=insertSignalExtrapolationContextMenu(cbinfo);

        dlgStruct=showCouplingElementParameterDialog(cbinfo,blk,port);

    end
end
