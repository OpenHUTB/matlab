function [ outOfDate, msg ] = updateCS( cs, action )







outOfDate = false;
msg = '';

stfOK = true;
targetComponent = getComponent( cs, 'any', 'Target' );

switch ( action )
case 'CheckIfWrongTargetClass'
doUpdate = false;
quickCheck = true;
checkObsolete = false;
case 'CheckIfAnythingOutOfDate'
doUpdate = false;
quickCheck = false;
checkObsolete = false;
case 'UpdateIfWrongTargetClass'
doUpdate = true;
quickCheck = true;
checkObsolete = false;
case 'UpdateIfAnythingOutOfDate'
doUpdate = true;
quickCheck = false;
checkObsolete = false;
case 'UpdateObsoleteTarget'
doUpdate = true;
quickCheck = false;
checkObsolete = true;
otherwise 
assert( false, 'Invalid input arguments' )
end 

stf = get_param( cs, 'SystemTargetFile' );
[ ~, fid, prevfpos ] = rtwprivate( 'getstf', [  ], stf );
if ( fid ==  - 1 )
DAStudio.error( 'Simulink:utility:SystemTargetFileNotFound', stf );
end 


[ className, replaceTLC ] = rtwprivate( 'tfile_classname', fid );
if isempty( className )
className = 'Simulink.STFCustomTargetCC';
end 

rtwprivate( 'closestf', fid, prevfpos );



if checkObsolete
if isempty( replaceTLC )
return ;
else 
MSLDiagnostic( 'RTW:tlc:ReplaceObsoleteTLCFileWarningSave', stf, replaceTLC ).reportAsWarning;
stf = replaceTLC;
outOfDate = true;
end 
elseif quickCheck





stfOK = isequal( class( targetComponent ), className );


if stfOK && ~isa( targetComponent, 'Simulink.STFCustomTargetCC' )
return ;
end 
outOfDate = true;


if ( doUpdate == false )
return ;
end 
end 




csCopy = copy( cs );
rtwCopy = getComponent( csCopy, 'Code Generation' );






if checkObsolete

settings = [  ];
else 
settings.TemplateMakefile = get_param( csCopy, 'TemplateMakefile' );
settings.MakeCommand = get_param( csCopy, 'MakeCommand' );
settings.Description = get_param( rtwCopy, 'Description' );
end 

csCopy.switchTarget( stf, settings );

rtwCopy = getComponent( csCopy, 'Code Generation' );


if checkObsolete
settings.TemplateMakefile = get_param( csCopy, 'TemplateMakefile' );
settings.MakeCommand = get_param( csCopy, 'MakeCommand' );
settings.Description = get_param( rtwCopy, 'Description' );
end 












if stfOK
csCopy.assignFrom( cs, true, 'CombineDisabledList' );
csCopy.assignFrom( cs, true, 'CombineDisabledList' );
else 
csCopy.assignFrom( cs, true, 'IgnoreDisabledList' );
csCopy.assignFrom( cs, true, 'IgnoreDisabledList' );
end 

if checkObsolete
diff = {  };
else 
[ iseq, diff ] = isequal( cs, csCopy );


if iseq && strcmp( className, 'Simulink.STFCustomTargetCC' )

if ~isequal( get_param( cs, 'EnumDefinition' ), get_param( csCopy, 'EnumDefinition' ) )
iseq = false;
diff{ end  + 1 } = 'Type definition';
end 
end 

outOfDate = ~iseq;
end 



if ( outOfDate && doUpdate )
newDiff = {  };
for i = 1:length( diff )



if ( ( strcmp( diff{ i }, 'ERTFirstTimeCompliant' ) ~= 1 ) &&  ...
( strcmp( diff{ i }, 'ParMdlRefBuildCompliant' ) ~= 1 ) )
newDiff{ end  + 1 } = diff{ i };%#ok
end 
end 
diff = newDiff;
if ~isempty( diff )
details = '';
for i = 1:length( diff )
details = [ details, sprintf( '\n' ), sprintf( '\t' ), diff{ i } ];%#ok
end 
msg = DAStudio.message( 'Simulink:utility:UpdateConfigSetTargetComponent', details );
end 

if ~checkObsolete
settings.TemplateMakefile = get_param( csCopy, 'TemplateMakefile' );
settings.MakeCommand = get_param( csCopy, 'MakeCommand' );
settings.Description = get_param( rtwCopy, 'Description' );
end 
model = cs.getModel;
if ~isempty( model )
dirty = get_param( model, 'Dirty' );
end 
cs.switchTarget( stf, settings );
if stfOK
cs.assignFrom( csCopy, true, 'CombineDisabledList' );
else 
cs.assignFrom( csCopy, true, 'IgnoreDisabledList' );
end 



cs.setRTWOptions( cs.ExtraOptions );



if checkObsolete
cs.setProp( 'SystemTargetFile', stf );
cs.getComponent( 'Code Generation' ).setProp( 'Description', settings.Description );
cs.setProp( 'TemplateMakefile', settings.TemplateMakefile );
cs.setProp( 'MakeCommand', settings.MakeCommand );
end 



if isempty( diff ) && ~isempty( model )
set_param( model, 'Dirty', dirty );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpiFE5HD.p.
% Please follow local copyright laws when handling this file.

