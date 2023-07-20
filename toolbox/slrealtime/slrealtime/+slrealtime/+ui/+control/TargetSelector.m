classdef TargetSelector<matlab.ui.componentcontainer.ComponentContainer







    properties(Dependent,SetAccess=private)
TargetName
    end
    methods
        function value=get.TargetName(this)
            value=this.Dropdown.Value;
        end
    end

    events



TargetSelectionChanged



GUIUpdated
    end

    methods(Access=public)
        function delete(this)
            delete(this.AddTargetListener);
            delete(this.RemoveTargetListener);
            delete(this.DefaultTargetListener);
            delete(this.RenameTargetListener);
        end
    end



    properties(Access=public,Constant,Hidden)
        SIMULINK_NORMAL_MODE='Simulink Normal Mode';
    end

    properties(Access=public)


FontName
FontSize
FontWeight
FontAngle
FontColor
    end

    properties(Access={?slrealtime.ui.container.Menu,?slrealtime.internal.SLRTComponent},Transient,NonCopyable)
        Dropdown matlab.ui.control.DropDown
    end

    properties(Access=private,Transient,NonCopyable)
        Grid matlab.ui.container.GridLayout

AddTargetListener
RemoveTargetListener
DefaultTargetListener
RenameTargetListener
    end

    methods(Access=protected)
        function setup(this)


            dropdownWidth=200;
            dropdownHeight=30;



            this.Grid=uigridlayout(this,[1,1],...
            'Padding',0,'RowSpacing',0,'ColumnSpacing',0);
            this.Grid.ColumnWidth={'1x'};
            this.Grid.RowHeight={'1x'};



            this.Dropdown=uidropdown(this.Grid,...
            'Editable',true,...
            'ValueChangedFcn',@(o,e)this.valueChanged(e));
            this.Dropdown.Layout.Row=1;
            this.Dropdown.Layout.Column=1;




            this.populateTargetsDropDown();
            targets=slrealtime.Targets;
            this.Dropdown.Value=targets.getDefaultTargetName();
            this.valueChanged([]);



            this.AddTargetListener=listener(targets,'AddedTarget',@(src,evnt)this.targetAdded());
            this.RemoveTargetListener=listener(targets,'RemovedTarget',@(src,evnt)this.targetRemoved());
            this.DefaultTargetListener=listener(targets,'DefaultTargetChanged',@(src,evnt)this.targetDefaultChanged());
            this.RenameTargetListener=listener(targets,'TargetNameChanged',@(src,evnt)this.targetRenamed(src,evnt));



            this.Position=[100,100,dropdownWidth,dropdownHeight];
            this.FontName=this.Dropdown.FontName;
            this.FontSize=this.Dropdown.FontSize;
            this.FontWeight=this.Dropdown.FontWeight;
            this.FontAngle=this.Dropdown.FontAngle;
            this.FontColor=this.Dropdown.FontColor;
            this.BackgroundColor=this.Dropdown.BackgroundColor;
        end

        function update(this)
            this.Dropdown.FontName=this.FontName;
            this.Dropdown.FontSize=this.FontSize;
            this.Dropdown.FontWeight=this.FontWeight;
            this.Dropdown.FontAngle=this.FontAngle;
            this.Dropdown.FontColor=this.FontColor;
            this.Dropdown.BackgroundColor=this.BackgroundColor;

            if this.isDesignTime()

                this.Dropdown.Items={'TargetPC1'};
            end
        end
    end



    methods(Access=private)
        function populateTargetsDropDown(this)



            targets=slrealtime.Targets;
            if(isdeployed&&...
                targets.getNumTargets==1&&...
                isequal(targets.getDefaultTargetName,'TargetPC1')&&...
                isempty(targets.getTargetSettings.address))
                tg=slrealtime;
                tg.TargetSettings.name='Enter_IP_Address_Here';
            end




            if(isdeployed&&...
                targets.getNumTargets>1&&...
                any(strcmp(targets.getTargetNames,'Enter_IP_Address_Here')))
                targets.removeTarget('Enter_IP_Address_Here');
            end
            defaultTarget=targets.getDefaultTargetName();

            this.Dropdown.ItemsData=[];
            this.Dropdown.ItemsData=targets.getTargetNames();
            this.Dropdown.Items=targets.getTargetNames();

            if targets.getNumTargets()>1

                idx=find(cellfun(@(x)strcmp(x,defaultTarget),this.Dropdown.Items));
                this.Dropdown.Items{idx}=[this.Dropdown.Items{idx},' (',message('slrealtime:appdesigner:Default').getString(),')'];
            end

            if~isdeployed&&slrealtime.internal.feature('InstrumentPanelSLNormalMode')
                this.Dropdown.ItemsData{end+1}=this.SIMULINK_NORMAL_MODE;
                this.Dropdown.Items{end+1}=this.SIMULINK_NORMAL_MODE;
            end
        end
    end



    methods(Access=public,Hidden)
        function targetAdded(this)
            oldValue=this.Dropdown.Value();
            this.populateTargetsDropDown();
            this.Dropdown.Value=oldValue;

            notify(this,'GUIUpdated');
        end

        function targetRemoved(this)
            oldValue=this.Dropdown.Value;
            this.populateTargetsDropDown();
            if~strcmp(oldValue,this.Dropdown.Value)

                targets=slrealtime.Targets;
                this.Dropdown.Value=targets.getDefaultTargetName();
                this.valueChanged([]);
            end

            notify(this,'GUIUpdated');
        end

        function targetDefaultChanged(this)
            targets=slrealtime.Targets;
            defaultTarget=targets.getDefaultTargetName();















            this.Dropdown.Items=this.Dropdown.ItemsData;

            if targets.getNumTargets()>1

                idx=find(cellfun(@(x)strcmp(x,defaultTarget),this.Dropdown.Items));
                this.Dropdown.Items{idx}=[this.Dropdown.Items{idx},' (',message('slrealtime:appdesigner:Default').getString(),')'];
            end

            notify(this,'GUIUpdated');
        end

        function targetRenamed(this,~,evnt)
            oldValue=this.Dropdown.Value;
            this.populateTargetsDropDown();
            if strcmp(oldValue,evnt.oldName)

                this.Dropdown.Value=evnt.newName;
            end

            notify(this,'GUIUpdated');
        end
    end



    methods(Access={?slrealtime.ui.container.Menu})
        function valueChanged(this,e)



            if~isempty(e)
                if~any(strcmp(e.Value,this.Dropdown.ItemsData))



                    if~slrealtime.internal.validateIpAddress(e.Value)
                        msg=message('slrealtime:appdesigner:NotTargetOrIpAddress',e.Value);
                        title=message('slrealtime:appdesigner:TargetErrorTitle');
                        uialert(...
                        ancestor(this.Parent,'figure'),...
                        msg.getString(),title.getString());

                        this.Dropdown.Value=e.PreviousValue;
                        return;
                    else
                        tgs=slrealtime.Targets;
                        try
                            new_tg=tgs.addTarget(e.Value);
                            new_tg.TargetSettings.address=e.Value;
                            tgs.setDefaultTargetName(e.Value);
                        catch ME
                            msg=message('slrealtime:appdesigner:CannotAddTarget',e.Value,slrealtime.internal.replaceHyperlinks(ME.message));
                            title=message('slrealtime:appdesigner:TargetErrorTitle');
                            uialert(...
                            ancestor(this.Parent,'figure'),...
                            msg.getString(),title.getString());

                            this.Dropdown.Value=e.PreviousValue;
                            return;
                        end
                    end
                else





                    targets=slrealtime.Targets;
                    defaultTarget=targets.getDefaultTargetName();
                    if strcmp(e.Value,defaultTarget)
                        idx=cellfun(@(x)strcmp(x,defaultTarget),this.Dropdown.ItemsData);
                        this.Dropdown.Value=this.Dropdown.ItemsData{idx};
                    end
                end
            end




            if~isempty(e)&&...
                any(strcmp({e.Value,e.PreviousValue},this.SIMULINK_NORMAL_MODE))
                tg=slrealtime.internal.NormalModeTarget.getInstance();
                if tg.isRunning()
                    tg.stop();
                end
                tg.disconnect();
            end

















            notify(this,'TargetSelectionChanged');
        end
    end




    methods(Access=protected)
        function val=isDesignTime(this)





            val=false;
            if isprop(ancestor(this,'figure'),'DesignTimeProperties')
                val=true;
            end
        end
    end




    methods(Access=public,Hidden)
        function out=getForTesting(this,prop)



            narginchk(2,2);

            if~ischar(prop)&&~isStringScalar(prop)
                slrealtime.internal.throw.Error('slrealtime:appdesigner:InvalidPropertyName');
            end

            if~contains(prop,'.')
                if isprop(this,prop)
                    out=this.(prop);
                else
                    slrealtime.internal.throw.Error('slrealtime:appdesigner:NotTargetProperty',class(this));
                end
            else
                props=split(prop,'.');
                numProps=length(props);
                obj=this;
                for i=1:(numProps-1)
                    obj=obj.(char(props(i)));
                end

                if isprop(obj,char(props(numProps)))||...
                    any(strcmp(fieldnames(obj),char(props(numProps))))
                    out=obj.(char(props(numProps)));
                else
                    slrealtime.internal.throw.Error('slrealtime:appdesigner:NotTargetProperty',class(obj));
                end
            end
        end
    end
end
