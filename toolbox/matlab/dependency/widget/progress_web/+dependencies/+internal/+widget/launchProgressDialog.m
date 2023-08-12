function webwindow = launchProgressDialog( uniqueName, options )





R36
uniqueName( 1, 1 )string{ mustBeNonzeroLengthText }
options.InitialMessage( 1, : )char{ mustBeNonzeroLengthText } =  ...
getString( message( "MATLAB:dependency:widgets:ProgressWaitingForMATLAB" ) );
options.Title( 1, : )char{ mustBeNonzeroLengthText } =  ...
getString( message( "MATLAB:dependency:widgets:ProgressTitle" ) );
options.Debug( 1, 1 )logical = false;
options.Tag( 1, : )char = '';
end 

if options.Debug
pageName = "index-debug";
else 
pageName = "index";
end 

encodedMessage = i_urlencode( options.InitialMessage );
baseUrl = "/toolbox/matlab/dependency/widget/progress_web/" +  ...
pageName + ".html?uniqueName=" + uniqueName + "&initialMessage=" +  ...
encodedMessage;

connector.ensureServiceOn(  );
urlWithNonce = connector.getUrl( baseUrl );

webwindow = matlab.internal.webwindow( urlWithNonce, matlab.internal.getDebugPort );
webwindow.Tag = options.Tag;
webwindow.Title = options.Title;
webwindow.setMinSize( [ 400, 130 ] );
webwindow.Position = i_getPosition( 400, 130 );
i_disableCloseButton( webwindow );
webwindow.show;
end 

function i_disableCloseButton( webwindow )
webwindow.CustomWindowClosingCallback = @( varargin )[  ];
end 

function position = i_getPosition( width, height )
R36
width( 1, 1 )double
height( 1, 1 )double
end 

ss = get( 0, 'ScreenSize' );
screen.Width = ss( 3 );
screen.Height = ss( 4 );

window.Width = min( screen.Width / 2, width );
window.Height = min( screen.Height / 2, height );

x = screen.Width / 2 - width / 2;
y = screen.Height / 2 - height / 2;

position = [ x, y, window.Width, window.Height ];
end 


function encodedText = i_urlencode( text )
R36
text( 1, : )char
end 



nat = unicode2native( text, 'utf8' );
regex = "([^a-zA-Z_0-9])";
encodedText = regexprep( string( char( nat ) ), regex, "%${dec2hex(char($1),2)}" );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpnb6sl_.p.
% Please follow local copyright laws when handling this file.

