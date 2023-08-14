function obj=videoinput(hBlock)









    obj=imaqdialog.videoinput(hBlock);


    obj.Block=hBlock;


    parent=obj.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end
    obj.Root=parent;


    obj.VideoDevice=obj.Block.VideoDevice;
    obj.VideoDeviceMenu=obj.Block.VideoDeviceMenu;
    obj.VideoStreamFormat=obj.Block.VideoStreamFormat;
    obj.VideoStreamFormatMenu=obj.Block.VideoStreamFormatMenu;
    obj.VideoFrameSize=obj.Block.VideoFrameSize;
    obj.VideoFrameSizeMenu=obj.Block.VideoFrameSizeMenu;
    obj.FrameRate=obj.Block.FrameRate;
    obj.DataType=obj.Block.DataType;
