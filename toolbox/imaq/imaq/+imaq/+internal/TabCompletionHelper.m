classdef TabCompletionHelper<handle





    methods(Static)

        function adaptors=getInstalledAdaptors

            hwInfo=imaqhwinfo;
            adaptors=hwInfo.InstalledAdaptors;
        end

        function fields=getFields(adaptor)

            hwInfo=imaqhwinfo(adaptor);
            fields=fieldnames(hwInfo);
        end

        function videoinputFields=getVideoinputFields(obj)

            viInfo=imaqhwinfo(obj);
            videoinputFields=fieldnames(viInfo);
        end

        function deviceIDs=getDeviceIDs(adaptor)

            hwInfo=imaqhwinfo(adaptor);
            deviceIDs=cellfun(@num2str,hwInfo.DeviceIDs,'UniformOutput',0);
        end

        function formats=getFormats(adaptor,deviceID)



            if imaq.internal.Utils.isCharOrScalarString(deviceID)
                deviceID=str2double(deviceID);
            end
            devInfo=imaqhwinfo(adaptor,deviceID);
            formats=devInfo.SupportedFormats;
        end

        function iatfiles=getIATfilesinCurrentDir

            searchOutput=dir('*.iat');
            iatfiles={searchOutput.name};
        end

        function validTriggerTypes=getValidTriggerTypes(vidobj)

            trigInfo=triggerinfo(vidobj);
            validTriggerTypes={trigInfo.TriggerType};
        end

        function validTriggerConditions=getValidTriggerConditions(vidobj,triggerType)


            trigInfo=triggerinfo(vidobj,triggerType);
            validTriggerConditions={trigInfo.TriggerCondition};
        end

        function propertyList=getProperties(vidobj)

            propertyList=fieldnames(get(vidobj));
        end

        function imaqmexOptions=getImaqmexNumericOptions



            commonFeatures={'-imaqPhysicalMemoryUsageLimitPercent'};

            if(isAdaptorAvailable('gige'))
                commonFeatures=[commonFeatures,'-gigePacketAckTimeout','-gigeHeartbeatTimeout','-gigeCommandPacketRetries'];
            end


            osSpecificFeatures={};
            if ispc
                if(isAdaptorAvailable('pointgrey'))
                    osSpecificFeatures={'-pointgreyStartDelay','-pointgreyStopDelay'};
                end
            else
                if ismac
                    if(isAdaptorAvailable('macvideo'))
                        osSpecificFeatures={'-macvideoFramegrabDuringDeviceDiscoveryTimeout',};
                    end
                end
            end
            imaqmexOptions=[commonFeatures,osSpecificFeatures];
        end

        function imaqmexOptions=getImaqmexBooleanOptions



            commonFeatures={'-debug','-vfw','-slowpreview','-useObsoletePreview','-logAllEvents','-previewFullBitDepth',...
            '-genicamCommandsAvailable','-limitPhysicalMemoryUsage'};
            if(isAdaptorAvailable('gige'))
                commonFeatures=[commonFeatures,'-debugGigeDiscovery','-debugGigeOpen','-debugGigeConnect',...
                '-debugGigeGVSPReception','-debugGigeFrameAssembly','-debugGigePacketResend','-gigeDisableForceIP',...
                '-gigeDisablePacketResend'];
            end


            osSpecificFeatures={};
            if ispc
                if(isAdaptorAvailable('dcam'))
                    osSpecificFeatures={'-useDCAMLittleEndian'};
                end
                if(isAdaptorAvailable('gentl'))
                    osSpecificFeatures=[osSpecificFeatures,'-debugGenTLDiscovery','-debugGenTLOperation','-debugGenTLAcquisition'];
                end
                if(isAdaptorAvailable('pointgrey'))
                    osSpecificFeatures=[osSpecificFeatures,'-pointgreyEmbedMetadata'];
                end
            else
                if ismac
                    if(isAdaptorAvailable('dcam'))
                        osSpecificFeatures={'-useDCAMLittleEndian'};
                    end
                elseif isunix
                        if(isAdaptorAvailable('gentl'))
                            osSpecificFeatures={'-debugGenTLDiscovery','-debugGenTLOperation','-debugGenTLAcquisition'};
                        end
                    end
                end
            end
            imaqmexOptions=[commonFeatures,osSpecificFeatures];
        end

        function gigeCameras=getGigeCameraList

            availableGigeCameras=gigecamlist;
            serialNums=table2cell(availableGigeCameras(:,'SerialNumber'));
            IPAddresses=table2cell(availableGigeCameras(:,'IPAddress'));
            gigeCameras=[serialNums,IPAddresses];
        end

    end
end

function result=isAdaptorAvailable(adaptor)

    hwInfo=imaqhwinfo;
    adaptors=hwInfo.InstalledAdaptors;
    result=any(ismember(adaptors,adaptor));
end