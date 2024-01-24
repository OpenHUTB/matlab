classdef audioPluginConfig

    properties
        DeepLearningConfig{ validateDLConfig( DeepLearningConfig ) } = [  ];
        CodeReplacementLibrary{ validateCRLConfig( CodeReplacementLibrary ) } = '';
    end
    methods
        function api = audioPluginConfig( args )
            arguments
                args.DeepLearningConfig = [  ];
                args.CodeReplacementLibrary = '';
            end

            api.CodeReplacementLibrary = args.CodeReplacementLibrary;
            api.DeepLearningConfig = args.DeepLearningConfig;
        end
    end
end


function validateDLConfig( dlcfg )

import matlab.internal.lang.capability.Capability;
if ~isempty( dlcfg )
    dlcfgClass = class( dlcfg );
    switch ( dlcfgClass )
        case 'coder.DeepLearningConfigBase'
            if ~deeplearningutil(  )
                error( message( "audio:plugin:NoDeepLearningToolbox" ) );
            end
        case 'coder.MklDNNConfig'
            if ~Capability.isSupported( Capability.LocalClient )
                error( message( "audio:plugin:MKLDNNNotSuportedONMATLABOnline" ) );
            end
            if ~deeplearningutil(  )
                error( message( "audio:plugin:NoDeepLearningToolbox" ) );
            end
            if isempty( getenv( 'INTEL_MKLDNN' ) )
                error( message( "audio:plugin:INTEL_MKLDNN_NotSet" ) );
            end
        otherwise
            error( message( 'audio:plugin:InvalidDLConfig' ) );
    end
end
end


function validateCRLConfig( crl )

isValidCRL = false;

switch computer( 'arch' )
    case { 'maca64' }
        switch ( crl )
            case ''
            case 'none'
            otherwise
                error( message( "audio:plugin:IntelCrlNotSupportedOnMacArm", crl ) );
        end

    case { 'maci64' }
        switch ( crl )
            case ''
            case 'none'
            case 'DSP Intel AVX2-FMA (Linux)'
                isValidCRL = true;
            case 'DSP Intel AVX2-FMA (Mac)'
                isValidCRL = true;
            otherwise
                error( message( "audio:plugin:CrlNotSupportedOnMac", crl ) );
        end

    case { 'glnxa64' }
        switch ( crl )
            case ''
            case 'none'
            case 'DSP Intel AVX2-FMA (Linux)'
                isValidCRL = true;
            otherwise
                error( message( "audio:plugin:CrlNotSupportedOnLinux", crl ) );
        end

    case { 'win64' }
        switch ( crl )
            case ''
            case 'none'
            case 'Intel AVX (Windows)'
                isValidCRL = true;
            case 'DSP Intel AVX2-FMA (Windows)'
                isValidCRL = true;
            case 'DSP Intel AVX2-FMA (Linux)'
                isValidCRL = true;
            otherwise
                error( message( 'audio:plugin:CrlNotSupportedOnWin', crl ) );
        end
end

if ( isValidCRL )
    if ~ecoderutil()
        error( message( "audio:plugin:NoEmbeddedCoderLicense" ) );
    end
end
end




