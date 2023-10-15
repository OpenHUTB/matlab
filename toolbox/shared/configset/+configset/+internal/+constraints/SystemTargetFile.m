function out = SystemTargetFile( action, cc, param, value )

arguments
    action
    cc
end
arguments( Repeating )
    param
    value
end

out = [  ];
if length( param ) >= 2 && param{ 2 } == "PlatformDefinition"
    platform = value{ 2 };
else
    platform = get_param( cc, 'PlatformDefinition' );
end
allowed = configset.internal.constraints.getSystemTargetFile(  ...
    get_param( cc, 'EmbeddedCoderDictionary' ), platform );
if allowed == ""

    allowed = "ert.tlc";
end
if ~isSupportedTarget( allowed )





    out = message(  ...
        'RTW:configSet:UnsupportedSystemTargetFileInPlatformDefinition',  ...
        allowed, platform );
elseif ~strcmp( value{ 1 }, allowed )
    if action == "apply"
        cs = cc.getConfigSet;
        set_param( cs, 'SystemTargetFile', allowed );
    else
        out = message( 'RTW:configSet:IncompatibleParameter', param{ 1 } );
    end
end

end

function out = isSupportedTarget( target )

if target == "ert.tlc"
    out = true;
elseif any( target == [ "autosar.tlc", "autosar_adaptive.tlc" ] )
    out = false;
else

    cs = Simulink.ConfigSet;
    set_param( cs, 'SystemTargetFile', target );
    out = get_param( cs, 'IsERTTarget' ) == "on";
end

end

