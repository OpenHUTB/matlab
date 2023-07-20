



classdef Component_Pkg<autosar.ui.app.base.OptionBase

    properties(Hidden,Constant)
        ID='Component_Pkg';
    end

    methods
        function obj=Component_Pkg(env)






            id=autosar.ui.app.option.Component_Pkg.ID;
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.OptionMessage=DAStudio.message('RTW:autosar:autosarComponentPackageStr');

            obj.Type='user_input';
            obj.Indent=1;

            obj.Value=autosar.mm.util.XmlOptionsDefaultPackages.ComponentsPackage;
            obj.Answer=true;
        end

        function out=isEnabled(obj)
            if obj.Env.IsSubComponent

                out=false;
            else
                out=true;
            end
        end

        function ret=onNext(obj)


            ret=0;


            compPackage=obj.Value;
            modelH=obj.Env.ModelHandle;
            maxShortNameLength=get_param(modelH,'AutosarMaxShortNameLength');
            idcheckmessage=autosar.ui.utils.isValidARIdentifier({compPackage},...
            'absPath',maxShortNameLength);
            if~isempty(idcheckmessage)
                ret=-1;
                errordlg(idcheckmessage,...
                autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
            else
                obj.Env.ComponentPkg=compPackage;
            end
        end

    end
end


