function listenPWD( this, isListen )




R36
this
isListen = true;
end 

if isListen
if isempty( this.DirectoryListener )


this.DirectoryListener = matlab.internal.mvm.eventmgr.MVMEvent.subscribe(  ...
'mvm_events::CurrentWorkFolderChangedEvent',  ...
@( evt )RptgenML.FileConverter.listFiles( '-force' ) );
end 
else 
if ~isempty( this.DirectoryListener )
delete( this.DirectoryListener );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpFkumJ5.p.
% Please follow local copyright laws when handling this file.

