function env=getModelEnvironment(smc)




    ;
    env=MECH.ModelEnvironment;

    props=fieldnames(env);
    for i=1:length(props)
        if isa(env.(props{i}),'double')
            env.(props{i})=evalin('base',smc.(props{i}));
        else
            env.(props{i})=smc.(props{i});
        end
    end




