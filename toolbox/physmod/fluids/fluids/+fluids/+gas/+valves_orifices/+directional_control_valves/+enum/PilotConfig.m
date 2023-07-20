classdef PilotConfig<int32





    enumeration
        Connected(1)
        Disconnected(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Connected')='Rigidly connected pilot spool and poppet';
            map('Disconnected')='Disconnected pilot spool and poppet';
        end
    end
end