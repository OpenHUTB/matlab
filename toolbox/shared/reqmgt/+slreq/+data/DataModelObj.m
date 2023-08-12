classdef DataModelObj < handle




properties ( Access = protected )
modelObject;

dasObject;
end 

methods ( Access = ?slreq.data.ReqData )
function modelObj = getModelObj( this )
modelObj = this.modelObject;
end 
end 


methods ( Access = protected )

function notifyObservers( this, changedInfo )
if nargin < 2
changedInfo.propName = 'Unset';
changedInfo.oldValue = 'N/A';
changedInfo.newValue = 'N/A';
end 

reqData = slreq.data.ReqData.getInstance(  );

isRevision = strcmp( changedInfo.propName, 'revision' );





if ~isRevision && ( isa( this, 'slreq.data.Link' ) || isa( this, 'slreq.data.LinkSet' ) )
reqData.notify( 'LinkDataChange', slreq.data.LinkDataChangeEvent( 'Set Prop Update', this, changedInfo ) );
elseif isa( this, 'slreq.data.Requirement' ) || isa( this, 'slreq.data.RequirementSet' )
reqData.notify( 'ReqDataChange', slreq.data.ReqDataChangeEvent( 'Set Prop Update', this, changedInfo ) );
end 
end 
end 

methods 

function this = DataModelObj(  )
end 


function delete( this )
this.modelObject = [  ];
end 


function clearModelObj( this )
this.modelObject = [  ];
end 

function id = getUuid( this )

id = this.modelObject.UUID;
end 

function clearDasObject( this, dasObj )
R36
this
dasObj = [  ];
end 
if isempty( dasObj ) || ~isempty( this.dasObject ) && dasObj == this.dasObject
this.dasObject = [  ];
end 
end 

function dasObject = getDasObject( this )
dasObject = this.dasObject;
end 


function setDasObject( this, dasObject )
this.dasObject = dasObject;
end 

end 

methods 
function obj = visit( obj, func )
persistent level;
if isempty( level )
level = 0;
end 
func( obj, level );
level = level + 1;
try 
children = obj.children;
for i = 1:length( children )

children( i ).visit( func );
end 
catch 
end 
level = level - 1;
end 
end 

methods ( Static )

function ok = checkLicense( arg )


persistent allowed prefix
if isempty( prefix )
prefix = length( 'allow ' );
allowed = '';
end 
ok = false;
if nargin > 0



if strcmp( arg, 'clear' )
allowed = '';
return ;
elseif strncmp( arg, 'allow ', prefix )
allowed = strrep( arg( prefix + 1:end  ), filesep, '/' );
return ;
elseif strcmp( strrep( arg, filesep, '/' ), allowed )
ok = true;
return ;
end 
end 

ok = ~builtin( '_license_checkout', 'Simulink_Requirements', 'quiet' );
end 

end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpI4TeJP.p.
% Please follow local copyright laws when handling this file.

