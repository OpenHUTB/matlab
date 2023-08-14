classdef UITablecreation<datacreation.internal.UIDatacreation





    methods(Access='protected')


        function update(obj)

            msg.x=[];
            msg.y=[];

            if~isempty(obj.Value)
                msg.x=table2array(obj.Value(:,1));
                msg.y=table2array(obj.Value(:,2));

            end


            obj.UIDrawScope.setLineData(0,msg,false);
        end


        function validateInput(~,inVal)


            if~istable(inVal)
                error(message('datacreation:datacreation:ucomponentvaluenottable'));
            end
        end


        function outData=constructValueFromData(~,inData)
            x=inData.x;
            y=inData.y;
            outData=table(x,y);
        end


        function outData=constructDataFromValue(~,inData)
            outData.x=table2array(inData(:,1));
            outData.y=table2array(inData(:,2));
        end


        function xData=getSelectedXData(obj,inIndices)
            xData=[];
            if isempty(inIndices)
                xData=obj.Value(:,1);
                xData=xData(inIndices);
            end
        end


        function yData=getSelectedYData(obj,inIndices)
            yData=[];
            if isempty(inIndices)
                yData=obj.Value(:,2);
                yData=yData(inIndices);
            end
        end

    end
end
