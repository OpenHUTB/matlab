function vhdltype = vhdlblockdatatype( dt )






switch dt
case { 'fixdt(''float16'')', 'single', 'half' }

vhdltype = 'real';
case 'str'
vhdltype = 'std_logic_vector(7 DOWNTO 0)';
otherwise 
vhdltype = vhdlgetvtype( dt );
end 







% Decoded using De-pcode utility v1.2 from file /tmp/tmp69IuyC.p.
% Please follow local copyright laws when handling this file.

