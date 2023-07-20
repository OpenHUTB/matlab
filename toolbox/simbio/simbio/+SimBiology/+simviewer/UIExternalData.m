










classdef UIExternalData<hgsetget

    properties(Access=public)
        Data=[];
        ColumnNames={};
        Name='';
        Color=[0,0.4470,0.7410];
        LineStyle='-';
        LineWidth=0.5;
        Marker='none';
        MarkerSize=6;
        MarkerEdgeColor='auto';
        MarkerFaceColor='none';
        SourceName='';
        Time='';
        Y='';
        Visible='on';



        MarkerEdgeColorLine='';
        MarkerFaceColorLine='';
    end

    methods
        function obj=UIExternalData(name)
            obj.Name=name;
        end
    end
end