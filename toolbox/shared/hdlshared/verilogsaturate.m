function result = verilogsaturate( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation, previousresult )









comment_char = hdlgetparameter( 'comment_char' );

rmode = strcmpi( rounding, { 'round', 'nearest', 'ceil', 'ceiling', 'convergent' } );

[ basename, deltasize ] = signed_unsigned_basename( name );
inputsize = inputsize + deltasize;

bpdiff = outputbp - inputbp;
intdiff = ( outputsize - outputbp ) - ( inputsize - inputbp );

if inputsigned == 1 && outputsigned == 0
intdiff = intdiff + 1;
elseif inputsigned == 0 && outputsigned == 1
intdiff = intdiff - 1;
end 

if outputsigned == 1
maxoutvalue = hdlconstantvalue( inf, outputsize, outputbp, outputsigned );
minoutvalue = hdlconstantvalue(  - inf, outputsize, outputbp, outputsigned );
else 
maxoutvalue = hdlconstantvalue( inf, outputsize, outputbp, outputsigned );
minoutvalue = hdlconstantvalue( 0, outputsize, outputbp, outputsigned );
end 

if inputsigned
bottombit = max( inputsize + intdiff - 1, 0 );
if inputsize - 2 == inputsize + intdiff - 1
lowerbits = ']';
lowersize = 1;
else 
lowerbits = [ ':', num2str( bottombit ), ']' ];
lowersize = max( inputsize - 2 - bottombit + 1, 1 );
end 

overflowcondition = [ basename, '[', num2str( inputsize - 1 ), '] == 1''b0 & ',  ...
basename, '[', num2str( inputsize - 2 ),  ...
lowerbits, ' != ',  ...
hdlconstantvalue( 0, lowersize, 0, 0 ) ];

tempsize = max( bottombit - outputsize + 1, 0 );
if any( rmode ) &&  ...
intdiff < 0 &&  ...
 - intdiff <= inputsize &&  ...
outputsigned == 1 &&  ...
outputsize > 1 &&  ...
outputsize <= inputsize &&  ...
tempsize <= bottombit &&  ...
bpdiff <= 0
if inputsize - 1 ~= bottombit
checksign = [ basename, '[', num2str( inputsize - 1 ), '] == 1''b0 && ' ];
else 
checksign = '';
end 

overflowcondition = [ '(', overflowcondition, ') || (',  ...
checksign,  ...
basename, '[', num2str( bottombit ),  ...
':', num2str( tempsize ), '] == ',  ...
hdlconstantvalue( inf, ( bottombit - tempsize + 1 ), 0, 1 ),  ...
') ', comment_char, ' special case0\n' ];
end 

if outputsigned == 1
underflowcondition = [ basename, '[', num2str( inputsize - 1 ), '] == 1''b1 && ',  ...
basename, '[', num2str( inputsize - 2 ),  ...
lowerbits, ' != ',  ...
hdlconstantvalue( inf, lowersize, 0, 0 ) ];
else 
underflowcondition = [ basename, '[', num2str( inputsize - 1 ), '] == 1''b1 ' ];
end 

else 
bottombit = max( inputsize + intdiff, 0 );
if inputsize - 2 == inputsize + intdiff - 1
lowerbits = ']';
lowersize = 1;
overflowcondition = [ basename, '[', num2str( inputsize - 1 ),  ...
lowerbits, ' != ',  ...
hdlconstantvalue( 0, lowersize, 0, 0 ) ];

elseif bottombit >= inputsize - 1
overflowcondition = '';
lowersize = 0;
else 
bottombit = max( inputsize + intdiff, 0 );
lowerbits = [ ':', num2str( bottombit ), ']' ];
lowersize = max( inputsize - 1 - bottombit + 1, 1 );
overflowcondition = [ basename, '[', num2str( inputsize - 1 ),  ...
lowerbits, ' != ',  ...
hdlconstantvalue( 0, lowersize, 0, 0 ) ];
end 

underflowcondition = '';

if any( rmode ) && intdiff < 0 && outputsize > 1 &&  ...
outputsize < inputsize && lowersize ~= inputsize
if outputsigned == 1
highbit = min( inputsize + intdiff, inputsize - 1 );
tempsize = max( inputsize + intdiff - outputsize + 1, 0 );
overflowcondition = [ overflowcondition, ' || ', basename, '[', num2str( highbit ),  ...
':', num2str( tempsize ), '] == ',  ...
hdlconstantvalue( inf, highbit - tempsize + 1, 0, 1 ),  ...
' ', comment_char, ' special case1\n' ];
else 
highbit = min( inputsize + intdiff - 1, inputsize - 1 );
tempsize = max( inputsize + intdiff - outputsize, 0 );
if highbit > tempsize
overflowcondition = [ overflowcondition, ' || ', basename, '[', num2str( highbit ),  ...
':', num2str( tempsize ), '] == ',  ...
hdlconstantvalue( inf, highbit - tempsize + 1, 0, 0 ),  ...
' ', comment_char, ' special case1\n' ];

end 
end 
end 
end 

flag = 0;

if bpdiff < 0
if intdiff < 0
flag = 1;
elseif intdiff > 0
if inputsigned == 1 && outputsigned == 0
overflowcondition = '';
flag = 1;
else 

end 
else 
if inputsigned == 1 && outputsigned == 0
overflowcondition = '';
flag = 1;
end 

if any( rmode );
flag = 1;
if rmode( 1 ) || rmode( 2 ) || rmode( 5 )
lowlimit = max(  - bpdiff - 1, 0 );
else 
lowlimit = max(  - bpdiff, 0 );
end 

if inputsize - lowlimit == 1
lowerbits = ']';
lowersize = 1;
else 
lowerbits = [ ':', num2str( lowlimit ), ']' ];
lowersize = inputsize - 1 - lowlimit;
end 

if inputsigned
overflowcondition = [ basename, '[', num2str( inputsize - 1 ), '] == 1''b0 && ',  ...
basename, '[', num2str( inputsize - 2 ),  ...
lowerbits, ' == ',  ...
hdlconstantvalue( inf, lowersize, 0, 0 ) ];
if outputsigned
underflowcondition = '';
end 
else 
underflowcondition = '';
if outputsigned == 0
overflowcondition = [ basename, '[', num2str( inputsize - 1 ),  ...
lowerbits, ' == ',  ...
hdlconstantvalue( inf, lowersize + 1, 0, 0 ) ];
else 
tempsize = max( inputsize - outputsize, 0 );
if outputsize > 1
if ~isempty( overflowcondition )
overflowcondition = [ overflowcondition, ' || ' ];
end 
if tempsize < inputsize - 1
overflowcondition = [ overflowcondition, basename, '[', num2str( inputsize - 1 ),  ...
':', num2str( tempsize ), '] == ',  ...
hdlconstantvalue( inf, outputsize, 0, 0 ),  ...
' ', comment_char, ' special case2\n' ];
else 
overflowcondition = [ overflowcondition, basename,  ...
'[', num2str( inputsize - 1 ),  ...
'] == ',  ...
hdlconstantvalue( 0, 1, 0, 0 ),  ...
' ', comment_char, ' special case3\n' ];
end 
end 
end 
end 
end 
end 
elseif bpdiff > 0
if intdiff < 0

flag = 1;
elseif intdiff > 0
if inputsigned == 1 && outputsigned == 0
overflowcondition = '';
flag = 1;
else 

end 
else 
if inputsigned == 1 && outputsigned == 0
overflowcondition = '';
flag = 1;
else 

end 
end 

else 
if intdiff < 0

flag = 1;
elseif intdiff > 0
if inputsigned == 1 && outputsigned == 0
overflowcondition = '';
flag = 1;
else 

end 
else 
if inputsigned == 1 && outputsigned == 0
overflowcondition = '';
flag = 1;
else 

end 
end 
end 


if flag == 0 || ( isempty( underflowcondition ) && isempty( overflowcondition ) )
result = previousresult;
elseif isempty( underflowcondition )
result = [ '(', overflowcondition, ') ? ', maxoutvalue, ' : ', previousresult ];

resourceLog( 2, outputsize, 'mux' )
elseif isempty( overflowcondition )
result = [ '(', underflowcondition, ') ? ', minoutvalue, ' : ', previousresult ];

resourceLog( 2, outputsize, 'mux' )
else 
result = [ '(', overflowcondition, ') ? ', maxoutvalue, ' : ',  ...
'\n      (', underflowcondition, ') ? ', minoutvalue,  ...
' : ', previousresult ];

resourceLog( 3, outputsize, 'mux' )
end 



function [ newname, deltasize ] = signed_unsigned_basename( name )

deltasize = 0;
if length( name ) > 10 && strcmp( name( 1:10 ), '$unsigned(' ) && name( end  ) == ')'
newname = name( 11:end  - 1 );
elseif length( name ) > 15 && strcmp( name( 1:15 ), '$signed({1''b0, ' ) && strcmp( name( end  - 1:end  ), '})' )
newname = name( 16:end  - 2 );
deltasize =  - 1;
elseif length( name ) > 8 && strcmp( name( 1:8 ), '$signed(' ) && name( end  ) == ')'
newname = name( 9:end  - 1 );
else 
newname = name;
end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmp7C98Qw.p.
% Please follow local copyright laws when handling this file.

