function[trafficNetwork,pos]=trafficNetworkReservation(trafficNetwork,destinationName,reservationSize,dir,maxIter)
    if nargin<4
        dir=[1,0];
    end
    if~all(dir==[1,0])&&~all(dir==[-1,0])&&~all(dir==[0,1])&&~all(dir==[0,-1])
        error("Cardinal direction must be specified.")
    end
    destinationName=round(destinationName);
    reservationSize=ceil(reservationSize);
    exactReservation=[destinationName-reservationSize/2,reservationSize];
    displacement=[0,0];
    currentReservation=exactReservation;
    blocked=true;
    ringCount=0;
    limits=[-inf,inf];
    iter=0;
    while blocked
        iter=iter+1;
        if iter>maxIter
            break;
        end
        if(dir(1)~=0&&displacement(2)>limits(1)&&displacement(2)<limits(2))||(dir(2)~=0&&displacement(1)>limits(1)&&displacement(1)<limits(2))
            if isempty(trafficNetwork.ResList)
                blocked=false;
            else
                blocked=any(rectint(trafficNetwork.ResList,currentReservation)>10^-3);
            end
            if~blocked
                xNodes=ceil(currentReservation(1)):floor(currentReservation(1)+currentReservation(3));
                yNodes=ceil(currentReservation(2)):floor(currentReservation(2)+currentReservation(4));
                if xNodes(1)<0||xNodes(end)>size(trafficNetwork.Map,1)||yNodes(1)<0||yNodes(end)>size(trafficNetwork.Map,2)
                    blocked=true;
                else
                    for ii=1:length(xNodes)
                        for jj=1:length(yNodes)
                            if dir(1)~=0&&~trafficNetwork.Map(xNodes(ii)+1,yNodes(jj)+1).North&&yNodes(jj)<limits(2)&&displacement(2)>0
                                limits=[limits(1),displacement(2)];
                            end
                            if dir(1)~=0&&~trafficNetwork.Map(xNodes(ii)+1,yNodes(jj)+1).South&&yNodes(jj)>limits(1)&&displacement(2)<0
                                limits=[displacement(2),limits(2)];
                            end
                            if dir(2)~=0&&~trafficNetwork.Map(xNodes(ii)+1,yNodes(jj)+1).East&&xNodes(ii)<limits(2)&&displacement(1)>0
                                limits=[limits(1),displacement(1)];
                            end
                            if dir(2)~=0&&~trafficNetwork.Map(xNodes(ii)+1,yNodes(jj)+1).West&&xNodes(ii)>limits(1)&&displacement(1)<0
                                limits=[displacement(1),limits(2)];
                            end
                            if~trafficNetwork.Map(xNodes(ii)+1,yNodes(jj)+1).North&&~trafficNetwork.Map(xNodes(ii)+1,yNodes(jj)+1).East&&~trafficNetwork.Map(xNodes(ii)+1,yNodes(jj)+1).South&&~trafficNetwork.Map(xNodes(ii)+1,yNodes(jj)+1).West
                                blocked=true;
                                break;
                            end
                        end
                        if blocked
                            break;
                        end
                    end
                end
            end
        end
        if blocked

            if dir(1)==0
                if displacement(1)>0
                    displacement=[-displacement(1),displacement(2)];
                else
                    displacement=[-displacement(1)+1,displacement(2)];
                end
            else
                if displacement(2)>0
                    displacement=[displacement(1),-displacement(2)];
                else
                    displacement=[displacement(1),-displacement(2)+1];
                end
            end
            if any(abs(displacement)>ringCount)
                ringCount=ringCount+1;
                displacement=dir*ringCount;
                limits=[-inf,inf];
            end
            currentReservation=exactReservation+[displacement.*reservationSize,0,0];
        end
    end
    if iter<=maxIter
        trafficNetwork.ResList=[trafficNetwork.ResList;currentReservation];
        pos=currentReservation(1:2)+reservationSize/2;
    else
        pos=[NaN,NaN];
    end
end
function[trafficNetwork,gotRes]=getExactReservation(trafficNetwork,destinationName)
    exactReservation=[destinationName-trafficNetwork.AgentRadius,trafficNetwork.AgentRadius*2,trafficNetwork.AgentRadius*2];
    gotRes=true;
    for ii=1:size(trafficNetwork.ResList,1)
        if rectint(trafficNetwork.ResList(ii,:),exactReservation)>0
            gotRes=false;
            return;
        end
    end
    trafficNetwork.ResList(end+1,:)=exactReservation;
end
function res=isReserved(trafficNetwork,destinationName)
    exactReservation=[destinationName-trafficNetwork.AgentRadius,trafficNetwork.AgentRadius*2,trafficNetwork.AgentRadius*2];
    res=false;
    for ii=1:size(trafficNetwork.ResList,1)
        if rectint(trafficNetwork.ResList(ii,:),exactReservation)>0
            res=true;
            return;
        end
    end
end
function trafficNetwork=clearReservation(trafficNetwork,destinationName)
    exactReservation=[destinationName-trafficNetwork.AgentRadius,trafficNetwork.AgentRadius*2,trafficNetwork.AgentRadius*2];
    for ii=1:size(trafficNetwork.ResList,1)
        if rectint(trafficNetwork.ResList(ii,:),exactReservation)>0
            trafficNetwork.ResList=[trafficNetwork.ResList(1:ii-1,:);trafficNetwork.ResList(ii+1:end,:)];
            return;
        end
    end
end