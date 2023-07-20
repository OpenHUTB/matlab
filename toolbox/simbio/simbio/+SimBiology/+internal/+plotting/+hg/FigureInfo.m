classdef FigureInfo<SimBiology.internal.plotting.hg.HGObjectInfo

    properties(Access=public)
        name='';
        id=[];
    end




    methods(Access=public)
        function obj=FigureInfo(input)
            if nargin>0
                if isstruct(input)
                    obj.handle=obj.returnValidHandle(input.handle);
                    obj.props=SimBiology.internal.plotting.hg.FigureProperties(input.props);
                    obj.name=input.name;
                    obj.id=input.id;
                else
                    obj.handle=obj.returnValidHandle(input);
                    obj.props=SimBiology.internal.plotting.hg.FigureProperties();
                end
            else
                obj.props=SimBiology.internal.plotting.hg.FigureProperties();
            end
        end

        function info=getStruct(obj)

            info=arrayfun(@(fig)struct('handle',fig.convertHandleToDouble(),...
            'props',fig.props.getStruct(),...
            'name',fig.name,...
            'id',fig.id),obj);

            info=[info(:)];
        end

        function h=getEmptyHandle(obj)
            h=matlab.ui.Figure.empty;
        end
    end




    methods(Access=public)
        function resetProps(obj)
            arrayfun(@(fig)set(fig,'props',SimBiology.internal.plotting.hg.FigureProperties()),obj);
        end

        function resetLabels(obj,resetTitle)
            arrayfun(@(fig)fig.props.resetLabels(resetTitle),obj);
        end
    end

end