function updateTransformedData( p )









data = p.pData_Raw;
dataU = p.DataUnits;
dispU = p.DisplayUnits;


is_lin = strcmpi( dispU, 'linear' );
if ~strcmpi( dispU, dataU )
Nd = numel( data );
if is_lin
if strcmpi( dataU, 'db' )

for i = 1:Nd
data( i ).mag = 10 .^ ( data( i ).mag ./ 20 );
end 
elseif strcmpi( dataU, 'db loss' )

for i = 1:Nd
data( i ).mag = 10 .^ (  - data( i ).mag ./ 20 );
end 
end 
else 
if strcmpi( dataU, 'linear' )





for i = 1:Nd
mag = data( i ).mag;
isNonNeg = mag >= 0;
mag( isNonNeg ) = 20 .* log10( mag( isNonNeg ) );
mag( ~isNonNeg ) = NaN;
data( i ).mag = mag;

if any( ~isNonNeg )
if all( ~isNonNeg )
str = 'All';
else 
str = 'Some';
end 
str = [ str ...
, ' input magnitudes are negative, and cannot be shown in dB.' ];%#ok<AGROW>
warning( 'polari:AllMinusInf', str );
showBannerMessage( p, str );
end 
end 
else 

for i = 1:Nd
data( i ).mag =  - data( i ).mag;
end 
end 
end 
end 



if p.NormalizeData
N = numel( data );
for i = 1:N
m_i = data( i ).mag;
m_max = max( m_i );
if is_lin
m_i = m_i ./ m_max;
else 
m_i = m_i - m_max;
end 
data( i ).mag = m_i;
end 
end 


p.pData = data;
p.DataCacheDirty = false;

% Decoded using De-pcode utility v1.2 from file /tmp/tmptp_tA4.p.
% Please follow local copyright laws when handling this file.

