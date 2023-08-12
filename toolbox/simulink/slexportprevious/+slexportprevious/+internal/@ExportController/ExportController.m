
classdef ExportController < handle

properties ( SetAccess = 'private', GetAccess = 'public' )
sourceModelName
sourceModelFile
targetVersion
end 

properties ( GetAccess = 'public', Dependent )
targetModelFile
targetModelName
isSLX
end 

properties ( Access = 'private' )
targetModelHelper
preprocessHelper
guiHelper
failureFlag
end 

methods ( Access = 'public' )

function obj = ExportController( sourceModelName, targetFile, ver, opts )

R36
sourceModelName;
targetFile{ mustBeTextScalar };
ver;
opts.BreakUserLinks( 1, 1 )logical = false;
opts.BreakToolboxLinks( 1, 1 )logical = false;
opts.AllowPrompt( 1, 1 )logical = false;
end 

if isempty( sourceModelName )

return ;
end 

targetFile = char( targetFile );

if ~ischar( sourceModelName )


sourceModelName = get_param( sourceModelName, 'Name' );
end 
if ~bdIsLoaded( sourceModelName )
DAStudio.error( 'Simulink:ExportPrevious:ModelNotLoaded', sourceModelName );
end 

obj.sourceModelName = sourceModelName;

obj.sourceModelFile = get_param( obj.sourceModelName, 'FileName' );

obj.assertSourceFileExists(  );

if ~isa( ver, 'saveas_version' )
validateattributes( ver, { 'char', 'string' }, { 'scalartext' }, '', 'version' );
end 

obj.targetVersion = saveas_version( ver );

[ ~, ~, ext ] = fileparts( targetFile );
if ~isempty( ext )




ext_format = ext( 2:end  );
if ~strcmp( obj.targetVersion.format, ext_format ) && ismember( ext_format, { 'mdl', 'slx' } )



if isstring( ver )
ver = char( ver );
end 
if ischar( ver ) &&  ...
~contains( upper( ver ), upper( obj.targetVersion.format ) )
v = [ obj.targetVersion.release, '_', ext_format ];
obj.targetVersion = saveas_version( v );
end 
end 
end 

obj.targetModelHelper = slexportprevious.internal.TargetModelHelper( targetFile, obj.targetVersion );

obj.preprocessHelper = obj.createPreprocessHelper( opts.BreakUserLinks, opts.BreakToolboxLinks );
obj.preprocessHelper.errorFcn = @( E )obj.reportAsWarning( E );
obj.preprocessHelper.useGUI = opts.AllowPrompt;

obj.guiHelper = obj.createGuiHelper( opts.AllowPrompt );

obj.failureFlag = false;

end 

function delete( obj )
delete( obj.preprocessHelper );
delete( obj.targetModelHelper );
delete( obj.guiHelper );
end 

function reportAsWarning( obj, E )
obj.failureFlag = true;
obj.guiHelper.reportAsWarning( E );
end 

end 

methods 

function f = get.targetModelFile( obj )
f = obj.targetModelHelper.targetModelFile;
end 

function n = get.targetModelName( obj )
n = obj.targetModelHelper.targetModelName;
end 

function x = get.isSLX( obj )
x = obj.targetVersion.isSLX;
end 

end 

methods ( Access = 'protected' )


function assertSourceFileExists( obj )
exist_result = exist( obj.sourceModelFile, 'file' );
if exist_result ~= 4 && exist_result ~= 2
DAStudio.error( 'Simulink:ExportPrevious:AssertModelFileExists', obj.sourceModelName );
end 
end 

function pph = createPreprocessHelper( obj, breakUserLinks, breakToolboxLinks )

pph = slexportprevious.internal.PreprocessHelper(  ...
obj.targetModelName, obj.targetModelFile,  ...
obj.targetVersion,  ...
breakUserLinks, breakToolboxLinks );
end 

function gh = createGuiHelper( obj, useGUI )

gh = slexportprevious.internal.GUIHelper( obj.sourceModelName,  ...
obj.targetVersion.release, useGUI );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwrK050.p.
% Please follow local copyright laws when handling this file.

