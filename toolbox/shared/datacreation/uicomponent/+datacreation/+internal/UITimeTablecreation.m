classdef UITimeTablecreation<datacreation.internal.UIDatacreation





    methods(Access='protected')


        function update(obj)

            msg.x=[];
            msg.y=[];

            if~isempty(obj.Value)

                x=timetable2table(obj.Value);


                msg.x=double(seconds(table2array(x(:,1))));
                msg.y=obj.Value{:,1};

            end


            obj.UIDrawScope.setLineData(0,msg,false);
        end


        function validateInput(~,inVal)


            if~istimetable(inVal)
                error(message('datacreation:datacreation:ucomponentvaluenottimetable'));
            end
        end


        function outData=constructValueFromData(~,inData)
            x=inData.x;
            y=inData.y;
            outData=timetable(seconds(x),y);
        end


        function outData=constructDataFromValue(~,inData)
            x=timetable2table(inData);


            outData.x=double(seconds(table2array(x(:,1))));
            outData.y=inData{:,1};
        end


        function xData=getSelectedXData(obj,inIndices)
            xData=[];
            if isempty(inIndices)
                xData=timetable2table(obj.Value);
                xData=double(seconds(xData(:,1)));
                xData=xData(inIndices);
            end
        end


        function yData=getSelectedYData(obj,inIndices)
            yData=[];
            if isempty(inIndices)
                yData=timetable2table(obj.Value);
                yData=double(seconds(yData(:,2)));
                yData=yData(inIndices);
            end
        end

    end
end
