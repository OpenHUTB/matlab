classdef VideoDeviceInternal<matlab.system.SFunSystem





%#function mimaqfvd


    properties(Dependent,Nontunable,AbortSet)





        Device='Default';









        VideoFormat='Default';





        DeviceFile=[];







        ROI=[];





        HardwareTriggering='off';







        TriggerConfiguration='none/none';







        ReturnedColorSpace='rgb';







        BayerSensorAlignment='grbg';






        ReturnedDataType='single';




        ReadAllFrames='off';
    end

    properties(Nontunable,SetAccess=private)






        DeviceProperties;
    end


    properties(Hidden,Access=protected)

InternalStruct
    end
    properties(Hidden,Access=private)
InternalStructList

VideoInputObject

TempVideoInputObject
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'Device'...
            ,'VideoFormat'...
            ,'DeviceFile'...
            ,'ROI'...
            ,'HardwareTriggering'...
            ,'TriggerConfiguration'...
            ,'ReturnedColorSpace'...
            ,'BayerSensorAlignment'...
            ,'ReturnedDataType'...
            ,'DeviceProperties'...
            ,'ReadAllFrames'...
            };
        end
        function obj=loadobj(in)

            inStruct=in.ChildClassData.InternalStruct;

            try
                videoFormat=inStruct.VideoFormat;
                if strcmpi(videoFormat,'From device file')
                    if isempty(inStruct.DeviceFile)
                        obj=imaq.internal.VideoDeviceInternal(inStruct.AdaptorName,inStruct.DeviceID);
                    else
                        obj=imaq.internal.VideoDeviceInternal(inStruct.AdaptorName,inStruct.DeviceID,inStruct.DeviceFile);
                    end
                else
                    obj=imaq.internal.VideoDeviceInternal(inStruct.AdaptorName,inStruct.DeviceID,videoFormat);
                end
            catch ME

                w=warning;
                warning off backtrace;
                warning(message('imaq:videodevice:couldNotRestoreObject',ME.message));
                warning(w);
            end

            try
                props=getInactiveProps(obj);
                if~ismember('ROI',props)
                    obj.ROI=inStruct.ROI;
                end
                if~ismember('HardwareTriggering',props)
                    obj.HardwareTriggering=inStruct.HardwareTriggering;
                end
                if~ismember('TriggerConfiguration',props)
                    obj.TriggerConfiguration=inStruct.TriggerConfiguration;
                end
                if~ismember('ReturnedColorSpace',props)
                    obj.ReturnedColorSpace=inStruct.ReturnedColorSpace;
                end
                if~ismember('BayerSensorAlignment',props)
                    obj.BayerSensorAlignment=inStruct.BayerSensorAlignment;
                end
                if~ismember('ReturnedDataType',props)
                    obj.ReturnedDataType=inStruct.ReturnedDataType;
                end
                if~ismember('ReadAllFrames',props)
                    obj.ReadAllFrames=inStruct.ReadAllFrames;
                end


                dp=in.ChildClassData.DevicePropertyValues;
                if isempty(dp)
                    return;
                end
                set(obj.VideoInputObject,'SelectedSourceName',dp.SourceName);


                dp=rmfield(dp,'SourceName');
                fn=fieldnames(dp);
                for m=1:numel(fn)
                    obj.DeviceProperties.(fn{m})=dp.(fn{m});
                end
            catch ME

                w=warning;
                warning off backtrace;
                warning(message('imaq:videodevice:couldNotRestoreProperties',ME.message));
                warning(w);
            end
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)

            props=getInactiveProps(obj);
            flag=ismember(prop,props);
        end


        function out=saveObjectImpl(obj)

            out=[];

            out.SaveLockedData=false;


            out.InternalStruct=obj.InternalStruct;
            out.InternalStruct=rmfield(out.InternalStruct,{'DeviceProperties','ObjectBeingDestroyedListener'});


            if isempty(obj.VideoInputObject)||~isvalid(obj.VideoInputObject)
                out.DevicePropertyValues=[];
                return;
            end
            s=getselectedsource(obj.VideoInputObject);
            allFieldsStruct=rmfield(set(s),{'Tag'});
            allFields=fieldnames(allFieldsStruct);


            allFields{end+1}='SourceName';

            for idx=1:length(allFields)
                currentFieldName=allFields{idx};
                dp.(currentFieldName)=s.(currentFieldName);
            end
            out.DevicePropertyValues=dp;
        end
    end
    methods

        function this=VideoDeviceInternal(varargin)

            coder.allowpcode('plain');


            this@matlab.system.SFunSystem('mimaqfvd');

            setVarSizeAllowedStatus(this,false);


            prevWarn=warning('off','imaq:imaqhwinfo:additionalVendors');


            infoStructList.DeviceList=imaq.internal.Utility.getDeviceList;
            infoStructList.ObjectConstructorList=imaq.internal.Utility.getObjectConstructorList;
            infoStructList.AllFormatsList=imaq.internal.Utility.getAllFormats;
            infoStructList.ReturnedColorSpaceList={'rgb','grayscale','YCbCr'};
            infoStructList.BayerSensorAlignmentList=imaq.internal.Utility.getAllBayerTypes;
            infoStructList.ReturnedDataTypeList=imaq.internal.Utility.getAllDataTypes;
            infoStructList.HardwareTriggeringList={'on','off'};
            infoStructList.ReadAllFrames={'on','off'};


            infoStruct.DeviceFile='';
            infoStruct.ReturnedColorSpace='rgb';
            infoStruct.BayerSensorAlignment='grbg';
            infoStruct.ReturnedDataType='single';
            infoStruct.CanDoHardwareTrigger=false;
            infoStruct.HardwareTriggering='off';
            infoStruct.TriggerConfiguration='none/none';
            infoStruct.DeviceProperties=[];
            infoStruct.ROI=[];
            infoStruct.ObjectBeingDestroyedListener=[];
            infoStruct.ObjectDestroyed=false;
            infoStruct.ReadAllFrames='off';


            throwError=true;
            try
                switch(nargin)
                case 0

                    infoStruct.ObjectConstructor=imaq.internal.Utility.getObjectConstructor(1);
                    infoStruct.AdaptorName=imaq.internal.Utility.getAdaptor(1);
                    if strcmpi(infoStruct.AdaptorName,'none')
                        if feature('hotlinks')
                            error(message('imaq:videodevice:noDevices'));
                        end
                    end
                    infoStruct.DeviceID=imaq.internal.Utility.getDeviceID(1);
                    throwError=false;
                case 1

                    imaq.internal.Utility.validateAdaptor(varargin{1});
                    infoStruct.AdaptorName=varargin{1};
                    infoStruct.DeviceID=1;

                    warning(prevWarn);

                    infoStruct.ObjectConstructor=sprintf('videoinput(''%s'', %d)',infoStruct.AdaptorName,infoStruct.DeviceID);
                otherwise

                    imaq.internal.Utility.validateAdaptor(varargin{1});
                    infoStruct.AdaptorName=varargin{1};
                    infoStruct.DeviceID=varargin{2};


                    infoStruct.ObjectConstructor=sprintf('videoinput(''%s'', %d)',...
                    infoStruct.AdaptorName,infoStruct.DeviceID);
                end
            catch excep
                warning(prevWarn);
                throwAsCaller(excep);
            end


            warning(prevWarn);


            if~ismember(infoStruct.DeviceID,imaq.internal.Utility.getAllDevIDs(infoStruct.AdaptorName))

                error(message('imaq:videodevice:invalidID',infoStruct.AdaptorName));
            end


            allObjectConstructors=imaq.internal.Utility.getObjectConstructorList;
            infoStruct.CurrentDeviceIndex=find(strcmp(allObjectConstructors,infoStruct.ObjectConstructor));

            infoStruct.VideoFormat=imaq.internal.Utility.getDefaultFormat(infoStruct.CurrentDeviceIndex);
            infoStruct.FullObjectConstructor=infoStruct.ObjectConstructor;
            if(nargin>=3)
                isDeviceFile=imaq.internal.Utility.validateFormat(varargin{3},infoStruct.CurrentDeviceIndex);
                if isDeviceFile
                    infoStruct.VideoFormat='From device file';
                    infoStruct.DeviceFile=varargin{3};
                    if~ischar(infoStruct.DeviceFile)||isempty(infoStruct.DeviceFile)
                        error(message('imaq:videodevice:strFormat'));
                    end
                    infoStruct.FullObjectConstructor=strrep(infoStruct.ObjectConstructor,')',[',''',infoStruct.DeviceFile,''')']);
                else
                    infoStruct.VideoFormat=varargin{3};
                    infoStruct.DeviceFile='';
                    infoStruct.FullObjectConstructor=strrep(infoStruct.ObjectConstructor,')',[',''',infoStruct.VideoFormat,''')']);
                end
            end


            infoStruct.Device=infoStructList.DeviceList{infoStruct.CurrentDeviceIndex};
            infoStructList.VideoFormatList=infoStructList.AllFormatsList{infoStruct.CurrentDeviceIndex};


            this.InternalStruct=infoStruct;
            this.InternalStructList=infoStructList;




            try
                create(this);
            catch ME
                if throwError
                    throw(ME);
                else

                    warnStatus=warning;
                    warning off backtrace;
                    warning(message('imaq:videodevice:unableToConnect',infoStruct.Device));
                    warning(warnStatus);
                end
            end


            if(nargin>3)

                if mod(length(varargin(4:end)),2)
                    error(message('imaq:videodevice:invalidPVPairs'));
                end
                for idx=4:2:length(varargin)
                    if strncmpi(varargin{idx},'DeviceProperties.',length('DeviceProperties.'))

                        propName=varargin{idx}(length('DeviceProperties.')+1:end);

                        set(this.DeviceProperties,propName,varargin{idx+1});
                    else

                        set(this,varargin{idx},varargin{idx+1});
                    end
                end
            end
        end


        function set.Device(obj,inDevice)

            validDeviceStr=validatestring(inDevice,obj.InternalStructList.DeviceList,...
            'imaq.VideoDevice','DEVICE');


            tempStruct=obj.InternalStruct;
            tempStructList=obj.InternalStructList;


            obj.InternalStruct.Device=validDeviceStr;


            obj.InternalStruct.CurrentDeviceIndex=find(strcmp(obj.InternalStructList.DeviceList,obj.InternalStruct.Device)==true);


            obj.InternalStructList.VideoFormatList=obj.InternalStructList.AllFormatsList{obj.InternalStruct.CurrentDeviceIndex};
            obj.InternalStruct.VideoFormat=imaq.internal.Utility.getDefaultFormat(obj.InternalStruct.CurrentDeviceIndex);
            obj.InternalStruct.DeviceFile='';


            updateInternalProperties(obj);


            try
                create(obj);
            catch ME
                obj.InternalStruct=tempStruct;
                obj.InternalStructList=tempStructList;
                throw(ME);
            end
        end

        function set.VideoFormat(obj,inFormat)

            validFormatStr=validatestring(inFormat,obj.InternalStructList.VideoFormatList,...
            'imaq.VideoDevice','VIDEOFORMAT');


            tempStruct=obj.InternalStruct;


            obj.InternalStruct.VideoFormat=validFormatStr;


            updateInternalProperties(obj);


            isPreviewing=strcmpi(obj.VideoInputObject.Previewing,'on');
            if isPreviewing
                closepreview(obj.VideoInputObject);
            end
            try
                create(obj);
            catch ME
                obj.InternalStruct=tempStruct;
                if isPreviewing
                    preview(obj.VideoInputObject);
                end
                throw(ME);
            end
        end

        function set.DeviceFile(obj,inDeviceFile)

            if~ischar(inDeviceFile)
                error(message('imaq:videodevice:strFormat'));
            end


            tempStruct=obj.InternalStruct;


            obj.InternalStruct.DeviceFile=inDeviceFile;


            updateInternalProperties(obj);


            try
                create(obj);
            catch ME
                obj.InternalStruct=tempStruct;
                error(message('imaq:videodevice:invalidDeviceFile',inDeviceFile));
            end
        end

        function set.ROI(obj,roi)

            restoreIfObjDestroyed(obj);

            if isempty(obj.VideoInputObject)||~isvalid(obj.VideoInputObject)
                obj.InternalStruct.ROI=[];
                return;
            end


            validateattributes(roi,{'numeric'},{'vector','size',[1,4],'>',0},'set','ROI');


            maxVideoResolution=obj.VideoInputObject.VideoResolution;
            x=roi(1)-1;
            y=roi(2)-1;
            width=roi(3);
            height=roi(4);
            if(x+width>maxVideoResolution(1))
                error(message('imaq:videodevice:roiWidthExceeded'));
            elseif(y+height>maxVideoResolution(2))
                error(message('imaq:videodevice:roiHeightExceeded'));
            end

            set(obj.VideoInputObject,'ROIPosition',[roi(1)-1,roi(2)-1,roi(3),roi(4)]);


            actualROI=obj.VideoInputObject.ROI;
            obj.InternalStruct.ROI=[actualROI(1)+1,actualROI(2)+1,actualROI(3),actualROI(4)];
        end

        function set.HardwareTriggering(obj,setState)

            hwTrigStr=validatestring(setState,obj.InternalStructList.HardwareTriggeringList,...
            'imaq.VideoDevice','HARDWARETRIGGERING');

            obj.InternalStruct.HardwareTriggering=hwTrigStr;
        end

        function set.TriggerConfiguration(obj,triggerConfig)

            trigConfigStr=validatestring(triggerConfig,obj.InternalStructList.TriggerConfigurationList,...
            'imaq.VideoDevice','TRIGGERCONFIGURATION');


            obj.InternalStruct.TriggerConfiguration=trigConfigStr;
        end

        function set.ReturnedColorSpace(obj,rcs)

            rcsStr=validatestring(rcs,obj.InternalStructList.ReturnedColorSpaceList,...
            'imaq.VideoDevice','RETURNEDCOLORSPACE');


            set(obj.VideoInputObject,'ReturnedColorSpace',rcsStr);


            obj.InternalStruct.ReturnedColorSpace=rcsStr;
        end

        function set.BayerSensorAlignment(obj,bayerSA)

            bayerSAStr=validatestring(bayerSA,obj.InternalStructList.BayerSensorAlignmentList,...
            'imaq.VideoDevice','BAYERSENSORALIGNMENT');


            set(obj.VideoInputObject,'BayerSensorAlignment',bayerSAStr);


            obj.InternalStruct.BayerSensorAlignment=bayerSAStr;
        end

        function set.ReturnedDataType(obj,dataType)

            dataTypeStr=validatestring(dataType,obj.InternalStructList.ReturnedDataTypeList,...
            'imaq.VideoDevice','RETURNEDDATATYPE');

            obj.InternalStruct.ReturnedDataType=dataTypeStr;
        end

        function set.ReadAllFrames(obj,setState)

            modestr=validatestring(setState,obj.InternalStructList.ReadAllFrames,...
            'imaq.VideoDevice','ReadAllFrames');

            obj.InternalStruct.ReadAllFrames=modestr;
        end


        function device=get.Device(obj)
            device=obj.InternalStruct.Device;
        end

        function videoFormat=get.VideoFormat(obj)
            videoFormat=obj.InternalStruct.VideoFormat;
        end

        function deviceFile=get.DeviceFile(obj)
            deviceFile=obj.InternalStruct.DeviceFile;
        end

        function deviceProps=get.DeviceProperties(obj)
            deviceProps=obj.InternalStruct.DeviceProperties;
        end

        function outROI=get.ROI(obj)
            outROI=obj.InternalStruct.ROI;
        end

        function hwTriggering=get.HardwareTriggering(obj)
            hwTriggering=obj.InternalStruct.HardwareTriggering;
        end

        function triggerConfig=get.TriggerConfiguration(obj)
            triggerConfig=obj.InternalStruct.TriggerConfiguration;
        end

        function rcs=get.ReturnedColorSpace(obj)
            rcs=obj.InternalStruct.ReturnedColorSpace;
        end

        function bayerSA=get.BayerSensorAlignment(obj)
            bayerSA=obj.InternalStruct.BayerSensorAlignment;
        end

        function dataType=get.ReturnedDataType(obj)
            dataType=obj.InternalStruct.ReturnedDataType;
        end
        function ReadAllFrames=get.ReadAllFrames(obj)
            ReadAllFrames=obj.InternalStruct.ReadAllFrames;
        end


        function delete(obj)
            if~isempty(obj.VideoInputObject)&&isvalid(obj.VideoInputObject)
                deleteInternalObjects(obj)
            end
        end
    end

    methods(Hidden)
        function adaptorName=getAdaptor(obj)
            adaptorName=obj.InternalStruct.AdaptorName;
        end

        function setParameters(obj)

            restoreIfObjDestroyed(obj);



            if isempty(obj.VideoInputObject)||~isvalid(obj.VideoInputObject)
                if(strcmpi(obj.VideoFormat,'From device file')&&isempty(obj.DeviceFile))
                    error(message('imaq:videodevice:noFormatSpecified'));
                else
                    error(message('imaq:videodevice:noDeviceForStep',obj.Device));
                end
            end



            randString='';
            if~isSizesOnlyCall(obj)
                [~,randString]=fileparts(tempname);
                obj.VideoInputObject.UserData=randString;
            end


            sourceProperties=get(obj.DeviceProperties);
            settableSourceProperties=set(obj.DeviceProperties);


            sourceName=sourceProperties.SourceName;


            sourceProperties=rmfield(sourceProperties,'SourceName');
            settableSourceProperties=rmfield(settableSourceProperties,'SourceName');
            readOnlyFields=setdiff(fieldnames(sourceProperties),fieldnames(settableSourceProperties));
            sourceProperties=rmfield(sourceProperties,readOnlyFields);


            allFields=fieldnames(sourceProperties);


            for curFieldID=1:length(allFields)
                curFieldName=allFields{curFieldID};
                if isnumeric(sourceProperties.(curFieldName))
                    sourceProperties.(curFieldName)=double(sourceProperties.(curFieldName));
                end
            end



            xyROI=[obj.ROI(2)-1,obj.ROI(1)-1,obj.ROI([4,3])];


            dataType=obj.ReturnedDataType;
            if strcmpi(obj.ReturnedDataType,'native')
                info=imaqhwinfo(obj.VideoInputObject);
                dataType=info.NativeDataType;
            end


            if obj.InternalStruct.CanDoHardwareTrigger
                supportsHWtrigger='yes';
            else
                supportsHWtrigger='no';
            end


            productDir=toolboxdir('imaq');
            engXMLPath=fullfile(productDir,'imaq','private');

            info=imaqhwinfo(obj.InternalStruct.AdaptorName);
            [devXMLPath,engLibName]=fileparts(info.AdaptorDllName);
            engLibPath=fullfile(productDir,'imaqblks','imaqmex',computer('arch'));


            allDevicesSOFormat=imaq.internal.Utility.getDeviceList;
            index=strcmp(obj.Device,allDevicesSOFormat)==1;
            allDevices=imaq.internal.Utility.getDeviceListInSLFormat;


            metaDataList=imaq.internal.Utility.getMetaDataInfo(obj.InternalStruct.Device);


            obj.compSetParameters({allDevices{index},...
            obj.InternalStruct.ObjectConstructor,...
            obj.VideoFormat,...
            obj.DeviceFile,...
            sourceName,...
            num2str(xyROI),...
            obj.HardwareTriggering,...
            obj.TriggerConfiguration,...
            1/30,...
            'One multidimensional signal',...
            dataType,...
            supportsHWtrigger,...
            obj.ReturnedColorSpace,...
            randString,...
            num2str(obj.ROI(3)),...
            num2str(obj.ROI(4)),...
            num2str(obj.ROI(1)-1),...
            num2str(obj.ROI(2)-1),...
            engXMLPath,...
            devXMLPath,...
            engLibPath,...
            sourceProperties,...
            obj.ReturnedColorSpace,...
            obj.BayerSensorAlignment,...
            engLibName,...
            metaDataList,...
            metaDataList,...
            obj.ReadAllFrames
            });
        end
    end

    methods(Access=public)
        function hImage=preview(obj)
















            restoreIfObjDestroyed(obj);


            if nargout>0
                hImage=[];
            end


            if isempty(obj.VideoInputObject)||~isvalid(obj.VideoInputObject)
                if(strcmpi(obj.VideoFormat,'From device file')&&isempty(obj.DeviceFile))
                    error(message('imaq:videodevice:noFormatSpecified'));
                else
                    error(message('imaq:videodevice:noDeviceForStep',obj.Device));
                end
            end

            imHandle=preview(obj.VideoInputObject);


            if nargout>0
                hImage=imHandle;
            end
        end

        function closepreview(obj)






            closepreview(obj.VideoInputObject);
        end

        function out=imaqhwinfo(obj,varargin)












            narginchk(1,2);
            out=[];

            restoreIfObjDestroyed(obj);

            if isempty(obj.VideoInputObject)||~isvalid(obj.VideoInputObject)
                if(strcmpi(obj.VideoFormat,'From device file')&&isempty(obj.DeviceFile))
                    error(message('imaq:videodevice:noFormatSpecified'));
                else
                    error(message('imaq:videodevice:noDeviceForStep',obj.Device));
                end
            end

            switch nargin
            case 1
                out=imaqhwinfo(obj.VideoInputObject);
            case 2
                fieldName=varargin{1};
                out=imaqhwinfo(obj.VideoInputObject,fieldName);
            end
        end

        function varargout=set(obj,varargin)
























            restoreIfObjDestroyed(obj);


            if numel(obj)~=1
                error(message('imaq:videodevice:nonScalarSet'));
            end

            switch(nargin)
            case 1

                fn=fieldnames(obj);


                for ii=1:length(fn)
                    dPropInfo=obj.findprop(fn{ii});
                    if~strcmp(dPropInfo.SetAccess,'public')
                        continue;
                    end
                    val={set(obj,fn{ii})};
                    if isempty(val{1})
                        st.(fn{ii})={};
                    else
                        st.(fn{ii})=val;
                    end
                end
                varargout={st};
            case 2

                if isstruct(varargin{1})

                    st=varargin{1};
                    stfn=fieldnames(st);
                    for ii=1:length(stfn)
                        prop=stfn{ii};
                        try
                            matlab.system.setProp(obj,prop,st.(prop));
                        catch ME
                            throwAsCaller(ME);
                        end
                    end
                else

                    if imaq.internal.Utils.isScalarString(varargin{1})
                        varargin{1}=char(varargin{1});
                    end
                    propName=varargin{1};
                    propEnum=getPropEnum(obj,propName);
                    if~isempty(propEnum)
                        varargout={propEnum};
                        return;
                    end

                    varargout={{}};
                    prop=findprop(obj,propName);
                    if isempty(prop)

                        if strncmpi(varargin{1},'DeviceProperties.',length('DeviceProperties.'))

                            allFields=fieldnames(obj.DeviceProperties);
                            allFieldsWithPrefix=strcat('DeviceProperties.',allFields);
                            index=find(strcmp(varargin{1},allFieldsWithPrefix)==1,1);
                            if~isempty(index)
                                error(message('imaq:videodevice:incorrectSetUseToAccessProp',allFields{index},allFields{index}));
                            end
                        end

                        error(message('imaq:videodevice:invalidVideoDeviceProperty',varargin{1},class(obj)));
                    elseif~strcmp(prop.SetAccess,'public')
                        if strcmp(varargin{1},'DeviceProperties')
                            error(message('imaq:videodevice:devicePropReadOnly'));
                        end
                    end
                end
            otherwise

                if mod(length(varargin),2)
                    error(message('imaq:videodevice:invalidPVPairs'));
                end
                for ii=1:2:length(varargin)



                    if strncmpi(varargin{ii},'DeviceProperties.',length('DeviceProperties.'))

                        allFields=fields(obj.DeviceProperties);
                        allFieldsWithPrefix=strcat('DeviceProperties.',allFields);
                        index=find(strcmp(varargin{ii},allFieldsWithPrefix)==1,1);
                        if~isempty(index)
                            error(message('imaq:videodevice:incorrectSetUseToSetProp',allFields{index},allFields{index}));
                        end

                        error(message('imaq:videodevice:invalidVideoDeviceProperty',varargin{1},class(obj)));
                    end


                    if strncmpi(varargin{ii},'DeviceProperties',length('DeviceProperties'))
                        error(message('imaq:videodevice:devicePropSetAccess'));
                    end



                    if imaq.internal.Utils.isScalarString(varargin{ii})
                        varargin{ii}=char(varargin{ii});
                    end

                    if imaq.internal.Utils.isScalarString(varargin{ii+1})
                        varargin{ii+1}=char(varargin{ii+1});
                    end

                    try
                        matlab.system.setProp(obj,(varargin{ii}),varargin{ii+1});
                    catch ME

                        throwAsCaller(ME);
                    end
                end
                varargout={};
            end
        end
    end


    methods(Access={?imaq.internal.DeviceProperties})
        function restoreIfObjDestroyed(obj)

            if(obj.InternalStruct.ObjectDestroyed)

                createObject(obj);
                obj.VideoInputObject=obj.TempVideoInputObject;

                if isempty(obj.VideoInputObject)
                    return;
                end


                addListeners(obj);



                roi=obj.InternalStruct.ROI;
                set(obj.VideoInputObject,'ROIPosition',[roi(1)-1,roi(2)-1,roi(3),roi(4)]);


                restoreDeviceProperties(obj.DeviceProperties,obj.VideoInputObject);
            end
        end
    end

    methods(Access=private)
        function create(obj)

            createObject(obj);


            deleteInternalObjects(obj);
            obj.VideoInputObject=obj.TempVideoInputObject;

            if isempty(obj.VideoInputObject)
                return;
            end


            addListeners(obj);


            updateObjectParameters(obj);
        end



        function createObject(obj)

            if(strcmpi(obj.InternalStruct.VideoFormat,'From device file')&&isempty(obj.InternalStruct.DeviceFile))

                obj.TempVideoInputObject=[];
                obj.InternalStruct.ROI=[];
                obj.InternalStruct.DeviceProperties=[];
                return;
            end


            try
                obj.TempVideoInputObject=eval(obj.InternalStruct.FullObjectConstructor);
            catch ME
                throwAsCaller(ME);
            end
        end


        function addListeners(obj)

            uddObj=imaqgate('privateGetField',obj.VideoInputObject,'uddobject');
            obj.InternalStruct.ObjectBeingDestroyedListener=handle.listener(uddObj,'ObjectBeingDestroyed',@(src,event)objDestroyedCallback(obj));

            obj.InternalStruct.ObjectDestroyed=false;
        end

        function updateObjectParameters(obj)

            obj.InternalStruct.DeviceProperties=imaq.internal.DeviceProperties(obj,obj.VideoInputObject);


            obj.InternalStruct.ReturnedDataType='single';

            isKinectDepth=imaq.internal.Utility.isKinectDepthDevice(obj.Device);
            isKinectV2Depth=imaq.internal.Utility.isKinectV2DepthDevice(obj.Device);
            isKinectColor=imaq.internal.Utility.isKinectColorDevice(obj.Device);
            if(isKinectDepth||isKinectV2Depth)
                obj.InternalStructList.ReturnedColorSpaceList={'grayscale'};

                obj.InternalStruct.ReturnedDataType='uint16';
            elseif(isKinectColor)

                    obj.InternalStruct.ReturnedDataType='uint8';
                    obj.InternalStructList.ReturnedColorSpaceList={'rgb','grayscale','YCbCr'};
                else
                    obj.InternalStructList.ReturnedColorSpaceList={'rgb','grayscale','YCbCr'};
                end
            end
            if strcmpi(obj.VideoInputObject.ReturnedColorSpace,'grayscale')&&~isKinectDepth
                obj.InternalStructList.ReturnedColorSpaceList{end+1}='bayer';
            end
            obj.InternalStruct.ReturnedColorSpace=obj.VideoInputObject.ReturnedColorSpace;


            roi=obj.VideoInputObject.ROIPosition;
            obj.InternalStruct.ROI=[roi(1)+1,roi(2)+1,roi([3,4])];


            obj.InternalStruct.HardwareTriggering='off';
            triggerInformation=triggerinfo(obj.VideoInputObject);
            if any(ismember({triggerInformation.TriggerType},'hardware'))
                obj.InternalStruct.CanDoHardwareTrigger=true;
                hwTriggerConfig=triggerinfo(obj.VideoInputObject,'hardware');
                tcList=cellfun(@strcat,...
                {hwTriggerConfig.TriggerSource},...
                strcat('/',{hwTriggerConfig.TriggerCondition}),'UniformOutput',false);
            else
                obj.InternalStruct.CanDoHardwareTrigger=false;
                tcList={'none/none'};
            end
            obj.InternalStructList.TriggerConfigurationList=tcList;
            obj.InternalStruct.TriggerConfiguration=tcList{1};
        end

        function propEnum=getPropEnum(obj,propName)

            propEnum=[];
            propNameList=strcat(propName,'List');
            if~isfield(obj.InternalStructList,propNameList)
                return;
            end


            propEnum=(obj.InternalStructList.(propNameList))';
        end

        function deleteInternalObjects(obj)

            delete(obj.InternalStruct.ObjectBeingDestroyedListener);
            obj.InternalStruct.ObjectBeingDestroyedListener=[];


            delete(obj.VideoInputObject);


            delete(obj.DeviceProperties);
            obj.InternalStruct.DeviceProperties=[];
        end

        function objDestroyedCallback(obj)

            if isLocked(obj)
                release(obj);
            end


            delete(obj.InternalStruct.ObjectBeingDestroyedListener);
            obj.InternalStruct.ObjectBeingDestroyedListener=[];
            obj.InternalStruct.ObjectDestroyed=true;


            backupDeviceProperties(obj.DeviceProperties);
        end

        function updateInternalProperties(obj)

            obj.InternalStruct.ObjectConstructor=obj.InternalStructList.ObjectConstructorList{obj.InternalStruct.CurrentDeviceIndex};


            if~strcmpi(obj.InternalStruct.VideoFormat,'From device file')
                obj.InternalStruct.FullObjectConstructor=strrep(obj.InternalStruct.ObjectConstructor,')',[',''',obj.InternalStruct.VideoFormat,''')']);
            else
                obj.InternalStruct.FullObjectConstructor=strrep(obj.InternalStruct.ObjectConstructor,')',[',''',obj.InternalStruct.DeviceFile,''')']);
            end


            obj.InternalStruct.AdaptorName=imaq.internal.Utility.getAdaptor(obj.InternalStruct.CurrentDeviceIndex);


            obj.InternalStruct.DeviceID=imaq.internal.Utility.getDeviceID(obj.InternalStruct.CurrentDeviceIndex);
        end
    end

    methods(Access={?imaq.VideoDevice})
        function props=getInactiveProps(obj)
            props={};
            if~strcmp(obj.ReturnedColorSpace,'bayer')||imaq.internal.Utility.isKinectDepthDevice(obj.Device)
                props{end+1}='BayerSensorAlignment';
            end
            if~strcmp(obj.VideoFormat,'From device file')
                props{end+1}='DeviceFile';
            end
            if strcmpi(obj.VideoFormat,'From device file')&&isempty(obj.DeviceFile)
                props{end+1}='DeviceProperties';
                props{end+1}='ROI';
                props{end+1}='ReturnedColorSpace';
                props{end+1}='BayerSensorAlignment';
                props{end+1}='HardwareTriggering';
                props{end+1}='TriggerConfiguration';
                props{end+1}='ReturnedDataType';
                props{end+1}='ReadAllFrames';
            end

            if~obj.InternalStruct.CanDoHardwareTrigger
                props{end+1}='HardwareTriggering';
                props{end+1}='TriggerConfiguration';
            end
            if strcmpi(obj.HardwareTriggering,'off')
                props{end+1}='TriggerConfiguration';
            end

            if((isempty(obj.VideoInputObject)||~isvalid(obj.VideoInputObject))&&(~obj.InternalStruct.ObjectDestroyed))
                if~strcmpi(obj.VideoFormat,'From device file')
                    props{end+1}='DeviceFile';
                end
                props{end+1}='DeviceProperties';
                props{end+1}='ROI';
                props{end+1}='ReturnedColorSpace';
                props{end+1}='BayerSensorAlignment';
                props{end+1}='HardwareTriggering';
                props{end+1}='TriggerConfiguration';
                props{end+1}='ReturnedDataType';
                props{end+1}='ReadAllFrames';
            end
        end
    end

    methods(Hidden)
        function y=callTerminateAfterCodegen(~)





            y=true;
        end
    end
end
