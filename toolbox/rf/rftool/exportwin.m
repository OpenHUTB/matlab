function varargout=exportwin(varargin)




























    gui_Singleton=1;
    gui_State=struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@exportwin_OpeningFcn,...
    'gui_OutputFcn',@exportwin_OutputFcn,...
    'gui_LayoutFcn',@exportwin_LayoutFcn,...
    'gui_Callback',[]);
    if nargin&&ischar(varargin{1})
        gui_State.gui_Callback=str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}]=gui_mainfcn(gui_State,varargin{:});
    else
        gui_mainfcn(gui_State,varargin{:});
    end




    function exportwin_OpeningFcn(hObject,eventdata,handles,varargin)







        hrftoolfig=varargin{1};


        exportvarname=handles.exportvarnameedt;
        hrftool=guidata(hrftoolfig);
        nodes=hrftool.uitree.getSelectedNodes;
        selNode=nodes(1);
        cktobj=handle(getUserObject(selNode));
        name=double(char(getName(selNode)));
        name(~isstrprop(name,'alphanum'))=95;
        name=name(1:min(length(name),28));
        name=['rft_',char(name)];
        set(exportvarname,'String',name);


        handles.output=hObject;
        handles.rftoolfig=hrftoolfig;


        guidata(hObject,handles);






        function varargout=exportwin_OutputFcn(hObject,eventdata,handles)






            varargout{1}=handles.output;



            function exportvarnameedt_Callback(hObject,eventdata,handles)









                function exportvarnameedt_CreateFcn(hObject,eventdata,handles)







                    set(hObject,'BackgroundColor','white');






                    function exportokpushb_Callback(hObject,eventdata,handles)





                        exportvarname=handles.exportvarnameedt;
                        wsvarname=get(exportvarname,'String');

                        hrftool=guidata(handles.rftoolfig);
                        nodes=hrftool.uitree.getSelectedNodes;
                        selNode=nodes(1);
                        cktobj=copy(handle(getUserObject(selNode)));


                        if~isvarname(wsvarname)
                            errordlg([wsvarname,' is not a valid MATLAB variable name.'],...
                            'Invalid Variable Name');
                            return;
                        elseif evalin('base',sprintf('builtin(''exist'',''%s'')',wsvarname))

                            saveResponse=questdlg(['Variable exists in MATLAB workspace.  '...
                            ,'Do you want to overwrite it?'],'Overwrite Warning',...
                            'Yes','No','No');
                            switch saveResponse,
                            case 'Yes',
                                assignin('base',eval('wsvarname'),cktobj);
                                delete(handles.figure1);
                            case 'No',
                                return;
                            end
                        else
                            assignin('base',eval('wsvarname'),cktobj);
                            delete(handles.figure1);
                        end




                        function h1=exportwin_LayoutFcn(policy)


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
                            'edit',2,...
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
                            'lastSavedFile','exportwin.m');
                            appdata.lastValidTag='figure1';
                            appdata.GUIDELayoutEditor=[];

                            h1=figure(...
                            'Units','characters',...
                            'Color',[0.831372549019608,0.815686274509804,0.784313725490196],...
                            'Colormap',[0,0,0.5625;0,0,0.625;0,0,0.6875;0,0,0.75;0,0,0.8125;0,0,0.875;0,0,0.9375;0,0,1;0,0.0625,1;0,0.125,1;0,0.1875,1;0,0.25,1;0,0.3125,1;0,0.375,1;0,0.4375,1;0,0.5,1;0,0.5625,1;0,0.625,1;0,0.6875,1;0,0.75,1;0,0.8125,1;0,0.875,1;0,0.9375,1;0,1,1;0.0625,1,1;0.125,1,0.9375;0.1875,1,0.875;0.25,1,0.8125;0.3125,1,0.75;0.375,1,0.6875;0.4375,1,0.625;0.5,1,0.5625;0.5625,1,0.5;0.625,1,0.4375;0.6875,1,0.375;0.75,1,0.3125;0.8125,1,0.25;0.875,1,0.1875;0.9375,1,0.125;1,1,0.0625;1,1,0;1,0.9375,0;1,0.875,0;1,0.8125,0;1,0.75,0;1,0.6875,0;1,0.625,0;1,0.5625,0;1,0.5,0;1,0.4375,0;1,0.375,0;1,0.3125,0;1,0.25,0;1,0.1875,0;1,0.125,0;1,0.0625,0;1,0,0;0.9375,0,0;0.875,0,0;0.8125,0,0;0.75,0,0;0.6875,0,0;0.625,0,0;0.5625,0,0],...
                            'IntegerHandle','off',...
                            'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
                            'MenuBar','none',...
                            'Name','Export to Workspace',...
                            'NumberTitle','off',...
                            'PaperPosition',get(0,'defaultfigurePaperPosition'),...
                            'Position',[10,52.9230769230769,58.4,8.53846153846154],...
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
                            'Position',[0.0273972602739726,0.0720720720720721,0.928082191780822,0.828828828828829],...
                            'Tag','uipanel1',...
                            'Behavior',get(0,'defaultuipanelBehavior'),...
                            'CreateFcn',{@local_CreateFcn,'',appdata});

                            appdata=[];
                            appdata.lastValidTag='exportokpushb';

                            h3=uicontrol(...
                            'Parent',h2,...
                            'Units','normalized',...
                            'Callback','exportwin(''exportokpushb_Callback'',gcbo,[],guidata(gcbo))',...
                            'Position',[0.3690036900369,0.141304347826087,0.239852398523985,0.239130434782609],...
                            'String','OK',...
                            'Tag','exportokpushb',...
                            'CreateFcn',{@local_CreateFcn,'',appdata});

                            appdata=[];
                            appdata.lastValidTag='exportvarnameedt';

                            h4=uicontrol(...
                            'Parent',h2,...
                            'Units','normalized',...
                            'BackgroundColor',[1,1,1],...
                            'Callback','exportwin(''exportvarnameedt_Callback'',gcbo,[],guidata(gcbo))',...
                            'HorizontalAlignment','left',...
                            'Position',[0.457564575645756,0.565217391304348,0.472324723247232,0.217391304347826],...
                            'String','myrfobject',...
                            'Style','edit',...
                            'CreateFcn',{@local_CreateFcn,'exportwin(''exportvarnameedt_CreateFcn'',gcbo,[],guidata(gcbo))',appdata},...
                            'Tag','exportvarnameedt');

                            appdata=[];
                            appdata.lastValidTag='expvarnametxt';

                            h5=uicontrol(...
                            'Parent',h2,...
                            'Units','normalized',...
                            'HorizontalAlignment','right',...
                            'Position',[0.029520295202952,0.554347826086957,0.391143911439114,0.195652173913043],...
                            'String','Variable name:',...
                            'Style','text',...
                            'Tag','expvarnametxt',...
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
                                            error(message('rf:exportwin:NoField',gui_StateFields{i},gui_Mfile));
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

