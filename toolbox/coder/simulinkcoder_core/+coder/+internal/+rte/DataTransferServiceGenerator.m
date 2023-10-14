classdef DataTransferServiceGenerator < handle

    properties ( Access = private )
        RTEImplementationFilename( 1, : )char
        RTEOutFolder( 1, : )char
        RTEUtil = coder.internal.rte.util;
        Builders = {  };
    end

    methods
        function this = DataTransferServiceGenerator( implementationFilename, outFolder )
            arguments
                implementationFilename( 1, : )char
                outFolder( 1, : )char
            end
            this.RTEImplementationFilename = implementationFilename;
            this.RTEOutFolder = outFolder;
        end

        function generateRTEImplementation( this, codeDescriptor )
            platformServices = codeDescriptor.getServices(  );
            if isempty( platformServices )
                return ;
            end
            dataTransferService = platformServices.getServiceInterface(  ...
                coder.descriptor.Services.DataTransfer );
            if isempty( dataTransferService )
                return ;
            end

            model = codeDescriptor.ModelName;
            this.RTEUtil.displayProgressInfo( model,  ...
                'source',  ...
                this.RTEImplementationFilename );


            sourceFileName = fullfile( this.RTEOutFolder, this.RTEImplementationFilename );
            writer = rtw.connectivity.CodeWriter.create( 'filename', sourceFileName );
            for i = 1:dataTransferService.DataTransferElements.Size
                elem = dataTransferService.DataTransferElements( i );
                this.Builders{ end  + 1 } =  ...
                    coder.internal.rte.builder.AccessMethodBuilder.makeBuilder( elem, codeDescriptor );
            end

            includes = this.getIncludes( platformServices );
            for i = 1:length( includes )
                writer.wLine( [ '#include "', includes{ i }, '"' ] );
            end

            this.writeInternalData( writer );
            this.writeFunctionDefinition( writer );
            if coder.internal.rte.util.needPreInitDataTransForXIL( platformServices )
                this.writeInitalization( writer );
            end
        end
    end

    methods ( Access = private )

        function includes = getIncludes( ~, platformServices )
            includes{ 1 } = platformServices.getServicesHeaderFileName(  );
            includes{ end  + 1 } = 'string.h';
        end


        function writeInternalData( this, writer )
            for i = 1:length( this.Builders )
                writer.wLine( this.Builders{ i }.DataBuilder.emit );
            end
        end


        function writeFunctionDefinition( this, writer )
            writer.wComment( 'data transfer services' );
            for i = 1:length( this.Builders )
                for j = 1:length( this.Builders{ i }.DefBuilders )
                    this.Builders{ i }.DefBuilders{ j }.writeToFile( writer );
                end
            end
        end


        function writeInitalization( this, writer )
            proto = coder.internal.rte.util.getPreInitDataTransXILPrototype;
            writer.wLine( proto );
            writer.wLine( '{' );
            for i = 1:length( this.Builders )
                writer.wLine( this.Builders{ i }.DataBuilder.getInitialization );
            end
            writer.wLine( '}' );
        end
    end

end



