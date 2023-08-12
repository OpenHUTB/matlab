function singleObj = getInstance( isExternal, checkLicense )




mlock;

if nargin < 2
checkLicense = false;
end 

if nargin < 1
isExternal = false;
end 

if checkLicense
if sldvshareprivate( 'util_is_analyzing_for_fixpt_tool' )
invalid = false;
else 
invalid = builtin( '_license_checkout', 'Simulink_Design_Verifier', 'quiet' );
end 

if invalid
error( message( 'Sldv:BLOCKREPLACEMENTS:getInstance:SLDVNotLicensed' ) );
end 
end 



persistent localStaticObj;
if isempty( localStaticObj ) || ~isvalid( localStaticObj )
localStaticObj = Sldv.xform.BlkReplacer;
localStaticObj.constructBuiltinRepRulesTree;
elseif isExternal





localStaticObj.constructBuiltinRepRulesTree;
end 
singleObj = localStaticObj;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp9_mVlZ.p.
% Please follow local copyright laws when handling this file.

