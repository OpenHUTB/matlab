function[xData,yData]=generate_repeating_data(startTime,stopTime,T,xNorm,yNorm,firstY,lastY)






    n=ceil(stopTime/T)+1;
    nsub=length(xNorm);
    xData=(xNorm(:)*ones(1,n))+(ones(nsub,1))*(0:(n-1));
    yData=yNorm(:)*ones(1,n);
    xData=(xData(:)'*T);
    yData=yData(:)';


    I_remove=find(xData<startTime|stopTime<xData);
    xData(I_remove)=[];
    yData(I_remove)=[];


    if~isempty(xData)
        if(xData(1)~=startTime)
            xData(2:end+1)=xData(1:end);
            xData(1)=startTime;
            yData(2:end+1)=yData(1:end);
            yData(1)=firstY;
        end

        if(xData(end)~=stopTime)
            xData(end+1)=stopTime;
            yData(end+1)=lastY;
        end
    end