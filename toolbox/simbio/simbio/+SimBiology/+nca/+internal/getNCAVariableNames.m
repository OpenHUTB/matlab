function ncaVariableNames = getNCAVariableNames( dosingCount, singleOrMultipleResponse )
R36
dosingCount( 1, 1 )string
singleOrMultipleResponse( 1, 1 )string = "singleResponse"
end 

switch dosingCount
case "singleDosing"
ncaVariableNames = [ "Group";"doseSchedule";"administrationRoute";"Lambda_Z";"R2";"adjusted_R2"; ...
"Num_points";"AUC_0_last";"Tlast";"C_max";"C_max_Dose";"T_max";"MRT";"T_half";"AUC_infinity"; ...
"AUC_infinity_dose";"AUC_extrap_percent";"CL";"DM";"V_z";"responseName";"AUMC_0_last";"AUMC"; ...
"AUMC_extrap_percent";"V_ss";"C_0" ];
case "multipleDosing"
ncaVariableNames = [ "Group";"doseSchedule";"administrationRoute";"Lambda_Z";"R2";"adjusted_R2";"Num_points";"AUC_0_last";"Tlast"; ...
"C_max";"C_max_Dose";"T_max";"MRT";"T_half";"AUC_infinity";"AUC_infinity_dose";"AUC_extrap_percent";"CL";"DM";"V_z";"responseName"; ...
"T_min";"C_min";"C_avg";"PTF_Percent";"Accumulation_Index";"TAU";"AUC_TAU";"AUMC_TAU";"V_ss";"C_0" ];
otherwise 
error( 'Invalid option for dosingCount.' );
end 

switch singleOrMultipleResponse
case "singleResponse"

ncaVariableNames = ncaVariableNames( ncaVariableNames ~= "responseName" );
ncaVariableNames = ncaVariableNames.replace( "Group", "ID" );
case "multipleResponse"
otherwise 
error( 'Invalid option for singleOrMultipleResponse' );
end 

ncaVariableNames = cellstr( ncaVariableNames );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmptohSjc.p.
% Please follow local copyright laws when handling this file.

