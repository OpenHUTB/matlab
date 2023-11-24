patch([0,1,1,0,0],[0,0,1,1,0],[1,1,1])

plot([.2,.30,.30,.62],[.25,.25,.45,.55])
plot([.6,.83],[.70,.70])
plot([.6,.83],[.32,.32])
plot([.2,.45],[.70,.70])
plot([.45,.45],[.70,.55])
plot([.42,.45,.48],[.63,.55,.63])
radius=.03;
x=-radius:.01:radius;
y=real(sqrt(radius^2-x.^2));
patch([x,-x]+.60,[y,-y]+.70,[0,0,0])
patch([x,-x]+.30,[y,-y]+.45,[0,0,0])
patch([x,-x]+.60,[y,-y]+.32,[0,0,0])