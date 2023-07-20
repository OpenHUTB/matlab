classdef LegacySupportPackageRegistryInfo<handle



















    properties(GetAccess=public,SetAccess={?matlabshared.supportpkg.internal.sppkglegacy.SupportPackageRegistryPluginBase})



        BaseCode=''



        Name=''


        Version='';



        BaseProduct='';


        FwUpdate='';


        FwUpdateDisplayName='';



        ExtraInfoCheckBoxCmd=''



        PostInstallCmd=''



        PreUninstallCmd=''

















        CustomMWLicenseFiles=''


        RegistryXmlLoc=''



        SupportCategory='';





        Visible='';
    end

    properties(Dependent)


SupportPackageTag
    end
    methods
        function set.BaseCode(obj,baseCode)
            validateattributes(baseCode,{'char'},{'nonempty'},'setBaseCode','baseCode');
            obj.BaseCode=baseCode;
        end

        function set.Name(obj,name)
            validateattributes(name,{'char'},{'nonempty'},'setName','name');
            obj.Name=name;
        end

        function set.Version(obj,version)
            validateattributes(version,{'char'},{'nonempty'},'setVersion','version');
            obj.Version=version;
        end

        function set.BaseProduct(obj,baseProduct)
            validateattributes(baseProduct,{'char'},{'nonempty'},'setBaseProduct','baseProduct');
            obj.BaseProduct=baseProduct;
        end

        function set.ExtraInfoCheckBoxCmd(obj,extraInfoCheckBoxCmd)
            validateattributes(extraInfoCheckBoxCmd,{'char'},{'nonempty'},'setExtraInfoCheckBoxCmd','extraInfoCheckBoxCmd');
            obj.ExtraInfoCheckBoxCmd=extraInfoCheckBoxCmd;
        end

        function set.FwUpdate(obj,fwUpdate)
            validateattributes(fwUpdate,{'char'},{},'setFwUpdate','fwUpdate');
            obj.FwUpdate=fwUpdate;
        end

        function set.FwUpdateDisplayName(obj,fwUpdateNameDisplayName)
            validateattributes(fwUpdateNameDisplayName,{'char'},{},'setFwUpdateDisplayName','fwUpdateNameDisplayName');
            obj.FwUpdateDisplayName=fwUpdateNameDisplayName;
        end

        function set.SupportCategory(obj,category)
            validateattributes(category,{'char'},{},'setSupportCategory','category');
            obj.SupportCategory=category;
        end

        function set.Visible(obj,visible)
            validateattributes(visible,{'logical'},{},'setVisible','visible');
            obj.Visible=visible;
        end

        function set.PreUninstallCmd(obj,preUninstallCmd)
            validateattributes(preUninstallCmd,{'char'},{},'setPreUninstallCmd','preUninstallCmd');
            obj.PreUninstallCmd=preUninstallCmd;
        end

        function set.PostInstallCmd(obj,postUninstallCmd)
            validateattributes(postUninstallCmd,{'char'},{},'setPostUninstallCmd','preUninstallCmd');
            obj.PostInstallCmd=postUninstallCmd;
        end

        function set.CustomMWLicenseFiles(obj,customMWLicenseFiles)
            validateattributes(customMWLicenseFiles,{'char'},{},'setCustomMWLicenseFiles','customMWLicenseFiles');
            obj.CustomMWLicenseFiles=customMWLicenseFiles;
        end

        function set.RegistryXmlLoc(obj,registryXmlLoc)
            validateattributes(registryXmlLoc,{'char'},{'nonempty'},'setRegistryXmlLoc','registryXmlLoc');

            assert(logical(exist(registryXmlLoc,'file')),sprintf('The registry XML file %s does not exist',registryXmlLoc));
            obj.RegistryXmlLoc=registryXmlLoc;
        end

        function pkgTag=get.SupportPackageTag(obj)
            pkgTag=obj.getPkgTag(obj.Name);
        end
    end

    methods(Access=public,Static,Hidden)
        function pkgTag=getPkgTag(name,opts)




            pkgTag=regexprep(name,'\(R\)','');

            pkgTag=regexprep(pkgTag,'\W','');
            if~exist('opts','var')||~strcmpi(opts,'matchcase')
                pkgTag=lower(pkgTag);
            end
        end
    end

end


