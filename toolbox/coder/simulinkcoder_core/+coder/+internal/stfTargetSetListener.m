function stfTargetSetListener( hObj, hProps )





if ~isempty( hProps )





if isempty( hObj.PreSetListener )
hObj.PreSetListener = handle.listener( hObj, hProps, 'PropertyPreSet',  ...
@preSetFcn_Prop );

end 

getFunctions = hObj.GetFunction;
if ~isempty( getFunctions )
for i = 1:length( getFunctions )
prop = findprop( hObj, getFunctions( i ).prop );
if ~isempty( prop )
try 
prop.GetFunction = eval( getFunctions( i ).fcn );
catch 
disp( [ 'Get function "', getFunctions( i ).fcn, '" cannot be set',  ...
' to property "', prop.Name, '"' ] );
end 
end 
end 
end 

setFunctions = hObj.SetFunction;
if ~isempty( setFunctions )
for i = 1:length( setFunctions )
prop = findprop( hObj, setFunctions( i ).prop );
if ~isempty( prop )
try 
prop.SetFunction = eval( setFunctions( i ).fcn );
catch 
disp( [ 'Set function "', setFunctions( i ).fcn, '" cannot be set',  ...
' to property "', prop.Name, '"' ] );
end 
end 
end 
end 

end 




function preSetFcn_Prop( hProp, eventData )

hObj = eventData.AffectedObject;
if hObj.isActive
if ~isequal( get( hObj, hProp.Name ), eventData.NewVal )
hMdl = hObj.getModel;
set_param( hMdl, 'dirty', 'on' );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpUtiDwG.p.
% Please follow local copyright laws when handling this file.

