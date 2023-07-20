classdef AxesProperties<matlab.mixin.SetGet

    properties(Access=public)

        Title='';
        XLabel='';
        YLabel='';


        XGrid='on';
        YGrid='on';
        GridColor='#262626';
        GridLineStyle='-';


        XScale='linear';
        YScale='linear';
        XMax='auto';
        XMin='auto';
        YMax='auto';
        YMin='auto';


        Selected=false;
        IsZoomedX=false;
        IsZoomedY=false;
    end




    methods(Access=public)
        function obj=AxesProperties(input)

            if nargin>0
                if isstruct(input)||isa(input,'SimBiology.internal.plotting.hg.AxesProperties')
                    propNames=properties(obj);
                    cellfun(@(prop)set(obj,prop,input.(prop)),propNames);
                else

                    obj.configureSingleObjectFromAxes(input);
                end
            end
        end

        function info=getStruct(obj)
            info=struct('Title',obj.Title,...
            'XLabel',obj.XLabel,...
            'YLabel',obj.YLabel,...
            'XGrid',obj.XGrid,...
            'YGrid',obj.YGrid,...
            'GridColor',obj.GridColor,...
            'GridLineStyle',obj.GridLineStyle,...
            'XScale',obj.XScale,...
            'YScale',obj.YScale,...
            'XMax',obj.XMax,...
            'XMin',obj.XMin,...
            'YMax',obj.YMax,...
            'YMin',obj.YMin,...
            'Selected',obj.Selected,...
            'IsZoomedX',obj.IsZoomedX,...
            'IsZoomedY',obj.IsZoomedY);
        end
    end

    methods(Access=private)
        function configureSingleObjectFromAxes(obj,input)
            props=struct('Title',SimBiology.internal.plotting.hg.HGObjectInfo.convertLabelCellArray(input.Title.String),...
            'XLabel',SimBiology.internal.plotting.hg.HGObjectInfo.convertLabelCellArray(input.XLabel.String),...
            'YLabel',SimBiology.internal.plotting.hg.HGObjectInfo.convertLabelCellArray(input.YLabel.String),...
            'XGrid',char(input.XGrid),...
            'YGrid',char(input.YGrid),...
            'GridColor',SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertRGBToHex(input.GridColor),...
            'GridLineStyle',input.GridLineStyle,...
            'XScale',input.XScale,...
            'YScale',input.YScale,...
            'XMax','auto',...
            'XMin','auto',...
            'YMax','auto',...
            'YMin','auto',...
            'Selected',SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertOnOffToValue(input.Selected));

            set(obj,props);
        end
    end




    methods(Static)
        function labelProperties=getLabelProperties()
            labelProperties={'Title','XLabel','YLabel'};
        end

        function axesProperties=getAxesProperties()
            axesProperties={'XScale','YScale','XGrid','YGrid','GridColor','GridLineStyle'};
        end
    end

    methods(Access=public)
        function values=getValue(obj,property)
            values=obj.getValueForProperty(property);
        end
    end


    methods(Access=private)
        function value=getValueForProperty(obj,property)
            switch(property)
            case{'XGrid','YGrid','GridLineStyle','XScale','YScale','Selected'}
                value=obj.(property);
            case 'GridColor'
                value=getColorValue(obj,property);
            case{'XMin','XMax','YMin','YMax'}
                value=obj.(property);
                if~strcmp(value,'auto')
                    value=str2num(value);
                end
            end
        end

        function value=getColorValue(obj,property)
            value=SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertHexToRGB(obj.(property));
        end
    end




    methods(Access=public)
        function resetLabels(obj)
            set(obj,'Title','','XLabel','','YLabel','')
        end
    end

end