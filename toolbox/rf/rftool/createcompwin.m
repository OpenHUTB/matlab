function varargout=createcompwin(varargin)


























    gui_Singleton=1;
    gui_State=struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@createcompwin_OpeningFcn,...
    'gui_OutputFcn',@createcompwin_OutputFcn,...
    'gui_LayoutFcn',@createcompwin_LayoutFcn,...
    'gui_Callback',[]);
    if nargin&&ischar(varargin{1})
        gui_State.gui_Callback=str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}]=gui_mainfcn(gui_State,varargin{:});
    else
        gui_mainfcn(gui_State,varargin{:});
    end




    function createcompwin_OpeningFcn(hObject,eventdata,handles,varargin)






        set(hObject,'Visible','off');


        handles.rftoolfig=varargin{1};


        hcreatewin=hObject;


        handles.output=hObject;


        if strcmp(get(get(handles.rftoolfig,'currentObject'),'String'),'Insert')
            set(hObject,'Name','Insert Component or Network');
            set(handles.uipanel5,'Title','Insert RF Component or Network');
            set(handles.nw_rb,'Value',0)
            set(handles.comp_rb,'Value',1)
        else
            set(hObject,'Name','Create Network or Component');
            set(handles.uipanel5,'Title','Create RF Network or Component');
            set(handles.comp_rb,'Value',0)
            set(handles.nw_rb,'Value',1)
        end














        orig_state=warning('off','MATLAB:uitable:DeprecatedFunction');
        hTab=uitable('v0',hObject,12,2);
        warning(orig_state);



        hTab.setColumnNames({'Parameter name','Value'});

        entireFigPosition=get(hObject,'Position');
        currPanelPosition=get(handles.uipanel5,'Position');
        newPos=currPanelPosition.*entireFigPosition([3,4,3,4]);
        subPanelPosition=get(handles.CompDataTable,'position');
        newPos=[newPos(1:2),0,0]+subPanelPosition.*newPos([3,4,3,4]);



        hTab.setPosition(newPos);


        hTab.setColumnWidth(newPos(3)/2.168);



        hTab.setEditable(1,false);


        hTab.setEnabled(1,false);



        set(hTab,'DataChangedCallback','');


        object=rfckt.delay;

        data=displayProperties(object,hTab);


        rfhandles=guidata(handles.rftoolfig);

        huitree=rfhandles.uitree;

        compname=makenameunique('Component',huitree);
        set(handles.compname_edt,'String',compname);


        handles.compname=compname;

        set(handles.comptype_popup,'value',1)

        handles.comptype='Cascaded Network';


        handles.Tab=hTab;
        handles.createwin=hcreatewin;
        handles.paramdata=data;


        guidata(hObject,handles);

        rfhandles.hcreatewin=hcreatewin;
        guidata(handles.rftoolfig,rfhandles);

        drawnow;
        if~ispc,set(findall(hObject,'type','uicontrol'),'fontname','arial');end





        rbuttongrp_SelectionChangeFcn(hObject,[],handles);
        drawnow;

        uiwait(handles.figure1);


        function varargout=createcompwin_OutputFcn(hObject,eventdata,handles)






            try
                delete(handles.createwin);
            end



            function compname_edt_CreateFcn(hObject,eventdata,handles)







                set(hObject,'BackgroundColor','white');






                function comptype_popup_Callback(hObject,eventdata,handles)







                    listCompType=get(hObject,'String');
                    selCompType=char(listCompType(get(hObject,'Value')));


                    hTab=handles.Tab;



                    col_width=hTab.getColumnWidth;



                    if get(handles.comp_rb,'value')


                        object=ckt_name_map(selCompType);

                        if~isempty(object)

                            if strcmp(selCompType,'Data File')
                                try
                                    [fname,pname]=uigetfile({'*.s2p';'*.y2p';'*.z2p';'*.h2p';'*.g2p'},...
                                    'Import from File');
                                    if(ischar(fname))

                                        objname=fname(1:find(fname=='.')-1);

                                        if isempty(which(fname))
                                            fname=[pname,fname];
                                        end
                                        object=rfckt.datafile('File',['',fname,'']);
                                    end
                                catch readException
                                    if strfind(readException.identifier,'unsupportedfile')
                                        errstring='The filename extension must be SNP, YNP, ZNP or HNP.';
                                        errordlg(errstring,'Error importing data from file');
                                    else
                                        errordlg(readException.message,'Error importing data from file');
                                    end

                                    set(hObject,'Value',1);

                                    object=rfckt.delay;

                                end
                            end

                            data=displayProperties(object,hTab);

                        else
                            errordlg('Unknown Error. Could not find correct component!')
                            return
                        end
                    else

                        object=network_name_map(selCompType);
                        data={};



                        hTab.setVisible(0);

                    end


                    handles.paramdata=data;


                    handles.comptype=selCompType;


                    guidata(hObject,handles);



                    function comptype_popup_CreateFcn(hObject,eventdata,handles)







                        set(hObject,'BackgroundColor','white');






                        function ok_pushb_Callback(hObject,eventdata,handles)




                            hrftoolfig=handles.rftoolfig;
                            data=handles.paramdata;
                            hTab=handles.Tab;


                            hcompname=get(handles.compname_edt,'string');
                            listComp=get(handles.comptype_popup,'string');
                            hcomptype=listComp(get(handles.comptype_popup,'Value'));




                            rfhandles=guidata(hrftoolfig);
                            nextNode=get(rfhandles.uiroot,'NextNode');
                            availnum=ones(1,100);
                            while~isempty(nextNode)
                                name=get(nextNode,'Name');
                                currentNode=nextNode;
                                nextNode=get(currentNode,'NextNode');
                                if strcmp(name,hcompname)
                                    errordlg('Component name already used.');
                                    return;
                                end
                            end





                            if~isempty(data)



                                ce=hTab.Table.getCellEditor;



                                if~isempty(ce)

                                    awtinvoke(ce,'stopCellEditing');
                                    drawnow;
                                end



                                new_data=getData(hTab);

                                new_data=cell(new_data);
                                data(:,2)=new_data(:,2);

                            end


                            rfhandles=guidata(handles.rftoolfig);
                            rfhandles.new_data={hcompname,hcomptype,data};
                            guidata(handles.rftoolfig,rfhandles);


                            guidata(hObject,handles);

                            uiresume(handles.figure1);


                            function uitableedt_Callback(src,evd,hfig)


                                handles=guidata(hfig);
                                hTab=handles.Tab;



                                data=hTab.getData;

                                handles.paramdata=data;


                                guidata(hfig,handles);


                                function rbuttongrp_SelectionChangeFcn(hObject,eventdata,handles)





                                    hTab=handles.Tab;


                                    rfhandles=guidata(handles.rftoolfig);
                                    huitree=rfhandles.uitree;



                                    if get(handles.comp_rb,'Value')==1


                                        comp={'Delay Line';'Transmission Line';'Two Wire Transmission Line';...
                                        'Microstrip Transmission Line';'Parallel Plate Transmission Line';...
                                        'Coaxial Transmission Line';'Coplanar Waveguide Transmission Line';...
                                        'Series RLC';'Shunt RLC';...
                                        'LC Lowpass Pi';'LC Lowpass Tee';'LC Highpass Pi';...
                                        'LC Highpass Tee';'LC Bandpass Pi';'LC Bandpass Tee';...
                                        'LC Bandstop Pi';'LC Bandstop Tee';'Data File'};


                                        compname=makenameunique('Component',huitree);


                                        set(handles.compname_txt,'string','Component Name:');
                                        set(handles.comptype_edt,'string','Component Type:');
                                        set(handles.comptype_popup,'Value',1);
                                        set(handles.comptype_popup,'string',comp);



                                        object=rfckt.delay;

                                        displayProperties(object,hTab);

                                    else


                                        nw={'Cascaded Network';'Series Connected Network';...
                                        'Parallel Connected Network';'Hybrid Connected Network';...
                                        'Hybrid G Connected Network'};

                                        compname=makenameunique('Network',huitree);


                                        set(handles.compname_txt,'string','Network Name:');

                                        set(handles.comptype_edt,'string','Network Type:');
                                        set(handles.comptype_popup,'Value',1);
                                        set(handles.comptype_popup,'string',nw);




                                        hTab.setVisible(0);
                                    end

                                    set(handles.compname_edt,'String',compname);

                                    guidata(hObject,handles);

                                    comptype_popup_Callback(handles.comptype_popup,eventdata,handles)


                                    function nodes=tabdatachg(src,value,hfig)






                                        function varargout=displayProperties(object,hTab)





                                            col_width=hTab.getColumnWidth;


                                            obj_strt=set(object);
                                            obj_props=fieldnames(obj_strt);
                                            numProps=length(obj_props);
                                            data=cell(numProps,2);
                                            data_disp=cell(numProps,2);
                                            obj_values=cell(numProps,2);
                                            expanded_obj_props=cell(numProps,1);



                                            for idx=1:length(obj_props)
                                                obj_values{idx}=get(object,obj_props{idx});
                                                expanded_obj_props(idx)=param_name_map(obj_props(idx),1);
                                                data(idx,:)={expanded_obj_props{idx},property2str(obj_values{idx})};
                                            end










                                            hTab.setData(data);


                                            hTab.setColumnWidth(col_width);



                                            hTab.setVisible(1);

                                            varargout{1}=data;


                                            function compname=makenameunique(compname,huitree)
                                                hcurrnode=get(huitree,'root');
                                                more=1;
                                                usednumstr=[];
                                                while more==1
                                                    currname=get(hcurrnode,'Name');
                                                    if(length(currname)>=length(compname)&&...
                                                        strcmp(compname,currname(1:length(compname))))
                                                        usednumstr=[usednumstr,' ',currname(length(compname)+1:end)];
                                                    end
                                                    hnextnode=get(hcurrnode,'nextnode');
                                                    if~isempty(hnextnode)
                                                        hcurrnode=hnextnode;
                                                    else
                                                        more=0;
                                                    end
                                                end

                                                if isempty(usednumstr)
                                                    numstr='';
                                                else
                                                    testnum=1;
                                                    while strfind(usednumstr,num2str(testnum))
                                                        testnum=testnum+1;
                                                    end
                                                    numstr=num2str(testnum);
                                                end
                                                compname=[compname,numstr];




                                                function createcompwin_CloseRequestFcn(hObject,eventdata,handles)

                                                    rfhandles=guidata(handles.rftoolfig);
                                                    rfhandles.new_data={};
                                                    guidata(handles.rftoolfig,rfhandles);

                                                    uiresume(handles.figure1);



                                                    function h1=createcompwin_LayoutFcn(policy)


                                                        persistent hsingleton;
                                                        if strcmpi(policy,'reuse')&ishghandle(hsingleton)
                                                            h1=hsingleton;
                                                            return;
                                                        end

                                                        appdata=[];
                                                        appdata.GUIDEOptions=struct(...
                                                        'active_h',[],...
                                                        'taginfo',struct(...
                                                        'figure',2,...
                                                        'frame',2,...
                                                        'text',4,...
                                                        'edit',3,...
                                                        'popupmenu',2,...
                                                        'pushbutton',2,...
                                                        'uipanel',11,...
                                                        'radiobutton',11,...
                                                        'togglebutton',2),...
                                                        'override',0,...
                                                        'release',13,...
                                                        'resize','none',...
                                                        'accessibility','callback',...
                                                        'matlabfunction',1,...
                                                        'callbacks',1,...
                                                        'singleton',1,...
                                                        'syscolorfig',1,...
                                                        'blocking',0,...
                                                        'lastSavedFile','createcompwin.m');
                                                        appdata.lastValidTag='figure1';
                                                        appdata.GUIDELayoutEditor=[];

                                                        screen_size=get(0,'ScreenSize');
                                                        temp_pos=zeros(1,4);
                                                        temp_pos(4)=0.35*screen_size(4);
                                                        temp_pos(3)=temp_pos(4)*1.3;
                                                        temp_pos(1)=screen_size(1);
                                                        temp_pos(2)=screen_size(2)+screen_size(4)-1.4*temp_pos(4);
                                                        h1=figure(...
                                                        'CloseRequestFcn','createcompwin(''createcompwin_CloseRequestFcn'',gcf,[],guidata(gcf))',...
                                                        'Color',[0.831372549019608,0.815686274509804,0.784313725490196],...
                                                        'Colormap',[0,0,0.5625;0,0,0.625;0,0,0.6875;0,0,0.75;0,0,0.8125;0,0,0.875;0,0,0.9375;0,0,1;0,0.0625,1;0,0.125,1;0,0.1875,1;0,0.25,1;0,0.3125,1;0,0.375,1;0,0.4375,1;0,0.5,1;0,0.5625,1;0,0.625,1;0,0.6875,1;0,0.75,1;0,0.8125,1;0,0.875,1;0,0.9375,1;0,1,1;0.0625,1,1;0.125,1,0.9375;0.1875,1,0.875;0.25,1,0.8125;0.3125,1,0.75;0.375,1,0.6875;0.4375,1,0.625;0.5,1,0.5625;0.5625,1,0.5;0.625,1,0.4375;0.6875,1,0.375;0.75,1,0.3125;0.8125,1,0.25;0.875,1,0.1875;0.9375,1,0.125;1,1,0.0625;1,1,0;1,0.9375,0;1,0.875,0;1,0.8125,0;1,0.75,0;1,0.6875,0;1,0.625,0;1,0.5625,0;1,0.5,0;1,0.4375,0;1,0.375,0;1,0.3125,0;1,0.25,0;1,0.1875,0;1,0.125,0;1,0.0625,0;1,0,0;0.9375,0,0;0.875,0,0;0.8125,0,0;0.75,0,0;0.6875,0,0;0.625,0,0;0.5625,0,0],...
                                                        'IntegerHandle','off',...
                                                        'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
                                                        'MenuBar','none',...
                                                        'Name','Create Component',...
                                                        'NumberTitle','off',...
                                                        'PaperPosition',get(0,'defaultfigurePaperPosition'),...
                                                        'Position',temp_pos,...
                                                        'Renderer',get(0,'defaultfigureRenderer'),...
                                                        'RendererMode','manual',...
                                                        'Resize','off',...
                                                        'HandleVisibility','callback',...
                                                        'Tag','figure1',...
                                                        'UserData',[],...
                                                        'Behavior',get(0,'defaultfigureBehavior'),...
                                                        'Visible','off',...
                                                        'CreateFcn',{@local_CreateFcn,'',appdata});

                                                        appdata=[];
                                                        appdata.lastValidTag='uipanel5';

                                                        h7=uipanel(...
                                                        'Parent',h1,...
                                                        'Title','Create RF Component/Network',...
                                                        'Position',[0.01,0.02,.98,.96],...
                                                        'Tag','uipanel5',...
                                                        'Behavior',get(0,'defaultuipanelBehavior'),...
                                                        'CreateFcn',{@local_CreateFcn,'',appdata});

                                                        appdata=[];
                                                        appdata.lastValidTag='CompDataTable';

                                                        uipanel(...
                                                        'Parent',h7,...
                                                        'Units','normalized',...
                                                        'Title','',...
                                                        'Position',[.05,.10,.90,.45],...
                                                        'Tag','CompDataTable',...
                                                        'Behavior',get(0,'defaultuipanelBehavior'),...
                                                        'Visible','off',...
                                                        'CreateFcn',{@local_CreateFcn,'',appdata});

                                                        appdata=[];
                                                        appdata.lastValidTag='compname_txt';

                                                        uicontrol(...
                                                        'Parent',h1,...
                                                        'Units','normalized',...
                                                        'FontSize',get(0,'defaultuicontrolFontSize'),...
                                                        'HorizontalAlignment','right',...
                                                        'Position',[0.06-0.03,0.695,0.22+0.03,0.06],...
                                                        'String','Component Name:',...
                                                        'Style','text',...
                                                        'Tag','compname_txt',...
                                                        'CreateFcn',{@local_CreateFcn,'',appdata});

                                                        appdata=[];
                                                        appdata.lastValidTag='compname_edt';

                                                        uicontrol(...
                                                        'Parent',h1,...
                                                        'Units','normalized',...
                                                        'BackgroundColor',[1,1,1],...
                                                        'FontSize',get(0,'defaultuicontrolFontSize'),...
                                                        'HorizontalAlignment','left',...
                                                        'Position',[0.30,0.71,0.58,0.06],...
                                                        'String','Component1',...
                                                        'Style','edit',...
                                                        'CreateFcn',{@local_CreateFcn,'createcompwin(''compname_edt_CreateFcn'',gcbo,[],guidata(gcbo))',appdata},...
                                                        'Tag','compname_edt');

                                                        appdata=[];
                                                        appdata.lastValidTag='comptype_edt';

                                                        uicontrol(...
                                                        'Parent',h1,...
                                                        'Units','normalized',...
                                                        'FontSize',get(0,'defaultuicontrolFontSize'),...
                                                        'HorizontalAlignment','right',...
                                                        'Position',[0.06-0.03,0.60,0.22+0.03,0.06],...
                                                        'String','Component Type:',...
                                                        'Style','text',...
                                                        'Tag','comptype_edt',...
                                                        'CreateFcn',{@local_CreateFcn,'',appdata});

                                                        appdata=[];
                                                        appdata.lastValidTag='comptype_popup';

                                                        uicontrol(...
                                                        'Parent',h1,...
                                                        'Units','normalized',...
                                                        'BackgroundColor',[1,1,1],...
                                                        'Callback','createcompwin(''comptype_popup_Callback'',gcbo,[],guidata(gcbo))',...
                                                        'FontSize',get(0,'defaultuicontrolFontSize'),...
                                                        'Position',[0.30,0.615,0.58,0.06],...
                                                        'String',{'Delay Line';'Transmission Line';'Two Wire Transmission Line';...
                                                        'Microstrip Transmission Line';'Parallel Plate Transmission Line';...
                                                        'Coaxial Transmission Line';'Coplanar Waveguide Transmission Line';...
                                                        'Series RLC';'Shunt RLC';...
                                                        'LC Lowpass Pi';'LC Lowpass Tee';'LC Highpass Pi';...
                                                        'LC Highpass Tee';'LC Bandpass Pi';'LC Bandpass Tee';...
                                                        'LC Bandstop Pi';'LC Bandstop Tee';'Data File'},...
                                                        'Style','popupmenu',...
                                                        'Value',1,...
                                                        'CreateFcn',{@local_CreateFcn,'createcompwin(''comptype_popup_CreateFcn'',gcbo,[],guidata(gcbo))',appdata},...
                                                        'Tag','comptype_popup');

                                                        appdata=[];
                                                        appdata.lastValidTag='ok_pushb';

                                                        uicontrol(...
                                                        'Parent',h1,...
                                                        'Units','normalized',...
                                                        'Callback','createcompwin(''ok_pushb_Callback'',gcbo,[],guidata(gcbo))',...
                                                        'FontSize',get(0,'defaultuicontrolFontSize'),...
                                                        'Position',[0.45,0.05,0.10,0.05],...
                                                        'String','OK',...
                                                        'Tag','ok_pushb',...
                                                        'CreateFcn',{@local_CreateFcn,'',appdata});

                                                        appdata=[];
                                                        appdata.lastValidTag='rbuttongrp';

                                                        h8=uibuttongroup(...
                                                        'Parent',h7,...
                                                        'Title','',...
                                                        'Position',[0.20,0.85,0.6,0.1],...
                                                        'Tag','rbuttongrp',...
                                                        'Behavior',struct(),...
                                                        'SelectedObject',[],...
                                                        'SelectionChangeFcn','createcompwin(''rbuttongrp_SelectionChangeFcn'',gcbo,[],guidata(gcbo))',...
                                                        'CreateFcn',{@local_CreateFcn,'',appdata});
                                                        appdata=[];
                                                        appdata.lastValidTag='comp_rb';
                                                        appdata.Listeners={[]};

                                                        uicontrol(...
                                                        'Parent',h8,...
                                                        'Units','normalized',...
                                                        'Callback','',...
                                                        'FontSize',get(0,'defaultuicontrolFontSize'),...
                                                        'Position',[0.05,0.35,0.40,0.4],...
                                                        'String','Component',...
                                                        'Style','radiobutton',...
                                                        'Tag','comp_rb',...
                                                        'CreateFcn',{@local_CreateFcn,'',appdata});

                                                        appdata=[];
                                                        appdata.lastValidTag='nw_rb';
                                                        appdata.Listeners={[]};

                                                        uicontrol(...
                                                        'Parent',h8,...
                                                        'Units','normalized',...
                                                        'Callback','',...
                                                        'FontSize',get(0,'defaultuicontrolFontSize'),...
                                                        'Position',[0.7,0.35,0.30,0.4],...
                                                        'String','Network',...
                                                        'Style','radiobutton',...
                                                        'Tag','nw_rb',...
                                                        'CreateFcn',{@local_CreateFcn,'',appdata});


                                                        hsingleton=h1;



                                                        function local_CreateFcn(hObject,eventdata,createfcn,appdata)

                                                            if~isempty(appdata)
                                                                names=fieldnames(appdata);
                                                                for i=1:length(names)
                                                                    name=char(names(i));
                                                                    setappdata(hObject,name,getfield(appdata,name));
                                                                end
                                                            end

                                                            if~isempty(createfcn)
                                                                eval(createfcn);
                                                            end



                                                            function varargout=gui_mainfcn(gui_State,varargin)

                                                                gui_StateFields={'gui_Name'
'gui_Singleton'
'gui_OpeningFcn'
'gui_OutputFcn'
'gui_LayoutFcn'
                                                                'gui_Callback'};
                                                                gui_Mfile='';
                                                                for i=1:length(gui_StateFields)
                                                                    if~isfield(gui_State,gui_StateFields{i})
                                                                        error(message('rf:createcompwin:NoField',gui_StateFields{i},gui_Mfile));
                                                                    elseif isequal(gui_StateFields{i},'gui_Name')
                                                                        gui_Mfile=[gui_State.(gui_StateFields{i}),'.m'];
                                                                    end
                                                                end

                                                                numargin=length(varargin);

                                                                if numargin==0


                                                                    gui_Create=1;
                                                                elseif length(varargin{1})==1&&ishghandle(varargin{1})&&varargin{1}==gcbo

                                                                    vin{1}=gui_State.gui_Name;
                                                                    vin{2}=[get(varargin{1}.Peer,'Tag'),'_',varargin{end}];
                                                                    vin{3}=varargin{1};
                                                                    vin{4}=varargin{end-1};
                                                                    vin{5}=guidata(varargin{1}.Peer);
                                                                    feval(vin{:});
                                                                    return;
                                                                elseif ischar(varargin{1})&&numargin>1&&length(varargin{2})==1&&ishghandle(varargin{2})

                                                                    gui_Create=0;
                                                                else


                                                                    gui_Create=1;
                                                                end

                                                                if gui_Create==0
                                                                    varargin{1}=gui_State.gui_Callback;
                                                                    if nargout
                                                                        [varargout{1:nargout}]=feval(varargin{:});
                                                                    else
                                                                        feval(varargin{:});
                                                                    end
                                                                else
                                                                    if gui_State.gui_Singleton
                                                                        gui_SingletonOpt='reuse';
                                                                    else
                                                                        gui_SingletonOpt='new';
                                                                    end





                                                                    if~isempty(gui_State.gui_LayoutFcn)
                                                                        gui_hFigure=feval(gui_State.gui_LayoutFcn,gui_SingletonOpt);


                                                                        set(gui_hFigure,'visible','off')
                                                                        movegui(gui_hFigure,'onscreen')
                                                                    else
                                                                        gui_hFigure=local_openfig(gui_State.gui_Name,gui_SingletonOpt);


                                                                        if isappdata(gui_hFigure,'InGUIInitialization')
                                                                            delete(gui_hFigure);
                                                                            gui_hFigure=local_openfig(gui_State.gui_Name,gui_SingletonOpt);
                                                                        end
                                                                    end


                                                                    setappdata(gui_hFigure,'InGUIInitialization',1);


                                                                    gui_Options=getappdata(gui_hFigure,'GUIDEOptions');

                                                                    if~isappdata(gui_hFigure,'GUIOnScreen')

                                                                        if gui_Options.syscolorfig
                                                                            set(gui_hFigure,'Color',get(0,'DefaultUicontrolBackgroundColor'));
                                                                        end


                                                                        guidata(gui_hFigure,guihandles(gui_hFigure));
                                                                    end



                                                                    gui_MakeVisible=1;
                                                                    for ind=1:2:(length(varargin)-1)
                                                                        len1=min(length('visible'),length(varargin{ind}));
                                                                        len2=min(length('off'),length(varargin{ind+1}));
                                                                        if ischar(varargin{ind})&&ischar(varargin{ind+1})&&...
                                                                            strncmpi(varargin{ind},'visible',len1)&&len2>1
                                                                            if strncmpi(varargin{ind+1},'off',len2)
                                                                                gui_MakeVisible=0;
                                                                            elseif strncmpi(varargin{ind+1},'on',len2)
                                                                                gui_MakeVisible=1;
                                                                            end
                                                                        end
                                                                    end


                                                                    for index=1:2:(length(varargin)-1)
                                                                        try
                                                                            set(gui_hFigure,varargin{index},varargin{index+1})
                                                                        catch %#ok<CTCH>
                                                                            break
                                                                        end
                                                                    end



                                                                    gui_HandleVisibility=get(gui_hFigure,'HandleVisibility');
                                                                    if strcmp(gui_HandleVisibility,'callback')
                                                                        set(gui_hFigure,'HandleVisibility','on');
                                                                    end

                                                                    feval(gui_State.gui_OpeningFcn,gui_hFigure,[],guidata(gui_hFigure),varargin{:});

                                                                    if ishghandle(gui_hFigure)

                                                                        set(gui_hFigure,'HandleVisibility',gui_HandleVisibility);


                                                                        if gui_MakeVisible
                                                                            set(gui_hFigure,'Visible','on')
                                                                            if gui_Options.singleton
                                                                                setappdata(gui_hFigure,'GUIOnScreen',1);
                                                                            end
                                                                        end


                                                                        rmappdata(gui_hFigure,'InGUIInitialization');
                                                                    end



                                                                    if ishghandle(gui_hFigure)
                                                                        gui_HandleVisibility=get(gui_hFigure,'HandleVisibility');
                                                                        if strcmp(gui_HandleVisibility,'callback')
                                                                            set(gui_hFigure,'HandleVisibility','on');
                                                                        end
                                                                        gui_Handles=guidata(gui_hFigure);
                                                                    else
                                                                        gui_Handles=[];
                                                                    end

                                                                    if nargout
                                                                        [varargout{1:nargout}]=feval(gui_State.gui_OutputFcn,gui_hFigure,[],gui_Handles);
                                                                    else
                                                                        feval(gui_State.gui_OutputFcn,gui_hFigure,[],gui_Handles);
                                                                    end

                                                                    if ishghandle(gui_hFigure)
                                                                        set(gui_hFigure,'HandleVisibility',gui_HandleVisibility);
                                                                    end
                                                                end

                                                                function gui_hFigure=local_openfig(name,singleton)



                                                                    try
                                                                        gui_hFigure=openfig(name,singleton,'auto');
                                                                    catch



                                                                        gui_OldDefaultVisible=get(0,'defaultFigureVisible');
                                                                        set(0,'defaultFigureVisible','off');
                                                                        gui_hFigure=openfig(name,singleton);
                                                                        set(0,'defaultFigureVisible',gui_OldDefaultVisible);
                                                                    end


                                                                    function out_str=property2str(prop)

                                                                        out_str='';
                                                                        if isempty(prop)
                                                                            return
                                                                        end
                                                                        if isa(prop,'rfdata.rfdata')
                                                                            out_str=[class(prop),' object'];
                                                                        elseif isnumeric(prop)

                                                                            if(isvector(prop)&&size(prop,1)>1)
                                                                                prop=prop.';
                                                                            end
                                                                            out_str=num2str(prop);
                                                                        elseif ischar(prop)
                                                                            out_str=prop;
                                                                        end
