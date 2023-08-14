classdef WidgetBase<handle&matlab.mixin.Heterogeneous

    properties(Constant,Access=private)
        SeparatorFieldnames={'top','right','bottom','left'};
    end

    properties(Dependent)
Type
Position
Separators
Widths
CSH
ShowRunMetrics
HighlightOnHover
    end

    properties(Access=protected)
MF0Widget
    end

    properties(Access=?metric.dashboard.widgets.WidgetContainer)
RepositionFcn
ParentSizeFcn
    end

    methods(Access={?metric.dashboard.WidgetFactory,?metric.dashboard.widgets.WidgetBase})
        function obj=WidgetBase(element)
            obj.MF0Widget=element;
            if isempty(element.Widths.toArray)
                obj.Widths=12;
            end
            if isempty(element.CSH)
                element.CSH=dashboard.ui.CSHInfo(...
                mf.zero.getModel(element));
            end
        end
    end

    methods



        function type=get.Type(this)
            type=this.MF0Widget.Type;
        end



        function pos=get.Position(this)
            pos=double(this.MF0Widget.Position);
        end

        function set.Position(this,num)
            if isscalar(num)&&~isinf(num)&&(floor(num)==num)&&(num>0)
                if num>this.ParentSizeFcn()
                    error(message('dashboard:uidatamodel:PositionOutOfBounds',...
                    num,this.ParentSizeFcn()));
                end

                if this.Position==num
                    return
                end

                this.RepositionFcn(this,num);
            else
                error(message('dashboard:uidatamodel:PositiveInteger'));
            end
        end



        function separators=get.Separators(this)
            sepArr=this.MF0Widget.Separators.toArray();
            if(numel(sepArr)==0)
                separators=[];
                return;
            end
            for i=1:numel(sepArr)
                separators(i)=this.boolarray2struct(sepArr(i));%#ok<AGROW>
            end
        end

        function set.Separators(this,separators)
            if(isempty(separators))
                this.MF0Widget.Separators.clear();
                return;
            end
            if(numel(separators)~=1)&&(numel(separators)~=4)
                error(message('dashboard:uidatamodel:VectorSize'));
            end

            out=arrayfun(@this.struct2boolarray,separators);
            this.MF0Widget.Separators.clear();
            for i=1:numel(out)
                this.MF0Widget.Separators.add(out(i));
            end
        end



        function widths=get.Widths(this)
            widths=this.MF0Widget.Widths.toArray;
        end

        function set.Widths(this,widths)
            if~all((widths>=0)&(widths<=12))||...
                ~all(floor(widths)==widths)
                error(message('dashboard:uidatamodel:WrongWidths'));
            end
            this.widthSetter(widths);
        end



        function csh=get.CSH(this)
            csh=metric.dashboard.CSH(this.MF0Widget.CSH);
        end



        function out=get.ShowRunMetrics(this)
            out=this.MF0Widget.ShowRunMetrics;
        end

        function set.ShowRunMetrics(this,val)
            metric.dashboard.Verify.LogicalOrDoubleOneZero(val);
            this.MF0Widget.ShowRunMetrics=val;
        end



        function out=get.HighlightOnHover(this)
            out=this.MF0Widget.HighlightOnHover;
        end

        function set.HighlightOnHover(this,val)
            metric.dashboard.Verify.LogicalOrDoubleOneZero(val);
            this.MF0Widget.HighlightOnHover=val;
        end


        function verify(this)
            if(double(isempty(this.CSH.AnchorID))+double(isempty(this.CSH.MapKey)))==1
                error(message('dashboard:uidatamodel:CSHIncomplete',this.CSH.MapKey,this.CSH.AnchorID));
            end
        end

    end

    methods(Hidden)
        function uuid=getUUID(obj)
            uuid=obj.MF0Widget.UUID;
        end
    end

    methods(Access=?metric.dashboard.widgets.WidgetContainer)

        function w=getMF0Widget(this)
            w=this.MF0Widget;
        end

    end

    methods(Access=private)

        function widthSetter(this,widths)
            if numel(widths)==1
                widths=repmat(widths,4,1);
            end

            if numel(widths)~=4
                error(message('dashboard:uidatamodel:VectorSize'));
            end

            this.MF0Widget.Widths.clear;
            for i=1:numel(widths)
                this.MF0Widget.Widths.add(uint32(widths(i)));
            end
        end

        function boolArray=struct2boolarray(this,sepa)

            if~isstruct(sepa)
                error(message('dashboard:uidatamodel:WrongInputType',...
                'struct'));
            end

            if~all(isfield(sepa,this.SeparatorFieldnames))
                error(message('dashboard:uidatamodel:MissingFields',...
                sprintf('[%s\b\b]',sprintf('"%s", ',this.SeparatorFieldnames{:}))));
            end

            boolArray=dashboard.ui.BoolArray(mf.zero.getModel(this.MF0Widget));
            for i=1:4
                val=sepa.(this.SeparatorFieldnames{i});
                metric.dashboard.Verify.LogicalOrDoubleOneZero(val);
                boolArray.array.add(logical(val));
            end
        end

        function sepa=boolarray2struct(this,boolArray)
            sepa=cell2struct(num2cell(double(boolArray.array.toArray)),...
            this.SeparatorFieldnames,2);
        end

    end

end
