



function filterRules = makeCodeProverFilterRules( model, pscpResults, cvds, fromUI )

R36
model( 1, : )string
pscpResults( 1, : )string
cvds cell = {  }
fromUI logical = false
end 


model = char( model );
pscpResults = char( pscpResults );


model2SimMode = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
if isempty( cvds )


model2SimMode( model ) = { 'xil' };
else 

for ii = 1:numel( cvds )
cvd = cvds{ ii };
if isa( cvd, 'cvdata' )
allCvd = { cvd };
else 
allCvd = cvd.getAll(  );
end 
for jj = 1:numel( allCvd )

if ~SlCov.CovMode.isXIL( allCvd{ jj }.simMode ) ||  ...
allCvd{ jj }.isSharedUtility ||  ...
allCvd{ jj }.isCustomCode
continue 
end 


modelName = allCvd{ jj }.modelinfo.analyzedModel;
currMode = lower( char( allCvd{ jj }.simMode ) );
if model2SimMode.isKey( modelName )
simModes = model2SimMode( modelName );
else 
simModes = [  ];
end 
model2SimMode( modelName ) = [ simModes, { currMode } ];
end 
end 
end 


checksum2Rule = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
modelNames = model2SimMode.keys(  );
for ii = 1:numel( modelNames )
try 



simModes = model2SimMode( modelNames{ ii } );
[ ~, filterRule ] = slcoverage.Filter.makeCodeProverBasedFilter(  ...
modelNames{ ii }, pscpResults,  ...
'SimulationMode', simModes{ 1 } );
catch Me

msg = message( 'Slvnv:simcoverage:cvresultsexplorer:MakeCPFilterMessageDlgText',  ...
modelNames{ ii }, Me.message );
if fromUI
msgTitle = getString( message( 'Slvnv:simcoverage:cvresultsexplorer:MakeCPFilterMessageDlgTitle' ) );
warndlg( getString( msg ), msgTitle, 'modal' );
else 
warning( msg );
end 
continue 
end 

for jj = 1:numel( filterRule )


key = sprintf( '%s-%s-%s-%d-%d',  ...
filterRule( jj ).Selector.FileName,  ...
filterRule( jj ).Selector.FunctionName,  ...
filterRule( jj ).Selector.Expr,  ...
filterRule( jj ).Selector.ExprIndex,  ...
filterRule( jj ).Selector.CVMetricType );


checksum2Rule( key ) = filterRule( jj );
end 
end 


filterRules = checksum2Rule.values(  );
filterRules = [ filterRules{ : } ];

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpIwPgPo.p.
% Please follow local copyright laws when handling this file.

