function tf=canUseMultiThreading()










%#codegen

    coder.allowpcode('plain');

    ctx=eml_option('CodegenBuildContext');

    buildWorkflow=coder.const(@feval,'dlcoder_base.internal.getBuildWorkflow',ctx);

    if coder.const(feval('dlcoderfeature','UseCodegenConfigSetForSimulation'))&&strcmpi(buildWorkflow,'simulation')



        if~isempty(ctx)
            opt=coder.const(feval('getConfigProp',ctx,'MultiThreadedLoops'));
            tf=~isempty(opt)&&coder.const(feval('strcmp',opt,'on'));
        else
            tf=false;
        end
    elseif strcmpi(buildWorkflow,'simulink')







        tf=eml_option('EnablePARFOR');
    elseif strcmpi(buildWorkflow,'matlab')




        tf=eml_option('EnablePARFOR')&&eml_option('CompilerSupportsOpenMP');
    else
        tf=false;
    end
end

