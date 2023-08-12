function paramValue = pmsl_modelparameter( hModel, paramName, defaultValue,  ...
doWarn, defaultValueStr )











narginchk( 3, 5 );

if nargin == 3
doWarn = false;
elseif nargin == 4
narginchk( 5, 5 );
end 

hModel = pmsl_modelhandle( hModel );

modelParameters = get_param( hModel, 'ObjectParameters' );

if isfield( modelParameters, paramName )
paramValue = get_param( hModel, paramName );
else 
paramValue = defaultValue;
if doWarn
pm_warning( 'physmod:pm_sli:pmsl_modelparameter:ParameterNotFound',  ...
getfullname( hModel ), paramName, defaultValueStr );
end 
end 


end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpRFKu3P.p.
% Please follow local copyright laws when handling this file.

