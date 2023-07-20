function autoblksenableparameters(varargin)


















    MaskObject=get_param(varargin{1},'MaskObject');
    Parameters=MaskObject.Parameters;
    DialogControls=MaskObject.getDialogControls;
    ParamValues=struct('Evaluate',{Parameters.Evaluate},'Name',{Parameters.Name},'Visible',{Parameters.Visible},'Enabled',{Parameters.Enabled});
    if nargin>=6
        EnabledOnly=varargin{6};
    else
        EnabledOnly=false;
    end

    if ischar(varargin{2})
        ParamValues=SetParameter(varargin{2},ParamValues,'on',EnabledOnly);
    else
        for i=1:length(varargin{2})
            ParamValues=SetParameter(varargin{2}{i},ParamValues,'on',EnabledOnly);
        end
    end

    if nargin>=3
        if ischar(varargin{3})
            ParamValues=SetParameter(varargin{3},ParamValues,'off',EnabledOnly);
        else
            for i=1:length(varargin{3})
                ParamValues=SetParameter(varargin{3}{i},ParamValues,'off',EnabledOnly);
            end
        end
    end


    if nargin>=4
        ParamValues=HideDialogControls(DialogControls,ParamValues,varargin{4},'on',EnabledOnly);
    end
    if nargin>=5
        ParamValues=HideDialogControls(DialogControls,ParamValues,varargin{5},'off',EnabledOnly);
    end




    if~EnabledOnly
        set_param(varargin{1},'MaskVisibilities',{ParamValues.Visible});
    end
    set_param(varargin{1},'MaskEnables',{ParamValues.Enabled});

end


function ParamValues=HideDialogControls(DialogControls,ParamValues,ControlNames,Enabled,EnabledOnly)
    if isempty(Enabled)||isempty(ControlNames)
        return
    end
    ConIdx=1:length(ControlNames);

    for i=1:length(DialogControls)

        FindIdx=ConIdx(strcmp(ControlNames,DialogControls(i).Name));
        if~isempty(FindIdx)
            if isContainer(DialogControls(i))
                if~EnabledOnly
                    DialogControls(i).Visible=Enabled;
                end
                DialogControls(i).Enabled=Enabled;
                ParamValues=HideDialogControls(DialogControls(i).DialogControls,ParamValues,{DialogControls(i).DialogControls.Name},Enabled,EnabledOnly);
            else
                [ParamValues,isParam]=SetParameter(DialogControls(i).Name,ParamValues,Enabled,EnabledOnly);
                if~isParam
                    if~EnabledOnly
                        DialogControls(i).Visible=Enabled;
                    end
                    DialogControls(i).Enabled=Enabled;
                end
            end
            ConIdx=ConIdx(ConIdx~=FindIdx);
            ControlNames=ControlNames(ConIdx);
            ConIdx=1:length(ConIdx);
        end


        if isContainer(DialogControls(i))
            ParamValues=HideDialogControls(DialogControls(i).DialogControls,ParamValues,ControlNames,Enabled,EnabledOnly);
        end

    end

end


function[ParamValues,isParam]=SetParameter(ParameterName,ParamValues,Enabled,EnabledOnly)
    StrCmpOut=strcmp({ParamValues.Name},ParameterName);
    if any(StrCmpOut)
        ParamValues(StrCmpOut).Enabled=Enabled;
        if~EnabledOnly
            ParamValues(StrCmpOut).Visible=Enabled;
        end
        isParam=true;
    else
        isParam=false;
    end
end


function test=isContainer(DialogControl)
    test=isa(DialogControl,'Simulink.dialog.TabContainer')...
    ||isa(DialogControl,'Simulink.dialog.Tab')...
    ||isa(DialogControl,'Simulink.dialog.Group')...
    ||isa(DialogControl,'Simulink.dialog.CollapsiblePanel');
end


