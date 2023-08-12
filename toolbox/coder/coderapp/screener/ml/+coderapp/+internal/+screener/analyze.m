function result = analyze( aScreenerInput )
R36
aScreenerInput( 1, 1 )coderapp.internal.screener.ScreenerInput
end 


import coderapp.internal.screener.Screener;
analysisResult = Screener.analyze( aScreenerInput );
result = Screener.buildResultView( analysisResult );
postProcessResult( result );
end 

function postProcessResult( result )
for fcn = result.Result.Functions.toArray
result.QualifiedFileName.add( makeQualifiedFileName( fcn.Path ) );
end 
end 

function result = makeQualifiedFileName( aFilePath )
qualifiedName = coderapp.internal.util.getQualifiedFileName( aFilePath );
result = coderapp.internal.screener.QualifiedFileName;
result.Path = aFilePath;
result.Name = qualifiedName;
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpS2sHtF.p.
% Please follow local copyright laws when handling this file.

