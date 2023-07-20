function[POWERGUI_Status,POWERGUI_Handles,handles]=InitializePowerguiTools(CMDLINE,varargin,POWERGUI_Field,POWERGUI_mfilename)









    switch POWERGUI_mfilename
    case{'powergui','power_lineparam'}
    otherwise

        POWERGUI_mfilename=POWERGUI_mfilename(1:end-3);
    end

    POWERGUI_Status=0;
    POWERGUI_Handles=[];
    handles=[];

    if isempty(varargin)
        POWERGUI_Status=1;
        return
    else

        sys=varargin{1};
    end


    if~isempty(sys)
        if bdIsLoaded(sys)==0
            if CMDLINE
                load_system(sys)
            else
                open_system(sys)
            end
        end
    end


    if~isempty(sys)
        if length(varargin)<=1||CMDLINE
            PowerguiInfo=getPowerguiInfo(sys,gcb(sys));
            PowerguiBlock=PowerguiInfo.BlockName;
        else
            PowerguiBlock=varargin{2};
        end


        if isempty(PowerguiBlock)&&~isempty(sys)
            powergui(sys);
            PowerguiInfo=getPowerguiInfo(sys,gcb(sys));
            PowerguiBlock=PowerguiInfo.BlockName;
        end
    else
        PowerguiBlock=[];
    end


    POWERGUI_Handles=get_param(PowerguiBlock,'UserData');


    if isempty(POWERGUI_Handles)
        POWERGUI_Handles.powergui=[];
        POWERGUI_Handles.steadystate=[];
        POWERGUI_Handles.initstates=[];
        POWERGUI_Handles.loadflow=[];
        POWERGUI_Handles.loadflownew=[];
        POWERGUI_Handles.ltiview=[];
        POWERGUI_Handles.zmeter=[];
        POWERGUI_Handles.ffttool=[];
        POWERGUI_Handles.report=[];
        POWERGUI_Handles.hysteresis=[];
        POWERGUI_Handles.lineparam=[];
        POWERGUI_Handles.Ts=[];
    end


    if ishandle(POWERGUI_Handles.(POWERGUI_Field))

        if CMDLINE

            handles=guidata(POWERGUI_Handles.(POWERGUI_Field));
            POWERGUI_Status=2;
        else
            figure(POWERGUI_Handles.(POWERGUI_Field))
            handles.Data=[];
            POWERGUI_Status=1;
        end
        return
    end




    if CMDLINE
        fig=openfig(POWERGUI_mfilename,'new','invisible');
    else
        fig=openfig(POWERGUI_mfilename,'new');
        set(fig,'Color',get(fig,'DefaultUIcontrolBackgroundColor'));
    end


    POWERGUI_Handles.(POWERGUI_Field)=fig;


    set_param(PowerguiBlock,'UserData',POWERGUI_Handles);


    handles=guihandles(fig);
    handles.system=sys;
    handles.block=PowerguiBlock;
    handles.Data=[];


    guidata(fig,handles);
