function outputValue = slddEvalDataSrc( dataSrc, entryKeyTxt )




try 
dsa = Simulink.dd.DataSourceAccessor( dataSrc );
entries = dsa.entries;
entryKey = Simulink.dd.DataSourceEntryKey.fromString( entryKeyTxt );
ddEntryInfo = entries.find( entryKey );
ddValue = ddEntryInfo.Value;

if ( ~isa( ddValue, 'Simulink.dd.NullValue' ) )
path = '';
outputValue = slprivate( 'wrapComparisonItem', ddEntry, ddEntryInfo.Name, ddValue, path, false );

outputValue.addprop( 'DataSource' );
outputValue.addprop( 'LastModified' );
outputValue.addprop( 'LastModifiedBy' );
outputValue.addprop( 'Status' );

outputValue.DataSource = ddEntryInfo.DataSource;
outputValue.LastModified = Simulink.dd.private.convertISOTimeToLocal( ddEntryInfo.LastModified );
outputValue.LastModifiedBy = ddEntryInfo.LastModifiedBy;
outputValue.Status = ddEntryInfo.Status;
else 
outputValue = ddValue;
end 

catch 
outputValue = Simulink.dd.NullValue;
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQl05Xl.p.
% Please follow local copyright laws when handling this file.

