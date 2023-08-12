function emcOpenReport( reportFile, title )
R36
reportFile{ mustBeTextScalar( reportFile ) }
title{ mustBeTextScalar( title ) } = ''
end 



[ ~, ~, extension ] = fileparts( reportFile );

switch lower( extension )
case '.mldatx'
codergui.internal.showReportViewer( reportFile );
case '.html'
openOldReport( reportFile, title );
end 
end 


function openOldReport( reportFile, title )
if ~startsWith( reportFile, 'file:' )
reportFile = "file://" + strrep( reportFile, '\', '/' );
end 
browser = matlab.internal.webwindow( reportFile );
browser.MATLABWindowExitedCallback = @( varargin )coder.internal.closeAllLocationLoggingNumericTypeScopes( 'MATLABCoder' );
if isempty( title )
title = getString( message( 'Coder:reportGen:emlCoderTitle' ) );
end 
browser.Title = title;
browser.Tag = 'OldCodeGenerationReport';
browser.show(  );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpY0D024.p.
% Please follow local copyright laws when handling this file.

