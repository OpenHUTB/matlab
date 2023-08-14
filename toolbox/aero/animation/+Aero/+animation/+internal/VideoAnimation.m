classdef(CompatibleInexactProperties=true)VideoAnimation<Aero.animation.internal.Animation





    properties(Transient,SetObservable)
        VideoRecord Aero.animation.internal.VideoRecordType='off';
        VideoFileName='temp';
        VideoCompression='Motion JPEG AVI';
        VideoQuality{validateattributes(VideoQuality,{'numeric'},{'scalar'},'','VideoQuality')}=75;
        VideoTStart{validateattributes(VideoTStart,{'numeric'},{'scalar'},'','VideoTStart')}=NaN;
        VideoTFinal{validateattributes(VideoTFinal,{'numeric'},{'scalar'},'','VideoTFinal')}=NaN;
    end



    methods
        function value=get.VideoRecord(obj)
            value=char(obj.VideoRecord);
        end

        function set.VideoCompression(obj,value)

            value=check(Aero.AeroTypes.AeroVideoProfileTypeEnum,value,'VideoCompression');
            obj.VideoCompression=value;
        end

        function set.VideoFileName(obj,value)




            profileType=Aero.AeroTypes.AeroVideoProfileTypeEnum.Strings;
            extensionType={'.avi','.mj2','.mj2',{'.mp4','.m4v'},'.avi'};

            extensionExpected=extensionType{strncmp(obj.VideoCompression,profileType,length(obj.VideoCompression))};

            [path,name,extensionActual]=fileparts(value);

            if isempty(extensionActual)||any(strncmp(extensionActual,extensionExpected,length(extensionActual)))
                data=value;
            else
                warning(message('aero:VideoAnimation:WrongFileExtension'));
                data=fullfile(path,name);
            end

            obj.VideoFileName=data;
        end

        function set.VideoQuality(obj,value)

            if value<0
                warning(message('aero:VideoAnimation:VideoQualityRange',getString(message('aero:VideoAnimation:VideoQualitySetZero'))));
                obj.VideoQuality=0;
            elseif value>100
                warning(message('aero:VideoAnimation:VideoQualityRange',getString(message('aero:VideoAnimation:VideoQualitySetHundred'))));
                obj.VideoQuality=100;
            elseif isnan(value)
                warning(message('aero:VideoAnimation:VideoQualityRange',getString(message('aero:VideoAnimation:VideoQualitySetSeventyFive'))));
                obj.VideoQuality=75;
            else
                obj.VideoQuality=value;
            end
        end
    end

    methods(Hidden)
        function validateVideoStartStopTime(h)






            if(h.VideoTStart>h.VideoTFinal)
                error(message('aero:VideoAnimation:noInvertedTimeVideo'));
            end


            if(h.VideoTStart<h.TStart)
                error(message('aero:VideoAnimation:videoStartTimeBeforeStartTime'));
            end


            if(h.VideoTFinal>h.TFinal)
                error(message('aero:VideoAnimation:videoFinalTimeAfterFinalTime'));
            end
        end

        function setNonFiniteVideoTime(h)



            if~isfinite(h.VideoTStart)
                h.VideoTStart=h.TStart;
            end

            if~isfinite(h.VideoTFinal)
                h.VideoTFinal=h.TFinal;
            end

        end
    end
end