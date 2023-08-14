classdef(Sealed)ManagerImplFactory<handle









    methods(Static)
        function impl=getConflictManagerImpl()
            impl=visalib.internal.ManagerImplFactory.getInstance().ConflictManagerImpl;
        end

        function impl=getResourceManagerImpl()
            impl=visalib.internal.ManagerImplFactory.getInstance().ResourceManagerImpl;
        end

        function value=getInstance(createNewAsNeeded)












            persistent instance;

            narginchk(0,1)



            if nargin==0
                createNewAsNeeded=true;
            end

            if(isempty(instance)||~isvalid(instance))&&createNewAsNeeded
                instance=visalib.internal.ManagerImplFactory();
            end
            value=instance;
        end

        function releaseInstance()

            try
                delete(visalib.internal.ManagerImplFactory.getInstance(false));
            catch e %#ok<NASGU>

            end
        end
    end

    methods(Access=private)
        function obj=ManagerImplFactory()




            options=visalib.internal.getOptions();
            if isempty(options)
                visalib.internal.getOptions("default");
            end

            switch computer('arch')
            case 'win64'
                conflictManagerImpl=visalib.internal.ConflictManagerImplWindows("visaConfMgr.dll");
                resourceManagerImpl=visalib.internal.ResourceManagerImplWindows();


                try
                    conflictManagerImpl.loadConflictManager();
                    conflictManagerImpl.getNumVisaInstallations();
                    conflictManagerImpl.getVisaInstallationInfo();
                catch e
                    switch e.identifier
                    case "instrument:interface:visa:conflictManagerUnavailable"
                        throwAsCaller(visalib.internal.ErrorProxy.getVisaException("unableToFindPreferredVISA"));
                    otherwise
                        throwAsCaller(e);
                    end
                end
            case 'maci64'
                conflictManagerImpl=visalib.internal.ConflictManagerImplMac();
                resourceManagerImpl=visalib.internal.ResourceManagerImplMac();




                conflictManagerImpl.getNumVisaInstallations();
                conflictManagerImpl.getVisaInstallationInfo();

            case 'glnxa64'




                conflictManagerPath="";
                conflictManagerImpl=visalib.internal.ConflictManagerImplLinux(conflictManagerPath);
                resourceManagerImpl=visalib.internal.ResourceManagerImplLinux();
            end

            obj.ConflictManagerImpl=conflictManagerImpl;
            obj.ResourceManagerImpl=resourceManagerImpl;
        end

        function delete(obj)
            try
                obj.ConflictManagerImpl.unloadConflictManager();
            catch e %#ok<NASGU>

            end
            delete(obj.ConflictManagerImpl)
            delete(obj.ResourceManagerImpl)
        end
    end

    properties(Access=private)

        ConflictManagerImpl visalib.internal.ConflictManagerImplBase

        ResourceManagerImpl visalib.internal.ResourceManagerImplBase
    end
end

