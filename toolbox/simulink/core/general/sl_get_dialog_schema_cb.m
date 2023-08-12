function [ status, message ] = sl_get_dialog_schema_cb( dlg, action, h )



status = true;
message = '';




if strcmpi( action, 'doPreApply' )
dataType = dlg.getWidgetValue( 'dataType_tag' );
value = dlg.getWidgetValue( 'value_tag' );
dimensions = dlg.getWidgetValue( 'dimension_tag' );
complexity = dlg.getWidgetValue( 'complexity_tag' );

value = eval( [ dataType, '(', value, ')' ] );

source = h.getPropValue( 'Source' );
section = h.getPropValue( 'Section' );
name = h.getPropValue( 'Name' );

mfmdl = mf.zero.Model;
dataSrcIno = sl.data.srccache.DataSourceInfo.createObject( source, section, mfmdl );
conn = sl.data.srccache.CacheConnection.createConnection( dataSrcIno, mfmdl );

conn.assignInVariable( name, value, dataSrcIno );



ed = DAStudio.EventDispatcher;
ed.broadcastEvent( 'ListChangedEvent' );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpF7nBmD.p.
% Please follow local copyright laws when handling this file.

