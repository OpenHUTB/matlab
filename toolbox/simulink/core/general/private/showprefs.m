function showprefs( panel )











progressbar = DAStudio.WaitBar;



progressbar.setWindowTitle( [ DAStudio.message( 'Simulink:prefs:WindowTitle' ), ' ' ] );
progressbar.setCircularProgressBar( true );
progressbar.show(  );

p = Simulink.Preferences.getInstance;
e = p.showExplorer;
e.view( p );

% Decoded using De-pcode utility v1.2 from file /tmp/tmp2am4Bm.p.
% Please follow local copyright laws when handling this file.

