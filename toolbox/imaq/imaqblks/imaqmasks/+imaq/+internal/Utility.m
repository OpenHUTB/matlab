classdef(Hidden)Utility







    methods(Static)

        function allFormats=getAllFormats
            [~,~,allFormats]=imaqslgate('privateimaqslparsehwinfo',true);
        end


        function objList=getObjectConstructorList
            [~,objList]=imaqslgate('privateimaqslparsehwinfo');
        end





        function deviceList=getDeviceList
            [~,~,~,~,deviceList]=imaqslgate('privateimaqslparsehwinfo');
        end




        function deviceList=getDeviceListInSLFormat
            deviceList=imaqslgate('privateimaqslparsehwinfo');
        end


        function device=getDevice(devIndex)
            deviceList=imaq.internal.Utility.getDeviceList;
            device=deviceList{devIndex};
        end


        function allIDs=getAllDevIDs(adaptor)
            t=imaqhwinfo(adaptor);
            allIDs=t.DeviceIDs;
            allIDs=[allIDs{:}];
        end


        function objectConstructor=getObjectConstructor(devIndex)
            [~,objList]=imaqslgate('privateimaqslparsehwinfo');
            objectConstructor=objList{devIndex};
        end


        function defFormat=getDefaultFormat(devIndex)
            [~,~,~,allDevicesDefaultFormat]=imaqslgate('privateimaqslparsehwinfo',true);
            defFormat=allDevicesDefaultFormat{devIndex};
        end


        function adaptorName=getAdaptor(devIndex)
            adaptorName='none';
            device=imaq.internal.Utility.getDevice(devIndex);
            if strcmp(device,'(none)')
                return;
            end
            startIndex=strfind(device,'(');
            endIndex=strfind(device,'-');
            adaptorName=device(startIndex(end)+1:endIndex(end)-1);
        end


        function deviceID=getDeviceID(devIndex)
            deviceID=1;
            device=imaq.internal.Utility.getDevice(devIndex);
            if strcmp(device,'(none)')
                return;
            end
            startIndex=strfind(device,'-');
            deviceID=str2double(device(startIndex(end)+1));
        end


        function allAdaptors=getAllAdaptors
            [~,~,~,~,~,allAdaptors]=imaqslgate('privateimaqslparsehwinfo');
        end


        function adaptorsWithDevices=getAdaptorsWithDevices
            [~,~,~,~,~,~,adaptorsWithDevices]=imaqslgate('privateimaqslparsehwinfo');
        end


        function bayerSensorList=getAllBayerTypes
            bayerSensorList={'grbg','gbrg','rggb','bggr'};
        end


        function dataTypeList=getAllDataTypes
            dataTypeList={'native',...
            'uint8','uint16','uint32','int8','int16','int32','single','double'};
        end


        function validateAdaptor(adaptorName)

            if~any(strcmpi(adaptorName,imaq.internal.Utility.getAllAdaptors))

                msgObject=message('imaq:videodevice:invalidAdaptorName',adaptorName,imaq.internal.Utility.convertCellToStr(imaq.internal.Utility.getAllAdaptors));
                throwAsCaller(MException('imaq:videodevice:invalidAdaptorName',msgObject.getString));
            end
            if~any(strcmpi(adaptorName,imaq.internal.Utility.getAdaptorsWithDevices))

                msgObject=message('imaq:videodevice:noDevicesForAdaptor',adaptorName);
                throwAsCaller(MException('imaq:videodevice:noDevicesForAdaptor',msgObject.getString));
            end
        end


        function isDeviceFile=validateFormat(format,deviceIndex)
            isDeviceFile=false;
            allFormats=imaq.internal.Utility.getAllFormats;
            if~any(strcmpi(format,allFormats{deviceIndex}))
                if any(strcmpi('From device file',allFormats{deviceIndex}))
                    isDeviceFile=true;
                    return;
                end
                msgObject=message('imaq:videodevice:invalidFormat',format,imaq.internal.Utility.convertCellToStr(allFormats{deviceIndex}));
                throwAsCaller(MException('imaq:videodevice:invalidFormat',msgObject.getString));
            end
        end


        function enumListStr=convertCellToStr(enumList)
            enumListStr=strcat('{',enumList{1});
            separator=', ';
            for idx=2:length(enumList)
                enumListStr=sprintf('%s%s%s',enumListStr,separator,enumList{idx});
            end
            enumListStr=strcat(enumListStr,'}');
        end

        function isKinectDepth=isKinectDepthDevice(device)
            kinectDepth='Kinect Depth';
            isKinectDepth=false;
            if~isempty(strfind(device,kinectDepth))
                isKinectDepth=true;
            end
        end


        function isKinectV2Depth=isKinectV2DepthDevice(device)
            kinectV2Depth='Kinect V2 Depth';
            isKinectV2Depth=false;
            if~isempty(strfind(device,kinectV2Depth))
                isKinectV2Depth=true;
            end
        end


        function isKinectColor=isKinectColorDevice(device)
            kinectColor='Kinect Color';
            kinectV2Color='Kinect V2 Color';
            isKinectColor=false;
            if(~isempty(strfind(device,kinectColor))||~isempty(strfind(device,kinectV2Color)))
                isKinectColor=true;
            end
        end


        function[metadataStr,numMetadataList,metadataList]=getMetaDataInfo(device)
            metadataStr='';
            numMetadataList=0;
            metadataList={};
            if imaq.internal.Utility.isKinectDepthDevice(device)
                metadataList={'IsPositionTracked','IsSkeletonTracked','JointDepthIndices'...
                ,'JointImageIndices','JointTrackingState','JointWorldCoordinates'...
                ,'PositionDepthIndices','PositionImageIndices','PositionWorldCoordinates'...
                ,'SegmentationData','SkeletonTrackingID'};
            elseif imaq.internal.Utility.isKinectV2DepthDevice(device)
                    metadataList={'BodyIndexFrame','BodyTrackingID','ColorJointIndices','DepthJointIndices'...
                    ,'HandLeftConfidence','HandLeftState'...
                    ,'HandRightConfidence','HandRightState','IsBodyTracked'...
                    ,'JointPositions','JointTrackingState'};
                end
            end
            numMetadataList=numel(metadataList);
            metadataStr=sprintf('%s;',metadataList{:});
            metadataStr=metadataStr(1:end-1);
        end

        function supportPackageInstaller

            matlab.addons.supportpackage.internal.explorer.showSupportPackagesForBaseProducts('IA','tripwire');
        end
    end
end