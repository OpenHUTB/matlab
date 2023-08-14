function minorTicks=getMinorTicks(majorTicks,varargin)

    scaleType='Linear';
    if(nargin>1)
        scaleType=varargin{1};
    end

    switch scaleType
    case{'Log'}
        minorTicks=getLogMinorTicks(majorTicks);
    case{'Linear'}
        minorTicks=getLinearMinorTicks(majorTicks);
    end

end


function minorTicks=getLogMinorTicks(majorTicks)



    minorTicks=[];
    len=length(majorTicks);
    for i=1:len-1


        diff=majorTicks(i+1)/majorTicks(i);
        exponent=floor(log10(diff)-1);

        minorTickInterval=majorTicks(i)*(10^exponent);











        minorTicksForThisInterval=[majorTicks(i),...
        minorTickInterval*2:minorTickInterval:majorTicks(i+1)-minorTickInterval];
        minorTicks=[minorTicks,minorTicksForThisInterval];%#ok   
    end
end

function minorTicks=getLinearMinorTicks(majorTicks)

    minorTickInterval=(majorTicks(2)-majorTicks(1))/5;
    partialMinorTicks=majorTicks(1):minorTickInterval:majorTicks(end-1);
    remainingMinorTicks=(majorTicks(end-1)+minorTickInterval):minorTickInterval:majorTicks(end);
    minorTicks=horzcat(partialMinorTicks,remainingMinorTicks);
end