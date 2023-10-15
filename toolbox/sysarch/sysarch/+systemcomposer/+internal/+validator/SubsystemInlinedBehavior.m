classdef SubsystemInlinedBehavior < systemcomposer.internal.validator.BaseComponentBlockType


    methods

        function this = SubsystemInlinedBehavior( handleOrPath )
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

        function [ canConvert, allowed ] = canConjugatePort( ~ )
            canConvert = true;
            allowed = true;
        end
    end
end
