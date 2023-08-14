function dlgStruct=getDialogSchema(obj,dummy)














    [devices,formats,defaults,devNames]=imaqparsehwinfo;
    nDevices=length(devices);




    if nDevices==0
        devices={'(none)'};
        formats={{'(none)'}};
        defaults={{'(none)','(none)'}};
    end


    validateCurrentSelection(obj,nDevices,devices,devNames);


    menus=createParamMenus(obj,devices,formats,defaults);


    updateBlockParams(obj,dummy);


    dlgStruct=createMainDialogPanel(obj,menus);


    [isLibrary,isLocked]=obj.isLibraryBlock(obj.Block);
    if isLibrary&&isLocked
        dlgStruct.DisableDialog=true;
    elseif any(strcmp(obj.Root.SimulationStatus,{'running','paused'}))

        dlgStruct=obj.disableNonTunables(dlgStruct);
    end


    function validateCurrentSelection(obj,nDevices,devices,devNames)



        if any(ismember(devices,obj.VideoDevice)),
            obj.VideoDeviceMenu=obj.VideoDevice;
            return;
        else




            index=strmatch(obj.VideoDevice,devNames);
            if~isempty(index)



                obj.VideoDevice=devices{index(1)};
                obj.VideoDeviceMenu=devices{index(1)};
                return;
            end
        end



        if~strcmp(obj.VideoDevice,'(none)')

            if nDevices>0,
                msg=sprintf(...
                'Video input device ''%s'' is unavailable.',obj.VideoDevice);
                msg=sprintf(...
                '%s\nThe ''%s'' device will be selected.',msg,devNames{1});
            else
                msg='No video input devices are available.';
            end


            uiwait(errordlg(msg,'Device Selection Error','modal'));
        end



        obj.VideoDevice=devices{1};
        obj.VideoDeviceMenu=devices{1};


        function menus=createParamMenus(obj,devices,formats,defaults)




            indices=find(strcmp(devices,obj.VideoDevice)==true);
            selectedIndex=indices(1);


            DeviceNameMenu=initParamWidget('combobox','Device name:',...
            'VideoDeviceMenu',obj,'VideoDeviceMenu');
            DeviceNameMenu.Entries=devices;
            DeviceNameMenu.RowSpan=[1,1];
            DeviceNameMenu.ObjectMethod='updateBlockParams';
            DeviceNameMenu.MethodArgs={'%dialog'};
            DeviceNameMenu.ArgDataTypes={'handle'};


            oldFormatName=[obj.VideoStreamFormat,'_',obj.VideoFrameSize];
            oldFormatName=strrep(oldFormatName,'(16 bit)','');
            oldFormatName=strrep(oldFormatName,' ','');


            videoFormats=unique(formats{selectedIndex});
            if any(ismember(videoFormats,oldFormatName)),

                index=strmatch(oldFormatName,videoFormats);
                obj.VideoStreamFormat=videoFormats{index(1)};
                obj.VideoStreamFormatMenu=videoFormats{index(1)};
            elseif~any(ismember(videoFormats,obj.VideoStreamFormat)),






                obj.VideoStreamFormat=defaults{selectedIndex}{1};
                obj.VideoStreamFormatMenu=defaults{selectedIndex}{1};
            else
                obj.VideoStreamFormatMenu=obj.VideoStreamFormat;
            end
            VideoFormatMenu=initParamWidget('combobox','Input video format:',...
            'VideoStreamFormatMenu',obj,'VideoStreamFormatMenu');
            VideoFormatMenu.Entries=videoFormats;
            VideoFormatMenu.RowSpan=[2,2];
            VideoFormatMenu.ObjectMethod='updateBlockParams';
            VideoFormatMenu.MethodArgs={'%dialog'};
            VideoFormatMenu.ArgDataTypes={'handle'};


            VideoResolutionMenu=initParamWidget('edit',...
            'Video resolution (width x height):','VideoFrameSizeMenu',obj,...
            'VideoFrameSizeMenu');
            VideoResolutionMenu.Visible=false;


            FrameRateMenu=initParamWidget('combobox','Frame rate:','FrameRate',...
            obj,'FrameRate');
            FrameRateMenu.Entries=set(obj,'FrameRate')';
            FrameRateMenu.RowSpan=[4,4];


            DataTypeMenu=initParamWidget('combobox','Output data type:',...
            'DataType',obj,'DataType');
            DataTypeMenu.Entries=set(obj,'DataType')';
            DataTypeMenu.RowSpan=[5,5];


            menus={DeviceNameMenu,VideoFormatMenu,VideoResolutionMenu,...
            FrameRateMenu,DataTypeMenu};


            function dlgstruct=initParamWidget(type,name,tag,sync,prop)






                dlgstruct=initWidgetStruct(type,name,tag);
                dlgstruct.Mode=1;
                dlgstruct.Tunable=0;
                dlgstruct.ObjectProperty=prop;
                dlgstruct.RowSpan=[1,1];
                dlgstruct.ColSpan=[1,1];
                dlgstruct.DialogRefresh=1;

                if sync~=0
                    dlgstruct.MatlabMethod='slDialogUtil';
                    dlgstruct.MatlabArgs={sync,'sync','%dialog',type,'%tag'};
                end


                function dlgStruct=createMainDialogPanel(obj,menus)


                    description=initWidgetStruct('text',obj.Block.MaskDescription,...
                    'description');
                    description.WordWrap=1;

                    descriptionPane=initWidgetStruct('group',obj.Block.MaskType,...
                    'descriptionPane');
                    descriptionPane.Items={description};
                    descriptionPane.RowSpan=[1,1];
                    descriptionPane.ColSpan=[1,1];


                    parameterPane=initWidgetStruct('group','Parameters','parameterPane');
                    parameterPane.Items=menus;
                    parameterPane.RowSpan=[2,2];
                    parameterPane.ColSpan=[1,1];
                    parameterPane.LayoutGrid=[3,10];


                    emptyPane=initWidgetStruct('panel','','emptypane');
                    emptyPane.RowSpan=[3,3];
                    emptyPane.ColSpan=[1,1];


                    mainPanel=initWidgetStruct('panel','','mainPane');
                    mainPanel.Items={descriptionPane,parameterPane,emptyPane};
                    mainPanel.RowStretch=[0,0,1];
                    mainPanel.LayoutGrid=[3,1];


                    dlgTitle=strrep(obj.Block.Name,sprintf('\n'),'');
                    dlgStruct.DialogTitle=['Block Parameters: ',dlgTitle];
                    dlgStruct.HelpMethod='eval';
                    dlgStruct.HelpArgs={obj.Block.MaskHelp};
                    dlgStruct.Items={mainPanel};
                    dlgStruct.DialogTag=obj.Block.Name;

                    dlgStruct.PreApplyCallback='imaqpreapply';
                    dlgStruct.PreApplyArgs={obj,'%dialog'};

                    dlgStruct.SmartApply=0;
                    dlgStruct.CloseMethod='closeCallback';
                    dlgStruct.CloseMethodArgs={'%dialog'};
                    dlgStruct.CloseMethodArgsDT={'handle'};


                    function dlgstruct=initWidgetStruct(type,name,tag)

                        dlgstruct.Type=type;
                        dlgstruct.Name=name;
                        dlgstruct.Tag=tag;
