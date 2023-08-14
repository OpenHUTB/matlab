function varargout=importwin(varargin)




























    gui_Singleton=1;
    gui_State=struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@importwin_OpeningFcn,...
    'gui_OutputFcn',@importwin_OutputFcn,...
    'gui_LayoutFcn',@importwin_LayoutFcn,...
    'gui_Callback',[]);
    if nargin&&ischar(varargin{1})
        gui_State.gui_Callback=str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}]=gui_mainfcn(gui_State,varargin{:});
    else
        gui_mainfcn(gui_State,varargin{:});
    end




    function importwin_OpeningFcn(hObject,eventdata,handles,varargin)







        hrftoolfig=varargin{1};
        hrfhandles=varargin{2};
        listrfvar=varargin{3};


        hlistbox=handles.rffromwslistb;

        set(hlistbox,'String',listrfvar);


        handles.rftoolfig=hrftoolfig;
        handles.rfhandles=hrfhandles;

        handles.output=hObject;


        guidata(hObject,handles);


        drawnow;
        uiwait(handles.figure1);



        function varargout=importwin_OutputFcn(hObject,eventdata,handles)






            if~isempty(handles)

                varargout{1}=handles.output;
                varargout{2}=handles.rfhandles;


                delete(handles.figure1);
            end



            function rffromwslistb_Callback(hObject,eventdata,handles)









                function rffromwslistb_CreateFcn(hObject,eventdata,handles)







                    set(hObject,'BackgroundColor','white');





                    function importokpushb_Callback(hObject,eventdata,handles)

                        hlistbox=handles.rffromwslistb;
                        listrfvar=get(hlistbox,'String');
                        objname=listrfvar{get(hlistbox,'Value')};

                        handles.rfhandles.createobjstr=objname;


                        guidata(hObject,handles);

                        uiresume(handles.figure1);


                        function h1=importwin_LayoutFcn(policy)


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
                            'text',3,...
                            'listbox',2,...
                            'pushbutton',2,...
                            'uipanel',2),...
                            'override',0,...
                            'release',13,...
                            'resize','none',...
                            'accessibility','callback',...
                            'matlabfunction',1,...
                            'callbacks',1,...
                            'singleton',1,...
                            'syscolorfig',1,...
                            'blocking',0,...
                            'lastSavedFile','importwin.m');
                            appdata.lastValidTag='figure1';
                            appdata.GUIDELayoutEditor=[];

                            h1=figure(...
                            'Units','characters',...
                            'Color',[0.831372549019608,0.815686274509804,0.784313725490196],...
                            'Colormap',[0,0,0.5625;0,0,0.625;0,0,0.6875;0,0,0.75;0,0,0.8125;0,0,0.875;0,0,0.9375;0,0,1;0,0.0625,1;0,0.125,1;0,0.1875,1;0,0.25,1;0,0.3125,1;0,0.375,1;0,0.4375,1;0,0.5,1;0,0.5625,1;0,0.625,1;0,0.6875,1;0,0.75,1;0,0.8125,1;0,0.875,1;0,0.9375,1;0,1,1;0.0625,1,1;0.125,1,0.9375;0.1875,1,0.875;0.25,1,0.8125;0.3125,1,0.75;0.375,1,0.6875;0.4375,1,0.625;0.5,1,0.5625;0.5625,1,0.5;0.625,1,0.4375;0.6875,1,0.375;0.75,1,0.3125;0.8125,1,0.25;0.875,1,0.1875;0.9375,1,0.125;1,1,0.0625;1,1,0;1,0.9375,0;1,0.875,0;1,0.8125,0;1,0.75,0;1,0.6875,0;1,0.625,0;1,0.5625,0;1,0.5,0;1,0.4375,0;1,0.375,0;1,0.3125,0;1,0.25,0;1,0.1875,0;1,0.125,0;1,0.0625,0;1,0,0;0.9375,0,0;0.875,0,0;0.8125,0,0;0.75,0,0;0.6875,0,0;0.625,0,0;0.5625,0,0],...
                            'IntegerHandle','off',...
                            'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
                            'MenuBar','none',...
                            'Name','Import from Workspace',...
                            'NumberTitle','off',...
                            'PaperPosition',get(0,'defaultfigurePaperPosition'),...
                            'Position',[10,44.8461538461539,53.4,16.6153846153846],...
                            'Renderer',get(0,'defaultfigureRenderer'),...
                            'RendererMode','manual',...
                            'Resize','off',...
                            'HandleVisibility','callback',...
                            'Tag','figure1',...
                            'UserData',[],...
                            'Behavior',get(0,'defaultfigureBehavior'),...
                            'Visible','on',...
                            'CreateFcn',{@local_CreateFcn,'',appdata});

                            appdata=[];
                            appdata.lastValidTag='uipanel1';

                            h2=uipanel(...
                            'Parent',h1,...
                            'Title','RF Objects in Workspace',...
                            'Position',[0.0337078651685393,0.0185185185185188,0.947565543071161,0.958333333333333],...
                            'Tag','uipanel1',...
                            'Behavior',get(0,'defaultuipanelBehavior'),...
                            'CreateFcn',{@local_CreateFcn,'',appdata});

                            appdata=[];
                            appdata.lastValidTag='rffromwslistb';

                            h3=uicontrol(...
                            'Parent',h2,...
                            'Units','normalized',...
                            'BackgroundColor',[1,1,1],...
                            'Callback','importwin(''rffromwslistb_Callback'',gcbo,[],guidata(gcbo))',...
                            'Position',[0.0790513833992095,0.217391304347826,0.837944664031621,0.66183574879227],...
                            'String','myrfobject',...
                            'Style','listbox',...
                            'Value',1,...
                            'CreateFcn',{@local_CreateFcn,'importwin(''rffromwslistb_CreateFcn'',gcbo,[],guidata(gcbo))',appdata},...
                            'Tag','rffromwslistb');

                            appdata=[];
                            appdata.lastValidTag='importokpushb';

                            h4=uicontrol(...
                            'Parent',h2,...
                            'Units','normalized',...
                            'Callback','importwin(''importokpushb_Callback'',gcbo,[],guidata(gcbo))',...
                            'Position',[0.371541501976284,0.0724637681159419,0.256916996047431,0.106280193236715],...
                            'String','OK',...
                            'Tag','importokpushb',...
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
                                            error(message('rf:importwin:NoField',gui_StateFields{i},gui_Mfile));
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
                                        for ind=1:2:length(varargin)
                                            if length(varargin)==ind
                                                break;
                                            end
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


                                        for index=1:2:length(varargin)
                                            if length(varargin)==index
                                                break;
                                            end
                                            try set(gui_hFigure,varargin{index},varargin{index+1}),catchbreak,end
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

