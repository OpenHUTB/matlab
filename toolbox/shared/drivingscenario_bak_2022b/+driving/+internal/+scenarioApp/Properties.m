classdef Properties<matlabshared.application.Component&...
    matlabshared.application.ComponentBanner&...
    driving.internal.scenarioApp.UITools




    properties
        SpecificationIndex=1;
        InteractiveMode=false;
        Enabled=true
    end

    properties(SetAccess=protected,Hidden)
Layout
    end

    properties(Hidden)
hSpecificationIndex
hDelete
    end

    events
PropertyChanged
    end

    methods

        function this=Properties(varargin)

            this@matlabshared.application.Component(varargin{:});
        end

        function set.SpecificationIndex(this,newIndex)
            if isequal(newIndex,this.SpecificationIndex)
                return;
            end
            this.SpecificationIndex=newIndex;
            notify(this.Application,getIndexEventName(this));
        end

        function set.InteractiveMode(this,newMode)
            this.InteractiveMode=newMode;
            onNewInteractiveMode(this);
        end

        function updateForEnable(this)
            if this.Enabled
                update(this);
            else
                all=findall(this.Figure,'Enable','on');
                if~isempty(all)
                    set(all,'Enable','off');
                end
            end
        end
    end

    methods(Hidden)

        function num=strToNum(~,str)

            str=string(str);
            str=str.replace("[","");
            str=str.replace("]","");

            str=str.replace(";"," ");
            str=str.replace(","," ");
            str=strtrim(str);
            if str==""
                num=[];
            else
                num=double(split(str))';
            end
        end

        function setProperty(this,propName,newValue)

            id='';
            str='';


            if isa(newValue,'double')
                [id,str]=validateDoubleProperty(this,propName,newValue);
            end
            if~isempty(id)
                update(this);
                errorMessage(this,str,id);
                return;
            end

            if this.InteractiveMode
                setPropertyForInteractiveMode(this,propName,newValue)
            else
                setPropertyForNonInteractiveMode(this,propName,newValue);
            end
        end

        function defaultEditboxCallback(this,hSrc,~)
            setDoubleProperty(this,getPropertyFromTag(this,hSrc.Tag),hSrc);
        end

        function defaultCheckboxCallback(this,hSrc,~)
            edit=createEdit(this,getPropertyFromTag(this,hSrc.Tag),logical(hSrc.Value));
            applyEdit(this.Application,edit);
            update(this);
            notify(this,'PropertyChanged');
        end

        function defaultPopupCallback(this,hSrc,~)
            prop=getPropertyFromTag(this,hSrc.Tag);
            this.(prop)=hSrc.Value;
            update(this);
            if strcmp(prop,'SpecificationIndex')
                onFocus(this);
            end
        end

        function str=getErrorMessageString(~,propertyName,me)
            try
                str=getString(message(['driving:scenarioApp:Bad',propertyName]));
            catch ME_IGNORE %#ok<NASGU>
                str=me.message;
            end
        end
    end

    methods(Access=protected)
        function setupWidgets(this,spec,names,varargin)
            enable=matlabshared.application.logicalToOnOff(this.Enabled);
            setupWidgets@driving.internal.scenarioApp.UITools(this,spec,names,enable,varargin{:});
        end

        function options=getAddToApplicationOptions(this)

            app=this.Application;



            tile=getComponentTileIndex(app,app.ActorProperties);
            if isempty(tile)
                tile=1;
            end
            options=struct(...
            'Title',getName(this),...
            'Tag',getTag(this),...
            'Closable',isCloseable(this),...
            'Tile',tile);
        end

        function onNewInteractiveMode(~)

        end

        function setPropertyForInteractiveMode(this,propName,newValue)
            setPropertyForNonInteractiveMode(this,propName,newValue);
        end

        function setPropertyForNonInteractiveMode(this,propName,newValue)
            edit=createEdit(this,propName,newValue);
            oldValue=edit.OldValue;
            if iscell(oldValue)
                oldValue=oldValue{1};
            end
            if isequal(newValue,oldValue)



                update(this);
            else
                try
                    applyEdit(this.Application,edit)
                catch ME
                    update(this);
                    str=getErrorMessageString(this,propName,ME);
                    errorMessage(this,str,ME.identifier);
                    return;
                end
                update(this);
                notify(this,'PropertyChanged');
            end
        end

        function setVectorProperty(this,propertyName,varargin)
            newValue=zeros(1,numel(varargin));
            for indx=1:numel(newValue)
                newValue(indx)=str2double(this.(varargin{indx}).String);
            end

            setProperty(this,propertyName,newValue);
        end

        function[id,str]=validateDoubleProperty(this,name,value)
            id='';
            str='';
            if isnan(value)
                id=['driving:scenarioApp:Bad',name];
                str=getErrorMessageString(this,name,struct('message',getString(message(id))));
            end
        end

        function setDoubleProperty(this,propertyName,srcWidget)
            str=get(srcWidget,'String');
            newValue=str2double(str);
            if isnan(newValue)
                newValue=this.strToNum(str);
            end
            setProperty(this,propertyName,newValue);
        end

        function nameCallback(this,hSrc,~)
            newName=strtrim(hSrc.String);
            setProperty(this,'Name',newName);
        end

        function windowMotionCallback(varargin)

        end
    end

    methods(Abstract,Access=protected)
        eventName=getIndexEventName(this);
        updateScenario(this);
    end


    methods(Abstract)
        edit=createEdit(this);
    end
end


