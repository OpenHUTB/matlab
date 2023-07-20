function varargout=interfaceResolutionDialog(varargin)


























    gui_Singleton=1;
    gui_State=struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@interfaceResolutionDialog_OpeningFcn,...
    'gui_OutputFcn',@interfaceResolutionDialog_OutputFcn,...
    'gui_LayoutFcn',[],...
    'gui_Callback',[]);
    if nargin&&ischar(varargin{1})
        gui_State.gui_Callback=str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}]=gui_mainfcn(gui_State,varargin{:});
    else
        gui_mainfcn(gui_State,varargin{:});
    end

end



function interfaceResolutionDialog_OpeningFcn(hObject,eventdata,handles,varargin)








    handles.src=varargin{1};
    handles.dst=varargin{2};
    handles.collisions=varargin{3};
    handles.collisionResolutionOption=systemcomposer.architecture.model.interface.CollisionResolution.UNSPECIFIED;


    handles.ICRD_Header1.String=message('SystemArchitecture:Interfaces:ICRD_Header1',handles.dst).getString;
    handles.ICRD_Header2.String=message('SystemArchitecture:Interfaces:ICRD_Header2').getString;
    handles.ICRD_Header3.String=message('SystemArchitecture:Interfaces:ICRD_Header3').getString;
    handles.replacedst.String=message('SystemArchitecture:Interfaces:ICRD_ReplaceDst',handles.src).getString;
    handles.replacedst.Tooltip=message('SystemArchitecture:Interfaces:ICRD_ReplaceDstTooltip',handles.dst,handles.src).getString;
    handles.preservedst.String=message('SystemArchitecture:Interfaces:ICRD_KeepDst',handles.dst).getString;
    handles.preservedst.Tooltip=message('SystemArchitecture:Interfaces:ICRD_KeepDstTooltip',handles.dst,handles.src).getString;
    handles.collisionsList.String=handles.collisions;
    handles.collisionsList.Value=[];


    guidata(hObject,handles);



end


function varargout=interfaceResolutionDialog_OutputFcn(hObject,eventdata,handles)





    uiwait(handles.interfaceResolutionDialog);


    if(isvalid(hObject))
        handles=guidata(hObject);
        varargout{1}=handles.collisionResolutionOption;
    else
        varargout{1}=systemcomposer.architecture.model.interface.CollisionResolution.UNSPECIFIED;
    end


    delete(hObject);
end


function interfaceResolutionDialog_CloseRequestFcn(hObject,eventdata,handles)





    delete(hObject);
end


function replacedst_Callback(hObject,eventdata,handles)







    handles.collisionResolutionOption=systemcomposer.architecture.model.interface.CollisionResolution.REPLACE_DST;


    guidata(hObject,handles);


    uiresume();
end


function preservedst_Callback(hObject,eventdata,handles)







    handles.collisionResolutionOption=systemcomposer.architecture.model.interface.CollisionResolution.KEEP_DST;


    guidata(hObject,handles);


    uiresume();
end
