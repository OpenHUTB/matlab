classdef CommandStrProvider<handle






    properties(Access=protected)
        CommandPackage='Simulink.typeeditor.actions';
    end

    methods(Access=public)
        function commandStr=getCommandStr(this,commandType)

            assert(any(strcmp(commandType,{'cut','copy','deleteEntry','paste'})),...
            'unexpected command type')

            commandStr=[this.CommandPackage,'.',commandType];
        end
    end
end
