function data=exportToMatrix(this,varInfo)


    if~isempty(varInfo.Children)



        numberPoints=this.getSignalTmNumPoints(varInfo.Children(1).signalID);

        data=zeros(numberPoints,length(varInfo.Children));
        for idx=1:length(varInfo.Children)
            dataValues=this.getSignalObject(varInfo.Children(idx).signalID).Values;
            data(:,idx)=dataValues.Data;
        end
    else

        dataValues=this.getSignalObject(varInfo.signalID).Values;
        data=dataValues.Data(:);
    end
