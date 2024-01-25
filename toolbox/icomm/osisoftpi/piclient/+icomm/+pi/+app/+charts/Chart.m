classdef(Abstract)Chart<icomm.pi.app.Container

    properties(GetAccess=public,SetAccess=public,Dependent)
        Data timetable
        Overlay(1,1)logical
    end

    properties(GetAccess=protected,SetAccess=protected,Dependent)
        NumAxes(1,1)double
    end

    properties(GetAccess=protected,SetAccess=protected)
        Data_ timetable
        Overlay_(1,1)logical
    end

    properties(GetAccess=private,SetAccess=private)
        AxesLayout icomm.pi.app.AxesLayout
    end


    methods

        function value=get.Data(this)
            value=this.Data_;
        end


        function set.Data(this,value)
            this.Data_=value;
            this.update();
        end


        function value=get.Overlay(this)
            value=this.Overlay_;
        end


        function set.Overlay(this,value)
            if~isequal(value,this.Overlay_)
                this.Overlay_=value;
                this.update();
            end
        end


        function value=get.NumAxes(this)
            value=this.AxesLayout.NumAxes;
        end


        function set.NumAxes(this,value)
            this.AxesLayout.NumAxes=value;
        end

    end


    methods(Access=public)

        function this=Chart(varargin)
            parser=inputParser();
            parser.KeepUnmatched=true;
            parser.addParameter('GraphicsType','web',...
            @(x)validateattributes(x,{'char','string'},{'scalartext'}));
            parser.parse(varargin{:});
            inputs=parser.Results;
            thisLayout=icomm.pi.app.(inputs.GraphicsType).AxesLayout(...
            'Parent',[]);
            propIndex=find(cellfun(@(x)isequal(convertCharsToStrings(x),"GraphicsType"),varargin),1,'first');
            if~isempty(propIndex)
                varargin([propIndex,propIndex+1])=[];
            end
            this@icomm.pi.app.Container(thisLayout.UiContainer,varargin{:});
            this.AxesLayout=thisLayout;
        end


        function delete(this)
            delete(this.UiContainer);
        end

    end


    methods(Abstract,Access=protected)
        update(this)
    end


    methods(Access=protected)

        function thisAxes=getAxes(this,varargin)
            thisAxes=this.AxesLayout.getAxes(varargin{:});
        end

    end

end