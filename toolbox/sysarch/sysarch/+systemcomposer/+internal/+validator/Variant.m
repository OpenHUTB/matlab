classdef Variant < systemcomposer.internal.validator.BaseComponentBlockType


    methods

        function this = Variant( handleOrPath )
            arguments
                handleOrPath
            end
            this.handleOrPath = handleOrPath;
        end

        function [ canConvert, allowed ] = canAddVariant( this )
            canConvert = true;
            allowed = true;
        end
    end
end
