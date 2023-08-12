classdef DataUsage < matlab.mixin.CustomDisplay

properties 
DataSource( 1, 1 )lutdesigner.data.source.DataSource = lutdesigner.data.source.UnknownDataSource
UsedAs( 1, : )char{ mustBeTextScalar( UsedAs ) } = ''
end 

methods 
function this = DataUsage( dataSource, usedAs )
R36
dataSource = lutdesigner.data.source.UnknownDataSource
usedAs = ""
end 
this.DataSource = dataSource;
this.UsedAs = usedAs;
end 

function s = toStruct( this )
if isempty( this )
s = repmat( struct( 'DataSource', struct, 'UsedAs', '' ), size( this ) );
else 
s = arrayfun( @( x )scalarToStructImpl( x ), this );
end 
end 

function str = getDisplayString( this )
if isempty( this )
str = "";
return ;
end 
str = arrayfun( @( x )scalarGetDisplayStringImpl( x ), this );
end 
end 

methods ( Access = private )
function s = scalarToStructImpl( this )
s = struct(  ...
'DataSource', struct(  ...
'SourceType', this.DataSource.SourceType,  ...
'Source', this.DataSource.Source,  ...
'Name', this.DataSource.Name ),  ...
'UsedAs', this.UsedAs );
end 

function str = scalarGetDisplayStringImpl( this )
str = sprintf( "%s - %s:%s/%s",  ...
this.UsedAs,  ...
this.DataSource.SourceType, this.DataSource.Source, this.DataSource.Name ...
 );
end 
end 

methods ( Access = protected )
function footer = getFooter( this )
footer = sprintf( '%s\n', strjoin( getDisplayString( this ), '\n' ) );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp6c0KQg.p.
% Please follow local copyright laws when handling this file.

