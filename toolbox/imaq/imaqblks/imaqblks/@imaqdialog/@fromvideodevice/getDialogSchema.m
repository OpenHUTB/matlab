function dlgStruct=getDialogSchema(obj,~)












    [devices,objConstructors,formats,defaults]=...
    imaqslgate('privateimaqslparsehwinfo');


    imaqslgate('privateimaqsldevicesetup',obj,devices,objConstructors,...
    formats,defaults);

    obj.Device=obj.DeviceMenu;
    obj.VideoFormat=obj.VideoFormatMenu;





    if~obj.IsUserDataInvalid
        imaqslgate('privateimaqloadsourceproperties',obj);
    end


    if(any(strcmp(obj.Root.SimulationStatus,{'running','paused','terminating'})))

        videoSources={obj.VideoSource};

        triggerConfigurations={obj.TriggerConfiguration};

        colorSpaces={obj.ColorSpace};
    else

        videoSources=localGetSources(obj);


        localSetROIPosition(obj);


        triggerConfigurations=localGetTriggerInformation(obj);


        colorSpaces=localGetColorSpaceInformation(obj);
    end


    localShowPreviewAndProperties(obj);


    rowSpan=[1,1];
    colSpan=[1,3];
    descPane=tamslgate('privateslwidgetdescgrp',obj,rowSpan,colSpan);


    [paramPane,paramPaneEndRow]=localCreateFVDParamGroup(obj,devices,formats,videoSources,...
    triggerConfigurations,colorSpaces);



    metadataPane=localCreateFVDMetadataParamGroup(obj,paramPaneEndRow);

    if imaq.internal.Utility.isKinectDepthDevice(obj.Device)||...
        imaq.internal.Utility.isKinectV2DepthDevice(obj.Device)
        metadataPane.Visible=true;
    else
        metadataPane.Visible=false;
    end

    dlgItems={descPane,paramPane,metadataPane};

    dlgStruct=tamslgate('privateslpanemaindlg',obj,dlgItems,...
    'imaqslcbpreapply','imaqslcbclosedialog');


    [isLibrary,isLocked]=obj.isLibraryBlock(obj.Block);
    if isLibrary&&isLocked||any(strcmp(obj.Root.SimulationStatus,{'running','paused'}))
        dlgStruct.DisableDialog=true;
    end


    localResetDefault(obj);
end

function videoSources=localGetSources(obj)


    if isempty(obj.IMAQObject)||strcmp(obj.Device,'(none)')||~isvalid(obj.IMAQObject)
        videoSources={'(none)'};
        obj.VideoSource='(none)';
        return;
    end


    visource=obj.IMAQObject.Source;


    videoSources={visource.SourceName}';


    if obj.IsDifferentDevice||obj.IsDifferentFormat||strcmp(obj.VideoSource,'(none)')
        obj.VideoSource=videoSources{1};
    end


    set(obj.IMAQObject,'SelectedSourceName',obj.VideoSource);

end

function localSetROIPosition(obj)


    if isempty(obj.IMAQObject)||strcmp(obj.Device,'(none)')||~isvalid(obj.IMAQObject)
        obj.ROIPosition='(none)';
        return;
    end


    if obj.IsDifferentDevice||obj.IsDifferentFormat||strcmp(obj.ROIPosition,'(none)')
        maxResolution=obj.IMAQObject.VideoResolution;
        obj.ROIPosition=sprintf('[0 0 %d %d]',maxResolution(2),maxResolution(1));
        obj.ROIHeight=sprintf('%d',maxResolution(2));
        obj.ROIWidth=sprintf('%d',maxResolution(1));
        obj.ROIRow=sprintf('%d',0);
        obj.ROIColumn=sprintf('%d',0);

        obj.Block.ROIPosition=obj.ROIPosition;
    end



    ROI=str2num(obj.ROIPosition);%#ok<ST2NM>
    if length(ROI)~=4||any(ROI<0)
        maxResolution=obj.IMAQObject.VideoResolution;
        obj.ROIPosition=sprintf('[0 0 %d %d]',maxResolution(2),maxResolution(1));

        obj.Block.ROIPosition=obj.ROIPosition;
        obj.Block.ROIHeight=sprintf('%d',maxResolution(2));
        obj.Block.ROIWidth=sprintf('%d',maxResolution(1));
        ROI=[0,0,maxResolution(2),maxResolution(1)];
    else
        ROIHeight=ROI(3);
        ROIWidth=ROI(4);
        if str2double(obj.Block.ROIHeight)~=ROIHeight
            obj.Block.ROIHeight=sprintf('%d',ROIHeight);
        end
        if str2double(obj.Block.ROIWidth)~=ROIWidth
            obj.Block.ROIWidth=sprintf('%d',ROIWidth);
        end
    end
    set(obj.IMAQObject,'ROIPosition',ROI([2,1,4,3]));
end

function colorSpaces=localGetColorSpaceInformation(obj)


    if isempty(obj.IMAQObject)||strcmp(obj.Device,'(none)')||~isvalid(obj.IMAQObject)
        colorSpaces={'(none)'};
        obj.ColorSpace='(none)';
        return;
    end


    colorSpaces={'rgb','grayscale','YCbCr'};
    csInfo=propinfo(obj.IMAQObject,'ReturnedColorSpace');
    if strcmpi(csInfo.DefaultValue,'grayscale')
        colorSpaces=[colorSpaces,{'bayer'}];
    end


    if obj.IsDifferentDevice||obj.IsDifferentFormat
        obj.ColorSpace=obj.IMAQObject.ReturnedColorSpace;
        obj.ReturnedColorSpace=obj.ColorSpace;
    else
        obj.IMAQObject.ReturnedColorSpace=obj.ColorSpace;
        obj.IMAQObject.BayerSensorAlignment=obj.BayerSensorAlignment;
    end

end

function triggerConfigurations=localGetTriggerInformation(obj)


    if isempty(obj.IMAQObject)||strcmp(obj.Device,'(none)')||~isvalid(obj.IMAQObject)
        obj.EnableHWTrigger=false;
        triggerConfigurations={'none/none'};
        obj.TriggerConfiguration='none/none';
        return;
    end


    triggerInformation=triggerinfo(obj.IMAQObject);


    if any(ismember({triggerInformation.TriggerType},'hardware'))

        obj.CanDoHWTrigger=true;
        hwTriggerConfig=triggerinfo(obj.IMAQObject,'hardware');
        triggerConfigurations=cellfun(@strcat,...
        {hwTriggerConfig.TriggerSource},...
        strcat('/',{hwTriggerConfig.TriggerCondition}),'UniformOutput',false);
    else
        obj.CanDoHWTrigger=false;
        triggerConfigurations={'none/none'};
    end


    if obj.IsDifferentDevice||obj.IsDifferentFormat
        obj.EnableHWTrigger=false;
        obj.TriggerConfiguration=triggerConfigurations{1};
    end


    if~obj.EnableHWTrigger
        triggerconfig(obj.IMAQObject,'manual');
    else

        index=strfind(obj.TriggerConfiguration,'/');



        index=index(end);
        triggerSource=obj.TriggerConfiguration(1:index-1);
        triggerCondition=obj.TriggerConfiguration(index+1:end);
        triggerconfig(obj.IMAQObject,'hardware',triggerCondition,triggerSource);
    end
end

function localShowPreviewAndProperties(obj)


    if((obj.IsDifferentDevice||obj.IsDifferentFormat||...
        obj.IsDifferentSource)&&obj.IsPreviewing)
        preview(obj.IMAQObject);
    end

end


function[paramPane,rowInDialog]=localCreateFVDParamGroup(obj,devices,formats,...
    videoSources,triggerConfigurations,colorSpaces)


    tags=imaqslgate('privateimaqslstring','tags');


    rowInDialog=1;


    colSpan=[1,3];
    DeviceMenu=tamslgate('privateslwidgetcombo',sprintf('Device:                '),tags.DeviceMenu,...
    devices,[rowInDialog,rowInDialog],colSpan,...
    'imaqslcallback');
    DeviceMenu.Mode=true;


    rowInDialog=rowInDialog+1;
    selectedIndex=find(strcmp(devices,obj.Device)==true);
    VideoFormatMenu=tamslgate('privateslwidgetcombo',sprintf('Video format:       '),...
    tags.VideoFormatMenu,formats{selectedIndex},[rowInDialog,rowInDialog],...
    colSpan,'imaqslcallback');


    rowInDialog=rowInDialog+1;
    colSpan=[1,2];
    CameraFileField=tamslgate('privateslwidgetedit',sprintf('        Camera file:  '),tags.CameraFile,...
    [rowInDialog,rowInDialog],colSpan,'imaqslcallback');

    CameraFileField.Alignment=0;


    colSpan=[3,3];
    BrowseButton=tamslgate('privateslwidgetpushbutton',sprintf('     Browse...      '),tags.Browse,...
    [rowInDialog,rowInDialog],colSpan,'imaqslcallback');

    BrowseButton.Alignment=7;


    rowInDialog=rowInDialog+1;
    colSpan=[1,2];
    VideoSourceMenu=tamslgate('privateslwidgetcombo',sprintf('Video source:       '),...
    'VideoSource',videoSources,[rowInDialog,rowInDialog],...
    colSpan,'imaqslcallback');
    VideoSourceMenu.Tag=tags.VideoSource;


    colSpan=[3,3];
    PropertiesButton=tamslgate('privateslwidgetpushbutton',sprintf('Edit properties...'),...
    tags.EditProperties,[rowInDialog,rowInDialog],colSpan,...
    'imaqslcallback');
    PropertiesButton.Alignment=7;


    rowInDialog=rowInDialog+1;
    colSpan=[1,1];
    EnableHWTriggerCheckBox=tamslgate('privateslwidgetcheckbox',...
    sprintf('Enable hardware triggering'),tags.EnableHWTrigger,...
    [rowInDialog,rowInDialog],colSpan,'imaqslcallback');
    EnableHWTriggerCheckBox.Mode=true;


    rowInDialog=rowInDialog+1;
    colSpan=[1,3];
    TriggerConfigField=tamslgate('privateslwidgetcombo',sprintf('        Trigger configuration: '),...
    tags.TriggerConfiguration,triggerConfigurations,[rowInDialog,rowInDialog],...
    colSpan,'imaqslcallback');


    rowInDialog=rowInDialog+1;
    colSpan=[1,3];
    ROIPositionField=tamslgate('privateslwidgetedit',...
    sprintf('ROI position [r, c, height, width]: '),tags.ROIPosition,...
    [rowInDialog,rowInDialog],colSpan,'imaqslcallback');



    rowInDialog=rowInDialog+1;
    colSpan=[1,3];
    ColorSpaceField=tamslgate('privateslwidgetcombo',sprintf('Output color space:'),...
    tags.ColorSpace,colorSpaces,[rowInDialog,rowInDialog],...
    colSpan,'imaqslcallback');


    rowInDialog=rowInDialog+1;
    colSpan=[1,3];

    bayerSensorAlignment={'grbg','gbrg','rggb','bggr'};
    BayerSensorAlignmentField=tamslgate('privateslwidgetcombo',sprintf('        Bayer sensor alignment:'),...
    tags.BayerSensorAlignment,bayerSensorAlignment,[rowInDialog,rowInDialog],...
    colSpan,'imaqslcallback');
    BayerSensorAlignmentField.Mode=true;


    rowInDialog=rowInDialog+1;
    colSpan=[1,1];
    PreviewButton=tamslgate('privateslwidgetpushbutton',sprintf('Preview...'),tags.Preview,...
    [rowInDialog,rowInDialog],colSpan,'imaqslcallback');

    PreviewButton.Alignment=5;


    rowInDialog=rowInDialog+1;
    colSpan=[1,3];
    SampleTimeField=tamslgate('privateslwidgetedit',...
    sprintf('Block sample time:'),tags.SampleTime,...
    [rowInDialog,rowInDialog],colSpan,'imaqslcallback');


    rowInDialog=rowInDialog+1;
    colSpan=[1,3];
    entries={'One multidimensional signal','Separate color signals'};
    OutputPortsMenu=tamslgate('privateslwidgetcombo',sprintf('Ports mode:          '),...
    tags.OutputPortsMode,entries,[rowInDialog,rowInDialog],...
    colSpan,'imaqslcallback');


    if isempty(obj.IMAQObject)||~isvalid(obj.IMAQObject)||...
        strcmpi(obj.ColorSpace,'grayscale')
        OutputPortsMenu.Visible=false;
    else
        OutputPortsMenu.Visible=true;
    end


    rowInDialog=rowInDialog+1;
    colSpan=[1,3];
    entries={'single','double','int8','uint8',...
    'int16','uint16','int32','uint32'};
    DataTypeMenu=tamslgate('privateslwidgetcombo',sprintf('Data type:             '),...
    tags.DataType,entries,[rowInDialog,rowInDialog],...
    colSpan,'imaqslcallback');
    isKinectDepth=imaq.internal.Utility.isKinectDepthDevice(obj.Device);
    isKinectV2Depth=imaq.internal.Utility.isKinectV2DepthDevice(obj.Device);
    isKinectColor=imaq.internal.Utility.isKinectColorDevice(obj.Device);
    if((isKinectDepth||isKinectV2Depth)&&(obj.IsDifferentDevice))
        obj.DataType='uint16';
    elseif(isKinectColor&&obj.isDifferentDevice)
        obj.DataType='uint8';
    end


    rowInDialog=rowInDialog+1;
    colSpan=[1,1];
    ImageAcquisitionModeCheckBox=tamslgate('privateslwidgetcheckbox',...
    sprintf('Read All Frames'),tags.ImaqMode,...
    [rowInDialog,rowInDialog],colSpan,'imaqslcallback');
    ImageAcquisitionModeCheckBox.Mode=false;

    nestedDisableWidgets();

    function nestedDisableWidgets()

        if~any(ismember(formats{selectedIndex},'From camera file'))
            CameraFileField.Visible=false;
            BrowseButton.Visible=false;
        else
            CameraFileField.Visible=true;
            BrowseButton.Visible=true;
        end


        ImageAcquisitionModeCheckBox.Visible=true;


        if~strcmp(obj.VideoFormat,'From camera file')
            CameraFileField.Enabled=false;
            BrowseButton.Enabled=false;
        else
            CameraFileField.Enabled=true;
            BrowseButton.Enabled=true;
        end


        if isempty(obj.IMAQObject)||~isvalid(obj.IMAQObject)||obj.ObjectCreationFailed
            VideoSourceMenu.Enabled=false;
            PropertiesButton.Enabled=false;
            ROIPositionField.Enabled=false;
            ColorSpaceField.Enabled=false;
            BayerSensorAlignmentField.Enabled=false;
            PreviewButton.Enabled=false;
            EnableHWTriggerCheckBox.Enabled=false;
            TriggerConfigField.Enabled=false;
            SampleTimeField.Enabled=false;
            OutputPortsMenu.Enabled=false;
            DataTypeMenu.Enabled=false;
        end


        if~obj.EnableHWTrigger
            TriggerConfigField.Enabled=false;
        else
            TriggerConfigField.Enabled=true;
        end


        if any(ismember(colorSpaces,'bayer'))
            BayerSensorAlignmentField.Visible=true;
        else
            BayerSensorAlignmentField.Visible=false;
        end

        if strcmpi(obj.ColorSpace,'bayer')
            BayerSensorAlignmentField.Enabled=true;
        else
            BayerSensorAlignmentField.Enabled=false;
        end



        if~obj.CanDoHWTrigger
            EnableHWTriggerCheckBox.Visible=false;
            TriggerConfigField.Visible=false;
        else
            EnableHWTriggerCheckBox.Visible=true;
            TriggerConfigField.Visible=true;
        end


        if imaq.internal.Utility.isKinectDepthDevice(obj.Device)||...
            imaq.internal.Utility.isKinectV2DepthDevice(obj.Device)
            ColorSpaceField.Visible=false;
            BayerSensorAlignmentField.Visible=false;
        else
            ColorSpaceField.Visible=true;




        end
    end


    items={DeviceMenu,VideoFormatMenu,CameraFileField,BrowseButton,...
    VideoSourceMenu,PropertiesButton,ROIPositionField,ColorSpaceField,BayerSensorAlignmentField,PreviewButton,...
    EnableHWTriggerCheckBox,TriggerConfigField,SampleTimeField,...
    OutputPortsMenu,DataTypeMenu,ImageAcquisitionModeCheckBox};
    paramPane=tamslgate('privateslwidgetgroup',sprintf('Parameters'),tags.ParameterPane,...
    items,[2,2],[1,3],[rowInDialog+1,3]);
end


function metadataPane=localCreateFVDMetadataParamGroup(obj,paramPaneEndRow)

    tags=imaqslgate('privateimaqslstring','tags');

    rowInDialog=paramPaneEndRow;


    rowInDialog=rowInDialog+1;
    colSpan=[1,4];
    AllMetadata=tamslgate('privateslwidgetlistbox',sprintf('All Metadata'),tags.AllMetadata,...
    [rowInDialog,rowInDialog+6],colSpan,'imaqslcallback');
    metadata={};
    if~isempty(strfind(obj.Device,'Kinect Depth'))
        metadata={'IsPositionTracked',...
        'IsSkeletonTracked',...
        'JointDepthIndices',...
        'JointImageIndices',...
        'JointTrackingState',...
        'JointWorldCoordinates',...
        'PositionDepthIndices',...
        'PositionImageIndices',...
        'PositionWorldCoordinates',...
        'SegmentationData',...
        'SkeletonTrackingID'};
    elseif~isempty(strfind(obj.Device,'Kinect V2 Depth'))
            metadata={'BodyIndexFrame',...
            'BodyTrackingID',...
            'ColorJointIndices',...
            'DepthJointIndices',...
            'HandLeftConfidence',...
            'HandLeftState',...
            'HandRightConfidence',...
            'HandRightState',...
            'IsBodyTracked',...
            'JointPositions',...
            'JointTrackingState'};
        end
    end

    if~isempty(metadata)
        metadataStr=sprintf('%s;',metadata{:});
        obj.AllMetadata=metadataStr(1:end-1);
    end

    AllMetadata.Entries=metadata;

    colSpan=[10,18];
    SelectedMetadata=tamslgate('privateslwidgetlistbox',sprintf('Selected Metadata'),tags.SelectedMetadata,...
    [rowInDialog,rowInDialog+6],colSpan,'imaqslcallback');
    SelectedMetadata.Entries=imaqslgate('privateimaqslgetentries',obj.SelectedMetadata);


    rowInDialog=rowInDialog+3;
    colSpan=[6,8];
    AddButton=tamslgate('privateslwidgetpushbutton',...
    sprintf(''),tags.AddButton,...
    [rowInDialog,rowInDialog],colSpan,'imaqslcallback');
    AddButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','add_row.gif');
    AddButton.Alignment=6;
    AddButton.Enabled=true;



    rowInDialog=rowInDialog+1;
    colSpan=[6,8];
    RemoveButton=tamslgate('privateslwidgetpushbutton',...
    sprintf(''),tags.RemoveButton,...
    [rowInDialog,rowInDialog],colSpan,'imaqslcallback');
    RemoveButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','tte_delete.gif');
    RemoveButton.Alignment=6;
    if isempty(obj.SelectedMetadata)
        RemoveButton.Enabled=false;
    else
        RemoveButton.Enabled=true;
    end


    rowInDialog=rowInDialog-1;
    colSpan=[20,22];
    MoveUpButton=tamslgate('privateslwidgetpushbutton',...
    sprintf(''),tags.MoveUpButton,...
    [rowInDialog,rowInDialog],colSpan,'imaqslcallback');
    MoveUpButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','move_up.gif');
    MoveUpButton.Alignment=6;


    rowInDialog=rowInDialog+1;
    colSpan=[20,22];
    MoveDownButton=tamslgate('privateslwidgetpushbutton',...
    sprintf(''),tags.MoveDownButton,...
    [rowInDialog,rowInDialog],colSpan,'imaqslcallback');
    MoveDownButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','move_down.gif');
    MoveDownButton.Alignment=6;

    items={AllMetadata,SelectedMetadata,AddButton,RemoveButton,MoveUpButton,MoveDownButton};

    metadataPane=tamslgate('privateslwidgetgroup',sprintf('Metadata Output Ports'),tags.MetadataPane,...
    items,[3,3],[1,3],[rowInDialog+1,3]);

end


function localResetDefault(obj)


    obj.IsDifferentDevice=false;
    obj.IsDifferentFormat=false;
    obj.IsDifferentSource=false;

end

