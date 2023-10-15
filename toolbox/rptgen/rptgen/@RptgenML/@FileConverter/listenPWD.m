function listenPWD( this, isListen )

arguments
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


