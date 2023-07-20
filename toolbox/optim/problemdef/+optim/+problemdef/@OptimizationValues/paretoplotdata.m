function[xData,yData,zData,xLabel,yLabel,zLabel]=paretoplotdata(obj,objIndex)







    objNames=string(fieldnames(obj.ObjectiveSize))';
    numObjNames=numel(objNames);

    if numObjNames==1


        if isempty(objIndex)
            objIndex=1:3;
        end


        objLabel=objNames(1);
        xLabel=string(objLabel)+"("+objIndex(1)+")";
        yLabel=string(objLabel)+"("+objIndex(2)+")";
        objData=obj.Values.(objLabel);
        xData=objData(objIndex(1),:);
        yData=objData(objIndex(2),:);


        if size(objData,1)>2&&numel(objIndex)>2
            zLabel=string(objLabel)+"("+objIndex(3)+")";
            zData=objData(objIndex(3),:);
        else
            zLabel=strings(0,0);
            zData=[];
        end

    else


        if isempty(objIndex)
            xLabel=objNames(1);
            yLabel=objNames(2);
        elseif isnumeric(objIndex)
            xLabel=objNames(objIndex(1));
            yLabel=objNames(objIndex(2));
        else

            objIndex=string(objIndex);
            xLabel=objIndex(1);
            yLabel=objIndex(2);
        end
        xData=obj.Values.(xLabel);
        yData=obj.Values.(yLabel);


        if numObjNames>2
            if numel(objIndex)==2
                zLabel=strings(0,0);
                zData=[];
            elseif isempty(objIndex)
                zLabel=objNames(3);
                zData=obj.Values.(zLabel);
            elseif isnumeric(objIndex)
                zLabel=objNames(objIndex(3));
                zData=obj.Values.(zLabel);
            else


                zLabel=objIndex(3);
                zData=obj.Values.(zLabel);
            end
        else
            zLabel=strings(0,0);
            zData=[];
        end

    end
