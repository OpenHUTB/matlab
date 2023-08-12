function res = sfAutoscaleCache( modelName, cmd )



persistent CovSfAutoscaleOn;
if strcmpi( cmd, 'set' )

if ~strcmpi( CovSfAutoscaleOn, 'forceOff' )
if sfprivate( 'is_sf_fixpt_autoscale', modelName )
CovSfAutoscaleOn = 'on';
else 
CovSfAutoscaleOn = 'off';
end 
end 
elseif strcmpi( cmd, 'get' )
if isempty( CovSfAutoscaleOn )
CovSfAutoscaleOn = 'off';
end 
elseif strcmpi( cmd, 'forceOff' )
CovSfAutoscaleOn = 'forceOff';
elseif strcmpi( cmd, 'reset' )
CovSfAutoscaleOn = [  ];
end 

res = strcmpi( CovSfAutoscaleOn, 'on' );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp0kiFr6.p.
% Please follow local copyright laws when handling this file.

