function out = TargetLangStandard( action, cc, param, value )

arguments
    action
    cc
end
arguments( Repeating )
    param
    value
end

out = [  ];
allowed = [ "C89/C90 (ANSI)", "C99 (ISO)" ];
if ~any( allowed == value{ 1 } )
    if action == "apply"


        set_param( cc.getConfigSet, param{ 1 }, allowed( end  ) );
    else
        out = message( 'RTW:configSet:IncompatibleParameter', param{ 1 } );
    end
end

