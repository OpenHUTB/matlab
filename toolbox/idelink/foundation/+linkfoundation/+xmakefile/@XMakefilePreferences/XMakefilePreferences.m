classdef XMakefilePreferences<handle




    properties(Constant=true,Hidden=true)
        PreferenceGroup='MathWorks_Link_For_MAKE_Application_Preferences';
        ActiveConfiguration='ActiveConfiguration';
        ActiveTemplate='ActiveTemplate'
        DefaultTemplateDirectory='DefaultTemplateDirectory';
        UserTemplateDirectory='UserTemplateDirectory';
        UserConfigurationDirectory='UserConfigurationDirectory';
        MATLABIntegration='MATLABIntegration';

        XilinxIseInstallDir='XilinxIseInstallDir';

        CCSInstallDir='CCSInstallDir';
        C2000ToolsInstallDir='C2000ToolsInstallDir';
        C5500ToolsInstallDir='C5500ToolsInstallDir';
        C6000ToolsInstallDir='C6000ToolsInstallDir';
        DSPBIOSInstallDir='DSPBIOSInstallDir';

        CCSEclipseInstallDir='CCSEclipseInstallDir';
        C2000CGToolsInstallDir='C2000CGToolsInstallDir';
        C5500CGToolsInstallDir='C5500CGToolsInstallDir';
        C6000CGToolsInstallDir='C6000CGToolsInstallDir';
        C5500CSLInstallDir='C5500CSLInstallDir';
        C6000CSLInstallDir='C6000CSLInstallDir';
        C6000CSLInstallDirOptional='C6000CSLInstallDirOptional';
        DSPBIOSEclipseInstallDir='DSPBIOSEclipseInstallDir';
        C2000RTDXInstallDir='C2000RTDXInstallDir';
        XDCToolsInstallDir='XDCToolsInstallDir';

        CCEv5InstallDir='CCEv5InstallDir';
        CCEv5C2000CGToolsInstallDir='CCEv5C2000CGToolsInstallDir';
        CCEv5C5500CGToolsInstallDir='CCEv5C5500CGToolsInstallDir';
        CCEv5C6000CGToolsInstallDir='CCEv5C6000CGToolsInstallDir';
        CCEv5C5500CSLInstallDir='CCEv5C5500CSLInstallDir';
        CCEv5C6000CSLInstallDir='CCEv5C6000CSLInstallDir';
        CCEv5C6000CSLInstallDirOptional='CCEv5C6000CSLInstallDirOptional';
        CCEv5DSPBIOSInstallDir='CCEv5DSPBIOSInstallDir';
        CCEv5C2000RTDXInstallDir='CCEv5C2000RTDXInstallDir';
        CCEv5XDCToolsInstallDir='CCEv5XDCToolsInstallDir';

        GHSMULTIInstallDir='GHSMULTIInstallDir';
        ADIVDSPInstallDir='ADIVDSPInstallDir';
        MONTAVISTAInstallDir='MONTAVISTAInstallDir';
        MinGWInstallDir='MinGWInstallDir';
        MSVSInstallDir='MSVSInstallDir';
        MSVS05InstallDir='MSVS05InstallDir';
        MSVS08InstallDir='MSVS08InstallDir';
        WindRiverCompilerDir='WindRiverCompilerDir';
        VxWorksInstallDir='VxWorksInstallDir';
        WindRiverGNUCompilerDir='WindRiverGNUCompilerDir';
        WindRiver68CompilerDir='WindRiver68CompilerDir';
        VxWorks68InstallDir='VxWorks68InstallDir';
        WindRiver68GNUCompilerDir='WindRiver68GNUCompilerDir';
        WindRiver69CompilerDir='WindRiver69CompilerDir';
        VxWorks69InstallDir='VxWorks69InstallDir';
        WindRiver69GNUCompilerDir='WindRiver69GNUCompilerDir';
    end

    methods(Access='public')

        function disp(~)
            activeTemplate=linkfoundation.xmakefile.XMakefilePreferences.getActiveTemplate();
            activeConfiguration=linkfoundation.xmakefile.XMakefilePreferences.getActiveConfiguration();
            defaultTemplate=linkfoundation.xmakefile.XMakefilePreferences.getDefaultTemplateLocation().Path;
            userTemplate=linkfoundation.xmakefile.XMakefilePreferences.getUserTemplateLocation().Path;
            userConfiguration=linkfoundation.xmakefile.XMakefilePreferences.getUserConfigurationLocation().Path;
            ccsLocation=linkfoundation.xmakefile.XMakefilePreferences.getCCSInstallLocation().Path;
            c2000Location=linkfoundation.xmakefile.XMakefilePreferences.getC2000ToolsInstallLocation().Path;
            c5500Location=linkfoundation.xmakefile.XMakefilePreferences.getC5500ToolsInstallLocation().Path;
            c6000Location=linkfoundation.xmakefile.XMakefilePreferences.getC6000ToolsInstallLocation().Path;
            dspBIOSLocation=linkfoundation.xmakefile.XMakefilePreferences.getDSPBIOSInstallLocation().Path;
            ghsLocation=linkfoundation.xmakefile.XMakefilePreferences.getGHSMULTIInstallLocation().Path;
            adiLocation=linkfoundation.xmakefile.XMakefilePreferences.getADIVDSPInstallLocation().Path;
            XlxIseInstallDir=linkfoundation.xmakefile.XMakefilePreferences.getXilinxIseInstallLocation().Path;
            montaVistaLocation=linkfoundation.xmakefile.XMakefilePreferences.getMontaVistaInstallLocation().Path;
            mingwLocation=linkfoundation.xmakefile.XMakefilePreferences.getMinGWInstallLocation().Path;
            msvsLocation=linkfoundation.xmakefile.XMakefilePreferences.getMSVSInstallLocation().Path;
            msvs05Location=linkfoundation.xmakefile.XMakefilePreferences.getMSVS05InstallLocation().Path;
            ccsEclipseLocation=linkfoundation.xmakefile.XMakefilePreferences.getCCSEclipseInstallLocation().Path;
            c2000CGToolsLocation=linkfoundation.xmakefile.XMakefilePreferences.getC2000CGToolsInstallLocation().Path;
            c5500CGToolsLocation=linkfoundation.xmakefile.XMakefilePreferences.getC5500CGToolsInstallLocation().Path;
            c6000CGToolsLocation=linkfoundation.xmakefile.XMakefilePreferences.getC6000CGToolsInstallLocation().Path;
            c5500CSLLocation=linkfoundation.xmakefile.XMakefilePreferences.getC5500CSLInstallLocation().Path;
            c6000CSLLocation=linkfoundation.xmakefile.XMakefilePreferences.getC6000CSLInstallLocation().Path;
            c6000CSLLocationOptional=linkfoundation.xmakefile.XMakefilePreferences.getC6000CSLInstallLocationOptional().Path;
            dspBIOSEclipseLocation=linkfoundation.xmakefile.XMakefilePreferences.getDSPBIOSEclipseInstallLocation().Path;
            c2000RTDXLocation=linkfoundation.xmakefile.XMakefilePreferences.getC2000RTDXInstallLocation().Path;
            xdcToolsLocation=linkfoundation.xmakefile.XMakefilePreferences.getXDCToolsInstallLocation().Path;


            ccev5Location=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5InstallLocation().Path;
            ccev5c2000CGToolsLocation=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5C2000CGToolsInstallLocation().Path;
            ccev5c5500CGToolsLocation=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5C5500CGToolsInstallLocation().Path;
            ccev5c6000CGToolsLocation=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5C6000CGToolsInstallLocation().Path;
            ccev5c5500CSLLocation=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5C5500CSLInstallLocation().Path;
            ccev5c6000CSLLocation=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5C6000CSLInstallLocation().Path;
            ccev5c6000CSLLocationOptional=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5C6000CSLInstallLocationOptional().Path;
            CCEv5DSPBIOSLocation=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5DSPBIOSInstallLocation().Path;
            ccev5c2000RTDXLocation=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5C2000RTDXInstallLocation().Path;
            ccev5xdcToolsLocation=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5XDCToolsInstallLocation().Path;

            fprintf('%s\n',DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_preferences_info_template',...
            activeConfiguration,activeTemplate,userConfiguration,userTemplate,defaultTemplate,...
            ccsLocation,c2000Location,c5500Location,c6000Location,dspBIOSLocation,ghsLocation,...
            adiLocation,montaVistaLocation,mingwLocation,msvsLocation,msvs05Location,...
            ccsEclipseLocation,...
            c2000CGToolsLocation,c5500CGToolsLocation,c6000CGToolsLocation,...
            c5500CSLLocation,c6000CSLLocation,c6000CSLLocationOptional,...
            dspBIOSEclipseLocation,c2000RTDXLocation,xdcToolsLocation,...
            ccev5Location,...
            ccev5c2000CGToolsLocation,ccev5c5500CGToolsLocation,ccev5c6000CGToolsLocation,...
            ccev5c5500CSLLocation,ccev5c6000CSLLocation,ccev5c6000CSLLocationOptional,...
            CCEv5DSPBIOSLocation,ccev5c2000RTDXLocation,ccev5xdcToolsLocation,XlxIseInstallDir));
        end
    end

    methods(Static=true,Hidden=true,Access='public')



        function resetAllPreferences()
            linkfoundation.xmakefile.XMakefilePreferences.managePreference('rmgroup');
        end


        function value=getMATLABIntegrationEnable()
            value=linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.MATLABIntegration);
            if(isempty(value))
                value=false;
            end
        end
        function setMATLABIntegrationEnable(value)
            if(islogical(value))
                linkfoundation.xmakefile.XMakefilePreferences.setPreference(linkfoundation.xmakefile.XMakefilePreferences.MATLABIntegration,value);
            end
        end


        function value=getActiveConfiguration()
            value=linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.ActiveConfiguration);
        end



        function setActiveConfiguration(value)
            linkfoundation.xmakefile.XMakefilePreferences.setPreference(linkfoundation.xmakefile.XMakefilePreferences.ActiveConfiguration,value);
        end



        function value=getActiveTemplate()
            value=linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.ActiveTemplate);
        end



        function setActiveTemplate(value)
            linkfoundation.xmakefile.XMakefilePreferences.setPreference(linkfoundation.xmakefile.XMakefilePreferences.ActiveTemplate,value);
        end




        function location=getDefaultTemplateLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.DefaultTemplateDirectory));
            if(location.isempty()||~location.exists())

                location=linkfoundation.util.Location(fullfile(matlabroot,'toolbox','idelink','foundation','xmakefile','registry','templates'));
                if(~location.exists())
                    linkfoundation.xmakefile.raiseException('XMakefilePreferences','getDefaultTemplateLocation','',[],templateDir.EscapedPath);
                end
                linkfoundation.xmakefile.XMakefilePreferences.setPreference(linkfoundation.xmakefile.XMakefilePreferences.DefaultTemplateDirectory,location.Path);
            end
        end




        function location=getUserTemplateLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.UserTemplateDirectory));
            if(location.isempty()||~location.exists())
                location=linkfoundation.xmakefile.XMakefilePreferences.defUserPath();
                if(~location.exists())
                    linkfoundation.xmakefile.raiseException('XMakefilePreferences','getUserTemplateLocation','',[],templateDir.EscapedPath);
                end
                if dig.isProductInstalled('Simulink Coder')





                    fprintf('%s\n',DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_XMakefilePreferences_getUserTemplateLocation',location.EscapedPath));
                end
                linkfoundation.xmakefile.XMakefilePreferences.setPreference(linkfoundation.xmakefile.XMakefilePreferences.UserTemplateDirectory,location.Path);
            end
        end




        function setUserTemplateLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.UserTemplateDirectory);
        end





        function location=getUserConfigurationLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.UserConfigurationDirectory));
            if(location.isempty()||~location.exists())
                location=linkfoundation.xmakefile.XMakefilePreferences.defUserPath();
                if(~location.exists())
                    linkfoundation.xmakefile.raiseException('XMakefilePreferences','getUserConfigurationLocation','',[],location.EscapedPath);
                end
                fprintf('%s\n',DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_XMakefilePreferences_getUserConfigurationLocation',location.Path));
                linkfoundation.xmakefile.XMakefilePreferences.setPreference(linkfoundation.xmakefile.XMakefilePreferences.UserConfigurationDirectory,location.Path);
            end
        end




        function setUserConfigurationLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.UserConfigurationDirectory);
        end






        function location=getCCSInstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.CCSInstallDir));
            if(location.isempty()||~location.exists())
                root='HKEY_LOCAL_MACHINE\SOFTWARE\Texas Instruments\';
                registry=linkfoundation.util.Executable('reg');
                registry.addFlags(['query "',root,'"']);
                [result,output]=registry.execute();
                if(0~=result)
                    return;
                end
                exp='CCS_(?<Drive>\w\:)\|(?<Path>.+)\|$';
                tokens=textscan(output,'%s','Delimiter','\n','MultipleDelimsAsOne',1);
                lines=tokens{1,1};
                for index=1:length(lines)
                    names=regexp(lines{index},exp,'names');
                    if(isempty(names)||isempty(names.Drive))
                        continue;
                    end
                    location=linkfoundation.util.Location(fullfile(names.Drive,strrep(names.Path,'|','\')));
                    break;
                end
                if(~location.isempty()&&location.exists())
                    linkfoundation.xmakefile.XMakefilePreferences.setCCSInstallLocation(location);
                end
            end
        end



        function setCCSInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.CCSInstallDir);
        end



        function location=getC2000ToolsInstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.C2000ToolsInstallDir));
            if(location.isempty()||~location.exists())




                location=linkfoundation.util.Location([...
                linkfoundation.xmakefile.XMakefilePreferences.getCCSInstallLocation().Path...
                ,'C2000',filesep,'cgtools']);

                ccsRoot=linkfoundation.xmakefile.XMakefilePreferences.getCCSRootRegistry();
                if(isempty(ccsRoot))

                    return;
                end

                exp='TMS\d+C28\w+';
                c2000Entry=linkfoundation.xmakefile.XMakefilePreferences.getRegistryKey(ccsRoot,exp);
                if(isempty(c2000Entry))

                    return;
                end

                exp='REG_SZ\s+[\w\s\\]+CGT_(?<cgRoot>[\\\.\w\s\:\|]+)\|bin';
                cgRoot=linkfoundation.xmakefile.XMakefilePreferences.getRegistryKey([c2000Entry,'',filesep,'Build Tools'],exp);
                if(isempty(cgRoot))

                    return;
                end
                names=regexp(cgRoot,exp,'names','once');
                if(isempty(names)||isempty(names.cgRoot))

                    return;
                end
                cgRoot=names.cgRoot;
                cgLocation=linkfoundation.util.Location(strrep(cgRoot,'|','\'));
                if(~cgLocation.isempty()&&cgLocation.exists())
                    linkfoundation.xmakefile.XMakefilePreferences.setC2000ToolsInstallLocation(cgLocation);
                    location=cgLocation;
                end
            end
        end



        function setC2000ToolsInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.C2000ToolsInstallDir);
        end



        function location=getC5500ToolsInstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.C5500ToolsInstallDir));
            if(location.isempty()||~location.exists())




                location=linkfoundation.util.Location([...
                linkfoundation.xmakefile.XMakefilePreferences.getCCSInstallLocation().Path...
                ,'C5500',filesep,'cgtools']);


                ccsRoot=linkfoundation.xmakefile.XMakefilePreferences.getCCSRootRegistry();
                if(isempty(ccsRoot))

                    return;
                end

                exp='TMS\d+C55\w+';
                c5500Entry=linkfoundation.xmakefile.XMakefilePreferences.getRegistryKey(ccsRoot,exp);
                if(isempty(c5500Entry))

                    return;
                end

                exp='REG_SZ\s+[\w\s\\]+CGT_(?<cgRoot>[\\\.\w\s\:\|]+)\|bin';
                cgRoot=linkfoundation.xmakefile.XMakefilePreferences.getRegistryKey([c5500Entry,filesep,'Build Tools'],exp);
                if(isempty(cgRoot))

                    return;
                end
                names=regexp(cgRoot,exp,'names','once');
                if(isempty(names)||isempty(names.cgRoot))

                    return;
                end
                cgRoot=names.cgRoot;
                cgLocation=linkfoundation.util.Location(strrep(cgRoot,'|',filesep));
                if(~cgLocation.isempty()&&cgLocation.exists())
                    linkfoundation.xmakefile.XMakefilePreferences.setC5500ToolsInstallLocation(cgLocation);
                    location=cgLocation;
                end
            end
        end



        function setC5500ToolsInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.C5500ToolsInstallDir);
        end



        function location=getC6000ToolsInstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.C6000ToolsInstallDir));
            if(location.isempty()||~location.exists())




                location=linkfoundation.util.Location([...
                linkfoundation.xmakefile.XMakefilePreferences.getCCSInstallLocation().Path...
                ,'C6000',filesep,'cgtools']);


                ccsRoot=linkfoundation.xmakefile.XMakefilePreferences.getCCSRootRegistry();
                if(isempty(ccsRoot))

                    return;
                end

                exp='TMS\d+C6\w+';
                c6000Entry=linkfoundation.xmakefile.XMakefilePreferences.getRegistryKey(ccsRoot,exp);
                if(isempty(c6000Entry))

                    return;
                end

                exp='REG_SZ\s+[\w\s\\]+CGT_(?<cgRoot>[\\\.\w\s\:\|]+)\|bin';
                cgRoot=linkfoundation.xmakefile.XMakefilePreferences.getRegistryKey([c6000Entry,filesep,'Build Tools'],exp);
                if(isempty(cgRoot))

                    return;
                end
                names=regexp(cgRoot,exp,'names','once');
                if(isempty(names)||isempty(names.cgRoot))

                    return;
                end
                cgRoot=names.cgRoot;
                cgLocation=linkfoundation.util.Location(strrep(cgRoot,'|',filesep));
                if(~cgLocation.isempty()&&cgLocation.exists())
                    linkfoundation.xmakefile.XMakefilePreferences.setC6000ToolsInstallLocation(cgLocation);
                    location=cgLocation;
                end
            end
        end



        function setC6000ToolsInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.C6000ToolsInstallDir);
        end



        function location=getDSPBIOSInstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.DSPBIOSInstallDir));
            if(location.isempty()||~location.exists())


                location=linkfoundation.util.Location(getenv('BIOS_INSTALL_DIR'));
                if(~location.isempty()&&location.exists())
                    linkfoundation.xmakefile.XMakefilePreferences.setDSPBIOSInstallLocation(location);
                end
            end
        end



        function setDSPBIOSInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.DSPBIOSInstallDir);
        end






        function location=getGHSMULTIInstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.GHSMULTIInstallDir));
            if((location.isempty()||~location.exists())&&ispc())



                root='HKEY_LOCAL_MACHINE\SOFTWARE\Green Hills Software\Keys';
                registry=linkfoundation.util.Executable('reg');
                registry.addFlags(['query "',root,'"']);
                [result,output]=registry.execute();
                if(0~=result)
                    return;
                end

                tokens=textscan(output,'%s','Delimiter','\n','MultipleDelimsAsOne',1);
                lines=tokens{1,1};
                exp='^Directory.*REG_SZ\s(?<licensePath>.*$)';
                names='';
                for index=1:length(lines)
                    names=regexp(lines{index},exp,'names');
                    if(isempty(names)||isempty(names.licensePath))
                        continue;
                    end
                    break;
                end
                if(isempty(names)||isempty(names.licensePath))
                    return;
                end
                exp='(?<ghsRootPath>.*)?licensing';
                names=regexp(names.licensePath,exp,'names','warnings');
                if(isempty(names)||isempty(names.ghsRootPath))
                    return;
                end



                location=linkfoundation.util.Location(names.ghsRootPath);
                [found,directories]=location.findFiles('multi.exe',true);
                if(found)
                    linkfoundation.xmakefile.XMakefilePreferences.setGHSMULTIInstallLocation(directories{1});
                end
            end
        end



        function setGHSMULTIInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.GHSMULTIInstallDir);
        end






        function location=getADIVDSPInstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.ADIVDSPInstallDir));
            if(location.isempty()||~location.exists())

                root='HKEY_LOCAL_MACHINE\SOFTWARE\Analog Devices\';
                registry=linkfoundation.util.Executable('reg');
                registry.addFlags(['query "',root,'"']);
                [result,output]=registry.execute();
                if(0~=result)
                    return;
                end

                tokens=textscan(output,'%s','Delimiter','\n','MultipleDelimsAsOne',1);
                lines=tokens{1,1};
                exp='(?<vdspkey>^.*VisualDSP.*$)';
                for index=1:length(lines)
                    names=regexp(lines{index},exp,'names');
                    if(isempty(names)||isempty(names.vdspkey))
                        continue;
                    end
                    break;
                end
                if(isempty(names)||isempty(names.vdspkey))
                    return;
                end

                registry.resetCommandLine();
                registry.addFlags(['query "',names.vdspkey,'"']);
                [result,output]=registry.execute();
                if(0~=result)
                    return;
                end
                tokens=textscan(output,'%s','Delimiter','\n','MultipleDelimsAsOne',1);
                lines=tokens{1,1};
                exp='^Install.*REG_SZ\s(?<installPath>.*$)';
                for index=1:length(lines)
                    names=regexp(lines{index},exp,'names');
                    if(isempty(names)||isempty(names.installPath))
                        continue;
                    end
                    break;
                end
                if(isempty(names)||isempty(names.installPath))
                    return;
                end

                location=linkfoundation.util.Location(names.installPath);
                if(location.exists)
                    linkfoundation.xmakefile.XMakefilePreferences.setADIVDSPInstallLocation(location);
                end
            end
        end



        function setADIVDSPInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.ADIVDSPInstallDir);
        end






        function location=getMontaVistaInstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.MONTAVISTAInstallDir));
        end



        function setMontaVistaInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.MONTAVISTAInstallDir);
        end






        function location=getWindRiverCompilerLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.WindRiverCompilerDir));
        end



        function setWindRiverCompilerLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.WindRiverCompilerDir);
        end



        function location=getVxWorksInstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.VxWorksInstallDir));
        end



        function setVxWorksInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.VxWorksInstallDir);
        end



        function location=getWindRiverGNUCompilerLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.WindRiverGNUCompilerDir));
        end



        function setWindRiverGNUCompilerLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.WindRiverGNUCompilerDir);
        end






        function location=getWindRiver68CompilerLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.WindRiver68CompilerDir));
        end



        function setWindRiver68CompilerLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.WindRiver68CompilerDir);
        end



        function location=getVxWorks68InstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.VxWorks68InstallDir));
        end



        function setVxWorks68InstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.VxWorks68InstallDir);
        end



        function location=getWindRiver68GNUCompilerLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.WindRiver68GNUCompilerDir));
        end



        function setWindRiver68GNUCompilerLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.WindRiver68GNUCompilerDir);
        end






        function location=getWindRiver69CompilerLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.WindRiver69CompilerDir));
        end



        function setWindRiver69CompilerLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.WindRiver69CompilerDir);
        end



        function location=getVxWorks69InstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.VxWorks69InstallDir));
        end



        function setVxWorks69InstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.VxWorks69InstallDir);
        end



        function location=getWindRiver69GNUCompilerLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.WindRiver69GNUCompilerDir));
        end



        function setWindRiver69GNUCompilerLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.WindRiver69GNUCompilerDir);
        end






        function location=getMinGWInstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.MinGWInstallDir));
        end



        function setMinGWInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.MinGWInstallDir);
        end






        function location=getMSVSInstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.MSVSInstallDir));
            if(location.isempty()||~location.exists())
                if(~isempty(getenv('VSINSTALLDIR')))
                    location=linkfoundation.util.Location(getenv('VSINSTALLDIR'));
                elseif(~isempty(getenv('VS80COMNTOOLS')))
                    names=regexp(getenv('VS80COMNTOOLS'),'(?<rootDir>^.+)Common','names');
                    if(~isempty(names))
                        location=linkfoundation.util.Location(names.rootDir);
                    end
                elseif(~isempty(getenv('VS90COMNTOOLS')))
                    names=regexp(getenv('VS90COMNTOOLS'),'(?<rootDir>^.+)Common','names');
                    if(~isempty(names))
                        location=linkfoundation.util.Location(names.rootDir);
                    end
                else


                    location=linkfoundation.util.Location('C:\Program Files\Microsoft Visual Studio 8');
                end
            end
            if(~location.isempty()&&location.exists())
                linkfoundation.xmakefile.XMakefilePreferences.setMSVSInstallLocation(location);
            end
        end



        function setMSVSInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.MSVSInstallDir);
        end






        function location=getMSVS05InstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.MSVS05InstallDir));
            if(location.isempty()||~location.exists())
                if(~isempty(getenv('VSINSTALLDIR')))
                    location=linkfoundation.util.Location(getenv('VSINSTALLDIR'));
                elseif(~isempty(getenv('VS80COMNTOOLS')))
                    names=regexp(getenv('VS80COMNTOOLS'),'(?<rootDir>^.+)Common','names');
                    if(~isempty(names))
                        location=linkfoundation.util.Location(names.rootDir);
                    end
                else


                    location=linkfoundation.util.Location('C:\Program Files\Microsoft Visual Studio 8');
                end
            end
            if(~location.isempty()&&location.exists())
                linkfoundation.xmakefile.XMakefilePreferences.setMSVS05InstallLocation(location);
            end
        end



        function setMSVS05InstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.MSVS05InstallDir);
        end






        function location=getMSVS08InstallLocation()
            location=linkfoundation.util.Location(linkfoundation.xmakefile.XMakefilePreferences.getPreference(linkfoundation.xmakefile.XMakefilePreferences.MSVS08InstallDir));
            if(location.isempty()||~location.exists())
                if(~isempty(getenv('VSINSTALLDIR')))
                    location=linkfoundation.util.Location(getenv('VSINSTALLDIR'));
                elseif(~isempty(getenv('VS90COMNTOOLS')))
                    names=regexp(getenv('VS90COMNTOOLS'),'(?<rootDir>^.+)Common','names');
                    if(~isempty(names))
                        location=linkfoundation.util.Location(names.rootDir);
                    end
                else


                    location=linkfoundation.util.Location('C:\Program Files\Microsoft Visual Studio 9');
                end
            end
            if(~location.isempty()&&location.exists())
                linkfoundation.xmakefile.XMakefilePreferences.setMSVS08InstallLocation(location);
            end
        end



        function setMSVS08InstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,linkfoundation.xmakefile.XMakefilePreferences.MSVS08InstallDir);
        end





        function location=getXilinxIseInstallLocation()
            location=linkfoundation.util.Location(...
            linkfoundation.xmakefile.XMakefilePreferences.getPreference(...
            linkfoundation.xmakefile.XMakefilePreferences.XilinxIseInstallDir));
        end




        function setXilinxIseInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,...
            linkfoundation.xmakefile.XMakefilePreferences.XilinxIseInstallDir);
        end






        function location=getCCSEclipseInstallLocation()
            location=linkfoundation.util.Location(...
            linkfoundation.xmakefile.XMakefilePreferences.getPreference(...
            linkfoundation.xmakefile.XMakefilePreferences.CCSEclipseInstallDir));
        end




        function setCCSEclipseInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,...
            linkfoundation.xmakefile.XMakefilePreferences.CCSEclipseInstallDir);
        end





        function location=getCCEv5InstallLocation()
            location=linkfoundation.util.Location(...
            linkfoundation.xmakefile.XMakefilePreferences.getPreference(...
            linkfoundation.xmakefile.XMakefilePreferences.CCEv5InstallDir));
        end




        function setCCEv5InstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,...
            linkfoundation.xmakefile.XMakefilePreferences.CCEv5InstallDir);
        end




        function location=getC2000CGToolsInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCGToolsInstallLocation(...
            'C2000CGToolsInstallDir','C2000');
        end




        function setC2000CGToolsInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setCGToolsInstallLocation(...
            'C2000CGToolsInstallDir',location);
        end




        function location=getC5500CGToolsInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCGToolsInstallLocation(...
            'C5500CGToolsInstallDir','C5500');
        end




        function setC5500CGToolsInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setCGToolsInstallLocation(...
            'C5500CGToolsInstallDir',location);
        end




        function location=getC6000CGToolsInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCGToolsInstallLocation(...
            'C6000CGToolsInstallDir','C6000');
        end




        function setC6000CGToolsInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setCGToolsInstallLocation(...
            'C6000CGToolsInstallDir',location);
        end




        function location=getC5500CSLInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCSLInstallLocation(...
            'C5500CSLInstallDir');
        end




        function setC5500CSLInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setCSLInstallLocation(...
            'C5500CSLInstallDir',location)
        end




        function location=getC6000CSLInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCSLInstallLocation(...
            'C6000CSLInstallDir');
        end




        function setC6000CSLInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setCSLInstallLocation(...
            'C6000CSLInstallDir',location)
        end




        function location=getC6000CSLInstallLocationOptional()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCSLInstallLocationOptional(...
            'C6000CSLInstallDirOptional');
        end




        function setC6000CSLInstallLocationOptional(location)
            linkfoundation.xmakefile.XMakefilePreferences.setCSLInstallLocation(...
            'C6000CSLInstallDirOptional',location)
        end




        function location=getDSPBIOSEclipseInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCCSEclipseToolsInstallLocation(...
            'DSPBIOSEclipseInstallDir','DSPBIOSEclipse','bios_*');
        end




        function setDSPBIOSEclipseInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,...
            linkfoundation.xmakefile.XMakefilePreferences.DSPBIOSEclipseInstallDir);
        end




        function location=getC2000RTDXInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCCSEclipseToolsInstallLocation(...
            'C2000RTDXInstallDir','C2000RTDX','bios_*',1);
        end




        function setC2000RTDXInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,...
            linkfoundation.xmakefile.XMakefilePreferences.C2000RTDXInstallDir);
        end




        function location=getXDCToolsInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCCSEclipseToolsInstallLocation(...
            'XDCToolsInstallDir','XDCTools','xdctools_*');
        end




        function setXDCToolsInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,...
            linkfoundation.xmakefile.XMakefilePreferences.XDCToolsInstallDir);
        end


        function libpath=getCGToolsLibPath(proc)
            cgtools=linkfoundation.xmakefile.XMakefilePreferences.(['get',proc,'ToolsInstallLocation'])();
            libpath=linkfoundation.util.Location(fullfile(cgtools.Path,'lib'));
            if(~libpath.exists())
                libpath=[];
            end
        end






        function location=getCCEv5C2000CGToolsInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5CGToolsInstallLocation(...
            'CCEv5C2000CGToolsInstallDir','C2000');
        end




        function setCCEv5C2000CGToolsInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setCGToolsInstallLocation(...
            'CCEv5C2000CGToolsInstallDir',location);
        end




        function location=getCCEv5C5500CGToolsInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5CGToolsInstallLocation(...
            'CCEv5C5500CGToolsInstallDir','C5500');
        end




        function setCCEv5C5500CGToolsInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setCGToolsInstallLocation(...
            'CCEv5C5500CGToolsInstallDir',location);
        end




        function location=getCCEv5C6000CGToolsInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5CGToolsInstallLocation(...
            'CCEv5C6000CGToolsInstallDir','C6000');
        end




        function setCCEv5C6000CGToolsInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setCGToolsInstallLocation(...
            'CCEv5C6000CGToolsInstallDir',location);
        end




        function location=getCCEv5C5500CSLInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCSLInstallLocation(...
            'CCEv5C5500CSLInstallDir');
        end




        function setCCEv5C5500CSLInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setCSLInstallLocation(...
            'CCEv5C5500CSLInstallDir',location)
        end




        function location=getCCEv5C6000CSLInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCSLInstallLocation(...
            'CCEv5C6000CSLInstallDir');
        end




        function setCCEv5C6000CSLInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setCSLInstallLocation(...
            'CCEv5C6000CSLInstallDir',location)
        end




        function location=getCCEv5C6000CSLInstallLocationOptional()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCSLInstallLocationOptional(...
            'CCEv5C6000CSLInstallDirOptional');
        end




        function setCCEv5C6000CSLInstallLocationOptional(location)
            linkfoundation.xmakefile.XMakefilePreferences.setCSLInstallLocation(...
            'CCEv5C6000CSLInstallDirOptional',location)
        end




        function location=getCCEv5DSPBIOSInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5ToolsInstallLocation(...
            'CCEv5DSPBIOSInstallDir','CCEv5DSPBIOS','bios_*');
        end




        function setCCEv5DSPBIOSInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,...
            linkfoundation.xmakefile.XMakefilePreferences.CCEv5DSPBIOSInstallDir);
        end




        function location=getCCEv5C2000RTDXInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5ToolsInstallLocation(...
            'CCEv5C2000RTDXInstallDir','CCEv5C2000RTDX','bios_*',1);
        end




        function setCCEv5C2000RTDXInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,...
            linkfoundation.xmakefile.XMakefilePreferences.CCEv5C2000RTDXInstallDir);
        end




        function location=getCCEv5XDCToolsInstallLocation()
            location=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5ToolsInstallLocation(...
            'CCEv5XDCToolsInstallDir','CCEv5XDCTools','xdctools_*');
        end




        function setCCEv5XDCToolsInstallLocation(location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,...
            linkfoundation.xmakefile.XMakefilePreferences.CCEv5XDCToolsInstallDir);
        end


        function libpath=getCCEv5CGToolsLibPath(proc)
            cgtools=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5CGToolsInstallLocation(['CCEv5',proc,'CGToolsInstallDir'],proc);
            libpath=linkfoundation.util.Location(fullfile(cgtools.Path,'lib'));
            if(~libpath.exists())
                libpath=[];
            end
        end


        function libpath=getCGToolsLibPathForCCSv4(proc)
            cgtools=linkfoundation.xmakefile.XMakefilePreferences.(['get',proc,'CGToolsInstallLocation'])();
            libpath=linkfoundation.util.Location(fullfile(cgtools.Path,'lib'));
            if(~libpath.exists())
                libpath=[];
            end
        end


        function libpath=getCSLLibPath(proc)
            cgtools=linkfoundation.xmakefile.XMakefilePreferences.getCCSInstallLocation();
            libpath=linkfoundation.util.Location(fullfile(cgtools.Path,lower(proc),'csl','lib'));
            if(~libpath.exists())
                libpath=[];
            end
        end


        function libpath=getCCEv5CSLLibPath(proc)
            cgtools=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5InstallLocation();
            libpath=linkfoundation.util.Location(fullfile(cgtools.Path,lower(proc),'csl','lib'));
            if(~libpath.exists())
                libpath=[];
            end
        end


        function libpath=getCSLLibPathForCCSv4(proc)
            cgtools=linkfoundation.xmakefile.XMakefilePreferences.(['get',proc,'CSLInstallLocation'])();
            libpath=linkfoundation.util.Location(fullfile(cgtools.Path,'lib_3x'));
            if(~libpath.exists())
                libpath=linkfoundation.util.Location(fullfile(cgtools.Path,'lib'));
                if(~libpath.exists())
                    libpath=[];
                end
            end
        end


        function libpath=getCSLLibPathForCCEv5(proc)
            cgtools=linkfoundation.xmakefile.XMakefilePreferences.(['getCCEv5',proc,'CSLInstallLocation'])();
            libpath=linkfoundation.util.Location(fullfile(cgtools.Path,'lib_3x'));
            if(~libpath.exists())
                libpath=linkfoundation.util.Location(fullfile(cgtools.Path,'lib'));
                if(~libpath.exists())
                    libpath=[];
                end
            end
        end


        function libpath=getC6000CSLLibPathOptional()
            cgtools=linkfoundation.xmakefile.XMakefilePreferences.getC6000CSLInstallLocationOptional();
            libpath=linkfoundation.util.Location(fullfile(cgtools.Path,'lib_3x'));
            if(~libpath.exists())
                libpath=linkfoundation.util.Location(fullfile(cgtools.Path,'lib'));
                if(~libpath.exists())
                    libpath=[];
                end
            end
        end


        function libpath=getCCEv5C6000CSLLibPathOptional()
            cgtools=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5C6000CSLInstallLocationOptional();
            libpath=linkfoundation.util.Location(fullfile(cgtools.Path,'lib_3x'));
            if(~libpath.exists())
                libpath=linkfoundation.util.Location(fullfile(cgtools.Path,'lib'));
                if(~libpath.exists())
                    libpath=[];
                end
            end
        end

    end

    methods(Static=true,Hidden=true,Access='public')



        function setPreference(pref,value)
            linkfoundation.xmakefile.XMakefilePreferences.managePreference('setpref',pref,value);
        end



        function value=getPreference(pref)
            value=linkfoundation.xmakefile.XMakefilePreferences.managePreference('getpref',pref);
        end
    end

    methods(Static=true,Access='private')





        function prefVal=managePreference(action,varargin)
            group=linkfoundation.xmakefile.XMakefilePreferences.PreferenceGroup;
            prefVal=linkfoundation.util.linkpref(action,group,varargin{:});
        end




        function value=defUserPath()
            defPath=userpath;
            if(ispc())
                delimiter=';';
            else
                delimiter=';:';
            end

            value=linkfoundation.util.Location(tempdir);

            if(~isempty(defPath))
                tokens=textscan(defPath,'%s','Delimiter',delimiter,'MultipleDelimsAsOne',1);
                values=tokens{1};
                for index=1:length(values)
                    value=linkfoundation.util.Location(values{index});
                    if(value.exists())
                        break;
                    end
                end
            end

            if(~value.exists())
                value=linkfoundation.util.Location(tempdir);
            end
        end





        function setLocation(location,preference)
            if(~isa(location,'linkfoundation.util.Location'))
                location=linkfoundation.util.Location(location);
            end
            if(~isa(location,'linkfoundation.util.Location'))
                fprintf('%s\n',DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_XMakefilePreferences_setLocation_unknowntype',class(location)));
                return;
            end
            if(location.isempty()||~location.exists())
                fprintf('%s\n',DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_XMakefilePreferences_setLocation_exist',location.EscapedPath));
                return;
            end
            linkfoundation.xmakefile.XMakefilePreferences.setPreference(preference,location.Path);
        end






        function value=getCCSRootRegistry()
            value='';
            root='HKEY_LOCAL_MACHINE\SOFTWARE\Texas Instruments\';
            registry=linkfoundation.util.Executable('reg');
            registry.addFlags(['query "',root,'"']);
            [result,output]=registry.execute();
            if(0~=result)
                return;
            end
            exp='CCS_\w\:\|[\w\s\|\.]*CCStudio[\w\s\|\.]+\|$';
            tokens=textscan(output,'%s','Delimiter','\n','MultipleDelimsAsOne',1);
            lines=tokens{1,1};
            for index=1:length(lines)
                if(isempty(regexp(lines{index},exp,'once')))
                    continue;
                end
                value=lines{index};
                break;
            end
        end




        function value=getRegistryKey(root,exp)
            value='';
            registry=linkfoundation.util.Executable('reg');
            registry.addFlags(['query "',root,'"']);
            [result,output]=registry.execute();
            if(0~=result)
                return;
            end
            tokens=textscan(output,'%s','Delimiter','\n','MultipleDelimsAsOne',1);
            lines=tokens{1,1};
            for index=1:length(lines)
                if(isempty(regexp(lines{index},exp,'once')))
                    continue;
                end
                value=lines{index};
                break;
            end
        end







        function location=getCGToolsInstallLocation(prefname,procname)
            location=linkfoundation.util.Location(...
            linkfoundation.xmakefile.XMakefilePreferences.getPreference(...
            linkfoundation.xmakefile.XMakefilePreferences.(prefname)));
            if(location.isempty()||~location.exists())

                ccsInstallDir=linkfoundation.xmakefile.XMakefilePreferences.getCCSEclipseInstallLocation();
                if(isempty(ccsInstallDir.Path)||~ccsInstallDir.exists())
                    return;
                end
                location=linkfoundation.util.Location(fullfile(ccsInstallDir.Path,'tools','compiler',procname));
                if(location.exists())
                    setter=eval(['@linkfoundation.xmakefile.XMakefilePreferences.set'...
                    ,upper(procname),'CGToolsInstallLocation']);
                    setter(location);
                end
            end
        end





        function location=getCCEv5CGToolsInstallLocation(prefname,procname)
            location=linkfoundation.util.Location(...
            linkfoundation.xmakefile.XMakefilePreferences.getPreference(...
            linkfoundation.xmakefile.XMakefilePreferences.(prefname)));
            if(location.isempty()||~location.exists())

                ccsInstallDir=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5InstallLocation();
                if(isempty(ccsInstallDir.Path)||~ccsInstallDir.exists())
                    return;
                end
                location=linkfoundation.util.Location(fullfile(ccsInstallDir.Path,'tools','compiler',lower(procname)));
                if(location.exists())
                    setter=eval(['@linkfoundation.xmakefile.XMakefilePreferences.setCCEv5'...
                    ,upper(procname),'CGToolsInstallLocation']);
                    setter(location);
                end
            end
        end





        function setCGToolsInstallLocation(prefname,location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,...
            linkfoundation.xmakefile.XMakefilePreferences.(prefname));
        end





        function location=getCSLInstallLocation(prefname)
            location=linkfoundation.util.Location(...
            linkfoundation.xmakefile.XMakefilePreferences.getPreference(...
            linkfoundation.xmakefile.XMakefilePreferences.(prefname)));
        end





        function location=getCSLInstallLocationOptional(prefname)
            location=linkfoundation.util.Location(...
            linkfoundation.xmakefile.XMakefilePreferences.getPreference(...
            linkfoundation.xmakefile.XMakefilePreferences.(prefname)));
        end





        function setCSLInstallLocation(prefname,location)
            linkfoundation.xmakefile.XMakefilePreferences.setLocation(location,...
            linkfoundation.xmakefile.XMakefilePreferences.(prefname));
        end




        function location=getCCEv5ToolsInstallLocation(prefname,toolName,toolPrefix,optional)
            location=linkfoundation.util.Location(...
            linkfoundation.xmakefile.XMakefilePreferences.getPreference(...
            linkfoundation.xmakefile.XMakefilePreferences.(prefname)));
            if(location.isempty()||~location.exists())

                ccsInstallDir=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5InstallLocation();
                if(ccsInstallDir.isempty())


                    return
                end
                topLevelInstallDir=linkfoundation.util.Location(ccsInstallDir.Parent);
                toolDirs=topLevelInstallDir.directories(toolPrefix);
                if~isempty(toolDirs)

                    location=toolDirs{1};
                else


                    if(nargin==4&&optional)
                        location=linkfoundation.xmakefile.XMakefilePreferences.getCCEv5InstallLocation();
                    end
                end
                if(~location.isempty()&&location.exists())
                    setter=eval(['@linkfoundation.xmakefile.XMakefilePreferences.'...
                    ,'set',toolName,'InstallLocation']);
                    setter(location);
                end
            end
        end




        function location=getCCSEclipseToolsInstallLocation(prefname,toolName,toolPrefix,optional)
            location=linkfoundation.util.Location(...
            linkfoundation.xmakefile.XMakefilePreferences.getPreference(...
            linkfoundation.xmakefile.XMakefilePreferences.(prefname)));
            if(location.isempty()||~location.exists())

                ccsInstallDir=linkfoundation.xmakefile.XMakefilePreferences.getCCSEclipseInstallLocation();
                if(ccsInstallDir.isempty())
                    return
                end
                topLevelInstallDir=linkfoundation.util.Location(ccsInstallDir.Parent);
                toolDirs=topLevelInstallDir.directories(toolPrefix);
                if~isempty(toolDirs)

                    location=toolDirs{1};
                else


                    if(nargin==4&&optional)
                        location=linkfoundation.xmakefile.XMakefilePreferences.getCCSEclipseInstallLocation();
                    end
                end
                if(~location.isempty()&&location.exists())
                    setter=eval(['@linkfoundation.xmakefile.XMakefilePreferences.'...
                    ,'set',toolName,'InstallLocation']);
                    setter(location);
                end
            end
        end




        function location=getXilinxIseToolsInstallLocation(prefname,toolName,toolPrefix,optional)
            location=linkfoundation.util.Location(...
            linkfoundation.xmakefile.XMakefilePreferences.getPreference(...
            linkfoundation.xmakefile.XMakefilePreferences.(prefname)));
            if(location.isempty()||~location.exists())

                xlnxInstallDir=linkfoundation.xmakefile.XMakefilePreferences.getXilinxIseInstallLocation();
                if(xlnxInstallDir.isempty())
                    return
                end
                topLevelInstallDir=linkfoundation.util.Location(xlnxInstallDir.Path);
                toolDirs=topLevelInstallDir.directories(toolPrefix);
                if~isempty(toolDirs)
                    location=toolDirs{1};
                else
                    if(nargin==4&&optional)
                        location=linkfoundation.xmakefile.XMakefilePreferences.getXilinxIseInstallLocation();
                    end
                end
                if(~location.isempty()&&location.exists())
                    setter=eval(['@linkfoundation.xmakefile.XMakefilePreferences.'...
                    ,'set',toolName,'InstallLocation']);
                    setter(location);
                end
            end
        end

    end
end
