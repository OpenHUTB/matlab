classdef(Hidden)Utils<handle


    methods(Static)
        function out=isCharOrScalarString(input)


            out=ischar(input)||imaq.internal.Utils.isScalarString(input);
        end

        function out=isScalarString(input)

            out=(isstring(input)&&isscalar(input));
        end

        function out=isMathWorksAdaptor(adaptor)

            mwAdaptors={'dalsa';'dcam';'winvideo';'linuxvideo';'macvideo';'gentl';'gige';'kinect';...
            'matrox';'ni';'pointgrey'};
            if ismember(lower(adaptor),mwAdaptors)
                out=true;
            else
                out=false;
            end
        end

        function out=needsUsertoDownload3p(adaptor)
            adaptorsThatNeed3p={'dalsa';'hamamatsu';'matrox'};
            if ismember(lower(adaptor),adaptorsThatNeed3p)
                out=true;
            else
                out=false;
            end
        end

        function[baseCode,spkgName]=getBaseCodeAndSpkgName(adaptor)

            switch adaptor
            case 'dalsa'
                baseCode='DALSASAP';
                spkgName='Teledyne Dalsa Sapera';
            case 'dcam'
                baseCode='DCAM';
                spkgName='DCAM';
            case{'winvideo','linuxvideo','macvideo'}
                baseCode='OSVIDEO';
                spkgName='OS Generic';
            case 'gentl'
                baseCode='GENICAM';
                spkgName='GenICam GenTL';
            case 'gige'
                baseCode='GIGEVISION';
                spkgName='GigE Vision';
            case 'kinect'
                baseCode='KINECT';
                spkgName='Kinect';
            case 'matrox'
                baseCode='MATROX';
                spkgName='Matrox';
            case 'ni'
                baseCode='NIFRAME';
                spkgName='National Instruments Frame Grabbers';
            case 'pointgrey'
                baseCode='POINTGREY';
                spkgName='Point Grey';
            end
        end

        function out=getDocTagForTroubleshootingPage(adaptor)

            switch lower(adaptor)
            case 'dalsa'
                out='ts_dalsasapera';
            case 'dcam'
                if ispc
                    out='ts_dcamwin';
                elseif ismac
                    out='ts_dcammac';
                elseif isunix
                    out='ts_dcamlinux';
                end
            case 'winvideo'
                out='ts_winvideo';
            case 'linuxvideo'
                out='ts_linuxvideo';
            case 'macvideo'
                out='ts_macvideo';
            case 'gentl'
                out='ts_gentl';
            case 'gige'
                out='ts_gige';
            case 'kinect'
                out='ts_kinect';
            case 'matrox'
                out='ts_matrox';
            case 'ni'
                out='ts_ni';
            case 'pointgrey'
                out='ts_pointgrey';
            otherwise
                out='suppkgs';
            end
        end

        function out=isSuppOnPlatform(adaptor)
            winAdaptors={'dalsa';'dcam';'winvideo';'gentl';'gige';'hamamatsu';'kinect';...
            'matrox';'ni';'pointgrey';'qimaging'};
            lnxAdaptors={'dcam';'linuxvideo';'gentl';'gige'};
            macAdaptors={'dcam';'gige';'macvideo'};

            out=false;
            if ispc
                if ismember(lower(adaptor),winAdaptors)
                    out=true;
                end
            elseif ismac
                if ismember(lower(adaptor),macAdaptors)
                    out=true;
                end

            elseif isunix
                if ismember(lower(adaptor),lnxAdaptors)
                    out=true;
                end
            end
        end

        function out=isKnown3pAdaptor(adaptor)
            known3pAdaptors={'hamamatsu';'qimaging'};
            out=ismember(lower(adaptor),known3pAdaptors);
        end

        function out=getWarningIDFromAdaptor(adaptor)
            switch lower(adaptor)
            case 'matrox'
                out='imaq:imaqhwinfo:matrox3p';
            case 'kinect'
                out='imaq:imaqhwinfo:kinect3p';
            case 'pointgrey'
                out='imaq:imaqhwinfo:pointgrey3p';
            end
        end

        function out=getVendorNameFromAdaptor(adaptor)
            switch lower(adaptor)
            case 'hamamatsu'
                out='Hamamatsu Photonics‎';
            case 'qimaging'
                out='Teledyne Photometrics';
            end
        end
    end
end
