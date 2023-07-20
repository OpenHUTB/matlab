classdef FigureProperties<matlab.mixin.SetGet


    methods(Static)
        function const=BACKGROUND_AXES_TAG
            const='labelAxes';
        end
    end

    properties(Access=public)

        AxGrid=[];
        Row=1;
        Column=1;


        Title='';
        XLabel='';
        YLabel='';


        Insets=[10,10,10,10];
        Gap=[4,4];


        LinkedX=true;
        LinkedY=false;
    end




    methods(Access=public)
        function obj=FigureProperties(input)
            if nargin>0
                propNames=properties(obj);
                cellfun(@(prop)set(obj,prop,input.(prop)),propNames);
            end
        end

        function info=getStruct(obj)
            info=struct('Row',obj.Row,...
            'Column',obj.Column,...
            'AxGrid',obj.AxGrid,...
            'Title',obj.Title,...
            'XLabel',obj.XLabel,...
            'YLabel',obj.YLabel,...
            'Insets',obj.Insets,...
            'Gap',obj.Gap,...
            'LinkedX',obj.LinkedX,...
            'LinkedY',obj.LinkedY);
        end
    end




    methods(Access=public)
        function resetLabels(obj,resetTitle)
            if resetTitle
                set(obj,'Title','','XLabel','','YLabel','')
            else
                set(obj,'XLabel','','YLabel','')
            end
        end
    end

end