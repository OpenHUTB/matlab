function final_result = vhdltypeconvert( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation )










if any( strcmpi( rounding, { 'Floor', 'Simplest' } ) )
final_result = vtc_extract_floor_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation );
elseif strcmpi( rounding, 'Nearest' )
final_result = vtc_extract_nearest_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation );
elseif any( strcmpi( rounding, { 'Ceiling', 'Ceil' } ) )
final_result = vtc_extract_ceiling_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation );
elseif any( strcmpi( rounding, { 'Zero', 'Fix' } ) )
final_result = vtc_extract_zero_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation );
elseif strcmpi( rounding, 'Convergent' )
final_result = vtc_extract_convergent_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation );
elseif strcmpi( rounding, 'Round' )
final_result = vtc_extract_round_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation );
else 
error( message( 'HDLShared:directemit:unknownroundmode', rounding ) );
end 

if saturation
final_result = hdlsaturate( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation, final_result );
end 











function result = vtc_extract_floor_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation )

skip_finalconvert = 0;

[ resultname, conversion, deltasize ] = signed_unsigned_name( name, inputsize, saturation );

inputsize = inputsize + deltasize;

bpdiff = inputbp - outputbp;
if inputbp - inputsize >= outputbp
warning( message( 'HDLShared:directemit:floorsat1', 'vhdltypeconvert', name ) );
if ( outputsigned == 0 && inputsigned == 0 ) ||  ...
( outputsigned == 1 && inputsigned == 0 ) ||  ...
( outputsigned == 0 && saturation == 1 )
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
if outputsize ~= 1
result = [ '( OTHERS => ', signalslice( resultname, inputsize, inputsize - 1 ), ' )' ];
else 
result = signalslice( resultname, inputsize, inputsize - 1 );
end 
end 
elseif (  - inputbp > ( outputsize - outputbp - outputsigned ) ) ||  ...
( (  - inputbp == ( outputsize - outputbp ) ) && outputsigned == 0 )

warning( message( 'HDLShared:directemit:floorsat2', 'vhdltypeconvert', name ) );
if ~outputsigned
if ~saturation
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif inputsize == 1
resultname = strrep( name, '"0" & ', '' );
result = [ '(OTHERS => (', resultname, '))' ];
elseif outputsize ~= 1
result = '(OTHERS => (';
for n = inputsize - 1: - 1:1
result = [ result, signalslice( resultname, inputsize, n ), ' OR ' ];
end 
result = [ result, signalslice( resultname, inputsize, 0 ), '))' ];
else 
result = signalslice( resultname, inputsize, inputsize - 1 );
end 
else 
if ~saturation
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
result = [ '(', num2str( outputsize - 1 ), ' => ', resultname, '(', num2str( inputsize - 1 ), '),',  ...
' OTHERS => ''0''', ')' ];
end 
end 
elseif bpdiff > 0
if bpdiff > inputsize - 1
lowerbound = 0;
else 
lowerbound = bpdiff;
end 
if bpdiff + outputsize > inputsize
if inputsize - 1 == lowerbound
result = resultname;
if is_slv( inputvtype ) && inputsigned == true
result = addconversion( result, 4 );
result = signalresize( result, 1 );
result = signalresize( result, outputsize );
elseif inputsigned == false
result = signalslice( result, inputsize, inputsize - 1, inputsize - 1 );
result = [ '"0" & ', result ];
result = addconversion( result, 6 );
result = signalresize( result, outputsize );
else 
if saturation

result = forcesignalresize( result, 1 );
result = signalresize( result, outputsize );
else 
result = forcesignalresize( result, 1 );
result = signalresize( result, outputsize );
end 
end 
else 
result = signalslice( resultname, inputsize, inputsize - 1, lowerbound );
if ( conversion == 4 ) && ( inputsigned == false ) && ( outputsigned == true )
conversion = 5;
skip_finalconvert = 1;
end 

if ( conversion == 2 && is_slv( inputvtype ) == false ) || outputsize == 1
conversion = 0;
end 

result = addconversion( result, conversion );
result = signalresize( result, outputsize );
end 
else 
result = signalslice( resultname, inputsize, bpdiff + outputsize - 1, lowerbound );
if outputsize == 1
conversion = 0;
end 
result = addconversion( result, conversion );
end 

elseif bpdiff < 0
result = resultname;
if ~saturation
upperlim = min( max( outputsize + bpdiff - 1, 0 ), inputsize - 1 );
lowerlim = 0;
if upperlim == lowerlim, skip_finalconvert = 1;end 
result = signalslice( result, inputsize, upperlim, lowerlim );
if outputsize == 1
conversion = 0;
end 
if conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
end 
if conversion ~= 0 && upperlim ~= lowerlim
result = addconversion( result, conversion );
end 
else 
if conversion == 4 && is_slv( inputvtype ) &&  ...
inputsigned == true && outputsigned == false
conversion = 2;
elseif conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
elseif conversion == 0 && inputsize == 1 && outputsigned == true
conversion = 6;
end 

result = addconversion( result, conversion );
end 

if outputsize == 1

result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
result = signalresize( [ result, ' & ', vhdlnzeros(  - bpdiff ) ], outputsize );
end 


else 
result = resultname;

if outputsize > inputsize
if inputsigned == false && is_slv( inputvtype )
result = addconversion( result, 2 );
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
elseif inputsigned == true && outputsigned == false && is_slv( inputvtype )
result = addconversion( result, 4 );
result = signalresize( result, outputsize );
skip_finalconvert = 0;

elseif inputsigned == true && is_slv( inputvtype )
result = addconversion( result, 4 );
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
else 
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
end 

elseif inputsize > outputsize
result = signalslice( result, inputsize, outputsize - 1, 0 );
if outputsize == 1
conversion = 0;
end 
result = addconversion( result, conversion );
elseif inputsize == 1 && outputsize == 1 && inputbp == outputbp
result = name;
skip_finalconvert = 1;
else 
result = addconversion( result, conversion );
end 
end 

if skip_finalconvert == 0 && outputsize ~= 1
result = finalconvert( result, inputsigned, inputvtype, inputsize, outputsigned, outputvtype, outputsize );
end 



function result = vtc_extract_nearest_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation )

skip_finalconvert = 0;

[ resultname, conversion, deltasize ] = signed_unsigned_name( name, inputsize, saturation );

inputsize = inputsize + deltasize;

bpdiff = inputbp - outputbp;

if inputsigned
sign_bit = [ resultname, '(', num2str( inputsize - 1 ), ')' ];
else 
sign_bit = '"0"';
end 

if outputsize == 1
skip_finalconvert = 1;
if bpdiff == 0 & inputsize == 1 & outputsize == 1
result = name;
elseif bpdiff == 0
result = signalslice( resultname, inputsize, 0 );
elseif outputsigned && ( bpdiff == inputsize + 1 )
result = signalslice( resultname, inputsize, inputsize - 1 );
elseif bpdiff > inputsize - inputsigned
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif outputbp > inputbp
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif bpdiff > inputsize - 1
result = signalslice( resultname, inputsize, inputsize - 1 );
else 
if saturation
operator = ' OR ';
else 
operator = ' XOR ';
end 
result = [ signalslice( resultname, inputsize, bpdiff ), operator, signalslice( resultname, inputsize, bpdiff - 1 ) ];
end 
elseif inputbp - inputsize > outputbp
warning( message( 'HDLShared:directemit:nearestsat1', 'vhdltypeconvert', name ) );
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif (  - inputbp > ( outputsize - outputbp - outputsigned ) ) ||  ...
( (  - inputbp > ( outputsize - outputbp ) ) && outputsigned == 0 )

warning( message( 'HDLShared:directemit:nearestsat2', 'vhdltypeconvert', name ) );
if ( outputsigned == 0 && inputsigned == 0 ) ||  ...
( outputsigned == 1 && inputsigned == 0 ) ||  ...
( outputsigned == 0 && saturation == 1 )
if ~saturation
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif inputsize == 1

resultname = strrep( name, '"0" & ', '' );
result = [ '(OTHERS => (', resultname, '))' ];
else 
result = '(OTHERS => (';
for n = inputsize - 1: - 1:1
result = [ result, signalslice( resultname, inputsize, n ), ' OR ' ];%#ok
end 
result = [ result, signalslice( resultname, inputsize, 0 ), '))' ];
end 
else 
if ~saturation
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
result = [ '(', num2str( outputsize - 1 ), ' => ', signalslice( resultname, inputsize, inputsize - 1 ),  ...
', OTHERS => ''0''', ')' ];
end 
end 
elseif bpdiff > 0
if bpdiff + outputsize > inputsize
result = signalslice( resultname, inputsize, inputsize - 1, bpdiff - 1 );

sign_ext = [ sign_bit, ' & ' ];

if ( conversion == 4 ) && ( inputsigned == false ) && ( outputsigned == true )
conversion = 3;
sign_ext = '';
skip_finalconvert = 0;
end 

if conversion == 2 && is_slv( inputvtype ) == false
conversion = 0;
end 

result = addconversion( result, conversion );
result = signalresize( [ 'shift_right((', sign_ext, result, ' + 1), 1)' ],  ...
outputsize );
else 
result = signalslice( resultname, inputsize, bpdiff + outputsize - 1, bpdiff - 1 );
if is_slv( inputvtype ) == true && inputsigned == true && outputsigned == false
conversion = 2;
end 
result = addconversion( result, conversion );
if ~saturation
result = signalresize( [ 'shift_right(', result, ' + 1, 1)' ], outputsize );
else 
result = signalresize( [ 'shift_right(', sign_bit, ' & ', result, ' + 1, 1)' ], outputsize );
end 
end 

elseif bpdiff < 0
result = resultname;
if ~saturation
upperlim = min( max( outputsize + bpdiff - 1, 0 ), inputsize - 1 );
lowerlim = 0;
if upperlim == lowerlim, skip_finalconvert = 1;end 
result = signalslice( result, inputsize, upperlim, lowerlim );
if conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
end 
if conversion ~= 0 && upperlim ~= lowerlim
result = addconversion( result, conversion );
end 
else 
if conversion == 4 && is_slv( inputvtype ) &&  ...
inputsigned == true && outputsigned == false
conversion = 2;
elseif conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
elseif conversion == 0 && inputsize == 1 && outputsigned == true
conversion = 6;
end 
result = addconversion( result, conversion );
end 

result = signalresize( [ result, ' & ', vhdlnzeros(  - bpdiff ) ], outputsize );

else 
result = resultname;
if outputsize > inputsize
if inputsigned == false && is_slv( inputvtype )
result = addconversion( result, 2 );
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
elseif inputsigned == true && outputsigned == false && is_slv( inputvtype )
result = addconversion( result, 4 );
result = signalresize( result, outputsize );
skip_finalconvert = 0;

elseif inputsigned == true && is_slv( inputvtype )
result = addconversion( result, 4 );
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
else 
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
end 
elseif inputsize > outputsize
result = signalslice( result, inputsize, outputsize - 1, 0 );
if outputsize == 1
conversion = 0;
end 
result = addconversion( result, conversion );
elseif inputsize == 1 && outputsize == 1 && inputbp == outputbp
result = name;
skip_finalconvert = 1;
else 
result = addconversion( result, conversion );
end 
end 

if skip_finalconvert == 0
result = finalconvert( result, inputsigned, inputvtype, inputsize, outputsigned, outputvtype, outputsize );
end 



function result = vtc_extract_convergent_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation )

skip_finalconvert = 0;

[ resultname, conversion, deltasize ] = signed_unsigned_name( name, inputsize, saturation );

inputsize = inputsize + deltasize;

bpdiff = inputbp - outputbp;

if inputsigned
sign_bit = [ resultname, '(', num2str( inputsize - 1 ), ')' ];
else 
sign_bit = '"0"';
end 

if inputbp - inputsize >= outputbp
warning( message( 'HDLShared:directemit:convergentsat1', 'vhdltypeconvert', name ) );
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif (  - inputbp > ( outputsize - outputbp - outputsigned ) ) ||  ...
( (  - inputbp == ( outputsize - outputbp ) ) && outputsigned == 0 )

warning( message( 'HDLShared:directemit:convergentsat2', 'vhdltypeconvert', name ) );
if ( outputsigned == 0 && inputsigned == 0 ) ||  ...
( outputsigned == 1 && inputsigned == 0 ) ||  ...
( outputsigned == 0 && saturation == 1 )
if ~saturation
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
result = '(OTHERS => (';
for n = inputsize - 1: - 1:1
result = [ result, signalslice( resultname, inputsize, n ), ' OR ' ];%#ok
end 
result = [ result, signalslice( resultname, inputsize, 0 ), '))' ];
end 
else 
if ~saturation
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
result = [ '(', num2str( outputsize - 1 ), ' => ', signalslice( resultname, inputsize, inputsize - 1 ),  ...
', OTHERS => ''0''', ')' ];
end 
end 
elseif bpdiff > 0
if bpdiff + outputsize > inputsize

result = signalslice( resultname, inputsize, inputsize - 1, 0 );

sign_ext = [ sign_bit, ' & ' ];

if ( conversion == 4 ) && ( inputsigned == false ) && ( outputsigned == true )
conversion = 3;
sign_ext = '';
skip_finalconvert = 0;
end 

if conversion == 2 && is_slv( inputvtype ) == false
conversion = 0;
end 

result = addconversion( result, conversion );

convbit = [ '( "0" & (', signalslice( resultname, inputsize, bpdiff ) ];
for n = bpdiff - 2: - 1:0
convbit = [ convbit, ' & NOT ', signalslice( resultname, inputsize, bpdiff ) ];
end 
convbit = [ convbit, '))' ];

result = signalresize( [ 'shift_right(', sign_ext, result, ' + ',  ...
convbit,  ...
', ', num2str( bpdiff ), ')' ], outputsize );


else 
result = signalslice( resultname, inputsize, bpdiff + outputsize - 1, 0 );
if is_slv( inputvtype ) == true && inputsigned == true && outputsigned == false
conversion = 2;
end 
result = addconversion( result, conversion );
convbit = [ '( "0" & (', signalslice( resultname, inputsize, bpdiff ) ];
for n = bpdiff - 2: - 1:0
convbit = [ convbit, ' & NOT ', signalslice( resultname, inputsize, bpdiff ) ];
end 
convbit = [ convbit, '))' ];

if ~saturation
result = signalresize( [ 'shift_right(', result, ' + ',  ...
convbit,  ...
', ', num2str( bpdiff ), ')' ], outputsize );
else 
result = signalresize( [ 'shift_right(', result, ' + ',  ...
convbit,  ...
', ', num2str( bpdiff ), ')' ], outputsize );
end 
end 

elseif bpdiff < 0
result = resultname;
if ~saturation
upperlim = min( max( outputsize + bpdiff - 1, 0 ), inputsize - 1 );
lowerlim = 0;
if upperlim == lowerlim, skip_finalconvert = 1;end 
result = signalslice( result, inputsize, upperlim, lowerlim );
if conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
end 
if conversion ~= 0 && upperlim ~= lowerlim
result = addconversion( result, conversion );
end 
else 
if conversion == 4 && is_slv( inputvtype ) &&  ...
inputsigned == true && outputsigned == false
conversion = 2;
elseif conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
elseif conversion == 0 && inputsize == 1 && outputsigned == true
conversion = 6;
end 
result = addconversion( result, conversion );
end 

result = signalresize( [ result, ' & ', vhdlnzeros(  - bpdiff ) ], outputsize );
else 
result = resultname;
if outputsize > inputsize
if inputsigned == false && is_slv( inputvtype )
result = addconversion( result, 2 );
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
elseif inputsigned == true && outputsigned == false && is_slv( inputvtype )
result = addconversion( result, 4 );
result = signalresize( result, outputsize );
skip_finalconvert = 0;

elseif inputsigned == true && is_slv( inputvtype )
result = addconversion( result, 4 );
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
else 
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
end 
elseif inputsize > outputsize
result = signalslice( result, inputsize, outputsize - 1, 0 );
if outputsize == 1
conversion = 0;
end 
result = addconversion( result, conversion );
elseif inputsize == 1 && outputsize == 1 && inputbp == outputbp
result = name;
skip_finalconvert = 1;
else 
result = addconversion( result, conversion );
end 
end 

if skip_finalconvert == 0
result = finalconvert( result, inputsigned, inputvtype, inputsize, outputsigned, outputvtype, outputsize );
end 



function result = vtc_extract_round_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation )

skip_finalconvert = 0;

[ resultname, conversion, deltasize ] = signed_unsigned_name( name, inputsize, saturation );

inputsize = inputsize + deltasize;

bpdiff = inputbp - outputbp;

if inputsigned
sign_bit = [ resultname, '(', num2str( inputsize - 1 ), ')' ];
else 
sign_bit = '"0"';
end 

if inputbp - inputsize >= outputbp
warning( message( 'HDLShared:directemit:roundsat1', 'vhdltypeconvert', name ) );
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif (  - inputbp > ( outputsize - outputbp - outputsigned ) ) ||  ...
( (  - inputbp == ( outputsize - outputbp ) ) && outputsigned == 0 )

warning( message( 'HDLShared:directemit:roundsat2', 'vhdltypeconvert', name ) );
if ( outputsigned == 0 && inputsigned == 0 ) ||  ...
( outputsigned == 1 && inputsigned == 0 ) ||  ...
( outputsigned == 0 && saturation == 1 )
if ~saturation
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
result = '(OTHERS => (';
for n = inputsize - 1: - 1:1
result = [ result, signalslice( resultname, inputsize, n ), ' OR ' ];%#ok
end 
result = [ result, signalslice( resultname, inputsize, 0 ), '))' ];
end 
else 
if ~saturation
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
result = [ '(', num2str( outputsize - 1 ), ' => ', signalslice( resultname, inputsize, inputsize - 1 ),  ...
', OTHERS => ''0''', ')' ];
end 
end 
elseif bpdiff > 0
if bpdiff + outputsize > inputsize

result = signalslice( resultname, inputsize, inputsize - 1, 0 );

sign_ext = [ sign_bit, ' & ' ];

if ( conversion == 4 ) && ( inputsigned == false ) && ( outputsigned == true )
conversion = 3;
sign_ext = '';
skip_finalconvert = 0;
end 

if conversion == 2 && is_slv( inputvtype ) == false
conversion = 0;
end 

result = addconversion( result, conversion );

convbit = [ '( "0" & ( NOT ', sign_bit ];
for n = bpdiff - 2: - 1:0
convbit = [ convbit, ' & ', sign_bit ];
end 
convbit = [ convbit, '))' ];

result = signalresize( [ 'shift_right(', sign_ext, result, ' + ',  ...
convbit,  ...
', ', num2str( bpdiff ), ')' ], outputsize );


else 
result = signalslice( resultname, inputsize, bpdiff + outputsize - 1, 0 );
if is_slv( inputvtype ) == true && inputsigned == true && outputsigned == false
conversion = 2;
end 
result = addconversion( result, conversion );
convbit = [ '( "0" & ( NOT ', sign_bit ];
for n = bpdiff - 2: - 1:0
convbit = [ convbit, ' & ', sign_bit ];
end 
convbit = [ convbit, '))' ];

if ~saturation
result = signalresize( [ 'shift_right(', result, ' + ',  ...
convbit,  ...
', ', num2str( bpdiff ), ')' ], outputsize );
else 
result = signalresize( [ 'shift_right(', sign_bit, ' & ', result, ' + ',  ...
convbit,  ...
', ', num2str( bpdiff ), ')' ], outputsize );
end 
end 

elseif bpdiff < 0
result = resultname;
if ~saturation
upperlim = min( max( outputsize + bpdiff - 1, 0 ), inputsize - 1 );
lowerlim = 0;
if upperlim == lowerlim, skip_finalconvert = 1;end 
result = signalslice( result, inputsize, upperlim, lowerlim );
if conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
end 
if conversion ~= 0 && upperlim ~= lowerlim
result = addconversion( result, conversion );
end 
else 
if conversion == 4 && is_slv( inputvtype ) &&  ...
inputsigned == true && outputsigned == false
conversion = 2;
elseif conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
elseif conversion == 0 && inputsize == 1 && outputsigned == true
conversion = 6;
end 
result = addconversion( result, conversion );
end 

result = signalresize( [ result, ' & ', vhdlnzeros(  - bpdiff ) ], outputsize );
else 
result = resultname;
if outputsize > inputsize
if inputsigned == false && is_slv( inputvtype )
result = addconversion( result, 2 );
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
elseif inputsigned == true && outputsigned == false && is_slv( inputvtype )
result = addconversion( result, 4 );
result = signalresize( result, outputsize );
skip_finalconvert = 0;

elseif inputsigned == true && is_slv( inputvtype )
result = addconversion( result, 4 );
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
else 
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
end 
elseif inputsize > outputsize
result = signalslice( result, inputsize, outputsize - 1, 0 );
if outputsize == 1
conversion = 0;
end 
result = addconversion( result, conversion );
elseif inputsize == 1 && outputsize == 1 && inputbp == outputbp
result = name;
skip_finalconvert = 1;
else 
result = addconversion( result, conversion );
end 
end 

if skip_finalconvert == 0
result = finalconvert( result, inputsigned, inputvtype, inputsize, outputsigned, outputvtype, outputsize );
end 



function result = vtc_extract_ceiling_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation )

skip_finalconvert = 0;

[ resultname, conversion, deltasize ] = signed_unsigned_name( name, inputsize, saturation );

inputsize = inputsize + deltasize;

if inputsigned
sign_bit = [ resultname, '(', num2str( inputsize - 1 ), ')' ];
else 
sign_bit = '"0"';
end 

bpdiff = inputbp - outputbp;
if inputbp - inputsize >= outputbp
warning( message( 'HDLShared:directemit:ceilingsat1', 'vhdltypeconvert', name ) );
if ( outputsigned == 0 && inputsigned == 0 ) ||  ...
( outputsigned == 1 && inputsigned == 0 )
result = '(';
if inputsize > 1
for n = inputsize - 1: - 1:1
result = [ result, resultname, '(', num2str( n ), ') OR ' ];
end 
result = [ result, resultname, '(0))' ];
else 
result = [ result, resultname, ')' ];
end 
else 
if inputsize > 1
result = [ '(NOT ', resultname, '(', num2str( inputsize - 1 ), ') AND (' ];
for n = inputsize - 2: - 1:1
result = [ result, resultname, '(', num2str( n ), ') OR ' ];
end 
result = [ result, resultname, '(0)))' ];

else 
result = resultname;
end 
end 
if outputsize ~= 1
result = [ '(0 => ', result, ', OTHERS => ''0'')' ];
end 
elseif (  - inputbp > ( outputsize - outputbp - outputsigned ) ) ||  ...
( (  - inputbp == ( outputsize - outputbp ) ) && outputsigned == 0 )

warning( message( 'HDLShared:directemit:ceilingsat2', 'vhdltypeconvert', name ) );
if ~outputsigned
if ~saturation
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
if outputsize == 1
result = '(';
resultclose = ')';
elseif inputsize == 1
resultname = strrep( name, '"0" & ', '' );
result = '(OTHERS => (';
resultclose = '))';
else 
result = '(OTHERS => (';
resultclose = '))';
end 
for n = inputsize - 1: - 1:1
result = [ result, signalslice( resultname, inputsize, n ), ' OR ' ];%#ok
end 
result = [ result, signalslice( resultname, inputsize, 0 ), resultclose ];
end 
else 
if ~saturation
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
result = [ '(', num2str( outputsize - 1 ), ' => ', signalslice( resultname, inputsize, inputsize - 1 ),  ...
', OTHERS => ''0''', ')' ];
end 
end 
elseif bpdiff > 0
if bpdiff + outputsize > inputsize
sign_ext = [ sign_bit, ' & ' ];

result = signalslice( resultname, inputsize, inputsize - 1, bpdiff );

if inputsize - 1 == bpdiff
if inputsigned == true
conversion = 7;
else 
conversion = 6;
end 
end 

if ( conversion == 4 ) && ( inputsigned == false ) && ( outputsigned == true )
conversion = 3;
sign_ext = '';
skip_finalconvert = 0;
end 

if conversion == 2 && is_slv( inputvtype ) == false
conversion = 0;
end 

result = [ sign_ext, result ];
result = addconversion( result, conversion );
result = [ ' (', result, ' + ( "0" & (' ];
for n = bpdiff - 1: - 1:1
result = [ result, signalslice( resultname, inputsize, n ), ' OR ' ];%#ok
end 
result = [ result, signalslice( resultname, inputsize, 0 ), ')) )' ];
result = signalresize( result, outputsize );

else 
result = signalslice( resultname, inputsize, bpdiff + outputsize - 1, bpdiff );
if is_slv( inputvtype ) == true && inputsigned == true && outputsigned == false
conversion = 2;
end 
if outputsize ~= 1
result = addconversion( result, conversion );
end 
if outputsize == 1
if saturation
result = [ '(', result, ' OR (' ];
else 
result = [ '(', result, ' XOR (' ];
end 
else 
if ~saturation
result = [ result, ' + ( "0" & (' ];
else 
result = [ '(', sign_bit, ' & ', result, ') + ( "0" & (' ];
end 
end 
for n = bpdiff - 1: - 1:1
result = [ result, signalslice( resultname, inputsize, n ), ' OR ' ];%#ok
end 
result = [ result, signalslice( resultname, inputsize, 0 ), '))' ];
result = signalresize( result, outputsize );
end 

elseif bpdiff < 0
result = resultname;
if ~saturation
upperlim = min( max( outputsize + bpdiff - 1, 0 ), inputsize - 1 );
lowerlim = 0;
if upperlim == lowerlim && inputsize ~= 1, skip_finalconvert = 1;end 
result = signalslice( result, inputsize, upperlim, lowerlim );
if conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
end 
if conversion ~= 0 && upperlim ~= lowerlim
result = addconversion( result, conversion );
end 
else 
if conversion == 4 && is_slv( inputvtype ) &&  ...
inputsigned == true && outputsigned == false
conversion = 2;
elseif conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
elseif conversion == 0 && inputsize == 1 && outputsigned == true
conversion = 6;
end 
result = addconversion( result, conversion );
end 
result = signalresize( [ result, ' & ', vhdlnzeros(  - bpdiff ) ], outputsize );
else 
result = resultname;
if outputsize > inputsize
if inputsigned == false && is_slv( inputvtype )
result = addconversion( result, 2 );
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
elseif inputsigned == true && outputsigned == false && is_slv( inputvtype )
result = addconversion( result, 4 );
result = signalresize( result, outputsize );
skip_finalconvert = 0;

elseif inputsigned == true && is_slv( inputvtype )
result = addconversion( result, 4 );
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
else 
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
end 
elseif inputsize > outputsize
result = signalslice( result, inputsize, outputsize - 1, 0 );
if outputsize == 1
conversion = 0;
end 
result = addconversion( result, conversion );
elseif inputsize == 1 && outputsize == 1 && inputbp == outputbp
result = name;
skip_finalconvert = 1;
else 
result = addconversion( result, conversion );
end 
end 

if skip_finalconvert == 0
result = finalconvert( result, inputsigned, inputvtype, inputsize, outputsigned, outputvtype, outputsize );
end 




function result = vtc_extract_zero_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation )

skip_finalconvert = 0;

[ resultname, conversion, deltasize ] = signed_unsigned_name( name, inputsize, saturation );

inputsize = inputsize + deltasize;

if inputsigned == 0
sign_bit = '"0" & ';
else 
sign_bit = [ resultname, '(', num2str( inputsize - 1 ), ') & ' ];
end 

if saturation == 0
sign_bit = '';
end 

bpdiff = inputbp - outputbp;
if inputbp - inputsize >= outputbp
warning( message( 'HDLShared:directemit:zerosat1', 'vhdltypeconvert', name ) );
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif (  - inputbp > ( outputsize - outputbp - outputsigned ) ) ||  ...
( (  - inputbp == ( outputsize - outputbp ) ) && outputsigned == 0 )

warning( message( 'HDLShared:directemit:zerosat2', 'vhdltypeconvert', name ) );
if ( outputsigned == 0 && inputsigned == 0 ) || ( outputsigned == 1 && inputsigned == 0 )
if ~saturation
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif inputsize == 1
resultname = strrep( name, '"0" & ', '' );
result = [ '(OTHERS => (', resultname, '))' ];
else 
result = '(OTHERS => (';
for n = inputsize - 1: - 1:1
result = [ result, signalslice( resultname, inputsize, n ), ' OR ' ];%#ok
end 
result = [ result, signalslice( resultname, inputsize, 0 ), '))' ];
end 
else 
if ~saturation
result = vhdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
if outputsize == 1
result = signalslice( resultname, inputsize, inputsize - 1 );
else 
result = [ '(', num2str( outputsize - 1 ), ' => ', signalslice( resultname, inputsize, inputsize - 1 ),  ...
', OTHERS => ''0''', ')' ];
end 
end 
end 
elseif bpdiff > 0
if bpdiff + outputsize > inputsize
sign_ext = sign_bit;

result = signalslice( resultname, inputsize, inputsize - 1, bpdiff );

if inputsize - 1 == bpdiff
if inputsigned == true
sign_ext = [ resultname, '(', num2str( inputsize - 1 ), ') & ' ];
conversion = 7;
else 
sign_ext = '"0" & ';
conversion = 6;
end 
end 

if ( conversion == 4 ) && ( inputsigned == false ) && ( outputsigned == true )
conversion = 3;
sign_ext = '';
skip_finalconvert = 0;
end 

if conversion == 2 && is_slv( inputvtype ) == false
conversion = 0;
end 

result = [ sign_ext, result ];
result = addconversion( result, conversion );
if inputsigned
result = [ '(', result, ') + ( "0" & (', resultname, '(', resultname, '''left) AND (' ];
for n = bpdiff - 1: - 1:1
result = [ result, signalslice( resultname, inputsize, n ), ' OR ' ];
end 
result = [ result, signalslice( resultname, inputsize, 0 ), ')))' ];
end 
result = signalresize( result, outputsize );
else 
result = signalslice( resultname, inputsize, bpdiff + outputsize - 1, bpdiff );
if is_slv( inputvtype ) == true && inputsigned == true && outputsigned == false
conversion = 2;
end 
if outputsize ~= 1
result = addconversion( result, conversion );
end 
if inputsigned
if outputsize == 1
result = [ '((', result, ' AND ( ' ];
else 
result = [ '(', sign_bit, result, ') + ("0" & (', resultname, '(', resultname, '''left) AND (' ];
end 
for n = bpdiff - 1: - 1:1
result = [ result, signalslice( resultname, inputsize, n ), ' OR ' ];%#ok
end 
result = [ result, signalslice( resultname, inputsize, 0 ), ') ))' ];

end 
result = signalresize( result, outputsize );
end 

elseif bpdiff < 0
result = resultname;
if ~saturation
upperlim = min( max( outputsize + bpdiff - 1, 0 ), inputsize - 1 );
lowerlim = 0;
if upperlim == lowerlim, skip_finalconvert = 1;end 
result = signalslice( result, inputsize, upperlim, lowerlim );
if conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
end 
if conversion ~= 0 && upperlim ~= lowerlim
result = addconversion( result, conversion );
end 
else 
if conversion == 4 && is_slv( inputvtype ) &&  ...
inputsigned == true && outputsigned == false
conversion = 2;
elseif conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
elseif conversion == 0 && inputsize == 1 && outputsigned == true
conversion = 6;
end 
result = addconversion( result, conversion );
end 
result = signalresize( [ result, ' & ', vhdlnzeros(  - bpdiff ) ], outputsize );
else 
result = resultname;
if outputsize > inputsize
if inputsigned == false && is_slv( inputvtype )
result = addconversion( result, 2 );
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
elseif inputsigned == true && outputsigned == false && is_slv( inputvtype )
result = addconversion( result, 4 );
result = signalresize( result, outputsize );
skip_finalconvert = 0;

elseif inputsigned == true && is_slv( inputvtype )
result = addconversion( result, 4 );
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
else 
result = signalresize( result, outputsize );
result = addconversion( result, conversion );
skip_finalconvert = 1;
end 
elseif inputsize > outputsize
result = signalslice( result, inputsize, outputsize - 1, 0 );
if outputsize == 1
conversion = 0;
end 
result = addconversion( result, conversion );
elseif inputsize == 1 && outputsize == 1 && inputbp == outputbp
result = name;
skip_finalconvert = 1;
else 
result = addconversion( result, conversion );
end 
end 

if skip_finalconvert == 0
result = finalconvert( result, inputsigned, inputvtype, inputsize, outputsigned, outputvtype, outputsize );
end 




function result = signalslice( name, inputsize, upperlimit, lowerlimit )
if inputsize == 1
result = name;
else 
upperlimit = max( upperlimit, 0 );
if nargin == 3
lowerlimit = upperlimit;
end 
lowerlimit = max( lowerlimit, 0 );
if upperlimit == lowerlimit
result = [ name, '(', num2str( upperlimit ), ')' ];
else 
result = [ name, '(', num2str( upperlimit ), ' DOWNTO ', num2str( lowerlimit ), ')' ];
end 
end 



function result = signalresize( name, outputsize )
if outputsize == 0
result = name;
elseif outputsize == 1
result = name;
else 
result = forcesignalresize( name, outputsize );
end 

function result = forcesignalresize( name, outputsize )
result = [ 'resize(', name, ', ', num2str( outputsize ), ')' ];



function result = addconversion( name, convertnum )

switch convertnum
case 0
result = name;
case 1
result = [ 'std_logic_vector(', name, ')' ];
case 2
result = [ 'unsigned(', name, ')' ];
case 3
result = [ 'unsigned( ''0'' & ', name, ')' ];
case 4
result = [ 'signed(', name, ')' ];
case 5
result = [ 'signed( ''0'' & ', name, ')' ];
case 6
result = [ 'unsigned''(', name, ')' ];
case 7
result = [ 'signed''(', name, ')' ];
otherwise 
result = name;
end 




function [ newname, conversion, deltasize ] = signed_unsigned_name( name, inputsize, saturation )

deltasize = 0;
if length( name ) > 17 && strcmp( name( 1:17 ), 'std_logic_vector(' ) && name( end  ) == ')'
newname = name( 18:end  - 1 );
conversion = 1;
elseif length( name ) > 9 && strcmp( name( 1:9 ), 'unsigned(' ) && name( end  ) == ')'
newname = name( 10:end  - 1 );
conversion = 2;
elseif length( name ) > 14 && strcmp( name( 1:14 ), 'signed( ''0'' & ' ) && name( end  ) == ')'
newname = name( 15:end  - 1 );
deltasize =  - 1;
if saturation
conversion = 4;
else 
conversion = 4;
end 
elseif length( name ) > 7 && strcmp( name( 1:7 ), 'signed(' ) && name( end  ) == ')'
newname = name( 8:end  - 1 );
conversion = 4;



else 
newname = name;
conversion = 0;
end 



function [ result ] = finalconvert( name, inputsigned, inputvtype, inputsize, outputsigned, outputvtype, outputsize )


if outputsigned == 1 && inputsigned == 1
result = name;
elseif outputsize == 1
result = name;
elseif ~isempty( strfind( name, '=>' ) )
result = name;
elseif length( name ) > 10 && strcmp( name( 1:10 ), 'to_signed(' )
result = name;
elseif length( name ) > 12 && strcmp( name( 1:12 ), 'to_unsigned(' )
result = name;
elseif outputsigned == 1 && inputsigned == 0

if length( name ) > 7 && strcmp( name( 1:7 ), 'signed(' )
result = signalresize( name, outputsize );
elseif length( name ) > 7 && strcmp( name( 1:7 ), 'resize(' )
result = [ 'signed(', name, ')' ];
else 
result = [ 'signed''(', name, ')' ];
end 
elseif outputsigned == 0 && inputsigned == 1

if length( name ) > 9 && strcmp( name( 1:9 ), 'unsigned(' )
result = name;
elseif length( name ) > 7 && strcmp( name( 1:7 ), 'resize(' )
result = [ 'unsigned(', name, ')' ];
else 
result = [ 'unsigned(', name, ')' ];
end 
else 
result = name;
end 

if length( outputvtype ) > 16 && strcmp( outputvtype( 1:16 ), 'std_logic_vector' )
result = [ 'std_logic_vector''(', result, ')' ];
end 



function result = is_slv( inputvtype )
result = strncmp( inputvtype, 'std_logic_vector(', 17 );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpk4fv2U.p.
% Please follow local copyright laws when handling this file.

