classdef Points






    properties
        XData(:,:)double=nan
        YData(:,:)double=nan
        ZData(:,:)double=nan
    end

    methods
        function obj=Points(XData,YData,ZData)
            obj.XData=XData;
            obj.YData=YData;
            obj.ZData=ZData;
        end

        function value=getZMax(obj)
            value=nan;
            for objIdx=1:length(obj)
                objIdxValue=max(max(obj(objIdx).ZData));
                value=max([value,objIdxValue]);
            end
        end

        function value=getZMin(obj)
            value=nan;
            for objIdx=1:length(obj)
                objIdxValue=min(min(obj(objIdx).ZData));
                value=min([value,objIdxValue]);
            end
        end
    end
end