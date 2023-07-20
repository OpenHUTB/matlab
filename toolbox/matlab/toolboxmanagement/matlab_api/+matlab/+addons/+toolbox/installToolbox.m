function installedToolbox=installToolbox(fileName,agreedToLicense)

    narginchk(1,2);

    if(nargin<2)
        agreedToLicense=false;
    end

    validateattributes(fileName,{'char','string'},{'scalartext'},...
    'matlab.addons.toolbox.installToolbox','ToolboxFile',1)
    fileName=char(fileName);

    [~,~,ext]=fileparts(fileName);

    if~strcmpi(ext,'.mltbx')
        error(message('toolboxmanagement_matlab_api:installToolbox:invalidFileType'));
    end

    javaFileObject=java.io.File(fileName);
    installedToolbox=struct.empty;

    if~javaFileObject.exists
        error(message('toolboxmanagement_matlab_api:installToolbox:invalidFilePath',fileName));
    end

    try
        toolboxPackage=com.mathworks.mladdonpackaging.AddonPackage(javaFileObject);
        toolboxProperties=toolboxPackage.getProperties;
        toolboxGuid=char(toolboxProperties.getGuid);

        installOption='overwrite';
        import com.mathworks.addons_common.notificationframework.FolderRegistry;
        if FolderRegistry.hasMultipleVersionsInstalled(toolboxGuid)
            installOption='add';
        end

        if toolboxPackage.hasLicense&&~agreedToLicense
            toolbox=matlab.addons.install(fileName,installOption);
        else
            agreeToLicense=true;
            toolbox=matlab.addons.install(fileName,installOption,agreeToLicense);
        end

        if~isempty(toolbox)
            installedToolbox=struct;
            installedToolbox.Name=char(toolbox.Name);
            installedToolbox.Version=char(toolbox.Version);
            installedToolbox.Guid=toolboxGuid;
        end

    catch ex
        if isprop(ex,'ExceptionObject')&&...
            ~isempty(strfind(ex.ExceptionObject.getClass,'AddonPackageIOException'))
            error(message('toolboxmanagement_matlab_api:installToolbox:invalidToolboxFile'));
        else
            error(ex.message);
        end
    end
end