function DefaultSpringLoadedMode(hFig,modeName,state)

    if~hasuimode(hFig,modeName)
        dMode=uimode(hFig,modeName);
        set(dMode,'ModeStartFcn',{@localStartFcn,dMode});
        set(dMode,'ModeStopFcn',{@localStopFcn,dMode});
        set(dMode,'WindowButtonDownFcn',{@localWindowButtonDownFcn,dMode});
        set(dMode,'WindowButtonUpFcn',{@localWindowButtonUpFcn,dMode});
        set(dMode,'WindowButtonMotionFcn',{@localWindowButtonMoveFcn,dMode});
        set(dMode,'IsOneShot',true);
        dMode.UseContextMenu='off';
    end

    if strcmpi(state,'off')
        if isactiveuimode(hFig,modeName)
            activateuimode(hFig,'');
        end
    else
        activateuimode(hFig,modeName);
    end



    function localStartFcn(dMode)





        function localStopFcn(dMode)


            set(dMode.FigureHandle,'Visible','off','VisibleMode','auto');




            function localWindowButtonDownFcn(hFig,evd,dMode)


                function localWindowButtonUpFcn(hFig,evd,dMode)

                    activateuimode(hFig,'');


                    function localWindowButtonMoveFcn(hFig,evd,dMode)