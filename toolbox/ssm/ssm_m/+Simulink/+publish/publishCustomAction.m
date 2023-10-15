function publishCustomAction( modelName )

arguments
    modelName
end

if exist( modelName, 'file' ) == 4

    ssm.sl_agent_metadata.internal.genCustomActionFromModel( modelName );

elseif exist( modelName, 'file' ) == 2

    ssm.sl_agent_metadata.internal.genCustomActionFromSystemObject( modelName );

elseif evalin( 'base', [ 'exist(''', modelName, ''', ''var'')' ] ) == 1


    objBus = evalin( 'base', modelName );
    if isa( objBus, 'Simulink.Bus' )
        builder = ssm.sl_agent_metadata.internal.CustomActionBuilder( modelName );


        builder.ActionName = modelName;
        builder.buildData;
        builder.writeToFile;
    end
end

