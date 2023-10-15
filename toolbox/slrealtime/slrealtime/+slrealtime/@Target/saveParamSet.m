function saveParamSet( this, fileName, page )

arguments
    this
    fileName
    page = 0
end

validateattributes( page, { 'numeric' }, { 'scalar' } );
if page < 0 || page >= this.getNumPages(  ) || ( floor( page ) ~= page )
    this.throwError( 'slrealtime:target:invalidPageNum', num2str( page ) );
end

if ~this.isLoaded
    this.throwError( 'slrealtime:paramSet:tgIsNotLoaded' );
end

waitfor( this.tc, 'ParamSetConnected', true );

validateattributes( fileName, { 'char', 'string' }, { 'scalartext' } );
fileName = convertStringsToChars( fileName );

[ ~, fileName, ~ ] = fileparts( fileName );
if isempty( fileName )
    this.throwError( 'slrealtime:paramSet:invalidFileName' );
end




saveComplete = false;
    function cb( ~, evnt )
        if ~evnt.AffectedObject.isParamSetRunning
            saveComplete = true;
        end
    end

try
    l1 = addlistener( this.tc, 'isParamSetRunning', 'PostSet', @cb );
    c1 = onCleanup( @(  )delete( l1 ) );

    this.tc.paramSetCommand( 'save', fileName, 0, page );

    while ~saveComplete
        pause( 0.01 );
    end

    if ~isempty( this.tc.ParamSetProperties.Error )
        this.throwError( 'slrealtime:paramSet:failOnSave', this.tc.ParamSetProperties.Error );
    end

catch ME
    throwAsCaller( ME );
end

end
