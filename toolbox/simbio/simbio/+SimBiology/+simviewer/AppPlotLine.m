










classdef AppPlotLine<hgsetget

    properties(Access=public)
Type
Name


Expression
MathExpression
MathTokens
MathTokenPQN


Time
YData


        Color=[0,0.4470,0.7410];
        LineWidth=0.5;
        LineStyle='-';
        Marker='none';
        MarkerSize=6;
        MarkerEdgeColor='auto';
        MarkerFaceColor='none';
        Visible='on';



        MarkerEdgeColorLine='';
        MarkerFaceColorLine='';
    end

    methods
        function obj=AppPlotLine(type,name)
            obj.Type=type;
            obj.Name=name;
        end
    end
end