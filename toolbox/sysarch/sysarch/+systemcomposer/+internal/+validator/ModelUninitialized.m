classdef ModelUninitialized < systemcomposer.internal.validator.BaseComponentBlockType


    methods

        function this = ModelUninitialized( handleOrPath )
            arguments
                handleOrPath
            end
            this.handleOrPath = handleOrPath;
        end

        function [ canConvert, allowed ] = canLinkToModel( this )
            canConvert = true;
            allowed = true;
        end
    end
end

