function handles=uiwaitbar(handles,mode,value,position)








    narginchk(2,4);


    isCreate=true;
    if~strcmpi(mode,'create')
        isCreate=false;
    end

    waitValue=0;
    if(nargin<3)
        if~isCreate
            error(message('MATLAB:uitools:uiwaitbar:InvalidumberOfArguments'));
        end
    elseif(value>=0)&&(value<=100)
        waitValue=double(value);
    else
        error(message('MATLAB:uitools:uiwaitbar:InvalidValueRange'));
    end

    if isCreate
        waitPos=[0,0,1,1];
        if(nargin>3)
            if(all(size(position)==[1,4]))
                waitPos=position;
            else
                error(message('MATLAB:uitools:uiwaitbar:InvalidPositionVector'));
            end
        end

        [handles.progressbar,handles.container]=createProgressbar(waitPos,waitValue,handles);


        setappdata(handles.figure,'TMWWaitbar_handles',handles);

        setappdata(handles.figure,'TMWWaitbar_value',waitValue);

    else
        prgBar=handles.progressbar;

        if isempty(handles.container)
            prgBar.Value=waitValue/100;
        else
            prgBar.setValue(waitValue);
        end


        setappdata(handles.figure,'TMWWaitbar_value',waitValue);
    end
end

function[pHandle,cHandle]=createProgressbar(waitPos,waitValue,handles)
    if matlab.ui.internal.isUIFigure(handles.figure)

        pixelPos=getpixelposition(handles.axes);
        pHandle=matlab.ui.control.internal.ProgressIndicator('Parent',handles.figure,...
        'Value',waitValue/100,...
        'HandleVisibility','off');

        pHandle.Position(1:3)=pixelPos(1:3);

        cHandle={};
    else

        jw=javaObjectEDT('javax.swing.JProgressBar');

        jw.setMinimum(0);jw.setMaximum(100);

        c=handles.figure.Color;
        jw.setBackground(java.awt.Color(c(1),c(2),c(3)));

        jw.setValue(waitValue);


        [pHandle,cHandle]=matlab.ui.internal.JavaMigrationTools.suppressedJavaComponent(jw,[1,1,1,1],handles.figure);

        set(cHandle,'Units','points','Position',waitPos,'HandleVisibility','off');
    end
end
