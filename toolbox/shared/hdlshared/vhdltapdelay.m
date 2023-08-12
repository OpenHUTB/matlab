function [ hdlbody, hdlsignals ] = vhdltapdelay( in, out, processName, numdelays, delayorder, scalarIC )








hdlsignals = '';
singlequote = char( 39 );

name = hdlsignalname( in );
vtype = hdlsignalvtype( in );
sltype = hdlsignalsltype( in );
iscplx = hdlsignaliscomplex( in );

[ size, ~, signed ] = hdlwordsize( sltype );

outname = hdlsignalname( out );
outsltype = hdlsignalsltype( out );
[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );


gConnOld = hdlconnectivity.genConnectivity( 0 );

if numdelays == 1
[ hdlbody, hdlsignals ] = hdlunitdelay( in, out, processName, scalarIC );
else 
hdlsequentialcontext( true );

cclk = hdlgetcurrentclock;
if isempty( cclk ) || cclk == 0
clockname = hdlgetparameter( 'clockname' );
else 
clockname = hdlsignalname( cclk );
end 

cclken = hdlgetcurrentclockenable;
if isempty( cclken )
clockenablename = '';
elseif cclken == 0
clockenablename = hdlgetparameter( 'clockenablename' );
else 
clockenablename = hdlsignalname( cclken );
end 

creset = hdlgetcurrentreset;
if isempty( creset )
resetname = '';
elseif creset == 0
resetname = hdlgetparameter( 'resetname' );
else 
resetname = hdlsignalname( creset );
end 

if ( iscplx )
name_im = hdlsignalname( hdlsignalimag( in ) );
outname_im = hdlsignalname( hdlsignalimag( out ) );
end 


if ~strcmp( sltype, 'double' ) && ( scalarIC == 0 ) && ( outsize > 1 )
ICstr = '(OTHERS => ''0'')';
else 
ICstr = vhdlconstantvalue( scalarIC, outsize, outbp, outsigned );
end 


if hdlgetparameter( 'async_reset' ) == 1
sensList = [ 'PROCESS (', clockname, ', ', resetname, ')\n' ];%#ok<I18N_Concatenated_Msg>


asyncIf = [ 'IF ', resetname, ' = ''',  ...
int2str( hdlgetparameter( 'reset_asserted_level' ) ), ''' THEN', '\n' ];%#ok<I18N_Concatenated_Msg>


if ( hdlgetparameter( 'clockedge' ) == 0 )
if ( hdlgetparameter( 'clockedgestyle' ) == 0 )
asyncElsif = [ 'ELSIF ', clockname, singlequote, 'event AND ',  ...
clockname, ' = ''1'' THEN\n' ];
else 
asyncElsif = [ 'ELSIF ', 'rising_edge(', clockname, ') THEN\n' ];
end 
else 
if ( hdlgetparameter( 'clockedgestyle' ) == 0 )
asyncElsif = [ 'ELSIF ', clockname, singlequote, 'event AND ',  ...
clockname, ' = ''0'' THEN\n' ];
else 
asyncElsif = [ 'ELSIF ', 'falling_edge(', clockname, ') THEN\n' ];
end 
end 

else 
sensList = [ 'PROCESS (', clockname, ')\n' ];

if ( hdlgetparameter( 'clockedge' ) == 0 )
if ( hdlgetparameter( 'clockedgestyle' ) == 0 )
asyncIf = [ 'IF ', clockname, singlequote, 'event AND ',  ...
clockname, ' = ''1'' THEN\n' ];
else 
asyncIf = [ 'IF ', 'rising_edge(', clockname, ') THEN\n' ];
end 
else 
if ( hdlgetparameter( 'clockedgestyle' ) == 0 )
asyncIf = [ 'IF ', clockname, singlequote, 'event AND ',  ...
clockname, ' = ''0'' THEN\n' ];
else 
asyncIf = [ 'IF ', 'falling_edge(', clockname, ') THEN\n' ];
end 
end 


asyncElsif = [ 'IF ', resetname, ' = ''',  ...
int2str( hdlgetparameter( 'reset_asserted_level' ) ), ''' THEN', '\n' ];%#ok<I18N_Concatenated_Msg>


end 


asyncbody = scalarAsyncBody( outname, numdelays, ICstr );
[ name, size ] = hdlsignaltypeconvert( name, size, signed, vtype, outsigned );
syncbody = scalarSyncBody( name, outname, numdelays, delayorder );
if ( iscplx )
asyncbody = [ asyncbody, blanks( 6 ), scalarAsyncBody( outname_im, numdelays, ICstr ) ];
[ name_im, ~ ] = hdlsignaltypeconvert( name_im, size, signed, vtype, outsigned );
syncbody = [ syncbody, blanks( 8 ), scalarSyncBody( name_im, outname_im, numdelays, delayorder ) ];
end 


if hdlgetparameter( 'async_reset' ) == 1
hdlbody = [ blanks( 2 ), processName, ' : ', sensList,  ...
blanks( 2 ), 'BEGIN\n',  ...
blanks( 4 ), asyncIf,  ...
blanks( 6 ), asyncbody,  ...
blanks( 4 ), asyncElsif,  ...
blanks( 6 ), [ 'IF ', clockenablename, ' = ''1'' THEN\n' ],  ...
blanks( 8 ), syncbody,  ...
blanks( 6 ), 'END IF;\n',  ...
blanks( 4 ), 'END IF; \n',  ...
blanks( 2 ), 'END PROCESS ', processName, ';\n\n' ];%#ok<I18N_Concatenated_Msg>
else 
hdlbody = [ blanks( 2 ), processName, ' : ', sensList,  ...
blanks( 2 ), 'BEGIN\n',  ...
blanks( 4 ), asyncIf,  ...
blanks( 6 ), asyncElsif,  ...
blanks( 8 ), asyncbody,  ...
blanks( 6 ), [ 'ELSIF ', clockenablename, ' = ''1'' THEN\n' ],  ...
blanks( 8 ), syncbody,  ...
blanks( 6 ), 'END IF;\n',  ...
blanks( 4 ), 'END IF; \n',  ...
blanks( 2 ), 'END PROCESS ', processName, ';\n\n' ];%#ok<I18N_Concatenated_Msg>
end 

hdlsequentialcontext( false );
end 


if gConnOld
hCD = hdlconnectivity.getConnectivityDirector;
regout = out;


if numdelays > 1, 
if strcmpi( delayorder, 'Newest' ), 

outInd = ( 1:numdelays - 1 );
inInd = ( 0:numdelays - 2 );
out1Ind = 0;
else 

outInd = ( 0:numdelays - 2 );
inInd = ( 1:numdelays - 1 );
out1Ind = numdelays - 1;
end 
else 
out1Ind = [  ];
end 



hCD.addRegister( in, regout, hdlgetcurrentclock, hdlgetcurrentclockenable,  ...
'unroll', false, 'realonly', false,  ...
'inIndices', [  ], 'outIndices', out1Ind );

if numdelays > 1, 

hCD.addRegister( regout, regout, hdlgetcurrentclock, hdlgetcurrentclockenable,  ...
'unroll', false, 'realonly', false,  ...
'inIndices', inInd, 'outIndices', outInd );
end 
end 


hdlconnectivity.genConnectivity( gConnOld );




function asyncbody = scalarAsyncBody( outname, numdelays, ICstr )
ICstr = [ '(OTHERS => ', ICstr, ')' ];%#ok<I18N_Concatenated_Msg> % scalar expand ICstr
idxstr = [ '(0 TO ', int2str( numdelays - 1 ), ')' ];%#ok<I18N_Concatenated_Msg>
asyncbody = [ outname, idxstr, ' <= ', ICstr, ';\n' ];

function syncbody = scalarSyncBody( name, outname, numdelays, delayorder )
if ( numdelays > 2 )
idxstr1 = [ '(1 TO ', int2str( numdelays - 1 ), ')' ];%#ok<I18N_Concatenated_Msg>
idxstr2 = [ '(0 TO ', int2str( numdelays - 2 ), ')' ];%#ok<I18N_Concatenated_Msg>
else 
idxstr1 = '(1)';
idxstr2 = '(0)';
end 
if strcmp( delayorder, 'Newest' )
syncbody = [ outname, '(0)', ' <= ', name, ';\n' ];
syncbody = [ syncbody, blanks( 8 ), outname, idxstr1, ' <= ', outname, idxstr2, ';\n' ];
else 
syncbody = [ outname, idxstr2, ' <= ', outname, idxstr1, ';\n' ];
syncbody = [ syncbody, blanks( 8 ), outname, '(', int2str( numdelays - 1 ), ')', ' <= ', name, ';\n' ];
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpO5GfHo.p.
% Please follow local copyright laws when handling this file.

