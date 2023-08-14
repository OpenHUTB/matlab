classdef ParameterTuner<slrealtime.internal.SLRTComponent




    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        'Connected',...
        'Disconnected',...
        'Loaded',...
        'Stopped',...
        'ParamChanged',...
        'ParamSetChanged',...
'CalPageChanged'...
        }
    end

    methods(Access=public)
        function delete(this)
            delete(this.ComponentValueChangedListener);
        end

        function changeComponentValue(this,newValue)
            if isempty(this.Component)
                return;
            end

            oldValue=this.Component.Value;

            if~isempty(this.ConvertToComponent)
                newValue=this.ConvertToComponent(newValue);
            end

            this.Component.Value=newValue;

            this.componentValueChanged(...
            struct('Value',newValue,'PreviousValue',oldValue));
        end
    end

    properties(Access={?slrealtime.internal.SLRTComponent},Transient,NonCopyable)
        Image matlab.ui.control.Image
    end
    properties(Access=private,Transient,NonCopyable)
        Grid matlab.ui.container.GridLayout

ComponentValueChangedListener
    end

    properties(Access=public)
Component
BlockPath
ParameterName
ConvertToComponent
ConvertToTarget
    end

    methods(Access=protected)
        function setup(this)
            this.Grid=uigridlayout(this,[1,1],...
            'ColumnSpacing',0,'RowSpacing',0,'Padding',0);

            this.Position=[0,0,0,0];
            this.Visible='off';

            this.Image=uiimage(this.Grid);

            if isdeployed
                this.Image.ImageSource=fullfile(matlabroot,'mcr','toolbox','slrealtime','slrealtime','+slrealtime','+icons','warning_48.png');
            else
                this.Image.ImageSource=fullfile(matlabroot,'toolbox','slrealtime','slrealtime','+slrealtime','+icons','warning_48.png');
            end
        end

        function update(this)
            if this.firstUpdate
                this.firstUpdate=false;



                if isempty(this.GetTargetNameFcnH)
                    this.initTarget([]);
                end
            end
        end
    end

    methods
        function set.Component(this,value)
            if isempty(value)

                if~isempty(this.Component)
                    this.Component.Visible='on';
                    this.Component.Enable='on';
                    this.Component.Tooltip='';

                    this.Component=value;

                    delete(this.ComponentValueChangedListener);%#ok
                    this.ComponentValueChangedListener=[];%#ok
                end
            elseif isgraphics(value)

                if~isempty(this.Component)
                    this.Component.Visible='on';
                    this.Component.Enable='on';
                    this.Component.Tooltip='';
                end


                this.Component=value;
                this.Parent=this.Component.Parent;
                if~isempty(this.Layout)
                    this.Layout.Row=this.Component.Layout.Row;
                    this.Layout.Column=this.Component.Layout.Column;
                else
                    this.Position=this.Component.Position;
                    if this.Position(3)<5||this.Position(4)<5



                        this.Position(1)=this.Position(1)+this.Position(3)/2-15;
                        this.Position(2)=this.Position(2)+this.Position(4)/2-15;
                        this.Position(3)=30;
                        this.Position(4)=30;
                    else
                        this.Position(1)=this.Position(1)+2;
                        this.Position(2)=this.Position(2)+2;
                        this.Position(3)=this.Position(3)-4;
                        this.Position(4)=this.Position(4)-4;
                    end
                end

                delete(this.ComponentValueChangedListener);%#ok
                this.ComponentValueChangedListener=listener(this.Component,...
                'ValueChanged',@(src,e)this.componentValueChanged(e));%#ok

                this.updateGUIWrapper([]);
            else
                slrealtime.internal.throw.Error(...
                'slrealtime:appdesigner:ParamTunerComponent');
            end
        end

        function set.BlockPath(this,value)
            if ischar(value)||(isstring(value)&&isscalar(value))||...
                iscell(value)
                this.BlockPath=convertStringsToChars(value);
                this.updateGUIWrapper([]);
            else
                slrealtime.internal.throw.Error(...
                'slrealtime:appdesigner:ParamTunerBlockPath');
            end
        end

        function set.ParameterName(this,value)
            if ischar(value)||(isstring(value)&&isscalar(value))
                this.ParameterName=convertStringsToChars(value);
                this.updateGUIWrapper([]);
            else
                slrealtime.internal.throw.Error(...
                'slrealtime:appdesigner:ParamTunerParameterName');
            end
        end

        function set.ConvertToComponent(this,value)
            if isempty(value)
                this.ConvertToComponent=[];
            elseif isa(value,'function_handle')
                this.ConvertToComponent=value;
            else
                slrealtime.internal.throw.Error(...
                'slrealtime:appdesigner:ParamTunerConvert','ConvertToComponent');
            end
            this.updateGUIWrapper([]);
        end

        function set.ConvertToTarget(this,value)
            if isempty(value)
                this.ConvertToTarget=[];
            elseif isa(value,'function_handle')
                this.ConvertToTarget=value;
            else
                slrealtime.internal.throw.Error(...
                'slrealtime:appdesigner:ParamTunerConvert','ConvertToTarget');
            end
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(this)%#ok
        end

        function updateGUI(this,~)
            if isempty(this.Component)
                return;
            end

            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            if tg.isConnected()&&(tg.isLoaded()||tg.isRunning)

                try
                    if tg.getECUPage()~=tg.getXCPPage()
                        this.Visible='on';
                        this.Image.Tooltip=message('slrealtime:appdesigner:DisabledDueToPageSwitchingTooltip').getString();
                        return;
                    end
                catch

                end

                this.Component.Enable='on';
                if isempty(this.BlockPath)

                    if isempty(this.ParameterName)
                        this.Component.Tooltip='';
                    else
                        this.Component.Tooltip=this.ParameterName;
                    end
                else

                    this.Component.Tooltip=[this.BlockPath,':',this.ParameterName];
                end


                try
                    value=tg.getparam(this.BlockPath,this.ParameterName);
                    if this.isSimulinkNormalMode()



                        v=str2double(value);
                        if~isnan(v),value=v;end
                    end

                    if~isempty(this.ConvertToComponent)
                        this.Component.Value=this.ConvertToComponent(value);
                    else
                        this.Component.Value=value;
                    end
                catch ME
                    this.Visible='on';
                    if isempty(this.BlockPath)

                        this.Image.Tooltip=[this.ParameterName,newline,slrealtime.internal.replaceHyperlinks(ME.message)];
                    else

                        this.Image.Tooltip=[this.BlockPath,':',this.ParameterName,newline,slrealtime.internal.replaceHyperlinks(ME.message)];
                    end
                    return;
                end
                this.Visible='off';
                this.Image.Tooltip='';
            else
                this.Component.Enable='off';
                this.Component.Tooltip='';
                this.Visible='off';
                this.Image.Tooltip='';
            end
        end

        function componentValueChanged(this,evnt)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            try
                curr_value=tg.getparam(this.BlockPath,this.ParameterName);
                if isfi(curr_value)
                    datatype=curr_value.numerictype.tostringInternalFixdt;
                else
                    datatype=class(curr_value);
                end

                newValue=evnt.Value;

                if~isempty(this.ConvertToTarget)
                    newValue=this.ConvertToTarget(newValue);
                end

                if isa(newValue,datatype)



                    val=newValue;
                else



                    newValueStr=newValue;
                    if~ischar(newValue)
                        newValueStr=num2str(newValue);
                    end
                    if isa(newValueStr,datatype)



                        val=newValueStr;
                    else









                        try
                            dt=eval(datatype);
                            val=fi(str2num(newValueStr),dt);%#ok
                        catch
                            try
                                val=eval([datatype,'(',newValueStr,')']);
                            catch
                                try
                                    val=eval([datatype,'(''',newValueStr,''')']);
                                catch






                                    slrealtime.internal.throw.Error(...
                                    'slrealtime:appdesigner:ParamsIncorrectDataType',...
                                    datatype);
                                end
                            end
                        end



                    end
                end

                tg.setparam(this.BlockPath,this.ParameterName,val);

            catch ME
                this.uialert(ME,'CloseFcn',...
                @(~,~)this.Component.set('Value',evnt.PreviousValue));
                return;
            end
        end
    end
end
