


function dpigenerator_setvariable(prop,value)

    mgr=dpig.internal.VariableManager.getInstance;

    if nargin==0
        mgr.init;
    else
        mgr.(prop)=value;
    end

end