function [ variantBlockHdl ] = convertComponentsToVariants( block )




R36
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmplQ5mAb.p.
% Please follow local copyright laws when handling this file.

