classdef(Sealed=true)ExternalEngineUtils




    methods(Static,Access='private')
        function obj=ExternalEnginetUtils
        end
    end

    methods(Static)
        [cmd,args,followUp,dvo,encryptDvo,extResults,validate,extKill]=getCommand(name)
        [cmd,args,followUp,dvo,...
        encryptDvo,extResults,validate,extKill]=getServerCommand(analyzerObj)

        status=convertDvoToDvel(file,dir,dvo)
        out=readResults(str)
        engines=getAll
    end

    methods(Static,Access='private')

    end
end
