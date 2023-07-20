classdef UITools<matlabshared.application.UITools

    methods(Access=protected)
        function string=getLabelString(~,tag)
            string=getString(message(['driving:scenarioApp:',tag,'Label']));
        end

        function b=usingWebFigure(this)
            b=useAppContainer(this.Application);
        end

        function tag=getWidgetTagPrefix(this)
            tag=class(this);
            tag=[tag(30:end),'.'];
        end
    end

    methods(Hidden)
        function prop=getPropertyFromTag(~,tag)
            indx=find(tag=='.',1,'last');
            if isempty(indx)
                prop=tag;
            else
                prop=tag(indx+1:end);
            end
        end
    end
end


