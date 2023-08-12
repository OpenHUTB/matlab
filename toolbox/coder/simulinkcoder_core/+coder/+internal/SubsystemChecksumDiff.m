classdef SubsystemChecksumDiff < handle




properties ( Access = private )

csDetails1
csDetails2
ss1BlockName
ss2BlockName
ss1Path
ss2Path
csType

takenVariableNames
path2VariableName


end 
methods 

function this = SubsystemChecksumDiff( csDetails1, csDetails2, ss1Path, ss2Path, csType )

this.ss1BlockName = get_param( ss1Path, 'Name' );
this.ss2BlockName = get_param( ss2Path, 'Name' );
this.ss1Path = ss1Path;
this.ss2Path = ss2Path;
this.csDetails1 = this.prepStructure( csDetails1, this.ss1BlockName );
this.csDetails2 = this.prepStructure( csDetails2, this.ss2BlockName );
this.csType = csType;
this.takenVariableNames = {  };
this.path2VariableName = containers.Map;
this.validateInputs(  );
end 

function compare( this )
this.createVariablesForComparison(  );

coder.internal.invokeComparison( this.constructGetterFunction( this.ss1BlockName, this.ss1Path ),  ...
this.constructGetterFunction( this.ss2BlockName, this.ss2Path ),  ...
this.ss1BlockName,  ...
this.ss2BlockName,  ...
this.constructCleanupFunction( this.ss1BlockName, this.ss1Path ),  ...
this.constructCleanupFunction( this.ss2BlockName, this.ss2Path ) );

end 
end 
methods ( Access = 'protected' )

function validateInputs( this )
assert( ~strcmp( this.ss1Path, this.ss2Path ), 'Cannot diff subsystem with itself' );

this.validateInputHelper( this.ss1Path );
this.validateInputHelper( this.ss2Path );

end 

function retStructArray = prepStructure( this, inStructArray, blockName )
retStructArray = this.transformBlockPaths( inStructArray, blockName );

end 

function varName = getUniqueVariableName( this, blockName, pathname )


if ( this.path2VariableName.isKey( pathname ) )
varName = this.path2VariableName( pathname );
return ;
end 
varName = [ blockName, this.csType, '_data' ];
varName = varName( find( ~isspace( varName ) ) );





if ismember( this.takenVariableNames, varName )
varName = [ varName, '_1' ];
end 



this.takenVariableNames{ end  + 1 } = varName;
this.path2VariableName( pathname ) = varName;

end 

function getterFunction = constructGetterFunction( this, blockName, pathname )
getterFunction = [ 'evalin(''base'', ''', this.getUniqueVariableName( blockName, pathname ), ''')' ];

end 

function cleanupFunction = constructCleanupFunction( this, blockName, pathname )
cleanupFunction = [ 'evalin(''base'',''clear'', ''', this.getUniqueVariableName( blockName, pathname ), ''')' ];

end 

function createVariablesForComparison( this )

this.createVariablesForComparisonHelper( this.csDetails1, this.ss1BlockName, this.ss1Path );
this.createVariablesForComparisonHelper( this.csDetails2, this.ss2BlockName, this.ss2Path );

end 

function createVariablesForComparisonHelper( this, csDetails, blockName, pathName )

varName = this.getUniqueVariableName( blockName, pathName );
assignin( 'base', varName, csDetails );

end 

end 

methods ( Static )










function S = transformBlockPaths( S, blockName )
delim = '/';
for csItem = 1:length( S )
thisHandle = S( csItem ).Handle;
elements = split( thisHandle, delim );

elemBlockNameReplace = strrep( elements, blockName, '__Subsystem__' );


idx = find( strcmp( elemBlockNameReplace, '__Subsystem__' ) );
elemBlockNameReplace = elemBlockNameReplace( idx:end  );

thisHandle = strjoin( elemBlockNameReplace, delim );
S( csItem ).Handle = thisHandle;
end 
end 

function validateInputHelper( pathName )
assert( strcmp( get_param( pathName, 'BlockType' ), 'SubSystem' ), 'Cannot diff non-subsystem blocks' );
assert( strcmp( get_param( pathName, 'TreatAsAtomicUnit' ), 'on' ), 'TreatAsAtomicUnit parameter should be on' );
end 


end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp4ws2If.p.
% Please follow local copyright laws when handling this file.

