classdef RuleSet < handle





properties ( Access = 'public' )
mRules = {  };
end 

methods ( Access = 'public' )
function obj = RuleSet( rs )
if nargin == 1
if isa( rs, 'slexportprevious.RuleSet' )
obj = rs;
else 
if isfield( rs, 'Rules' )
rs = rs.Rules;
end 
assert( iscellstr( rs ) || isstring( rs ), 'Rules must be a cell array of strings' );
obj.mRules = rs( : );
end 
else 
obj.mRules = {  };
end 
end 


function validateRules( obj, ensure_unique )
R36
obj;
ensure_unique( 1, 1 )logical = true;
end 
rules = obj.mRules;
if ensure_unique
[ tmprules, ruleind ] = unique( rules );
if numel( tmprules ) ~= numel( rules )
duprules = setdiff( 1:numel( rules ), ruleind );
for i = 1:numel( duprules )

error( 'slexportprevious:build:DuplicateRule', 'Duplicate rule found: %s\n', rules{ duprules( i ) } );
end 
end 
end 
for i = 1:length( rules )
try 
Simulink.loadsave.ExportRuleProcessor.validateRule( rules{ i } );
catch E
error( E.identifier,  ...
[ 'Cannot process the following export rule:\n\n' ...
, '    %s \n\n' ...
, 'due to syntax violation: \n\n%s \n\n' ],  ...
rules{ i }, E.message );
end 
end 
end 


function writeRulesFile( obj, filename )

obj.validateRules;
rules = obj.mRules;

fid = fopen( filename, 'w', 'native', 'UTF-8' );
if ( fid ==  - 1 )

error( 'slexportprevious:build:WriteError',  ...
'Cannot open file %s for writing', filename );
end 
closefile = onCleanup( @(  )fclose( fid ) );

fprintf( 'Generating %s\n', filename );

for i = 1:length( rules )
fprintf( fid, '%s\n', rules{ i } );
end 

delete( closefile );
end 

function appendRule( obj, r )
if iscell( r )
obj.mRules = [ obj.mRules;r( : ) ];
elseif ischar( r )
obj.mRules{ end  + 1, 1 } = r;
else 
error( 'slexportprevious:build:RuleError',  ...
'Unexpected input type: %s', class( r ) );
end 
end 

function appendRules( obj, varargin )
for i = 1:numel( varargin )
obj.appendRule( varargin{ i } );
end 
end 

function appendSet( obj, s )
if isa( s, 'slexportprevious.RuleSet' )
obj.mRules = [ obj.mRules;s.mRules ];
elseif ~isempty( s )
error( 'slexportprevious:build:RuleError',  ...
'Unexpected input type: %s', class( s ) );
end 
end 

function r = getRules( obj )
r = obj.mRules;
end 

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_yKapp.p.
% Please follow local copyright laws when handling this file.

