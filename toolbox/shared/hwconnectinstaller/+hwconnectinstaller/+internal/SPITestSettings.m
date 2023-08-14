classdef SPITestSettings




























    methods(Static)
        function out=webAccessCheck





            out=getenv('SUPPORTPACKAGE_INSTALLER_WEBACCESSCHECK');
            if~any(strcmpi(out,{'','assume_access','assume_no_access'}))
                out='';
            end
        end

        function out=defaultWebAccess


            out=getenv('SUPPORTPACKAGE_INSTALLER_DEFAULT_WEBACCESS');
            if~any(strcmpi(out,{'','block'}))
                out='';
            end
        end

        function out=manifestLocation
            out=getenv('SUPPORTPACKAGE_INSTALLER_MANIFEST_LOCATION');
        end

        function out=thirdpartyPackageRegistry
            out=getenv('SUPPORTPACKAGE_INSTALLER_THIRDPARTY_PACKAGE_REGISTRY');
        end

        function out=ssiDebugMode
            out=getenv('SUPPORTPACKAGE_INSTALLER_SSI_DEBUGMODE');
        end

        function out=spPkgResourceLocation
            out=getenv('SUPPORTPACKAGE_INSTALLER_SPKGRESOURCE_LOCATION');
        end

        function out=instructionSetLocation
            out=getenv('SUPPORTPACKAGE_INSTALLER_INSTRUCTIONSET_LOCATION');
        end

        function out=mockSprootSettingWriterReader





            out=getenv('SUPPORTPACKAGE_INSTALLER_SPROOTSETTINGFILE_WRITERREADER');
        end

        function out=sprootSettingsFileLocation



            out=getenv('SUPPORTPACKAGE_INSTALLER_SPROOTFILE_LOCATION');
        end

        function out=defaultSprootDir


            out=getenv('SUPPORTPACKAGE_INSTALLER_DEFAULT_SPROOT');
        end

        function out=matlabIdentifier


            out=getenv('SUPPORTPACKAGE_INSTALLER_MATLAB_ID');
        end

        function out=maxNumSprootDefaults
            out=getenv('SUPPORTPACKAGE_INSTALLER_MAXNUM_DEFAULT_SPROOT');
        end

    end

end
