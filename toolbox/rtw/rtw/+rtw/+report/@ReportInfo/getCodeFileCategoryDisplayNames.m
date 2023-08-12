function out = getCodeFileCategoryDisplayNames(  )




persistent groupDispNames
if isempty( groupDispNames )
groupDispNames = { 
{ 
'Main'
'Model'
'Subsystem'
'Data'
'Utility'
'Shared'
'Reused'
'Interface'
'Static'
'Legacy'
'Other'
'RTE'
'ARA'
'SILPIL'
 }
{ 
message( 'RTW:report:FileGroup_Main' ).getString
message( 'RTW:report:FileGroup_Model' ).getString
message( 'RTW:report:FileGroup_Subsys' ).getString
message( 'RTW:report:FileGroup_Data' ).getString
message( 'RTW:report:FileGroup_Utility' ).getString
message( 'RTW:report:FileGroup_Shared' ).getString
message( 'RTW:report:FileGroup_Reused' ).getString
message( 'RTW:report:FileGroup_Interface' ).getString
message( 'RTW:report:FileGroup_Static' ).getString
message( 'RTW:report:FileGroup_Legacy' ).getString
message( 'RTW:report:FileGroup_Other' ).getString
message( 'RTW:report:FileGroup_RTE' ).getString
message( 'RTW:report:FileGroup_ARA' ).getString
message( 'RTW:report:FileGroup_SILPIL' ).getString
 }
 };
end 

out = groupDispNames;



% Decoded using De-pcode utility v1.2 from file /tmp/tmpLF8apb.p.
% Please follow local copyright laws when handling this file.

