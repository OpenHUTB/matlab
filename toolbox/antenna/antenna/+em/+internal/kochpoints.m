function finalPoints=kochpoints(length,iteration,varargin)











    w1=[1/3,0,0;0,1/3,0;0,0,1];
    w2=[(1/3)*cos(pi/3),-(1/3)*sin(pi/3),1/3;(1/3)*sin(pi/3)...
    ,(1/3)*cos(pi/3),0;0,0,1];
    w3=[(1/3)*cos(pi/3),(1/3)*sin(pi/3),cos(pi/3);...
    -(1/3)*sin(pi/3),(1/3)*cos(pi/3),(1/3)*sin(pi/3);0,0,1];
    w4=[1/3,0,2/3;0,1/3,0;0,0,1];
    v1=[0,1;0,0;1,1];

    for i=1:iteration
        y1a=w1*v1;
        y2a=w2*v1;
        y3a=w3*v1;
        y4a=w4*v1;
        y=[y1a,y2a,y3a,y4a];
        v1=y;
    end

    y=length*y(1:2,:);



    if nargin==2
        y=y';
        middle=y(2:2:end-1,:);
        y=[y(1,:);middle;y(end,:)];
        finalPoints=y;
    elseif nargin==3
        width=varargin{1};
        [~,c]=size(y);
        fixed_point=[];

        k=0.86592857142857;
        width=(width*(3^iteration))/(length*k);

        for i=1:2:c-3
            vector1=[y(1,i)-y(1,i+1);y(2,i)-y(2,i+1)];
            vector2=[y(1,i+3)-y(1,i+2);y(2,i+3)-y(2,i+2)];
            A=vector1;
            B=vector2;
            angle=acos(dot(A,B)/(norm(A)*norm(B)))*180/pi;
            angle=round(angle);

            if angle==120
                point=(A+B)*width;
            else
                point=-(A+B)*width;
            end
            fixed_point=[fixed_point,point+y(:,i+1)];%#ok<AGROW>
        end





        y=y';
        middle=y(2:2:end-1,:);
        y=[y(1,:);middle;y(end,:)];
        fixed_point=fixed_point';
        fixed_point=flipud(fixed_point);


        y_width1=fixed_point(1,2);
        x_width1=y(end,1);
        pointWidth1=[x_width1,y_width1];

        y_width2=fixed_point(end,2);
        x_width2=y(1,1);
        pointWidth2=[x_width2,y_width2];

        fixed_point=[pointWidth1;fixed_point;pointWidth2];
        finalPoints=[y;fixed_point];
    end
end