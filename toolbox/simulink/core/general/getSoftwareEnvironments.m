

















function ret = getSoftwareEnvironments( varargin )

persistent softwareEnvironmentTable;

if isempty( softwareEnvironmentTable )


index = 1;






softwareEnvironmentTable( index ).Name = 'C89/C90 (ANSI)';
softwareEnvironmentTable( index ).Type = 'ANSI_C';
softwareEnvironmentTable( index ).Environment = 'ansi_tfl_tmw.mat';
index = index + 1;

softwareEnvironmentTable( index ).Name = 'C99 (ISO)';
softwareEnvironmentTable( index ).Type = 'ISO_C';
softwareEnvironmentTable( index ).Environment = 'iso_tfl_tmw.mat';
index = index + 1;

softwareEnvironmentTable( index ).Name = 'GNU99 (GNU)';
softwareEnvironmentTable( index ).Type = 'GNU';
softwareEnvironmentTable( index ).Environment = 'gnu_tfl_tmw.mat';
index = index + 1;





end 

ret = [  ];
if nargin == 1
name = varargin{ 1 };
if isempty( name )
ret = softwareEnvironmentTable;
else 
for i = 1:length( softwareEnvironmentTable )
if strcmp( softwareEnvironmentTable( i ).Type, name )
ret = softwareEnvironmentTable( i );
break ;
end 
end 
end 
else 
mode = varargin{ 1 };
val = varargin{ 2 };

switch mode
case 'Type'
for i = 1:length( softwareEnvironmentTable )
if strcmp( softwareEnvironmentTable( i ).Type, val )
ret = softwareEnvironmentTable( i );
break ;
end 
end 

case 'Name'
for i = 1:length( softwareEnvironmentTable )
if strcmp( softwareEnvironmentTable( i ).Name, val )
ret = softwareEnvironmentTable( i );
break ;
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpz6AiV1.p.
% Please follow local copyright laws when handling this file.

