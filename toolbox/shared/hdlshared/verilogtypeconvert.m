function final_result = verilogtypeconvert( name, inputsize, inputbp, inputsigned, inputvtype,  ...
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

[ resultname, conversion, deltasize ] = signed_unsigned_name( name, saturation );

inputsize = inputsize + deltasize;

bpdiff = inputbp - outputbp;
if inputbp - inputsize >= outputbp
warning( message( 'HDLShared:directemit:floorsat1', 'verilogtypeconvert', name ) );
if ( outputsigned == 0 && inputsigned == 0 ) ||  ...
( outputsigned == 1 && inputsigned == 0 ) ||  ...
( outputsigned == 0 && saturation == 1 )
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
result = [ '{', num2str( outputsize ), '{', signalslice( resultname, inputsize, inputsize - 1 ), '}}' ];
end 
elseif (  - inputbp > ( outputsize - outputbp - outputsigned ) ) ||  ...
( (  - inputbp == ( outputsize - outputbp ) ) && outputsigned == 0 )

warning( message( 'HDLShared:directemit:floorsat2', 'verilogtypeconvert', name ) );
if ~outputsigned
if ~saturation
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif inputsize == 1
result = [ '{ ', num2str( outputsize ), '{', resultname, '} }' ];
else 
result = [ '|', resultname ];
end 
else 
if ~saturation
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
result = [ '{', signalslice( resultname, inputsize, inputsize - 1 ), ', ',  ...
hdlconstantvalue( 0, outputsize - 1, 0, 1 ), '}' ];
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
if inputsigned == false
result = signalslice( result, inputsize, inputsize - 1, inputsize - 1 );
result = addconversion( result, 3 );
else 
result = [ '{', num2str( outputsize ), '{',  ...
signalslice( resultname, inputsize, inputsize - 1 ), '}}' ];
result = signalresize( result, 1 );
end 

result = signalresize( result, outputsize );

else 
result = signalslice( resultname, inputsize, inputsize - 1, lowerbound );
if inputsigned
result = [ '{{', num2str( bpdiff + outputsize - inputsize ), '{',  ...
signalslice( resultname, inputsize, inputsize - 1 ), '}}, ' ...
, result, '}' ];
else 
result = [ '{', hdlconstantvalue( 0, bpdiff + outputsize - inputsize, 0, 0 ),  ...
', ', result, '}' ];
end 

if ( conversion == 4 ) && ( inputsigned == false ) && ( outputsigned == true )
conversion = 5;
skip_finalconvert = 1;
end 

if conversion == 2
conversion = 0;
end 
result = addconversion( result, conversion );
result = signalresize( result, outputsize );
end 
else 
result = signalslice( resultname, inputsize, bpdiff + outputsize - 1, lowerbound );
result = addconversion( result, conversion );
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
if conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
elseif conversion == 0 && inputsize == 1 && outputsigned == true
conversion = 6;
end 
result = addconversion( result, conversion );
end 
result = [ '{', result, ', ', hdlconstantvalue( 0,  - bpdiff, 0, 1 ), '}' ];
else 
result = resultname;
if outputsize > inputsize

if inputsigned
result = [ '{{', num2str( outputsize - inputsize ), '{',  ...
signalslice( resultname, inputsize, inputsize - 1 ), '}}, ' ...
, resultname, '}' ];
else 
result = [ '{', hdlconstantvalue( 0, outputsize - inputsize, 0, 0 ), ', ', resultname, '}' ];
end 
result = addconversion( result, conversion );
skip_finalconvert = 1;
elseif inputsize > outputsize
result = signalslice( result, inputsize, outputsize - 1, 0 );
result = addconversion( result, conversion );
else 
result = addconversion( result, conversion );
end 
end 

result = finalconvert( skip_finalconvert, result,  ...
inputsigned, inputvtype, inputsize,  ...
outputsigned, outputvtype, outputsize );




function result = vtc_extract_nearest_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation )

skip_finalconvert = 0;

[ resultname, conversion, deltasize ] = signed_unsigned_name( name, saturation );

inputsize = inputsize + deltasize;

bpdiff = inputbp - outputbp;

concatop = '{}';
if inputsigned
sign_bit = [ signalslice( resultname, inputsize, inputsize - 1 ), ', ' ];
else 
sign_bit = '1''b0, ';
end 

if outputsize == 1
skip_finalconvert = 1;
if bpdiff == 0
result = signalslice( resultname, inputsize, 0 );
elseif outputsigned && ( bpdiff == inputsize + 1 )
result = signalslice( resultname, inputsize, inputsize - 1 );
elseif bpdiff > inputsize - inputsigned
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif outputbp > inputbp
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif bpdiff > inputsize - 1
result = signalslice( resultname, inputsize, inputsize - 1 );
else 
if saturation
operator = ' | ';
else 
operator = ' ^ ';
end 
result = [ signalslice( resultname, inputsize, bpdiff ), operator, signalslice( resultname, inputsize, bpdiff - 1 ) ];
end 
elseif inputbp - inputsize > outputbp
warning( message( 'HDLShared:directemit:nearestsat1', 'verilogtypeconvert', name ) );
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif (  - inputbp > ( outputsize - outputbp - outputsigned ) ) ||  ...
( (  - inputbp == ( outputsize - outputbp ) ) && outputsigned == 0 )

warning( message( 'HDLShared:directemit:nearestsat2', 'verilogtypeconvert', name ) );
if ( outputsigned == 0 && inputsigned == 0 ) ||  ...
( outputsigned == 1 && inputsigned == 0 ) ||  ...
( outputsigned == 0 && saturation == 1 )
if ~saturation
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif inputsize == 1
result = [ '{ ', num2str( outputsize ), '{', resultname, '} }' ];
else 
result = [ '|', resultname ];
end 
else 
if ~saturation
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
result = [ '{', signalslice( resultname, inputsize, inputsize - 1 ), ', ',  ...
hdlconstantvalue( 0, outputsize - 1, 0, 1 ), '}' ];
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
if inputsigned == false
result = signalslice( result, inputsize, inputsize - 1, inputsize - 2 );
result = addconversion( result, 3 );
result = [ '(', concatop( 1 ), sign_bit, result, concatop( 2 ), ' + 1)>>>1' ];
else 
result = signalslice( result, inputsize, inputsize - 1, inputsize - 2 );
result = [ '{{', num2str( bpdiff + outputsize - inputsize ), '{',  ...
signalslice( resultname, inputsize, inputsize - 1 ), '}}, ' ...
, result, '}' ];
result = [ '(', result, ' + 1)>>>1' ];
end 
else 
result = signalslice( resultname, inputsize, inputsize - 1, max( lowerbound - 1, 0 ) );
if inputsigned
result = [ '{{', num2str( bpdiff + outputsize - inputsize ), '{',  ...
signalslice( resultname, inputsize, inputsize - 1 ), '}}, ' ...
, result, '}' ];
else 
result = [ '{', hdlconstantvalue( 0, bpdiff + outputsize - inputsize, 0, 0 ),  ...
', ', result, '}' ];
end 

if ( conversion == 4 ) && ( inputsigned == false ) && ( outputsigned == true )
conversion = 5;
skip_finalconvert = 1;
end 

if conversion == 2
conversion = 0;
end 
result = addconversion( result, conversion );

if inputsigned
result = [ '(', result, ' + 1)>>>1' ];
else 
result = [ '(', concatop( 1 ), sign_bit, result, concatop( 2 ), ' + 1)>>>1' ];
end 
end 
else 
result = signalslice( resultname, inputsize, bpdiff + outputsize - 1, bpdiff - 1 );
result = addconversion( result, conversion );
if ~saturation

result = [ '(', result, ' + 1)>>>1' ];
else 

result = [ '(', concatop( 1 ), sign_bit, result, concatop( 2 ), ' + 1)>>>1' ];
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
if conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
elseif conversion == 0 && inputsize == 1 && outputsigned == true
conversion = 6;
end 
result = addconversion( result, conversion );
end 
if inputsigned == 0
result = [ '{', sign_bit, result, '}' ];
end 
result = [ '{', result, ', ', hdlconstantvalue( 0,  - bpdiff, 0, 1 ), '}' ];

else 
result = resultname;
if outputsize > inputsize

if inputsigned
result = [ '{{', num2str( outputsize - inputsize ), '{',  ...
signalslice( resultname, inputsize, inputsize - 1 ), '}}, ' ...
, resultname, '}' ];
else 
result = [ '{', hdlconstantvalue( 0, outputsize - inputsize, 0, 0 ), ', ', resultname, '}' ];
end 
result = addconversion( result, conversion );
skip_finalconvert = 1;
elseif inputsize > outputsize
result = signalslice( result, inputsize, outputsize - 1, 0 );
result = addconversion( result, conversion );
else 
result = addconversion( result, conversion );
end 
end 

result = finalconvert( skip_finalconvert, result,  ...
inputsigned, inputvtype, inputsize,  ...
outputsigned, outputvtype, outputsize );



function result = vtc_extract_convergent_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation )

skip_finalconvert = 0;

[ resultname, conversion, deltasize ] = signed_unsigned_name( name, saturation );

inputsize = inputsize + deltasize;

bpdiff = inputbp - outputbp;

concatop = '{}';
if inputsigned
sign_bit = [ signalslice( resultname, inputsize, inputsize - 1 ), ', ' ];
else 
sign_bit = '1''b0, ';
end 

if inputbp - inputsize >= outputbp
warning( message( 'HDLShared:directemit:convergentsat1', 'verilogtypeconvert', name ) );
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif (  - inputbp > ( outputsize - outputbp - outputsigned ) ) ||  ...
( (  - inputbp == ( outputsize - outputbp ) ) && outputsigned == 0 )

warning( message( 'HDLShared:directemit:convergentsat2', 'verilogtypeconvert', name ) );
if ( outputsigned == 0 && inputsigned == 0 ) ||  ...
( outputsigned == 1 && inputsigned == 0 ) ||  ...
( outputsigned == 0 && saturation == 1 )
if ~saturation
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
result = [ concatop( 1 ), ' ', num2str( outputsize ), concatop( 1 ),  ...
'|', resultname, concatop( 2 ), concatop( 2 ) ];
end 
else 
if ~saturation
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 

result = [ concatop( 1 ),  ...
signalslice( resultname, inputsize, inputsize - 1 ),  ...
', ',  ...
hdlconstantvalue( 0, outputsize - 1, 0, 0 ),  ...
concatop( 2 ) ];
end 
end 
elseif bpdiff > 0
if bpdiff + outputsize > inputsize
result = signalslice( resultname, inputsize, inputsize - 1, 0 );
if inputsigned
result = [ '{{', num2str( bpdiff + outputsize - inputsize ), '{',  ...
signalslice( resultname, inputsize, inputsize - 1 ), '}}, ' ...
, result, '}' ];
else 
result = [ '{', hdlconstantvalue( 0, bpdiff + outputsize - inputsize, 0, 0 ),  ...
', ', result, '}' ];
end 

if conversion == 4, conversion = 5;skip_finalconvert = 1;end 

if conversion == 2, conversion = 0;end 

result = addconversion( result, conversion );



if bpdiff - 1 == 0
convbit = signalslice( resultname, inputsize, bpdiff );
else 
convbit = [ concatop( 1 ), signalslice( resultname, inputsize, bpdiff ),  ...
', ', concatop( 1 ), num2str( bpdiff - 1 ), concatop( 1 ),  ...
'~', signalslice( resultname, inputsize, bpdiff ), concatop( 2 ), concatop( 2 ), concatop( 2 ) ];
end 
if inputsigned
result = [ '(', result, ' + ', convbit,  ...
')>>>', num2str( bpdiff ) ];
else 
result = [ '(', concatop( 1 ), sign_bit, result, concatop( 2 ), ' + ', convbit,  ...
')>>>', num2str( bpdiff ) ];
end 

else 
result = signalslice( resultname, inputsize, bpdiff + outputsize - 1, 0 );
result = addconversion( result, conversion );

if bpdiff - 1 == 0
convbit = signalslice( resultname, inputsize, bpdiff );
else 
convbit = [ concatop( 1 ), signalslice( resultname, inputsize, bpdiff ),  ...
', ', concatop( 1 ), num2str( bpdiff - 1 ), concatop( 1 ),  ...
'~', signalslice( resultname, inputsize, bpdiff ), concatop( 2 ), concatop( 2 ), concatop( 2 ) ];
end 
if ~saturation
result = [ '(', result, ' + ', convbit, ')>>>', num2str( bpdiff ) ];
else 
result = [ '(', result, ' + ', convbit,  ...
')>>>', num2str( bpdiff ) ];
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
if conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
elseif conversion == 0 && inputsize == 1 && outputsigned == true
conversion = 6;
end 
result = addconversion( result, conversion );
end 

result = [ concatop( 1 ), result, ', ', hdlconstantvalue( 0,  - bpdiff, 0, 0 ), concatop( 2 ) ];

else 
result = resultname;
if outputsize > inputsize
if inputsigned
result = [ '{{', num2str( outputsize - inputsize ), '{',  ...
signalslice( resultname, inputsize, inputsize - 1 ), '}}, ' ...
, resultname, '}' ];
else 
result = [ '{', hdlconstantvalue( 0, outputsize - inputsize, 0, 0 ), ', ', resultname, '}' ];
end 
result = addconversion( result, conversion );
skip_finalconvert = 1;
elseif inputsize > outputsize
result = signalslice( result, inputsize, outputsize - 1, 0 );
result = addconversion( result, conversion );
else 
result = addconversion( result, conversion );
end 
end 

result = finalconvert( skip_finalconvert, result,  ...
inputsigned, inputvtype, inputsize,  ...
outputsigned, outputvtype, outputsize );



function result = vtc_extract_round_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation )

skip_finalconvert = 0;

[ resultname, conversion, deltasize ] = signed_unsigned_name( name, saturation );

inputsize = inputsize + deltasize;

bpdiff = inputbp - outputbp;

concatop = '{}';
if inputsigned
sign_bit = signalslice( resultname, inputsize, inputsize - 1 );;
else 
sign_bit = '1''b0';
end 

if inputbp - inputsize >= outputbp
warning( message( 'HDLShared:directemit:roundsat1', 'verilogtypeconvert', name ) );
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif (  - inputbp > ( outputsize - outputbp - outputsigned ) ) ||  ...
( (  - inputbp == ( outputsize - outputbp ) ) && outputsigned == 0 )

warning( message( 'HDLShared:directemit:roundsat2', 'verilogtypeconvert', name ) );
if ( outputsigned == 0 && inputsigned == 0 ) ||  ...
( outputsigned == 1 && inputsigned == 0 ) ||  ...
( outputsigned == 0 && saturation == 1 )
if ~saturation
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
result = [ concatop( 1 ), ' ', num2str( outputsize ), concatop( 1 ),  ...
'|', resultname, concatop( 2 ), concatop( 2 ) ];
end 
else 
if ~saturation
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 

result = [ concatop( 1 ),  ...
signalslice( resultname, inputsize, inputsize - 1 ),  ...
', ',  ...
hdlconstantvalue( 0, outputsize - 1, 0, 0 ),  ...
concatop( 2 ) ];
end 
end 
elseif bpdiff > 0
if bpdiff + outputsize > inputsize
result = signalslice( resultname, inputsize, inputsize - 1, 0 );
if inputsigned
result = [ '{{', num2str( bpdiff + outputsize - inputsize ), '{',  ...
signalslice( resultname, inputsize, inputsize - 1 ), '}}, ' ...
, result, '}' ];
else 
result = [ '{', hdlconstantvalue( 0, bpdiff + outputsize - inputsize, 0, 0 ),  ...
', ', result, '}' ];
end 

if conversion == 4, conversion = 5;skip_finalconvert = 1;end 

if conversion == 2, conversion = 0;end 

result = addconversion( result, conversion );



if bpdiff - 1 == 0
convbit = [ concatop( 1 ), '1''b0, ~', sign_bit, concatop( 2 ) ];
else 
convbit = [ concatop( 1 ), '~', sign_bit,  ...
', ', concatop( 1 ), num2str( bpdiff - 1 ), concatop( 1 ),  ...
sign_bit, concatop( 2 ), concatop( 2 ), concatop( 2 ) ];
end 
if inputsigned
result = [ '(', result, ' + ', convbit,  ...
')>>>', num2str( bpdiff ) ];
else 
result = [ '(', concatop( 1 ), sign_bit, ', ', result, concatop( 2 ), ' + ', convbit,  ...
')>>>', num2str( bpdiff ) ];
end 

else 
result = signalslice( resultname, inputsize, bpdiff + outputsize - 1, 0 );
result = addconversion( result, conversion );

if bpdiff - 1 == 0
convbit = [ concatop( 1 ), '1''b0, ~', sign_bit, concatop( 2 ) ];
else 
convbit = [ concatop( 1 ), '~', sign_bit,  ...
', ', concatop( 1 ), num2str( bpdiff - 1 ), concatop( 1 ),  ...
sign_bit, concatop( 2 ), concatop( 2 ), concatop( 2 ) ];
end 
if ~saturation
result = [ '(', result, ' + ', convbit, ')>>>', num2str( bpdiff ) ];
else 
result = [ '(', concatop( 1 ), sign_bit, ', ', result, ' + ', convbit, concatop( 2 ),  ...
')>>>', num2str( bpdiff ) ];
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
if conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
elseif conversion == 0 && inputsize == 1 && outputsigned == true
conversion = 6;
end 
result = addconversion( result, conversion );
end 

result = [ concatop( 1 ), result, ', ', hdlconstantvalue( 0,  - bpdiff, 0, 0 ), concatop( 2 ) ];

else 
result = resultname;
if outputsize > inputsize
if inputsigned
result = [ '{{', num2str( outputsize - inputsize ), '{',  ...
signalslice( resultname, inputsize, inputsize - 1 ), '}}, ' ...
, resultname, '}' ];
else 
result = [ '{', hdlconstantvalue( 0, outputsize - inputsize, 0, 0 ), ', ', resultname, '}' ];
end 
result = addconversion( result, conversion );
skip_finalconvert = 1;
elseif inputsize > outputsize
result = signalslice( result, inputsize, outputsize - 1, 0 );
result = addconversion( result, conversion );
else 
result = addconversion( result, conversion );
end 
end 

result = finalconvert( skip_finalconvert, result,  ...
inputsigned, inputvtype, inputsize,  ...
outputsigned, outputvtype, outputsize );



function result = vtc_extract_ceiling_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation )

skip_finalconvert = 0;

[ resultname, conversion, deltasize ] = signed_unsigned_name( name, saturation );

inputsize = inputsize + deltasize;

if inputsigned
sign_bit = [ signalslice( resultname, inputsize, inputsize - 1 ), ', ' ];
else 
sign_bit = '1''b0, ';
end 

bpdiff = inputbp - outputbp;
if inputbp - inputsize >= outputbp
warning( message( 'HDLShared:directemit:ceilingsat1', 'verilogtypeconvert', name ) );
if ( outputsigned == 0 && inputsigned == 0 ) ||  ...
( outputsigned == 1 && inputsigned == 0 )

result = [ '{', hdlconstantvalue( 0, outputsize - 1, 0, 1 ), ', ', '|', resultname, '}' ];
elseif outputsize == 1
result = [ '(~', signalslice( resultname, inputsize, inputsize - 1 ),  ...
') & |', signalslice( resultname, inputsize, inputsize - 2, 0 ) ];
elseif inputsize == 1
result = resultname;
else 

result = [ '{', hdlconstantvalue( 0, outputsize - 1, 0, 1 ), ', ',  ...
'(~', signalslice( resultname, inputsize, inputsize - 1 ),  ...
' & (|', signalslice( resultname, inputsize, inputsize - 2, 0 ), '))}' ];
end 
elseif (  - inputbp > ( outputsize - outputbp - outputsigned ) ) ||  ...
( (  - inputbp == ( outputsize - outputbp ) ) && outputsigned == 0 )

warning( message( 'HDLShared:directemit:ceilingsat2', 'verilogtypeconvert', name ) );
if ~outputsigned
if ~saturation
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif inputsize == 1
result = [ '{ ', num2str( outputsize ), '{', resultname, '} }' ];
else 

result = [ '|', resultname ];
end 
else 
if ~saturation
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 

result = [ '{', signalslice( resultname, inputsize, inputsize - 1 ), ', ',  ...
hdlconstantvalue( 0, outputsize - 1, 0, 1 ), '}' ];
end 
end 
elseif bpdiff > 0
if bpdiff + outputsize > inputsize
result = signalslice( resultname, inputsize, inputsize - 1, bpdiff );
if inputsigned
result = [ '{{', num2str( bpdiff + outputsize - inputsize ), '{',  ...
signalslice( resultname, inputsize, inputsize - 1 ), '}}, ' ...
, result, '}' ];
else 
result = [ '{', hdlconstantvalue( 0, bpdiff + outputsize - inputsize, 0, 0 ),  ...
', ', result, '}' ];
end 

if conversion == 4, conversion = 5;skip_finalconvert = 1;end 

if conversion == 2, conversion = 0;end 

result = addconversion( result, conversion );
if inputsigned
result = [ result, ' + |', signalslice( resultname, inputsize, bpdiff - 1, 0 ) ];
else 
result = [ '{', sign_bit, result, '} + |', signalslice( resultname, inputsize, bpdiff - 1, 0 ) ];
end 
else 
result = signalslice( resultname, inputsize, bpdiff + outputsize - 1, bpdiff );
result = addconversion( result, conversion );
if outputsize == 1
if saturation
result = [ result, ' | (|', signalslice( resultname, inputsize, bpdiff - 1, 0 ), ')' ];
else 
result = [ result, ' ^ (|', signalslice( resultname, inputsize, bpdiff - 1, 0 ), ')' ];
end 
else 
if ~saturation
result = [ result, ' + |', signalslice( resultname, inputsize, bpdiff - 1, 0 ) ];
else 
result = [ '{', sign_bit, result, '} + |', signalslice( resultname, inputsize, bpdiff - 1, 0 ) ];
end 
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
if conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
elseif conversion == 0 && inputsize == 1 && outputsigned == true
conversion = 6;
end 
result = addconversion( result, conversion );
end 


result = [ '{', result, ', ', hdlconstantvalue( 0,  - bpdiff, 0, 1 ), '}' ];

else 
result = resultname;
if outputsize > inputsize

if inputsigned
result = [ '{{', num2str( outputsize - inputsize ), '{',  ...
signalslice( resultname, inputsize, inputsize - 1 ), '}}, ' ...
, resultname, '}' ];
else 
result = [ '{', hdlconstantvalue( 0, outputsize - inputsize, 0, 0 ), ', ', resultname, '}' ];
end 
result = addconversion( result, conversion );
skip_finalconvert = 1;
elseif inputsize > outputsize
result = signalslice( result, inputsize, outputsize - 1, 0 );
result = addconversion( result, conversion );
else 
result = addconversion( result, conversion );
end 
end 

result = finalconvert( skip_finalconvert, result,  ...
inputsigned, inputvtype, inputsize,  ...
outputsigned, outputvtype, outputsize );



function result = vtc_extract_zero_bits( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation )

skip_finalconvert = 0;

[ resultname, conversion, deltasize ] = signed_unsigned_name( name, saturation );

inputsize = inputsize + deltasize;

if inputsigned == 0
sign_bit = [ signalslice( resultname, inputsize, inputsize - 1 ), ', ' ];
else 
sign_bit = '1''b0, ';
end 

if saturation == 0
sign_bit = '';
end 

bpdiff = inputbp - outputbp;
if inputbp - inputsize >= outputbp
warning( message( 'HDLShared:directemit:zerosat1', 'verilogtypeconvert', name ) );
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif (  - inputbp > ( outputsize - outputbp - outputsigned ) ) ||  ...
( (  - inputbp == ( outputsize - outputbp ) ) && outputsigned == 0 )

warning( message( 'HDLShared:directemit:zerosat2', 'verilogtypeconvert', name ) );
if ( outputsigned == 0 && inputsigned == 0 ) || ( outputsigned == 1 && inputsigned == 0 )
if ~saturation
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
elseif inputsize == 1
result = [ '{ ', num2str( outputsize ), '{', resultname, '} }' ];
else 

result = [ '|', resultname ];
end 
else 
if ~saturation
result = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
else 
if outputsize == 1
result = signalslice( resultname, inputsize, inputsize - 1 );
else 

result = [ '{', signalslice( resultname, inputsize, inputsize - 1 ), ', ',  ...
hdlconstantvalue( 0, outputsize - 1, 0, 1 ), '}' ];
end 
end 
end 
elseif bpdiff > 0
if bpdiff + outputsize > inputsize
result = signalslice( resultname, inputsize, inputsize - 1, bpdiff );
if inputsigned
result = [ '{{', num2str( bpdiff + outputsize - inputsize ), '{',  ...
signalslice( resultname, inputsize, inputsize - 1 ), '}}, ' ...
, result, '}' ];
else 
result = [ '{', hdlconstantvalue( 0, bpdiff + outputsize - inputsize, 0, 0 ),  ...
', ', result, '}' ];
end 

if conversion == 4, conversion = 5;skip_finalconvert = 1;end 

if conversion == 2, conversion = 0;end 

result = addconversion( result, conversion );
if inputsigned
if saturation
result = [ '{', sign_bit, result, '} + (',  ...
signalslice( resultname, inputsize, inputsize - 1 ), ' & |',  ...
signalslice( resultname, inputsize, bpdiff - 1, 0 ), ')' ];
else 
result = [ result, ' + (',  ...
signalslice( resultname, inputsize, inputsize - 1 ), ' & |',  ...
signalslice( resultname, inputsize, bpdiff - 1, 0 ), ')' ];
end 
end 

else 
result = signalslice( resultname, inputsize, bpdiff + outputsize - 1, bpdiff );
result = addconversion( result, conversion );
if inputsigned
result = [ '{', sign_bit, result, '} + (',  ...
signalslice( resultname, inputsize, inputsize - 1 ), ' & |',  ...
signalslice( resultname, inputsize, bpdiff - 1, 0 ), ')' ];
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
if conversion == 4 && inputsigned == false && outputsigned == true
conversion = 5;
elseif conversion == 0 && inputsize == 1 && outputsigned == true
conversion = 6;
end 
result = addconversion( result, conversion );
end 
result = [ '{', result, ', ', hdlconstantvalue( 0,  - bpdiff, 0, 1 ), '}' ];
else 
result = resultname;
if outputsize > inputsize

if inputsigned
result = [ '{{', num2str( outputsize - inputsize ), '{',  ...
signalslice( resultname, inputsize, inputsize - 1 ), '}}, ' ...
, resultname, '}' ];
else 
result = [ '{', hdlconstantvalue( 0, outputsize - inputsize, 0, 0 ), ', ', resultname, '}' ];
end 
result = addconversion( result, conversion );
skip_finalconvert = 1;
elseif inputsize > outputsize
result = signalslice( result, inputsize, outputsize - 1, 0 );
result = addconversion( result, conversion );
else 
result = addconversion( result, conversion );
end 
end 

result = finalconvert( skip_finalconvert, result,  ...
inputsigned, inputvtype, inputsize,  ...
outputsigned, outputvtype, outputsize );



function [ result ] = signalslice( name, inputsize, upperlimit, lowerlimit )

if inputsize == 1
result = name;
else 
array_deref = hdlgetparameter( 'array_deref' );

if nargin == 3
lowerlimit = upperlimit;
end 
lowerlimit = max( lowerlimit, 0 );
if upperlimit == lowerlimit
result = [ name, array_deref( 1 ), num2str( upperlimit ), array_deref( 2 ) ];
else 
result = [ name, array_deref( 1 ), num2str( upperlimit ), ':',  ...
num2str( lowerlimit ), array_deref( 2 ) ];
end 
end 




function [ result ] = signalresize( name, size )
result = name;



function result = addconversion( name, convertnum )

switch convertnum
case 0
result = name;
case 1
result = name;
case 2
result = [ '$unsigned(', name, ')' ];
case 3
result = [ '$unsigned( {1''b0, ', name, '})' ];
case 4
result = [ '$signed(', name, ')' ];
case 5
result = [ '$signed( {1''b0, ', name, '})' ];
case 6
result = [ '$unsigned( {1''b0, ', name, '})' ];
otherwise 
result = name;
end 




function [ newname, conversion, deltasize ] = signed_unsigned_name( name, saturation )

deltasize = 0;
if length( name ) > 10 && strcmp( name( 1:10 ), '$unsigned(' ) && name( end  ) == ')'
newname = name( 11:end  - 1 );
conversion = 2;
elseif length( name ) > 15 && strcmp( name( 1:15 ), '$signed({1''b0, ' ) && strcmp( name( end  - 1:end  ), '})' )
newname = name( 16:end  - 2 );
deltasize =  - 1;
if saturation
conversion = 4;
else 
conversion = 4;
end 
elseif length( name ) > 8 && strcmp( name( 1:8 ), '$signed(' ) && name( end  ) == ')'
newname = name( 9:end  - 1 );
conversion = 4;
else 
newname = name;
conversion = 0;
end 



function [ result ] = finalconvert( skip, name, inputsigned, inputvtype, inputsize, outputsigned, outputvtype, outputsize )


if outputsigned == 1 && inputsigned == 1
if name( 1 ) == '{'
result = [ '$signed(', name, ')' ];
else 
result = name;
end 
elseif ~skip && outputsigned == 1 && inputsigned == 0

result = [ '$signed(', name, ')' ];
elseif ~skip && outputsigned == 0 && inputsigned == 1

if length( name ) > 10 && strcmp( name( 1:10 ), '$unsigned(' )
result = name;
else 
result = [ '$unsigned(', name, ')' ];
end 
else 
result = name;
end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmp3d6wIh.p.
% Please follow local copyright laws when handling this file.

