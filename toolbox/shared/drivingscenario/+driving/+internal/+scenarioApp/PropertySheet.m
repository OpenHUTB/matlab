classdef PropertySheet<matlabshared.application.PropertySheet&driving.internal.scenarioApp.UITools

    events
HeightChanged
    end

    methods
        function this=PropertySheet(varargin)
            this@matlabshared.application.PropertySheet(varargin{:});
            this.Panel=createPanel(this);
            createWidgets(this);
        end

        function[id,str]=validateDoubleProperty(~,~,~)
            id='';
            str='';
        end

        function h=getMinimumHeight(this)
            [~,h]=getMinimumSize(this.Layout);
        end

        function spec=getSpecification(this)
            spec=getCurrentSpecification(this.Dialog);
        end

        function setProperty(this,varargin)
            setProperty(this.Dialog,varargin{:});
        end

        function errorMessage(this,varargin)
            errorMessage(this.Dialog,varargin{:});
        end

        function warningMessage(this,varargin)
            warningMessage(this.Dialog,varargin{:});
        end

        function w=getLabelMinimumWidth(~)
            w=0;
        end

        function edit=createEdit(this,varargin)
            edit=createEdit(this.Dialog,varargin{:});
        end

        function topInset=getTopInset(~)
            topInset=-3;
        end
        function rightInset=getRightInset(~)
            rightInset=-2;
        end
        function leftInset=getLeftInset(~)
            leftInset=0;
        end
    end

    methods(Hidden)

        function defaultCheckboxCallback(this,varargin)
            defaultCheckboxCallback(this.Dialog,varargin{:});
        end

        function toggleShowCallback(this,varargin)
            toggleShowCallback@driving.internal.scenarioApp.UITools(this,varargin{:});
            notify(this,'HeightChanged');
        end

        function defaultEditboxCallback(this,varargin)
            defaultEditboxCallback(this.Dialog,varargin{:});
        end

        function num=strToNum(this,str)
            num=strToNum(this.Dialog,str);
        end

        function varargout=getErrorMessageString(this,varargin)
            [varargout{1:nargout}]=getErrorMessageString(this.Dialog,varargin{:});
        end
    end

    methods(Access=protected)

        function setVectorProperty(this,propertyName,varargin)
            newValue=zeros(1,numel(varargin));
            for indx=1:numel(newValue)
                newValue(indx)=str2double(this.(varargin{indx}).String);
            end

            setProperty(this,propertyName,newValue);
        end

        function enab=getEnable(this)
            enab=matlabshared.application.logicalToOnOff(this.Dialog.Enabled);
        end

        function setupWidgets(this,spec,name,varargin)
            enable=matlabshared.application.logicalToOnOff(this.Dialog.Enabled);
            setupWidgets@driving.internal.scenarioApp.UITools(this,spec,name,enable,varargin{:});
        end


        function createWidgets(~)

        end

        function b=usingWebFigure(this)
            b=useAppContainer(this.Dialog.Application);
        end
    end
end


