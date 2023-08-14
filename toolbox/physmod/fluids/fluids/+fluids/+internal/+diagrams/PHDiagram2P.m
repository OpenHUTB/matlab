classdef PHDiagram2P<handle

















































    properties(Constant,Access=private)

        p_unit="MPa";
        h_unit="kJ/kg";
        T_unit="K";

        numContours=50;

        contourStepList=[0.1,0.2,0.5,1,2,5,10,15,20,25,30,40,50,75,100,125,150,175,200,250,300,350,400,450,500];

        contourLabelSpacing=144;

        contourLabelSkip=4;

        foundationPropPath="foundation.two_phase_fluid.utilities.two_phase_fluid_properties";
        fluidsPropPath="fluids.two_phase_fluid.utilities.two_phase_fluid_predefined_properties";

        fluidIcon=fullfile(matlabroot,"toolbox","physmod","fluids","fluids",...
        "+fluids","+internal","+diagrams","fluid.svg");
        backIcon=fullfile(matlabroot,"toolbox","physmod","fluids","fluids",...
        "+fluids","+internal","+diagrams","backward.svg");
        playIcon=fullfile(matlabroot,"toolbox","physmod","fluids","fluids",...
        "+fluids","+internal","+diagrams","play.svg");
        pauseIcon=fullfile(matlabroot,"toolbox","physmod","fluids","fluids",...
        "+fluids","+internal","+diagrams","pause.svg");
        replayIcon=fullfile(matlabroot,"toolbox","physmod","fluids","fluids",...
        "+fluids","+internal","+diagrams","replay.svg");
        forwardIcon=fullfile(matlabroot,"toolbox","physmod","fluids","fluids",...
        "+fluids","+internal","+diagrams","forward.svg");

        playbackDuration=8;
        timerPeriod=0.025;




        version="2.0";
    end


    properties(Transient,Access=private)

        hBlock=-1;
        hFigure=-1;
        hPropBlock=-1;
        propBlockPath="";
        hFluidButton=-1;
        hBackButton=-1;
        hPlayButton=-1;
        hForwardButton=-1;
        hPlayerSlider=-1;
        hTimeLabel=-1;
        hTimeEdit=-1;
        hSpeedDropdown=-1;
        hPlayerTimer=-1;
        hAxes=-1;
        hAxesToolbar=-1;
        hLink=-1;
        hContours=-1;
        hSatLiq=-1;
        hSatVap=-1;
        hSup=-1;
        hCycle=-1;
        hDialog=-1;
        hListBox=-1;

figurePosition

p_contour
h_contour
T_contour
p_sat
h_sat_liq
h_sat_vap
p_crit
fluidName

        p_cycle=NaN;
        h_cycle=NaN;
        t_steps=0;
        num_steps=0;
        idx_steps=1;

        timerTime=0;
        playbackDurationScale=10/8;
    end





    methods(Static)



        function Start(hBlock,numPoints)
            obj=get_param(hBlock,"UserData");
            if isa(obj,mfilename("class"))&&isvalid(obj)
                if isgraphics(obj.hFigure)

                    obj.getFluidProperties
                    obj.updateContours
                else

                    obj.createScopeWindow
                end
            else

                obj=fluids.internal.diagrams.PHDiagram2P(hBlock);
                obj.createScopeWindow
            end


            obj.p_cycle=nan(numPoints,1);
            obj.h_cycle=nan(numPoints,1);
            obj.t_steps=0;


            obj.num_steps=0;
            obj.idx_steps=0;


            if strcmp(obj.hPlayerTimer.Running,"on")
                stop(obj.hPlayerTimer)
            end


            obj.hFluidButton.Enable=false;
            obj.hBackButton.Enable=false;
            obj.hPlayButton.Enable=false;
            obj.hForwardButton.Enable=false;
            obj.hPlayerSlider.Enable=false;
            obj.hTimeLabel.Enable=false;
            obj.hTimeEdit.Enable=false;
            obj.hSpeedDropdown.Enable=false;
        end



        function Outputs(hBlock,p_input,h_input,t_input)
            obj=get_param(hBlock,"UserData");


            obj.num_steps=obj.num_steps+1;
            obj.p_cycle(:,obj.num_steps)=p_input(:);
            obj.h_cycle(:,obj.num_steps)=h_input(:);
            obj.t_steps(1,obj.num_steps)=t_input;


            obj.idx_steps=obj.num_steps;
            if obj.hFigure.Visible
                obj.updateCycle
            end
        end



        function Terminate(hBlock)
            obj=get_param(hBlock,"UserData");


            obj.hFluidButton.Enable=true;

            if obj.num_steps>1

                idx_delete=[false,diff(cummax(obj.t_steps))<=0];
                obj.t_steps(idx_delete)=[];
                obj.p_cycle(:,idx_delete)=[];
                obj.h_cycle(:,idx_delete)=[];
                obj.num_steps=numel(obj.t_steps);
                obj.idx_steps=obj.num_steps;


                t_min=obj.t_steps(1);
                t_max=obj.t_steps(obj.num_steps);
                obj.hPlayerSlider.Limits=[t_min,t_max];
                obj.hTimeEdit.Tooltip="Enter playback time between "...
                +t_min+" and "+t_max;


                obj.updateControls
                obj.hPlayButton.Icon=obj.replayIcon;
                obj.hPlayButton.Tooltip="Replay";


                obj.hBackButton.Enable=true;
                obj.hPlayButton.Enable=true;
                obj.hForwardButton.Enable=true;
                obj.hPlayerSlider.Enable=true;
                obj.hTimeLabel.Enable=true;
                obj.hTimeEdit.Enable=true;
                obj.hSpeedDropdown.Enable=true;


                obj.playbackDurationScale=(t_max-t_min)/obj.playbackDuration;
            else

                set(obj.hPlayerSlider,"Limits",[0,10],"Value",0)
                set(obj.hTimeEdit,"Value",0,"Tooltip","Enter playback time")
            end
        end



        function OpenFcn(hBlock)

            if bdIsLibrary(bdroot(hBlock))
                web(nesl_help(hBlock))
                return
            end

            obj=get_param(hBlock,"UserData");
            if isa(obj,mfilename("class"))&&isvalid(obj)
                if isgraphics(obj.hFigure)

                    obj.hFigure.Visible=true;
                    figure(obj.hFigure)

                    try

                        obj.getFluidProperties
                        obj.updateContours
                    catch err

beep
                        uialert(obj.hFigure,err.message,"Error",...
                        "CloseFcn",@(hObject,eventData)uiresume(obj.hFigure))
                        uiwait(obj.hFigure)
                    end
                else

                    obj.createScopeWindow


                    obj.hFigure.Visible=true;
                    figure(obj.hFigure)
                end
            else

                obj=fluids.internal.diagrams.PHDiagram2P(hBlock);
                obj.createScopeWindow


                obj.hFigure.Visible=true;
                figure(obj.hFigure)
            end
        end



        function LoadFcn(hBlock)

            dataStruct=get_param(hBlock,"UserData");
            if isempty(dataStruct)
                return
            end


            obj=fluids.internal.diagrams.PHDiagram2P(hBlock);

            try

                obj.propBlockPath=dataStruct.propBlockPath;
                if obj.propBlockPath~=""
                    modelName=string(get_param(bdroot(hBlock),"Name"));
                    obj.hPropBlock=getSimulinkBlockHandle(modelName+"/"+obj.propBlockPath,true);
                    if obj.hPropBlock==-1
                        obj.propBlockPath="";
                    end
                end


                obj.figurePosition=dataStruct.figurePosition;
                obj.p_contour=dataStruct.p_contour;
                obj.h_contour=dataStruct.h_contour;
                obj.T_contour=dataStruct.T_contour;
                obj.p_sat=dataStruct.p_sat;
                obj.h_sat_liq=dataStruct.h_sat_liq;
                obj.h_sat_vap=dataStruct.h_sat_vap;
                obj.fluidName=dataStruct.fluidName;
                if str2double(dataStruct.version)>1.0
                    obj.p_crit=dataStruct.p_crit;
                else
                    obj.p_crit=inf;
                end


                obj.createScopeWindow
                obj.hFigure.Visible=dataStruct.figureVisible;

            catch err

                delete(obj)
                set_param(hBlock,"UserData",[])
                rethrow(err)
            end
        end



        function NameChangeFcn(hBlock)

            obj=get_param(hBlock,"UserData");
            if isa(obj,mfilename("class"))&&isvalid(obj)
                if isgraphics(obj.hFigure)
                    obj.hFigure.Name=obj.getBlockName;
                end
            end
        end



        function CopyFcn(hBlock)
            objOld=get_param(hBlock,"UserData");
            if isa(objOld,mfilename("class"))&&isvalid(objOld)

                objNew=fluids.internal.diagrams.PHDiagram2P(hBlock);


                objNew.hPropBlock=objOld.hPropBlock;
                objNew.propBlockPath=objOld.propBlockPath;
                objNew.p_contour=objOld.p_contour;
                objNew.h_contour=objOld.h_contour;
                objNew.T_contour=objOld.T_contour;
                objNew.p_sat=objOld.p_sat;
                objNew.h_sat_liq=objOld.h_sat_liq;
                objNew.h_sat_vap=objOld.h_sat_vap;
                objNew.p_crit=objOld.p_crit;
                objNew.fluidName=objOld.fluidName;
                if isgraphics(objOld.hFigure)
                    objNew.figurePosition=objOld.hFigure.Position;
                end


                objNew.createScopeWindow
            end
        end



        function DeleteFcn(hBlock)
            obj=get_param(hBlock,"UserData");
            if isa(obj,mfilename("class"))&&isvalid(obj)
                if isgraphics(obj.hFigure)
                    close(obj.hFigure)
                end
            end
        end




        function DestroyFcn(hBlock)
            obj=get_param(hBlock,"UserData");
            if isa(obj,mfilename("class"))&&isvalid(obj)
                if isgraphics(obj.hFigure)
                    delete(obj.hFigure)
                end
                if isa(obj.hPlayerTimer,'timer')&&isvalid(obj.hPlayerTimer)
                    if strcmp(obj.hPlayerTimer.Running,"on")
                        stop(obj.hPlayerTimer)
                    end
                    delete(obj.hPlayerTimer)
                end
            end
        end



        function PreSaveFcn(hBlock)
            obj=get_param(hBlock,"UserData");
            if isa(obj,mfilename("class"))&&isvalid(obj)


                try
                    obj.validatePropBlock
                catch err
                    warning(err.message)
                end


                dataStruct.propBlockPath=obj.propBlockPath;
                dataStruct.figurePosition=obj.hFigure.Position;
                dataStruct.figureVisible=obj.hFigure.Visible;
                dataStruct.p_contour=obj.p_contour;
                dataStruct.h_contour=obj.h_contour;
                dataStruct.T_contour=obj.T_contour;
                dataStruct.p_sat=obj.p_sat;
                dataStruct.h_sat_liq=obj.h_sat_liq;
                dataStruct.h_sat_vap=obj.h_sat_vap;
                dataStruct.p_crit=obj.p_crit;
                dataStruct.fluidName=obj.fluidName;
                dataStruct.version=obj.version;


                dataStruct.obj=obj;
            else
                dataStruct=[];
            end


            set_param(hBlock,"UserData",dataStruct,"UserDataPersistent","on")
        end



        function PostSaveFcn(hBlock)
            dataStruct=get_param(hBlock,"UserData");
            if~isempty(dataStruct)&&isstruct(dataStruct)
                set_param(hBlock,"UserData",dataStruct.obj)
            end
        end




        function newException=ErrorFcn(hSubsystem,errorType,originalException)
            if string(errorType)=="Simulink:blocks:MSFB_BlockMethodFailed"
                blockPath=string(getfullname(hSubsystem));
                newException=MSLException(hSubsystem,...
                message("physmod:fluids:diagrams:ErrorInBlock",blockPath));
            else
                newException=originalException;
            end
        end




        function hBlockOut=createBlock(hSystem,blockName)
            iconSize=[40,40];
            classPath=mfilename("class");


            hBlock=add_block("simulink/User-Defined Functions/Level-2 MATLAB S-Function",...
            string(hSystem)+"/"+string(mfilename));
            set_param(hBlock,"FunctionName","thermodynamicDiagram",...
            "Parameters",""""+classPath+"""")


            Simulink.BlockDiagram.createSubsystem(hBlock)
            hSubsystem=get_param(get_param(hBlock,"Parent"),"Handle");
            set_param(hSubsystem,"Name",blockName)


            ports=get_param(hBlock,"PortConnectivity");
            set_param(ports(string({ports.Type})=="1").SrcBlock,"Name","p")
            set_param(ports(string({ports.Type})=="2").SrcBlock,"Name","h")


            position=get_param(hSubsystem,"Position");
            set_param(hSubsystem,"Position",[position(1:2),position(1:2)+iconSize])






            DVG.Registry.addIconPackage(fullfile(matlabroot,...
            "toolbox/physmod/fluids/fluids/BlockGraphics"));
            pm_assert(DVG.Registry.isIconRegistered(...
            "SimscapeFluids.PHDiagram2P"));
            SLBlockIcon.setMaskDVGIcon(hSubsystem,...
            "SimscapeFluids.PHDiagram2P");
            set_param(hSubsystem,"MaskIconOpaque","opaque-with-ports")


            set_param(hSubsystem,...
            "OpenFcn","feval('"+classPath+".OpenFcn', gcbh)",...
            "LoadFcn","feval('"+classPath+".LoadFcn', gcbh)",...
            "NameChangeFcn","feval('"+classPath+".NameChangeFcn', gcbh)",...
            "CopyFcn","feval('"+classPath+".CopyFcn', gcbh)",...
            "DeleteFcn","feval('"+classPath+".DeleteFcn', gcbh)",...
            "DestroyFcn","feval('"+classPath+".DestroyFcn', gcbh)",...
            "PreSaveFcn","feval('"+classPath+".PreSaveFcn', gcbh)",...
            "PostSaveFcn","feval('"+classPath+".PostSaveFcn', gcbh)",...
            "ErrorFcn",classPath+".ErrorFcn")


            set_param(hSubsystem,"MaskHideContents","on")


            set_param(hSubsystem,...
            "MaskType",blockName,...
            "MaskDescription","physmod:fluids:diagrams:PHDiagram2PDescription",...
            "MaskHelp","web(nesl_help(gcbh))")

            if nargout>0
                hBlockOut=hBlock;
            end
        end

    end





    methods


        function obj=PHDiagram2P(hBlock)








            obj.hBlock=hBlock;


            obj.hPlayerTimer=timer("Period",obj.timerPeriod,...
            "ExecutionMode","fixedRate","ObjectVisibility","off",...
            "StartFcn",@obj.timerStart,"StopFcn",@obj.timerStop,...
            "TimerFcn",@obj.timerTrigger);


            set_param(hBlock,"UserData",obj)


            if nargout==0
                clear obj
            end
        end



        function delete(obj)







            if isgraphics(obj.hFigure)
                delete(obj.hFigure)
            end

            if isa(obj.hPlayerTimer,'timer')&&isvalid(obj.hPlayerTimer)
                if strcmp(obj.hPlayerTimer.Running,"on")
                    stop(obj.hPlayerTimer)
                end
                delete(obj.hPlayerTimer)
            end
        end

    end





    methods(Access=private)


        function createScopeWindow(obj)

            if isempty(obj.p_contour)
                obj.hPropBlock=-1;
                obj.propBlockPath="";
                obj.getFluidProperties;
            end


            textHeight=20;
            margins=10;
            buttonSize=20;



            obj.hFigure=uifigure("Name",obj.getBlockName,...
            "CloseRequestFcn",@obj.closeFigure,"DeleteFcn",@obj.deleteFigure,...
            "Visible",false);

            if isempty(obj.figurePosition)

                addHeight=buttonSize+margins+textHeight+margins;
                obj.hFigure.Position(2)=obj.hFigure.Position(2)-addHeight;
                obj.hFigure.Position(4)=obj.hFigure.Position(4)+addHeight;
            else

                obj.hFigure.Position=obj.figurePosition;
            end


            hGrid=uigridlayout(obj.hFigure,...
            "RowHeight",{buttonSize,"1x",textHeight},...
            "ColumnWidth",{buttonSize,6,buttonSize,buttonSize,buttonSize,"1x","fit","fit","fit",6,buttonSize},...
            "ColumnSpacing",4,"RowSpacing",margins,...
            "Padding",[margins,0,margins,margins]);


            obj.hFluidButton=uibutton(hGrid,"Icon",obj.fluidIcon,...
            "Text","","Tooltip","Select fluid properties",...
            "ButtonPushedFcn",@obj.createFluidsDialog);
            obj.hFluidButton.Layout.Row=1;
            obj.hFluidButton.Layout.Column=1;


            obj.hBackButton=uibutton(hGrid,"Icon",obj.backIcon,...
            "Text","","Tooltip","Back one time step",...
            "ButtonPushedFcn",@obj.playbackStepBack);
            obj.hBackButton.Layout.Row=1;
            obj.hBackButton.Layout.Column=3;


            obj.hPlayButton=uibutton(hGrid,"Icon",obj.playIcon,...
            "Text","","Tooltip","Play",...
            "ButtonPushedFcn",@obj.playbackPlayPause);
            obj.hPlayButton.Layout.Row=1;
            obj.hPlayButton.Layout.Column=4;


            obj.hForwardButton=uibutton(hGrid,"Icon",obj.forwardIcon,...
            "Text","","Tooltip","Forward one time step",...
            "ButtonPushedFcn",@obj.playbackStepForward);
            obj.hForwardButton.Layout.Row=1;
            obj.hForwardButton.Layout.Column=5;


            obj.hPlayerSlider=uislider(hGrid,"Limits",[0,10],...
            "MajorTicks",[],"MinorTicks",[],...
            "Tooltip","Playback control",...
            "ValueChangedFcn",@obj.playbackSetTime,...
            "ValueChangingFcn",@obj.playbackSetTime);
            obj.hPlayerSlider.Layout.Row=1;
            obj.hPlayerSlider.Layout.Column=6;


            obj.hTimeLabel=uilabel(hGrid,"Text"," Time:");
            obj.hTimeLabel.Layout.Row=1;
            obj.hTimeLabel.Layout.Column=7;


            obj.hTimeEdit=uieditfield(hGrid,"numeric","Value",0,...
            "ValueDisplayFormat","%11.4g","Tooltip","Enter playback time",...
            "ValueChangedFcn",@obj.playbackSetTime);
            obj.hTimeEdit.Layout.Row=1;
            obj.hTimeEdit.Layout.Column=8;


            obj.hSpeedDropdown=uidropdown(hGrid,"Value",1,...
            "Items",["2X","1X","1/2X","1/3X","1/4X","1/6X","1/8X"],...
            "ItemsData",[2,1,1/2,1/3,1/4,1/6,1/8],...
            "Tooltip","Playback speed");
            obj.hSpeedDropdown.Layout.Row=1;
            obj.hSpeedDropdown.Layout.Column=9;


            hHelpButton=uibutton(hGrid,"Text","?","FontWeight","bold",...
            "Tooltip","Help",...
            "ButtonPushedFcn",@(hObject,eventData)web(nesl_help(obj.hBlock)));
            hHelpButton.Layout.Row=1;
            hHelpButton.Layout.Column=11;


            if obj.num_steps==0
                obj.hBackButton.Enable=false;
                obj.hPlayButton.Enable=false;
                obj.hForwardButton.Enable=false;
                obj.hPlayerSlider.Enable=false;
                obj.hTimeLabel.Enable=false;
                obj.hTimeEdit.Enable=false;
                obj.hSpeedDropdown.Enable=false;
            end


            obj.hAxes=uiaxes(hGrid);
            obj.hAxes.Layout.Row=2;
            obj.hAxes.Layout.Column=[1,numel(hGrid.ColumnWidth)];


            approxStep=(max(obj.T_contour(:))-min(obj.T_contour(:)))/obj.numContours;
            contourStep=obj.contourStepList(find(obj.contourStepList>approxStep,1));


            levels=ceil(min(obj.T_contour(:))/contourStep)*contourStep:contourStep:max(obj.T_contour(:));
            [~,obj.hContours]=contour(obj.hAxes,obj.h_contour,obj.p_contour,obj.T_contour,levels);


            nSup=sum(obj.p_sat<obj.p_crit)+1;
            nSub=min(nSup,length(obj.p_sat));


            hold(obj.hAxes,"on")
            obj.hSatLiq=plot(obj.hAxes,obj.h_sat_liq(1:nSub),obj.p_sat(1:nSub),...
            '-',"Color",[0.5,0.5,0.5],"LineWidth",1);
            obj.hSatVap=plot(obj.hAxes,obj.h_sat_vap(1:nSub),obj.p_sat(1:nSub),...
            '-',"Color",[0.5,0.5,0.5],"LineWidth",1);
            obj.hSup=plot(obj.hAxes,obj.h_sat_liq(nSup:end),obj.p_sat(nSup:end),...
            '--',"Color",[0.5,0.5,0.5],"LineWidth",1);
            if isempty(obj.hSup)
                obj.hSup=plot(obj.hAxes,NaN,NaN,'--',"Color",[0.5,0.5,0.5],"LineWidth",1);
            end


            obj.hCycle=plot(obj.hAxes,NaN,NaN,"ko-","LineWidth",1.5);
            obj.updateCycle;
            hold(obj.hAxes,"off")


            xlabel(obj.hAxes,"Specific Enthalpy ("+obj.h_unit+")")
            ylabel(obj.hAxes,"Pressure ("+obj.p_unit+")")
            title(obj.hAxes,obj.fluidName)
            set(obj.hAxes,"XLim",[min(obj.h_contour(:)),max(obj.h_contour(:))],...
            "YLim",[min(obj.p_contour(:)),max(obj.p_contour(:))],...
            "XLimMode","manual","YLimMode","manual","Yscale","log","Box",true)


            set(obj.hContours,"ShowText",true,"LabelSpacing",obj.contourLabelSpacing,...
            "TextList",levels(1:obj.contourLabelSkip:end))



            obj.hAxesToolbar=axtoolbar(obj.hAxes,...
            ["export","datacursor","pan","zoomin","zoomout","restoreview"]);


            obj.hLink=uihyperlink(hGrid,"Text",obj.propBlockPath,"FontWeight","normal",...
            "HyperlinkClickedFcn",@obj.highlightBlock);
            obj.hLink.Layout.Row=3;
            obj.hLink.Layout.Column=[1,numel(hGrid.ColumnWidth)];
        end



        function closeFigure(obj,~,~)
            if strcmp(obj.hPlayerTimer.Running,"on")
                stop(obj.hPlayerTimer)
            end
            obj.hFigure.Visible=false;
            if isgraphics(obj.hDialog)
                obj.hDialog.Visible=false;
            end
        end



        function deleteFigure(obj,~,~)
            if strcmp(obj.hPlayerTimer.Running,"on")
                stop(obj.hPlayerTimer)
            end


            obj.figurePosition=obj.hFigure.Position;


            if isgraphics(obj.hDialog)
                delete(obj.hDialog)
            end
        end



        function highlightBlock(obj,~,~)
            try

                obj.getFluidProperties
                obj.updateContours


                if obj.hPropBlock~=-1
                    hilite_system(obj.hPropBlock,"find")
                end

            catch err

beep
                uialert(obj.hFigure,err.message,"Error",...
                "CloseFcn",@(hObject,eventData)uiresume(obj.hFigure))
                uiwait(obj.hFigure)
            end
        end



        function name=getBlockName(obj)
            name=replace(strtrim(string(get_param(obj.hBlock,"Name"))),newline," ");
        end



        function updateCycle(obj)
            set(obj.hCycle,"XData",[obj.h_cycle(:,obj.idx_steps);obj.h_cycle(1,obj.idx_steps)],...
            "YData",[obj.p_cycle(:,obj.idx_steps);obj.p_cycle(1,obj.idx_steps)])
            drawnow("limitrate")
        end



        function updateControls(obj)
            obj.hTimeEdit.Value=round(obj.t_steps(obj.idx_steps),4,"significant");
            obj.hPlayerSlider.Value=obj.t_steps(obj.idx_steps);
        end



        function timerStart(obj,hPlayerTimer,~)

            if obj.idx_steps==obj.num_steps
                obj.idx_steps=1;
            end


            obj.hFluidButton.Enable=false;
            disableDefaultInteractivity(obj.hAxes)
            obj.hAxesToolbar.Visible=false;
            obj.hTimeEdit.Editable=false;


            obj.hPlayButton.Icon=obj.pauseIcon;
            obj.hPlayButton.Tooltip="Pause";


            hPlayerTimer.UserData=tic;
            obj.timerTime=toc(hPlayerTimer.UserData);
        end



        function timerStop(obj,~,~)

            if obj.idx_steps==obj.num_steps
                obj.hPlayButton.Icon=obj.replayIcon;
                obj.hPlayButton.Tooltip="Replay";
            else
                obj.hPlayButton.Icon=obj.playIcon;
                obj.hPlayButton.Tooltip="Play";
            end


            obj.hFluidButton.Enable=true;
            enableDefaultInteractivity(obj.hAxes)
            obj.hAxesToolbar.Visible=true;
            obj.hTimeEdit.Editable=true;
        end



        function timerTrigger(obj,hPlayerTimer,~)

            newTimerTime=toc(hPlayerTimer.UserData);
            t_inc=(newTimerTime-obj.timerTime)*obj.playbackDurationScale*obj.hSpeedDropdown.Value;


            t_new=obj.t_steps(obj.idx_steps)+t_inc;


            if t_new>obj.t_steps(obj.idx_steps+1)
                last_step=true;
                for idx=obj.idx_steps+1:obj.num_steps
                    if obj.t_steps(idx)>t_new
                        last_step=false;
                        obj.idx_steps=idx-1;
                        break
                    end
                end


                if last_step
                    obj.idx_steps=obj.num_steps;
                end
                obj.timerTime=newTimerTime;


                obj.updateControls
                obj.updateCycle


                if last_step
                    stop(hPlayerTimer)
                end
            end
        end



        function playbackPlayPause(obj,~,~)
            if strcmp(obj.hPlayerTimer.Running,"on")
                stop(obj.hPlayerTimer)
            else
                start(obj.hPlayerTimer)
            end
        end



        function playbackStepBack(obj,~,~)
            if strcmp(obj.hPlayerTimer.Running,"on")
                stop(obj.hPlayerTimer)
            end

            if obj.idx_steps>1

                obj.idx_steps=obj.idx_steps-1;
                obj.updateControls
                obj.updateCycle


                if obj.idx_steps==obj.num_steps
                    obj.hPlayButton.Icon=obj.replayIcon;
                    obj.hPlayButton.Tooltip="Replay";
                else
                    obj.hPlayButton.Icon=obj.playIcon;
                    obj.hPlayButton.Tooltip="Play";
                end
            end
        end



        function playbackStepForward(obj,~,~)
            if strcmp(obj.hPlayerTimer.Running,"on")
                stop(obj.hPlayerTimer)
            end

            if obj.idx_steps<obj.num_steps

                obj.idx_steps=obj.idx_steps+1;
                obj.updateControls
                obj.updateCycle


                if obj.idx_steps==obj.num_steps
                    obj.hPlayButton.Icon=obj.replayIcon;
                    obj.hPlayButton.Tooltip="Replay";
                else
                    obj.hPlayButton.Icon=obj.playIcon;
                    obj.hPlayButton.Tooltip="Play";
                end
            end
        end



        function playbackSetTime(obj,~,eventData)
            if strcmp(obj.hPlayerTimer.Running,"on")
                stop(obj.hPlayerTimer)
            end


            t_new=eventData.Value;
            [~,obj.idx_steps]=min(abs(obj.t_steps-t_new));


            obj.updateControls
            obj.updateCycle


            if obj.idx_steps==obj.num_steps
                obj.hPlayButton.Icon=obj.replayIcon;
                obj.hPlayButton.Tooltip="Replay";
            else
                obj.hPlayButton.Icon=obj.playIcon;
                obj.hPlayButton.Tooltip="Play";
            end
        end



        function createFluidsDialog(obj,~,~)

            hPropList=-1;
            propBlockPathList="Default Fluid - Water";
            listBoxValue=-1;

            if isgraphics(obj.hDialog)

                obj.hDialog.Visible=true;
                figure(obj.hDialog)

            else

                dialogSize=[500,200];
                buttonSize=[80,25];
                promptHeight=40;
                margins=10;



                obj.hDialog=uifigure("Name","Select Fluid Properties",...
                "CloseRequestFcn",@(hObject,eventData)set(hObject,"Visible",false));


                obj.hDialog.Position(2)=obj.hDialog.Position(2)+obj.hDialog.Position(4)-dialogSize(2);
                obj.hDialog.Position(3:4)=dialogSize;


                hGrid=uigridlayout(obj.hDialog,...
                "ColumnWidth",{"1x",buttonSize(1),buttonSize(1)},...
                "RowHeight",{promptHeight,"1x",buttonSize(2)},...
                "ColumnSpacing",margins,"RowSpacing",margins,...
                "Padding",[margins,margins,margins,margins]);


                hPrompt=uilabel(hGrid,"WordWrap",true,"Text",...
                "Select a Two-Phase Fluid Properties (2P) or Two-Phase Fluid Predefined Properties (2P) block in the model");
                hPrompt.Layout.Row=1;
                hPrompt.Layout.Column=[1,3];


                obj.hListBox=uilistbox(hGrid,"Items",propBlockPathList,"ItemsData",hPropList,...
                "Value",listBoxValue);
                obj.hListBox.Layout.Row=2;
                obj.hListBox.Layout.Column=[1,3];


                hOKButton=uibutton(hGrid,...
                "Text",getString(message("MATLAB:uistring:popupdialogs:OK")),...
                "ButtonPushedFcn",@obj.dialogOK);
                hOKButton.Layout.Row=3;
                hOKButton.Layout.Column=2;


                hCancelButton=uibutton(hGrid,...
                "Text",getString(message("MATLAB:uistring:popupdialogs:Cancel")),...
                "ButtonPushedFcn",@(hObject,eventData)close(hObject.Parent.Parent));
                hCancelButton.Layout.Row=3;
                hCancelButton.Layout.Column=3;
            end


            hProgress=uiprogressdlg(obj.hDialog,"Title","Searching for fluid properties blocks",...
            "Indeterminate",true);


            propBlockSearchList=find_system(bdroot(obj.hBlock),...
            "LookUnderMasks","all","MatchFilter",@Simulink.match.allVariants,"RegExp","on",...
            "ComponentPath",obj.fluidsPropPath+"|"+obj.foundationPropPath);


            if~isempty(propBlockSearchList)
                hPropList=get_param(propBlockSearchList,"Handle");
                if iscell(hPropList)
                    hPropList=cell2mat(hPropList);
                end


                propBlockPathList=obj.getPropBlockPath(hPropList);


                hPropList=[-1;hPropList];
                propBlockPathList=["Default Fluid - Water";propBlockPathList];
            end


            listBoxValue=hPropList(hPropList==obj.hPropBlock);
            if isempty(listBoxValue)
                listBoxValue=-1;
            end


            set(obj.hListBox,"Items",propBlockPathList,"ItemsData",hPropList,...
            "Value",listBoxValue);
            close(hProgress)
        end



        function dialogOK(obj,~,~)

            hPropBlockPrev=obj.hPropBlock;
            propBlockPathPrev=obj.propBlockPath;


            obj.hPropBlock=obj.hListBox.Value;
            obj.propBlockPath=string(obj.hListBox.Items(obj.hListBox.ItemsData==obj.hListBox.Value));

            try

                obj.getFluidProperties
                obj.updateContours
                close(obj.hDialog)

            catch err

                obj.hPropBlock=hPropBlockPrev;
                obj.propBlockPath=propBlockPathPrev;


beep
                uialert(obj.hDialog,err.message,"Error",...
                "CloseFcn",@(hObject,eventData)uiresume(obj.hDialog))
                uiwait(obj.hDialog)
            end
        end



        function propBlockPath=getPropBlockPath(obj,hPropBlock)

            modelName=string(get_param(bdroot(obj.hBlock),"Name"));
            tmpPropBlockPath=string(getfullname(hPropBlock));
            propBlockPath=regexprep(extractAfter(tmpPropBlockPath,modelName+"/"),"\s+"," ");
        end



        function updateContours(obj)

            approxStep=(max(obj.T_contour(:))-min(obj.T_contour(:)))/obj.numContours;
            contourStep=obj.contourStepList(find(obj.contourStepList>approxStep,1));


            nSup=sum(obj.p_sat<obj.p_crit)+1;
            nSub=min(nSup,length(obj.p_sat));


            levels=ceil(min(obj.T_contour(:))/contourStep)*contourStep:contourStep:max(obj.T_contour(:));
            set(obj.hContours,"XData",obj.h_contour,"YData",obj.p_contour,"ZData",obj.T_contour,...
            "LevelList",levels)
            set(obj.hSatLiq,"XData",obj.h_sat_liq(1:nSub),"YData",obj.p_sat(1:nSub))
            set(obj.hSatVap,"XData",obj.h_sat_vap(1:nSub),"YData",obj.p_sat(1:nSub))
            set(obj.hSup,"XData",obj.h_sat_liq(nSup:end),"YData",obj.p_sat(nSup:end))
            set(obj.hAxes,"XLim",[min(obj.h_contour(:)),max(obj.h_contour(:))],...
            "YLim",[min(obj.p_contour(:)),max(obj.p_contour(:))])


            obj.hContours.TextList=levels(1:obj.contourLabelSkip:end);


            obj.hAxes.Title.String=obj.fluidName;
            obj.hLink.Text=obj.propBlockPath;
            if obj.propBlockPath==""
                obj.hLink.Tooltip="";
            else
                obj.hLink.Tooltip="Highlight selected fluid properties block";
            end
        end



        function getFluidProperties(obj)

            obj.validatePropBlock
            blk=obj.hPropBlock;


            if blk==-1||string(get_param(blk,"ComponentPath"))==obj.foundationPropPath
                if blk==-1


                    load_system("fl_lib")
                    blk=getSimulinkBlockHandle("fl_lib/Two-Phase Fluid/Utilities/Two-Phase Fluid Properties (2P)",true);
                    obj.fluidName="Default Fluid - Water";
                else
                    obj.fluidName="Custom Fluid";
                end


                paramList=["u_min","u_max","unorm_liq","unorm_vap","p_TLU",...
                "v_liq","v_vap","T_liq","T_vap","u_sat_liq","u_sat_vap","p_crit"];
                n=length(paramList);


                Simulink.Block.eval(blk)
                maskWS=get_param(blk,"MaskWSVariables");
                [~,~,idx]=intersect([paramList,paramList+"_unit"],{maskWS.Name},"stable");
                maskWSValues={maskWS(idx).Value};


                u_min=obj.getSimscapeValue(maskWSValues{1},maskWSValues{1+n});
                u_max=obj.getSimscapeValue(maskWSValues{2},maskWSValues{2+n});
                unorm_liq=obj.getSimscapeValue(maskWSValues{3},maskWSValues{3+n});
                unorm_vap=obj.getSimscapeValue(maskWSValues{4},maskWSValues{4+n});
                p_TLU=obj.getSimscapeValue(maskWSValues{5},maskWSValues{5+n});
                v_liq=obj.getSimscapeValue(maskWSValues{6},maskWSValues{6+n});
                v_vap=obj.getSimscapeValue(maskWSValues{7},maskWSValues{7+n});
                T_liq=obj.getSimscapeValue(maskWSValues{8},maskWSValues{8+n});
                T_vap=obj.getSimscapeValue(maskWSValues{9},maskWSValues{9+n});
                u_sat_liq=obj.getSimscapeValue(maskWSValues{10},maskWSValues{10+n});
                u_sat_vap=obj.getSimscapeValue(maskWSValues{11},maskWSValues{11+n});
                p_crit=obj.getSimscapeValue(maskWSValues{12},maskWSValues{12+n});%#ok<PROP>
            else

                fluidEnum=eval(get_param(blk,"fluid"));


                fluidNameMap=fluids.two_phase_fluid.utilities.enum.Fluid.displayText;
                [~,fluidCellStr]=enumeration("fluids.two_phase_fluid.utilities.enum.Fluid");
                obj.fluidName=fluidNameMap(fluidCellStr{fluidEnum});


                [u_min_val,u_max_val,unorm_liq_val,unorm_vap_val,p_TLU_val,...
                v_liq_val,v_vap_val,~,~,T_liq_val,T_vap_val,...
                ~,~,~,~,~,~,...
                u_sat_liq_val,u_sat_vap_val,p_crit_val]=...
                fluids.internal.two_phase_fluid.utilities.TwoPhaseFluidPredefinedProperties.extractTables(fluidEnum);
                u_min=simscape.Value(u_min_val,"kJ/kg");
                u_max=simscape.Value(u_max_val,"kJ/kg");
                unorm_liq=simscape.Value(unorm_liq_val,"1");
                unorm_vap=simscape.Value(unorm_vap_val,"1");
                p_TLU=simscape.Value(p_TLU_val,"MPa");
                v_liq=simscape.Value(v_liq_val,"m^3/kg");
                v_vap=simscape.Value(v_vap_val,"m^3/kg");
                T_liq=simscape.Value(T_liq_val,"K");
                T_vap=simscape.Value(T_vap_val,"K");
                u_sat_liq=simscape.Value(u_sat_liq_val,"kJ/kg");
                u_sat_vap=simscape.Value(u_sat_vap_val,"kJ/kg");
                p_crit=simscape.Value(p_crit_val,"MPa");%#ok<PROP>
            end


            u_liq=(unorm_liq(:)+1)*(u_sat_liq(:)'-u_min(:)')+u_min(:)';
            u_vap=(unorm_vap(:)-2)*(u_max(:)'-u_sat_vap(:)')+u_max(:)';


            p_liq=repmat(p_TLU(:)',length(unorm_liq),1);
            p_vap=repmat(p_TLU(:)',length(unorm_vap),1);
            h_liq=u_liq+p_liq.*v_liq;
            h_vap=u_vap+p_vap.*v_vap;


            obj.p_contour=value([p_liq;p_vap],obj.p_unit);
            obj.h_contour=value([h_liq;h_vap],obj.h_unit);
            obj.T_contour=value([T_liq;T_vap],obj.T_unit);


            obj.p_sat=value(p_TLU(:)',obj.p_unit);
            obj.h_sat_liq=value(h_liq(end,:),obj.h_unit);
            obj.h_sat_vap=value(h_vap(1,:),obj.h_unit);
            obj.p_crit=value(p_crit,obj.p_unit);%#ok<PROP>
        end



        function validatePropBlock(obj)

            if obj.hPropBlock==-1
                obj.propBlockPath="";
                return
            end

            try

                if string(get_param(obj.hPropBlock,"ComponentPath"))==obj.fluidsPropPath...
                    ||string(get_param(obj.hPropBlock,"ComponentPath"))==obj.foundationPropPath

                    obj.propBlockPath=obj.getPropBlockPath(obj.hPropBlock);
                else

                    modelName=string(get_param(bdroot(obj.hBlock),"Name"));
                    throw(MException(message("physmod:fluids:diagrams:PropBlockNotFound",...
                    modelName+"/"+obj.propBlockPath)))
                end
            catch

                modelName=string(get_param(bdroot(obj.hBlock),"Name"));
                hPropBlockCheck=getSimulinkBlockHandle(modelName+"/"+obj.propBlockPath,true);

                if(hPropBlockCheck~=-1)&&...
                    (string(get_param(hPropBlockCheck,"ComponentPath"))==obj.fluidsPropPath...
                    ||string(get_param(hPropBlockCheck,"ComponentPath"))==obj.foundationPropPath)

                    obj.hPropBlock=hPropBlockCheck;
                else

                    modelName=string(get_param(bdroot(obj.hBlock),"Name"));
                    throw(MException(message("physmod:fluids:diagrams:PropBlockNotFound",...
                    modelName+"/"+obj.propBlockPath)))
                end
            end
        end



        function ssc=getSimscapeValue(~,maskWSValue,maskWSUnit)
            if isa(maskWSValue,"Simulink.Parameter")

                value=maskWSValue.Value;
            else
                value=maskWSValue;
            end

            if isempty(value)

                throw(MException(message("physmod:fluids:diagrams:UnrecognizedVariables")))
            end

            if isempty(maskWSUnit)

                unit="1";
            else
                unit=maskWSUnit;
            end


            ssc=simscape.Value(value,unit);
        end

    end

end