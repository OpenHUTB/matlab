classdef UITimeseriescreation<datacreation.internal.UIDatacreation





    methods(Access='protected')


        function update(obj)

            msg.x=[];
            msg.y=[];

            if~isempty(obj.Value)




                msg.x=obj.Value.Time;
                msg.y=obj.Value.Data;

            end


            obj.UIDrawScope.setLineData(0,msg,false);
        end


        function validateInput(~,inVal)


            if~isa(inVal,'timeseries')||(~isvector(inVal.Time)&&~isvector(inVal.Data))
                error(message('datacreation:datacreation:ucomponentvaluenottimeseries'));
            end
        end


        function outData=constructValueFromData(~,inData)
            x=inData.x;
            y=inData.y;
            outData=timeseries(y,x);
        end


        function outData=constructDataFromValue(~,inData)
            outData.x=inData.Time;
            outData.y=inData.Data;
        end


        function xData=getSelectedXData(obj,inIndices)
            xData=[];
            if isempty(inIndices)
                xData=obj.Value.Time(inIndices);
            end
        end


        function yData=getSelectedYData(obj,inIndices)
            yData=[];
            if isempty(inIndices)
                yData=obj.Value.Data(inIndices);
            end
        end

    end
end
