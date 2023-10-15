function [ variantBlockHdl ] = convertComponentsToVariants( block )

arguments
    block( 1, 1 )double
end

try
    variantBlockHdl =  - 1;
    if ishandle( block )
        compToVariantConverter = systemcomposer.internal.arch.internal.ComponentToVariantConverter( block );
        variantBlockHdl = compToVariantConverter.convert(  );
    end
catch ME
    rethrow( ME );
end
end
