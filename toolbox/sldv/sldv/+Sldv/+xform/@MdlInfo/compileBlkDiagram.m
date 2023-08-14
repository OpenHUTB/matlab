function compileBlkDiagram(mdlH,mdlWasCompiled,target)




    if nargin<3
        target='compileForSizes';
    end

    if~mdlWasCompiled
        mdlName=get_param(mdlH,'Name');
        try
            doit();
        catch Mex
            ok=false;
            if strcmp(Mex.identifier,'Simulink:Data:WksErrorInLateBindingWithBlock')


                try
                    doit();
                    ok=true;
                catch

                end
            end
            if~ok
                newExc=MException('Sldv:xform:MdlInfo:compileBlkDiagram:FailedToCompile',...
                'Failed to compile ''%s''',mdlName);
                newExc=newExc.addCause(Mex);
                throw(newExc);
            end
        end
    end

    function doit()
        standaloneMode=false;
        Simulink.observer.internal.loadObserverModelsForBD(mdlH,standaloneMode);
        set_param(mdlName,'InSLDVAnalysis','on');
        oc=onCleanup(@()set_param(mdlName,'InSLDVAnalysis','off'));
        if strcmp(target,'compileModelRef')
            mdlObj=get_param(mdlName,'Object');
            mdlObj.init('MDLREF_NORMAL');
        else
            evalc(sprintf('feval(mdlName,[],[],[],''%s'');',target));
        end
    end
end
