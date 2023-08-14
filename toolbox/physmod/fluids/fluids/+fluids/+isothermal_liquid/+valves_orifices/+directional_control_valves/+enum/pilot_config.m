classdef pilot_config<int32





    enumeration
        connected(1)
        disconnected(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('connected')='Rigidly connected pilot spool and poppet';
            map('disconnected')='Disconnected pilot spool and poppet';
        end
    end
end