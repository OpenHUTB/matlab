function fList = addFunction( this, functionNames )

arguments
    this{ mustBeA( this, 'systemcomposer.arch.Architecture' ) }
    functionNames{ mustBeText }
end

functionNames = string( functionNames );

this.validateAPISupportForAUTOSAR( 'addFunction' );

if strcmp( this.Definition, 'Composition' ) &&  ...
        ~( Simulink.internal.isArchitectureModel( this.SimulinkModelHandle, 'SoftwareArchitecture' ) ||  ...
        Simulink.internal.isArchitectureModel( this.SimulinkModelHandle, 'AUTOSARArchitecture' ) )
    error( 'systemcomposer:API:CannotAddFunctionToSysArch', message(  ...
        'SystemArchitecture:API:CannotAddFunctionToSysArch' ).getString );
elseif strcmp( this.Definition, 'Behavior' )
    error( 'systemcomposer:API:CannotAddFunctionToBehArch', message(  ...
        'SystemArchitecture:API:CannotAddFunctionToBehArch' ).getString );
elseif isempty( this.Parent )
    error( 'systemcomposer:API:CannotAddFunctionToRootArch', message(  ...
        'SystemArchitecture:API:CannotAddFunctionToRootArch' ).getString );
elseif this.Parent.IsAdapterComponent
    error( 'systemcomposer:API:CannotAddFunctionToAdapterComps', message(  ...
        'SystemArchitecture:API:CannotAddFunctionToAdapterComps' ).getString );
end

t = this.MFModel.beginTransaction;
addedBlocks = [  ];
fList = systemcomposer.arch.Function.empty(  );

for i = 1:numel( functionNames )

    txnSuspender = systemcomposer.internal.SubdomainBlockValidationSuspendTransaction( this.SimulinkModelHandle );

    try

        fName = functionNames( i );
        zcModel = systemcomposer.architecture.model.SystemComposerModel ...
            .getSystemComposerModel( this.MFModel );

        inportName = strcat( zcModel.getRootArchitecture(  ).getName(  ), '/', fName );
        inpBlock = add_block( 'built-in/Inport', inportName,  ...
            'MakeNameUnique', 'on',  ...
            'OutputFunctionCall', 'on' );
        addedBlocks( end  + 1 ) = inpBlock;%#ok


        functionName = get_param( inpBlock, 'Name' );


        compH = get_param( string( this.getQualifiedName(  ) ), 'Handle' );
        parentComp = systemcomposer.utils.getArchitecturePeer( compH );
        calledFunc =  ...
            parentComp.getArchitecture(  ).getTrait( systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass ).createFunction(  ...
            functionName, systemcomposer.architecture.model.swarch.FunctionType.OSFunction );

        rootSWTrait =  ...
            zcModel.getRootArchitecture(  ).getTrait( systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass );
        rootFunc = rootSWTrait.createFunction(  ...
            functionName, systemcomposer.architecture.model.swarch.FunctionType.OSFunction );
        rootFunc.setCalledFunctionInfo( parentComp, calledFunc );


        swarch.utils.applyDefaultStereotypesToFunction( calledFunc );

        fList( i ) = systemcomposer.internal.getWrapperForImpl( rootFunc );

    catch ME

        for j = 1:length( addedBlocks )
            delete_block( addedBlocks( j ) );
        end

        fList = [  ];%#ok
        delete( txnSuspender );
        rethrow( ME );
    end

    delete( txnSuspender );
end

t.commit;
end


