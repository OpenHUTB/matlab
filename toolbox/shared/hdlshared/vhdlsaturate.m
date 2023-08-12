function result = vhdlsaturate( name, inputsize, inputbp, inputsigned, inputvtype,  ...
outputsize, outputbp, outputsigned, outputvtype,  ...
rounding, saturation, previousresult )






rmode = strcmpi( rounding, { 'Round', 'Nearest', 'Ceil', 'Ceiling', 'Convergent' } );

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
lowerbits = ')';
lowerquote = '''';
lowersize = 1;
else 
lowerbits = [ ' DOWNTO ', num2str( bottombit ), ')' ];
lowerquote = '"';
lowersize = max( inputsize - 2 - bottombit + 1, 1 );
end 

overflowcondition = [ basename, '(', num2str( inputsize - 1 ), ') = ''0'' AND ',  ...
basename, '(', num2str( inputsize - 2 ),  ...
lowerbits, ' /= ',  ...
lowerquote, sprintf( '%d', zeros( 1, lowersize ) ), lowerquote ];

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
checksign = [ basename, '(', num2str( inputsize - 1 ), ') = ''0'' AND ' ];
else 
checksign = '';
end 

overflowcondition = [ '(', overflowcondition, ') OR (',  ...
checksign,  ...
basename, '(', num2str( bottombit ),  ...
' DOWNTO ', num2str( tempsize ), ') = "0',  ...
sprintf( '%d', ones( 1, ( bottombit - tempsize + 1 ) - 1 ) ), '")', ' -- special case0' ];
end 

if outputsigned == 1
underflowcondition = [ basename, '(', num2str( inputsize - 1 ), ') = ''1'' AND ',  ...
basename, '(', num2str( inputsize - 2 ),  ...
lowerbits, ' /= ',  ...
lowerquote, sprintf( '%d', ones( 1, lowersize ) ), lowerquote ];
else 
underflowcondition = [ basename, '(', num2str( inputsize - 1 ), ') = ''1'' ' ];
end 

else 
bottombit = max( inputsize + intdiff, 0 );
if ( inputsize - 2 == inputsize + intdiff - 1 )
lowerbits = ')';
lowerquote = '''';
lowersize = 1;
overflowcondition = [ basename, '(', num2str( inputsize - 1 ),  ...
lowerbits, ' /= ',  ...
lowerquote, sprintf( '%d', zeros( 1, lowersize ) ), lowerquote ];
elseif bottombit >= inputsize - 1
overflowcondition = '';
lowersize = 0;
else 
lowerbits = [ ' DOWNTO ', num2str( bottombit ), ')' ];
lowerquote = '"';
lowersize = max( inputsize - 1 - bottombit + 1, 1 );
overflowcondition = [ basename, '(', num2str( inputsize - 1 ),  ...
lowerbits, ' /= ',  ...
lowerquote, sprintf( '%d', zeros( 1, lowersize ) ), lowerquote ];
end 

underflowcondition = '';

if any( rmode ) && intdiff < 0 && outputsize > 1 &&  ...
outputsize < inputsize && lowersize ~= inputsize
if outputsigned == 1
highbit = min( inputsize + intdiff, inputsize - 1 );
tempsize = max( inputsize + intdiff - outputsize + 1, 0 );
overflowcondition = [ overflowcondition, ' OR ', basename, '(', num2str( highbit ),  ...
' DOWNTO ', num2str( tempsize ), ') = "0',  ...
sprintf( '%d', ones( 1, highbit - tempsize ) ), '"', ' -- special case1' ];
else 
highbit = min( inputsize + intdiff - 1, inputsize - 1 );
tempsize = max( inputsize + intdiff - outputsize, 0 );
if highbit > tempsize
overflowcondition = [ overflowcondition, ' OR ', basename, '(', num2str( highbit ),  ...
' DOWNTO ', num2str( tempsize ), ') = "',  ...
sprintf( '%d', ones( 1, highbit - tempsize + 1 ) ), '"', ' -- special case1' ];
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
lowerbits = ')';
lowersize = 1;
lowerquote = '''';
else 
lowerbits = [ ' DOWNTO ', num2str( lowlimit ), ')' ];
lowersize = inputsize - 1 - lowlimit;
lowerquote = '"';
end 

if inputsigned
overflowcondition = [ basename, '(', num2str( inputsize - 1 ), ') = ''0'' AND ',  ...
basename, '(', num2str( inputsize - 2 ),  ...
lowerbits, ' = ',  ...
lowerquote, sprintf( '%d', ones( 1, lowersize ) ), lowerquote ];
if outputsigned
underflowcondition = '';
end 
else 
underflowcondition = '';
if outputsigned == 0
overflowcondition = [ basename, '(', num2str( inputsize - 1 ),  ...
lowerbits, ' = ',  ...
lowerquote, sprintf( '%d', ones( 1, lowersize + 1 ) ), lowerquote ];
else 
tempsize = max( inputsize - outputsize, 0 );
if outputsize > 1
if ~isempty( overflowcondition )
overflowcondition = [ overflowcondition, ' OR ' ];
end 
if tempsize < inputsize - 1
overflowcondition = [ overflowcondition, basename,  ...
'(', num2str( inputsize - 1 ),  ...
' DOWNTO ', num2str( tempsize ), ') = "',  ...
sprintf( '%d', ones( 1, outputsize ) ), '"', ' -- special case2' ];
else 
overflowcondition = [ overflowcondition, basename,  ...
'(', num2str( inputsize - 1 ),  ...
') = ''0''',  ...
' -- special case3' ];
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
result = [ maxoutvalue,  ...
' WHEN ', overflowcondition,  ...
'\n      ELSE ', previousresult ];

resourceLog( 2, outputsize, 'mux' )
elseif isempty( overflowcondition )
result = [ minoutvalue,  ...
' WHEN ', underflowcondition,  ...
'\n      ELSE ', previousresult ];

resourceLog( 2, outputsize, 'mux' )
else 
result = [ maxoutvalue,  ...
' WHEN ', overflowcondition,  ...
'\n      ELSE ',  ...
minoutvalue,  ...
' WHEN ', underflowcondition,  ...
'\n      ELSE (', previousresult, ')' ];

resourceLog( 3, outputsize, 'mux' )

end 



function [ newname, deltasize ] = signed_unsigned_basename( name )

deltasize = 0;
if length( name ) > 17 && strcmp( name( 1:17 ), 'std_logic_vector(' ) && name( end  ) == ')'
newname = name( 18:end  - 1 );
elseif length( name ) > 9 && strcmp( name( 1:9 ), 'unsigned(' ) && name( end  ) == ')'
newname = name( 10:end  - 1 );
elseif length( name ) > 14 && strcmp( name( 1:14 ), 'signed( ''0'' & ' ) && name( end  ) == ')'
newname = name( 15:end  - 1 );
deltasize =  - 1;
elseif length( name ) > 7 && strcmp( name( 1:7 ), 'signed(' ) && name( end  ) == ')'
newname = name( 8:end  - 1 );
else 
newname = name;
end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpOW156A.p.
% Please follow local copyright laws when handling this file.

