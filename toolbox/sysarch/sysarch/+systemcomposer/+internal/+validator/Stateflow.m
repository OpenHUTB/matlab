classdef Stateflow < systemcomposer.internal.validator.BaseComponentBlockType


    methods

        function this = Stateflow( handleOrPath )
            arguments
                handleOrPath
            end
            this.handleOrPath = handleOrPath;
        end

        function [ canConvert, allowed ] = canAddVariant( this )
            canConvert = true;
            allowed = true;
        end

        function [ canConvert, allowed ] = canInline( this )
            canConvert = true;
            allowed = true;
        end
    end
end
% Decoded using De-pcode utility v1.2 from file /tmp/tmpqLPRQX.p.
% Please follow local copyright laws when handling this file.

