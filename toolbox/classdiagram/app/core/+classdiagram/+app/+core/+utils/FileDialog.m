classdef FileDialog < handle



properties ( Access = { ?classdiagram.app.core.ClassDiagramApp,  ...
?classdiagram.app.core.Exporter,  ...
?classdiagram.app.core.Importer,  ...
 } )
mockFileDialog;
end 

methods 
function set.mockFileDialog( obj, value )
R36
obj( 1, 1 )classdiagram.app.core.utils.FileDialog;
value( 1, 1 )classDiagramTest.MockFileDialog;
end 
obj.mockFileDialog = value;
end 

function value = get.mockFileDialog( obj )
value = obj.mockFileDialog;
end 
end 

methods ( Access = { ?classdiagram.app.core.ClassDiagramApp,  ...
?classdiagram.app.core.Exporter,  ...
?classdiagram.app.core.Importer,  ...
?classDiagramTest.ClassDiagramTestCase,  ...
?classDiagramTest.SaveLoadModelTester } )
function [ filename, pathname ] = uigetfile( obj, filter, title, defaultName )
if isempty( obj.mockFileDialog )
[ filename, pathname ] = uigetfile( filter, title, defaultName );
else 
[ filename, pathname ] = obj.mockFileDialog.exec( filter, title, defaultName );
end 
end 

function [ filename, pathname ] = uiputfile( obj, filter, title, defaultName )
if isempty( obj.mockFileDialog )
[ filename, pathname ] = uiputfile( filter, title, defaultName );
else 
[ filename, pathname ] = obj.mockFileDialog.exec( filter, title, defaultName );
end 
end 

function cwd = pwd( obj )
if isempty( obj.mockFileDialog )
cwd = pwd;
else 
cwd = obj.mockFileDialog.pwd(  );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpUHiw82.p.
% Please follow local copyright laws when handling this file.

