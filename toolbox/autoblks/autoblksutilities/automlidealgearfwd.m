function[y,xdot]=automlidealgearfwd(u,x,N,J1,J2,b1,b2,dirSwitch)


%#codegen
    coder.allowpcode('plain')
    if dirSwitch
        gearDir=1;
    else
        gearDir=-1;
    end
    A=[0,0,0,0;0,0,0,0;0,0,0,1;0,0,0,-(b1*N^2+b2)/(J1*N^2+J2)];
    B=[0,0;0,0;0,0;gearDir*N/(J1*N^2+J2),1/(J1*N^2+J2)];
    C=[0,0,gearDir*N,0;...
    0,0,0,gearDir*N;...
    0,0,1,0;...
    0,0,0,1];
    D=zeros(4,2);

    xdot=A*x+B*u;
    y=C*x+D*u;
end

