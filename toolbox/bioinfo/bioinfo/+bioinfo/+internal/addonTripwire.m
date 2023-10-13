function addonTripwire( addonName, mode )

arguments
    addonName( 1, 1 )string{ mustBeMember( addonName, [ "cufflinks", "bwa", "bowtie2" ] ) }
    mode( 1, 1 )string{ mustBeMember( mode, [ "error", "warn" ] ) } = "error"
end

[ fullName, version, GUID, binName, addonFolderFunc ] = getAddonInfo( addonName );

isInstalled = false;
addons = matlab.addons.installedAddons;

if ~isempty( addons )
    idx = ( strcmp( addons.Version, version ) &  ...
        strcmp( addons.Identifier, GUID ) );

    addonVersion = addons.Version( idx );
    addonEnabled = addons.Enabled( idx );

    if isscalar( addonVersion )
        if addonEnabled

            addonFolder = addonFolderFunc(  );
            if addonName ~= "bowtie2"
                if ismac
                    addonFolder = fullfile( addonFolder, binName.mac );
                else

                    addonFolder = fullfile( addonFolder, binName.linux );
                end
            end
            isInstalled = true;
        else
            msg = message( "bioinfo:addonTripwire:AddonNotEnabled", fullName, GUID );
            if mode == "error"
                throwAsCaller( MException( msg ) );
            else
                warning( msg );
                return ;
            end
        end
    end
end

if ~isInstalled && ~isempty( getenv( 'MWE_INSTALL' ) )

    qePath = getQePath( addonName );
    if ismac
        addonFolder = fullfile( qePath, binName.mac );
    else

        addonFolder = fullfile( qePath, binName.linux );
    end
    isInstalled = true;
end

if ~isInstalled
    msg = message( "bioinfo:addonTripwire:AddonNotInstalled", fullName, GUID );
    if mode == "error"
        throwAsCaller( MException( msg ) );
    else
        warning( msg );
        return ;
    end
else

    if ~contains( [ pathsep, getenv( 'PATH' ), pathsep ], [ pathsep, char( addonFolder ), pathsep ] )
        setenv( 'PATH', [ char( addonFolder ), pathsep, getenv( 'PATH' ) ] );
    end

    if ispc
        [ wslAvailable, wslErrorMessage ] = bioinfo.internal.wsl.ensureWSL( fullName );
        if ~wslAvailable && mode == "error"
            throwAsCaller( MException( wslErrorMessage ) );
        elseif ~wslAvailable
            warning( wslErrorMessage )
        end

        bioinfo.internal.wsl.addSupportPackageToWSLENV( addonFolder );
    end

end
end


function [ fullName, version, GUID, binName, addonFolderFunc ] =  ...
    getAddonInfo( addonName )

switch addonName
    case 'cufflinks'
        fullName = "Cufflinks Support Package for the Bioinformatics Toolbox";
        addonFolderFunc = @(  )cufflinks.getInstallationLocation( "Cufflinks" );
        version = "22.1.0";
        GUID = "b7d7ed6d-33e7-4ca9-abee-4352f6bf5678";

        binName.mac = "cufflinks-2.2.1.OSX_x86_64";
        binName.linux = "cufflinks-2.2.1.Linux_x86_64";

    case 'bwa'
        fullName = "BWA Support Package for Bioinformatics Toolbox";
        addonFolderFunc = @(  )bwa.getInstallationLocation( "BWA" );
        version = "22.1.0";
        GUID = "187ce7b1-bd31-46e7-962c-de6dfbff2144";

        binName.mac = "bwa-0.7.17.OSX_x86_64";
        binName.linux = "bwa-0.7.17.Linux_x86_64";

    case 'bowtie2'
        fullName = "Bowtie 2 Support Package for the Bioinformatics Toolbox";
        addonFolderFunc = @(  )bowtie2.getInstallationLocation( "Bowtie2" );
        version = "22.1.0";
        GUID = "5003e11f-482e-4177-8877-a3ce5afd6715";

        binName.mac = "bowtie2-2.3.2-legacy-mac";
        binName.linux = "bowtie2-2.3.2-legacy-linux";
end
end


function qePath = getQePath( addonName )

switch addonName
    case 'cufflinks'
        qePath = fullfile( getenv( 'LARGE_TEST_DATA_ROOT' ),  ...
            'Bioinformatics_Toolbox', 'v000', 'bioinfo', 'cufflinks' );

    case 'bwa'
        qePath = fullfile( getenv( 'LARGE_TEST_DATA_ROOT' ),  ...
            'Bioinformatics_Toolbox', 'v000', 'bioinfo', 'bwa' );
    case 'bowtie2'
        qePath = fullfile( getenv( 'LARGE_TEST_DATA_ROOT' ),  ...
            'Bioinformatics_Toolbox', 'v000', 'bioinfo', 'bowtie2' );
end
end



