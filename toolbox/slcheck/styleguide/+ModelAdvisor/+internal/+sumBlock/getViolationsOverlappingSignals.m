function violations=getViolationsOverlappingSignals(sumBlock)


    violations=[];

    if isempty(sumBlock)
        return;
    end

    inports=sumBlock.LineHandles.Inport;
    if isempty(inports)
        return;
    end



    inports=inports(arrayfun(@(x)x>0,inports));

    if isempty(inports)||(size(inports,1)==1&&size(inports,2)==1)
        return;
    end


    data=get_param(inports,'object');

    yPoints=cellfun(@(x)x.Points(end),data);

    signalHandles=cellfun(@(x)x.Handle,data);
    signalEndpoints=sortrows([signalHandles,yPoints],2);




    for sCount=1:length(signalEndpoints)-1



        if(signalEndpoints(sCount+1,2)-signalEndpoints(sCount,2))<10
            violations=[violations;signalEndpoints(sCount,1);...
            signalEndpoints(sCount+1,1)];%#ok<AGROW>
        end
    end

    violations=unique(violations);
end