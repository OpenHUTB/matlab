function[status,message]=breakpointddg_cb(dlg,op,varargin)



    status=true;
    message='';

    dlgSource=dlg.getDialogSource;
    forwardedObject=dlgSource.getForwardedObject;
    if~isempty(forwardedObject)
        if isa(forwardedObject,'Simulink.SlidDAProxy')
            forwardedObject=forwardedObject.getForwardedObject;
        end
        obj=forwardedObject;
    else
        obj=dlgSource;
    end


    if isequal(op,'preapply')
        idx=i_valueIndex(obj.DialogData.bp);
        if(true==obj.DialogData.bpValueDirty)
            try
                obj.DialogData.Breakpoints.Value=obj.evalPropValue('Breakpoints',...
                obj.DialogData.bp{idx}.Value,dlg.getContext());
            catch e %#ok
                status=false;
                errordlg(DAStudio.message('Simulink:dialog:BreakpointInvalidValueForBreakpoints'),dlg.getTitle,'modal');
                message='';
                return;
            end
        end

        if(~isvector(obj.DialogData.Breakpoints.Value))
            status=false;
            errordlg(DAStudio.message('Simulink:dialog:BreakpointIsNotVector',num2str(1)),dlg.getTitle,'modal');
            message='';
        end
        if(true==status)
            [status,message]=saveData(obj);
        end
    elseif isequal(op,'postapply')
        obj.DialogData=[];
        dlg.refresh();
    elseif isequal(op,'prerevert')
        obj.DialogData=[];
    elseif isequal(op,'close')
        if isa(obj,'Simulink.Breakpoint')
            mydlgs=DAStudio.ToolRoot.getOpenDialogs(obj);
            if isequal(length(mydlgs),0)
                obj.DialogData=[];
            end
        end
    elseif isequal(op,'grpTypeDef_tag')
        data=obj.DialogData;
        if isequal(varargin{1},'DataScope')
            dataScopeStr=varargin{3}(varargin{2}+1);
            data.StructTypeInfo.(varargin{1})=dataScopeStr{1};
        else
            data.StructTypeInfo.(varargin{1})=varargin{2};
        end
        obj.DialogData=data;
    elseif isequal(op,'supportTunableSize_tag')
        data=obj.DialogData;
        data.SupportTunableSize=varargin{1};
        obj.DialogData=data;
    end
end

function[status,message]=saveData(obj)
    status=true;
    message='';

    try
        data=obj.DialogData;
        if isfield(data,'Breakpoints')
            obj.Breakpoints=data.Breakpoints;
        end

        if isfield(data,'StructTypeInfo')
            obj.StructTypeInfo=data.StructTypeInfo;
        end
        if isfield(data,'SupportTunableSize')
            obj.SupportTunableSize=data.SupportTunableSize;
        end
    catch E
        status=false;
        message=E.message;
    end
end

function idx=i_valueIndex(l_data)

    for k=1:size(l_data,2)
        if isequal(l_data{k}.Name,'Value')
            idx=k;
            break;
        end
    end
end
