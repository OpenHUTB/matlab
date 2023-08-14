function libElement=libdlg(libH,varargin)































    figname=getString(message('rptgen:RptgenML:ReportGeneratorLabel'));
    smode=1;
    promptstring=getString(message('rptgen:RptgenML:selectComponentLabel'));
    listsize=[200,300];
    initialvalue=[];
    okstring=getString(message('rptgen:RptgenML:defaultOkLabel'));
    cancelstring=getString(message('rptgen:RptgenML:defaultCancelLabel'));
    fus=8;
    ffs=8;
    uh=22;

    if mod(length(varargin),2)~=0

        error(message('rptgen:RptgenML:invalidDlgArguments'));
    end

    for i=1:2:length(varargin)
        switch lower(varargin{i})
        case 'name'
            figname=varargin{i+1};
        case 'promptstring'
            promptstring=varargin{i+1};
        case 'listsize'
            listsize=varargin{i+1};
        case 'initialvalue'
            initialvalue=varargin{i+1};
        case 'uh'
            uh=varargin{i+1};
        case 'fus'
            fus=varargin{i+1};
        case 'ffs'
            ffs=varargin{i+1};
        case 'okstring'
            okstring=varargin{i+1};
        case 'cancelstring'
            cancelstring=varargin{i+1};
        otherwise
            error(message('rptgen:RptgenML:unknownDlgParameter',varargin{i}));
        end
    end

    if ischar(promptstring)
        promptstring=cellstr(promptstring);
    end

    if isempty(initialvalue)
        initialvalue=1;
    end

    ex=get(0,'defaultuicontrolfontsize')*1.7;

    fp=get(0,'defaultfigureposition');
    w=2*(fus+ffs)+listsize(1);
    h=2*ffs+6*fus+ex*length(promptstring)+listsize(2)+uh+(smode==2)*(fus+uh);
    fp=[fp(1),fp(2)+fp(4)-h,w,h];

    fig_props={...
    'name',figname...
    ,'color',get(0,'defaultUicontrolBackgroundColor')...
    ,'resize','off'...
    ,'numbertitle','off'...
    ,'menubar','none'...
    ,'windowstyle','modal'...
    ,'visible','off'...
    ,'createfcn',''...
    ,'position',fp...
    ,'closerequestfcn','delete(gcbf)'...
    };


    fig=figure(fig_props{:});

    if~isempty(promptstring)
        uicontrol('style','text','string',promptstring,...
        'horizontalalignment','left',...
        'position',[ffs+fus,fp(4)-(ffs+fus+ex*length(promptstring))...
        ,listsize(1),ex*length(promptstring)]);
    end

    btn_wid=(fp(3)-2*(ffs+fus)-fus)/2;


    uicontrol('style','frame',...
    'position',[ffs+fus-1,ffs+fus-1,btn_wid+2,uh+2],...
    'backgroundcolor','k');

    listbox=uicontrol('style','listbox',...
    'position',[ffs+fus,ffs+uh+4*fus+(smode==2)*(fus+uh),listsize],...
    'string',{getString(message('rptgen:RptgenML:findingComponentsLabel'))},...
    'backgroundcolor','w',...
    'max',smode,...
    'tag','listbox',...
    'value',initialvalue);





    ok_btn=uicontrol('style','pushbutton',...
    'Enable','off',...
    'string',okstring,...
    'position',[ffs+fus,ffs+fus,btn_wid,uh],...
    'callback',{@doOK,listbox});


    cancel_btn=uicontrol('style','pushbutton',...
    'string',cancelstring,...
    'position',[ffs+2*fus+btn_wid,ffs+fus,btn_wid,uh],...
    'callback',{@doCancel,listbox});

    set([fig,listbox,ok_btn,cancel_btn],'keypressfcn',{@doKeypress,listbox})

    set(fig,'position',getnicedialoglocation(fp,get(fig,'Units')));


    movegui(fig)
    set(fig,'visible','on');
    drawnow;
    allComps=populateListbox([],[],listbox,libH);
    set(listbox,'callback',{@doListboxClick,ok_btn});





    allCategories=find(allComps,'-depth',1,'-isa','RptgenML.LibraryCategory');
    l=handle.listener(allCategories,findprop(allCategories(1),'Expanded'),'PropertyPostSet',{@populateListbox,listbox,libH});


    try
        uiwait(fig);
    catch
        if ishghandle(fig,'figure')
            delete(fig);
        end
    end

    if isappdata(0,'ListDialogAppData')
        ad=getappdata(0,'ListDialogAppData');
        libElement=ad.selection;
        rmappdata(0,'ListDialogAppData')
    else

        libElement=[];
    end

    function doKeypress(fig_h,evd,listbox)




        switch evd.Key
        case{'return','space'}
            doOK([],[],listbox);
        case 'escape'
            doCancel([],[],listbox);
        end


        function doOK(ok_btn,evd,listbox)

            selectIdx=get(listbox,'value');
            selectObj=get(listbox,'UserData');
            if isempty(selectObj)

                return;
            end

            selectObj=selectObj(selectIdx);

            if isa(selectObj,'RptgenML.LibraryCategory')
                selectObj.exploreAction;

            else
                ad.selection=selectObj;
                setappdata(0,'ListDialogAppData',ad)
                delete(gcbf);
            end


            function doCancel(cancel_btn,evd,listbox)
                ad.selection=[];
                setappdata(0,'ListDialogAppData',ad)
                delete(gcbf);

                function doSelectAll(selectall_btn,evd,listbox)
                    set(selectall_btn,'enable','off')
                    set(listbox,'value',1:length(get(listbox,'string')));

                    function doListboxClick(listbox,evd,ok_btn,selectall_btn)

                        if strcmp(get(gcbf,'SelectionType'),'open')
                            doOK([],[],listbox);
                        else
                            selectedObj=get(listbox,'UserData');
                            selectedObj=selectedObj(get(listbox,'value'));
                            if isa(selectedObj,'RptgenML.LibraryCategory')
                                set(ok_btn,'Enable','off');
                            else
                                set(ok_btn,'Enable','on');
                            end







                        end


                        function allLibElements=populateListbox(src,evd,listbox,lib)

                            allLibElements=lib.getChildren;
                            for i=length(allLibElements):-1:1
                                dispString{i}=allLibElements(i).getDisplayLabel;
                            end

                            oldValue=get(listbox,'value');






                            set(listbox,...
                            'String',dispString,...
                            'Value',min(length(dispString),oldValue),...
                            'UserData',allLibElements);


                            function figure_size=getnicedialoglocation(figure_size,figure_units)





                                parentHandle=gcbf;
                                propName='Position';
                                if isempty(parentHandle)
                                    parentHandle=0;
                                    propName='ScreenSize';
                                end

                                old_u=get(parentHandle,'Units');
                                set(parentHandle,'Units',figure_units);
                                container_size=get(parentHandle,propName);
                                set(parentHandle,'Units',old_u);

                                figure_size(1)=container_size(1)+1/2*(container_size(3)-figure_size(3));
                                figure_size(2)=container_size(2)+2/3*(container_size(4)-figure_size(4));


