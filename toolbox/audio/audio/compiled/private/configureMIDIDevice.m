function[midiControlCell,mappings,status]=configureMIDIDevice(objHandle,...
    params,cachedMIDIControls,cachedMIDIMappings,interface,enableCodeGeneration)




    cachedMIDIProperties={};
    for index=1:length(cachedMIDIMappings)
        cachedMIDIProperties{end+1}=cachedMIDIMappings{index}.Property;%#ok  
    end
    isExtPlugin=isa(objHandle,'audio.internal.loadableAudioPlugin');
    fig=launchDialog(params,cachedMIDIControls,cachedMIDIProperties,isExtPlugin,enableCodeGeneration);

    midiControlCell=cachedMIDIControls;
    mappings=cachedMIDIMappings;


    chooseControlViaDialog(fig);

    status=true;

    if~isvalid(fig)
        return;
    end

    cgBox=findall(fig,'tag','checkboxCG');
    if~isempty(cgBox)&&isvalid(cgBox)
        cg=get(cgBox,'Value');
    else
        cg=0;
    end

    if cg

        str=StringWriter;
        t=datetime('now','TimeZone','local','Format','dd-MMM-yyyy HH:mm:ss ZZZZ');
        add(str,sprintf('function setupMIDIControls(obj)\n'));
        add(str,sprintf('\n%% Generated on %s\n\n',char(t)));
        add(str,sprintf('%% Use this code to synchronize your object with the MIDI device.\n'));
    end

    unsetString=getString(message('audio:shared:MIDIUnset'));



    for index=1:length(params)
        param=params{index};
        editbox=findall(fig,'tag',sprintf('textDisplay%s',param.Property));
        midiStr=get(editbox,'String');

        if strcmp(midiStr,'Cancel')
            status=false;
            break;
        end

        propInd=find(ismember(cachedMIDIProperties,param.Property),1);
        if strcmp(midiStr,unsetString)&&isempty(propInd)
            continue
        end

        if~strcmp(midiStr,unsetString)

            midiStr=strrep(midiStr,'control ','');
            midiStr=strrep(midiStr,' on ','');
            ind=strfind(midiStr,'''');
            noDevice=false;
            if isempty(ind)
                ind=strfind(midiStr,'no MIDI device');
                noDevice=true;
            end
            channelNumber=midiStr(1:ind(1)-1);
            midiStr=midiStr(ind(1):end);
            midiStr=strrep(midiStr,'''','');
            deviceName=midiStr;

            if isExtPlugin
                val=getParameter(objHandle,param.Index);
            else
                val=objHandle.(param.Property);
                if~ischar(val)
                    if(val<param.Min)
                        val=param.Min;
                    end
                    if(val>param.Max)
                        val=param.Max;
                    end
                end
            end

            [fromNormFcn,fromPropFcn]=getPluginMappingRules(param);
            initialMIDIVal=fromPropFcn(val);

            if strcmp(channelNumber,'any')
                if noDevice
                    midicontrol=midicontrols();
                else
                    midicontrol=midicontrols('MIDIDevice',deviceName);
                end
            else
                if noDevice
                    midicontrol=midicontrols(str2double(channelNumber));
                else
                    midicontrol=midicontrols(str2double(channelNumber),initialMIDIVal,'MIDIDevice',deviceName);
                end
            end
            midisync(midicontrol,initialMIDIVal);
            if isExtPlugin
                midicallback(midicontrol,@(midicontrol)midiObjectCallbackExternalPlugin(...
                midicontrol,objHandle,param,interface));
            else
                midicallback(midicontrol,@(midicontrol)midiObjectCallback(...
                midicontrol,objHandle,param.Property,fromNormFcn,interface));
            end
        else
            midicontrol=[];
        end

        if isempty(propInd)
            midiControlCell{end+1}=midicontrol;%#ok
            mappings{end+1}=param;%#ok
        else
            midiControlCell{propInd}=midicontrol;
        end

        if cg&&~strcmp(midiStr,unsetString)
            if isExtPlugin
                if ischar(channelNumber)&&strcmp(channelNumber,'any')
                    line=sprintf('configureMIDI(obj,%d,''DeviceName'',''%s''); %% %s\n',param.Index,deviceName,param.DisplayName);
                else
                    line=sprintf('configureMIDI(obj,%d,%s,''DeviceName'',''%s''); %% %s\n',param.Index,channelNumber,deviceName,param.DisplayName);
                end
            else
                if ischar(channelNumber)&&strcmp(channelNumber,'any')
                    line=sprintf('configureMIDI(obj,''%s'',''DeviceName'',''%s'');\n',param.Property,deviceName);
                else
                    line=sprintf('configureMIDI(obj,''%s'',%s,''DeviceName'',''%s'');\n',param.Property,channelNumber,deviceName);
                end
            end
            add(str,line);
        end

    end

    if cg
        matlab.desktop.editor.newDocument(string(str));
    end

    delete(fig);

end

function chooseControlViaDialog(fig)
    listenForAnyControlOnAnyDevice(fig);
    uiwait(fig);
end

function listenForAnyControlOnAnyDevice(fig)
    data=guidata(fig);
    devinfo=midicontrols.devices;
    devinfo=devinfo([devinfo.input]);
    data.ctls={};
    for d=devinfo

        try
            h=midicontrols('MIDIDevice',d.name,'InitialValue',0.5);
            midicallback(h,@(ctl)midicb(ctl,d.name,fig));
            data.ctls{end+1}=h;
        catch e %#ok  
        end
    end
    guidata(fig,data);
end

function fig=launchDialog(params,cachedMIDIControls,cachedMIDIProperties,isExtPlugin,enableCG)

    fig=figure(...
    'Units','characters',...
    'Color',[0.701960784313725,0.701960784313725,0.701960784313725],...
    'Colormap',[0,0,0.5625;0,0,0.625;0,0,0.6875;0,0,0.75;0,0,0.8125;0,0,0.875;0,0,0.9375;0,0,1;0,0.0625,1;0,0.125,1;0,0.1875,1;0,0.25,1;0,0.3125,1;0,0.375,1;0,0.4375,1;0,0.5,1;0,0.5625,1;0,0.625,1;0,0.6875,1;0,0.75,1;0,0.8125,1;0,0.875,1;0,0.9375,1;0,1,1;0.0625,1,1;0.125,1,0.9375;0.1875,1,0.875;0.25,1,0.8125;0.3125,1,0.75;0.375,1,0.6875;0.4375,1,0.625;0.5,1,0.5625;0.5625,1,0.5;0.625,1,0.4375;0.6875,1,0.375;0.75,1,0.3125;0.8125,1,0.25;0.875,1,0.1875;0.9375,1,0.125;1,1,0.0625;1,1,0;1,0.9375,0;1,0.875,0;1,0.8125,0;1,0.75,0;1,0.6875,0;1,0.625,0;1,0.5625,0;1,0.5,0;1,0.4375,0;1,0.375,0;1,0.3125,0;1,0.25,0;1,0.1875,0;1,0.125,0;1,0.0625,0;1,0,0;0.9375,0,0;0.875,0,0;0.8125,0,0;0.75,0,0;0.6875,0,0;0.625,0,0;0.5625,0,0],...
    'IntegerHandle','off',...
    'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
    'MenuBar','none',...
    'NumberTitle','off',...
    'PaperPosition',get(0,'defaultfigurePaperPosition'),...
    'Position',[103.833333333333,45.75,80,20],...
    'Resize','off',...
    'HandleVisibility','callback',...
    'UserData',[],...
    'Tag','figure1',...
    'Visible','on',...
    'WindowStyle','modal');


    if isExtPlugin
        paramSelectionLabel=getString(message('audio:shared:MIDISelectExternal'));
    else
        paramSelectionLabel=getString(message('audio:shared:MIDISelect'));
    end

    uicontrol(...
    'Parent',fig,...
    'Units','characters',...
    'HorizontalAlignment','left',...
    'Position',[4.5,17,41.6666666666667,1.08333333333333],...
    'BackgroundColor',[0.701960784313725,0.701960784313725,0.701960784313725],...
    'Style','text',...
    'String',paramSelectionLabel,...
    'Tag','midiparamtext');


    dropdown_list=cell(1,length(params));
    dropdown_props=cell(1,length(params));
    for index=1:length(params)
        dropdown_props{index}=params{index}.Property;
        if isExtPlugin
            dropdown_list{index}=sprintf('%2d: %s',params{index}.Index,params{index}.DisplayName);
        else
            dropdown_list{index}=params{index}.Property;
        end
    end
    uicontrol(...
    'Parent',fig,...
    'Units','characters',...
    'HorizontalAlignment','left',...
    'Position',[4.5,15,41.6666666666667,1.08333333333333],...
    'Style','popupmenu',...
    'Tag','midiparamdropdown',...
    'String',dropdown_list,...
    'UserData',dropdown_props,...
    'Callback',@dropDownCallback);


    uicontrol(...
    'Parent',fig,...
    'Units','characters',...
    'HorizontalAlignment','left',...
    'Position',[4.5,12,41.6666666666667,1.08333333333333],...
    'BackgroundColor',[0.701960784313725,0.701960784313725,0.701960784313725],...
    'String',getString(message('audio:shared:MIDIOperate')),...
    'Style','text',...
    'Tag','textInstructions');

    dropdown=findall(fig,'tag','midiparamdropdown');
    dropdown_val=get(dropdown,'Value');
    L=length(params);
    for index=1:L
        param=params{index};

        vis=dropdown_val==index;
        if vis
            visStr='on';
        else
            visStr='off';
        end
        index=find(ismember(cachedMIDIProperties,param.Property),1);%#ok
        if~isempty(index)
            ctrl=cachedMIDIControls{index};%#ok
            ctrlStr=evalc('disp(ctrl)');
            ctrlStr=strrep(ctrlStr,'midicontrols object: ','');
            ctrlStr=strrep(ctrlStr,newline,'');
        else
            ctrlStr=getString(message('audio:shared:MIDIUnset'));
        end
        uicontrol(...
        'Parent',fig,...
        'Units','characters',...
        'BackgroundColor',[1,1,1],...
        'HorizontalAlignment','left',...
        'Position',[4.5,10,45.3333333333333,1.08333333333333],...
        'Style','text',...
        'Tag',sprintf('textDisplay%s',param.Property),...
        'Visible',visStr,...
        'String',ctrlStr);
    end


    uicontrol(...
    'Parent',fig,...
    'Units','characters',...
    'Callback',@pushbuttonCancelCallback,...
    'Position',[52,9.75,16,1.5],...
    'String',getString(message('audio:shared:MIDIReset')),...
    'Tag','pushbuttonReset',...
    'Callback',@pushbuttonResetCallback);


    if enableCG
        uicontrol(...
        'Parent',fig,...
        'Units','characters',...
        'Position',[4.5,6.5,30,1.75],...
        'Tag','checkboxCG',...
        'String',getString(message('audio:shared:MIDICG')),...
        'Style','checkbox',...
        'BackgroundColor',[0.701960784313725,0.701960784313725,0.701960784313725]);
    end


    uicontrol(...
    'Parent',fig,...
    'Units','characters',...
    'Callback',@pushbuttonOKCallback,...
    'Position',[15,1.41666666666667,10,1.75],...
    'Tag','pushbuttonOK',...
    'String',getString(message('audio:shared:OK')));


    uicontrol(...
    'Parent',fig,...
    'Units','characters',...
    'Callback',@pushbuttonCancelCallback,...
    'Position',[35,1.41666666666667,12,1.75],...
    'String',getString(message('audio:shared:Cancel')),...
    'Tag','pushbuttonCancel');


    uicontrol(...
    'Parent',fig,...
    'Units','characters',...
    'Callback',@pushbuttonHelpCallback,...
    'Position',[55,1.41666666666667,12,1.75],...
    'String',getString(message('audio:shared:Help')),...
    'Tag','pushbuttonHelp');

    pos=get(fig,'Position');
    pos(2)=pos(2)-20;
    set(fig,'Position',pos)

    set(fig,'Name',getString(message('audio:shared:MIDISetup')));


    function pushbuttonOKCallback(hObject,eventdata)%#ok<INUSD>
        uiresume;
    end

    function pushbuttonCancelCallback(hObject,eventdata)%#ok<INUSD>
        setControlAndDevice(hObject,[],'')
        fig=get(hObject,'Parent');

        handles=guihandles(hObject);
        dropdown=handles.midiparamdropdown;
        list=get(dropdown,'UserData');
        for ind=1:length(list)
            editbox=handles.(sprintf('textDisplay%s',list{ind}));
            set(editbox,'String','Cancel');
        end

        uiresume;
    end

    function pushbuttonHelpCallback(hObject,eventdata)%#ok<INUSD>
        helpview(fullfile(docroot,'audio','helptargets.map'),'configureMIDI');
    end
end

function dropDownCallback(hObject,eventdata)%#ok<INUSD>


    handles=guihandles(hObject);

    dropdown=handles.midiparamdropdown;
    list=get(dropdown,'UserData');
    val=get(dropdown,'Value');

    for index=1:length(list)
        editbox=handles.(sprintf('textDisplay%s',list{index}));
        if index==val
            set(editbox,'Visible','on');
        else
            set(editbox,'Visible','off');
        end
    end

end

function pushbuttonResetCallback(hObject,eventdata)%#ok<INUSD>


    handles=guihandles(hObject);
    dropdown=handles.midiparamdropdown;
    list=get(dropdown,'UserData');
    val=get(dropdown,'Value');

    editbox=handles.(sprintf('textDisplay%s',list{val}));
    set(editbox,'String',getString(message('audio:shared:MIDIUnset')));
end