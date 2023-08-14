function[pProbe,tProbe]=meshProbe(obj,S,FeedPoints,Wfeed)




    numSections=ceil(S/Wfeed);


    FeedPoints=FeedPoints';


    if ismembertol(FeedPoints(2,1),FeedPoints(2,2),1e-12,'ByRows',true)

        feedloc=[mean(FeedPoints(1,:)),FeedPoints(2,1)];

        axispt1=[0,0,0;0,0,0];axispt2=[0,1,0;0,0,1];
        ang=[90,90];

    elseif ismembertol(FeedPoints(1,1),FeedPoints(1,2),1e-12,'ByRows',true)

        feedloc=[FeedPoints(1,1),mean(FeedPoints(2,:))];
        axispt1=[0,0,0];axispt2=[0,1,0];
        ang=90;
    end


    translateV=[feedloc,S/2];


    if~isequal(S/2,FeedPoints(3,1))
        translateV=[0,0,S/2;feedloc,FeedPoints(3,1)-S];
    end
    [pProbe,tProbe]=getStripMesh(obj,S,Wfeed,numSections+1,...
    ang,axispt1',axispt2',translateV');
end
