classdef EventConnector < handle

    properties ( Access = public )
        ClientContent diagram.markup.ClientContent
        DisplayedLabel string = ""
        Label string = ""
        MarkupConnector
        SourcePath( 1, : )char
        TargetPath( 1, : )char
    end


    methods ( Hidden = true )
        function obj = EventConnector( clientContent,  ...
                sourcePath,  ...
                targetPath )
            arguments
                clientContent( 1, 1 )diagram.markup.ClientContent
                sourcePath( 1, : )char
                targetPath( 1, : )char
            end

            obj.ClientContent = clientContent;
            obj.SourcePath = sourcePath;
            obj.TargetPath = targetPath;
        end
    end

    methods
        function addLabel( this, label )
            if this.Label == ""
                this.Label = label;
                this.DisplayedLabel = label;
            elseif label < this.Label
                this.Label = label;
                this.DisplayedLabel = label + ", ...";
            elseif label > this.Label
                this.DisplayedLabel = this.Label + ", ...";
            end
        end

        function connector = create( this )
            [ sourceObject, targetObject ] = this.resolvePathsToObjects(  );

            cc = this.ClientContent;
            connector = cc.createConnector( sourceObject, targetObject );
            connector.label = this.DisplayedLabel;
            connector.sourceEndpointShape = diagram.markup.EndpointShape.Nothing;
            connector.targetEndpointShape = diagram.markup.EndpointShape.Arrow;
            connector.sourceAttachment = diagram.markup.AttachmentPoint.TopRight;
            connector.targetAttachment = diagram.markup.AttachmentPoint.TopLeft;
            this.MarkupConnector = connector;
        end
    end

    methods ( Access = private )
        function [ sourceObject, targetObject ] = resolvePathsToObjects( this )
            sourceParent = get_param( this.SourcePath, 'Parent' );
            targetParent = get_param( this.TargetPath, 'Parent' );
            if strcmp( this.TargetPath, sourceParent )
                sourceObject = diagram.resolver.resolve( this.SourcePath );
                targetObject = sourceObject.getParent(  );
            elseif strcmp( this.SourcePath, targetParent )
                targetObject = diagram.resolver.resolve( this.TargetPath );
                sourceObject = targetObject.getParent(  );
            else
                sourceObject = diagram.resolver.resolve( this.SourcePath );
                targetObject = diagram.resolver.resolve( this.TargetPath );
            end
        end
    end
end

