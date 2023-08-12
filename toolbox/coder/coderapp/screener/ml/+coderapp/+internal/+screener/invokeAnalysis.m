



function [ resultView, mfzModel ] = invokeAnalysis( files, aScreenerOptions, opts )
R36
files string{ mustBeNonempty( files ) }
aScreenerOptions( 1, 1 )coder.internal.ScreenerOptions
opts.MfzModel( 1, 1 )mf.zero.Model
end 

if isfield( opts, 'MfzModel' )
mfzModel = opts.MfzModel;
else 
nargoutchk( 2, 2 );
mfzModel = mf.zero.Model(  );
end 

input = coderapp.internal.screener.ScreenerInput( mfzModel );
input.Target = aScreenerOptions.Target;
input.Options = coderapp.internal.screener.ScreenerOptions( mfzModel );
input.Options.TraverseMathWorksCode = aScreenerOptions.AnalyzeMathWorksCode;
for filter = reshape( aScreenerOptions.MessageFilters, 1, [  ] )
input.Options.MessageFilters.add( filter )
end 
input.Options.UseMetadata = aScreenerOptions.UseMetadata;
input.Options.UseEMLWhich = aScreenerOptions.UseEMLWhich;

for file = reshape( files, 1, [  ] )
input.EntryPointFiles.add( file );
end 

resultView = coderapp.internal.screener.analyze( input );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpx4vjsi.p.
% Please follow local copyright laws when handling this file.

