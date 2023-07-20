function cleanBusName=hCleanDTOPrefix(h,busName)%#ok





    cleanBusName=regexprep(busName,'^dto(Dbl|Sgl|Scl)(Flt|Fxp)?_','');




