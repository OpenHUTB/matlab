classdef Component < systemcomposer.internal.validator.BaseComponentBlockType

    properties
        hasChildren = false;
        hasPhysicalPorts = false;
    end

    methods

        function this = Component( handleOrPath )
            arguments
                handleOrPath
            end
            this.handleOrPath = handleOrPath;
            handle = get_param( handleOrPath, 'handle' );
            comp = systemcomposer.utils.getArchitecturePeer( handle );
            this.hasChildren = ~isempty( comp ) && ~isempty( comp.getArchitecture(  ).getComponents(  ) );

            prts = systemcomposer.architecture.model.design.Port.empty;
            if ~isempty( comp )
                prts = comp.getPorts;
            end

            for idx = 1:numel( prts )
                if prts( idx ).getPortAction == systemcomposer.architecture.model.core.PortAction.PHYSICAL
                    this.hasPhysicalPorts = true;
                    break ;
                end
            end
        end

        function [ canConvert, allowed ] = canAddVariant( ~ )
            canConvert = true;
            allowed = true;
        end

        function [ canConvert, allowed ] = canCreateSimulinkBehavior( this )
            canConvert = ~this.hasChildren;
            allowed = canConvert;
        end

        function [ canConvert, allowed ] = canCreateStateflowBehavior( this )
            canConvert = ~this.hasChildren && ~this.hasPhysicalPorts;
            if license( 'test', 'Stateflow' ) && dig.isProductInstalled( 'Stateflow' )
                allowed = ~this.hasPhysicalPorts;
            else
                allowed = false;
            end
        end

        function [ canConvert, allowed ] = canLinkToModel( ~ )
            canConvert = true;
            allowed = true;
        end

        function [ canConvert, allowed ] = canSaveAsArchitecture( ~ )
            canConvert = true;
            allowed = true;
        end

        function [ canConvert, allowed ] = canSaveAsSoftwareArchitecture( this )
            canConvert = ~this.hasPhysicalPorts;
            allowed = ~this.hasPhysicalPorts;
        end

        function [ canConvert, allowed ] = canInline( ~ )
            canConvert = false;
            allowed = false;
        end

        function [ canConvert, allowed ] = canConjugatePort( ~ )
            canConvert = true;
            allowed = true;
        end
    end
end

