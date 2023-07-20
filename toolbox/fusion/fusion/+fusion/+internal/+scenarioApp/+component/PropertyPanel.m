classdef PropertyPanel<fusion.internal.scenarioApp.component.BaseComponent&...
    fusion.internal.scenarioApp.component.UITools&...
    matlabshared.application.ComponentBanner


    properties
        Enabled=true
    end

    properties(SetAccess=protected,Hidden)
Layout
    end

    methods

        function this=PropertyPanel(varargin)
            this@fusion.internal.scenarioApp.component.BaseComponent(varargin{:});
        end
    end

    methods(Hidden)

        function vector=getVectorFromWidgets(this,varargin)
            vector=zeros(1,numel(varargin));
            for index=1:numel(varargin)
                vector(index)=str2double(this.(varargin{index}).String);
            end
        end

        function updateShowProperties(this)
            fig=this.Figure;
            checkboxes=findall(fig,'style','checkbox');
            tags=get(checkboxes,'Tag');
            objs=checkboxes(strncmp(tags,'Show',4));
            props=tags(strncmp(tags,'Show',4));
            model=this.Application.ViewModel.(this.getTag);

            for i=1:numel(objs)
                this.(props{i})=model.(props{i});
                objs(i).Value=this.(props{i});
            end

        end

    end

    methods(Access=protected)

        function str=getLabelString(this,tag)
            str=msgString(this,tag);
        end
    end

    methods(Access=protected)

        function nextRow=insertPanel(this,layout,panelTag,nextRow,type)

            if nargin<5
                type='';
            end
            panel=this.(['h',type,panelTag,'Panel']);
            if this.(['Show',panelTag])
                if~contains(layout,panel)
                    grid=layout.Grid;
                    if size(grid,1)>=nextRow&&any(~isnan(grid(nextRow,:)))
                        insert(layout,'row',nextRow);
                    end
                    add(layout,panel,nextRow,[1,size(layout.Grid,2)],...
                    'Fill','Both',...
                    'TopInset',1,...
                    'BottomInset',2,...
                    'LeftInset',10);
                end
                [~,h]=getMinimumSize(this.([panelTag,'Layout']));
                layout.setConstraints(nextRow,[1,size(layout.Grid,2)],...
                'MinimumHeight',h);
                nextRow=nextRow+1;
                vis='on';
            else
                if contains(layout,panel)
                    remove(layout,panel);
                    clean(layout);
                end
                vis='off';
            end
            panel.Visible=vis;
        end

        function toggles=findToggles(this)
            if usingWebFigure(this)

                toggles=findall(this.Figure,'Type','uiimage');
            else

                toggles=findall(this.Figure,'style','checkbox');
            end
            tags=get(toggles,'Tag');
            toggles=toggles(strncmp(tags,'Show',4));
        end

        function objs=getCDataObjects(this,toggles)
            objs=gobjects(size(toggles));
            for i=1:numel(toggles)
                if usingWebFigure(this)
                    objs(i)=toggles(i).Parent;
                else
                    objs(i)=toggles(i);
                end
            end
        end

        function configureCDataObjects(this,objs,toggles)
            if usingWebFigure(this)
                for i=1:numel(toggles)
                    tag=toggles(i).Tag;
                    propName=tag(1:end-length('Image'));
                    setappdata(objs(i),'Value',this.(propName));
                end
            end
        end

        function setAllToggleCData(this)





            toggles=findToggles(this);


            cDataObjs=getCDataObjects(this,toggles);


            configureCDataObjects(this,cDataObjs,toggles);


            for i=1:numel(cDataObjs)
                matlabshared.application.setToggleCData(cDataObjs(i));
            end
        end
    end

    methods(Abstract)
        update(this);
        tag=getTag(this);
    end

    methods(Abstract,Access=protected)
        createFigure(this);
    end


    methods(Access=protected)
        function fail=validateNonNegativeProperty(~,value)
            fail=false;
            try
                validateattributes(value,{'numeric'},{'real','nonnan','finite','nonnegative','scalar'});
            catch
                fail=true;
            end
        end

        function fail=validateNumericProperty(~,value)
            fail=false;
            try
                validateattributes(value,{'numeric'},{'real','nonnan','finite','scalar'});
            catch
                fail=true;
            end
        end

        function fail=validateProbability(~,value)
            fail=false;
            try
                validateattributes(value,{'double'},{'scalar','real','>',0,'<=',1})
            catch
                fail=true;
            end
        end

        function fail=validateFAR(~,value)
            fail=false;
            try
                validateattributes(value,{'double'},{'scalar','finite','real','>=',1e-7,'<=',1e-3});
            catch
                fail=true;
            end
        end
    end
end