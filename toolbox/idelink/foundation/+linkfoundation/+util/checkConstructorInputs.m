function args=checkConstructorInputs(args)




    nargs=length(args);
    if(mod(nargs,2)~=0)
        DAStudio.error('ERRORHANDLER:utils:ConstructorInputsNotInPairs','BASELINK');
    end


