classdef(Hidden,Sealed)TargetHardwareDeprecationInfo<hgsetget





    properties(Access={?realtime.internal.TargetHardware,?linkfoundation.pjtgenerator.AdaptorRegistry})
DeprecateFcn
        AutomaticallyUpgradeModel=true
    end


    methods(Access={?realtime.internal.TargetHardware,?linkfoundation.pjtgenerator.AdaptorRegistry})
        function out=TargetHardwareDeprecationInfo(aDeprecateFcn)
            out.DeprecateFcn=aDeprecateFcn;
        end
    end


    methods
        function run(hObj,hCS,aForceUpdate)
            modelName=get_param(hCS.getModel,'Name');



            if isempty(modelName)
                return;
            end

            lforce=false;
            if nargin>2&&isequal(aForceUpdate,'f')
                lforce=true;
            end


            [allMdls,~]=find_mdlrefs(modelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            lMdlRefs=allMdls(1:end-1);
            for ii=1:numel(lMdlRefs)
                if~bdIsLoaded(allMdls{ii})


                    load_system(allMdls{ii});
                    set_param(modelName,'Dirty','off');
                end
            end
            if hObj.AutomaticallyUpgradeModel||lforce
                try
                    feval(hObj.DeprecateFcn,hCS);
                catch ex
                    warning('An error occured while making the model ''%s'' compatible with the current release of MATLAB:\n %s',modelName,ex.getReport)
                end
                if~lforce
                    MSLDiagnostic('codertarget:setup:WarnWhenUpdateRealtime2CoderTarget',modelName).reportAsWarning;
                end
            else







            end
        end
    end


    methods
        function obj=set.DeprecateFcn(obj,val)
            if~isa(val,'function_handle')||numel(val)>1
                DAStudio.error('codertarget:targetapi:InvalidFcnHandleProperty','DeprecateFcn');
            end
            obj.DeprecateFcn=val;
        end
        function obj=set.AutomaticallyUpgradeModel(obj,val)
            if~ischar(val)&&~islogical(val)
                DAStudio.error('codertarget:targetapi:InvalidLogicalProperty','AutomaticallyUpgradeModel');
            end
            if isempty(val)
                val=false;
            elseif ischar(val)
                val=~isequal(val,'false')&&~isequal(val,'0');
            end
            obj.AutomaticallyUpgradeModel=val;
        end
    end
end
