function animateQuadrotor(t,x)





    xmin=-7.5;
    xmax=8;
    ymin=-11;
    ymax=7.5;
    zmin=-7.5;
    zmax=7;

    scale_angle=1;

    xm=x(1);
    ym=x(2);
    zm=x(3);
    phi=x(4)*scale_angle;
    theta=x(5)*scale_angle;
    psi=x(6)*scale_angle;

    scale=2.4;
    r=0.1*scale;
    th=0:0.01:2*pi;
    x_cir=r*cos(th);
    y_cir=r*sin(th);

    height=0.1*scale;
    l=0.25*scale;
    rotor1=[x_cir'+l,y_cir',zeros(length(x_cir),1)+height,ones(length(x_cir),1)];
    rotor2=[x_cir'-l,y_cir',zeros(length(x_cir),1)+height,ones(length(x_cir),1)];
    rotor3=[x_cir',y_cir'+l,zeros(length(x_cir),1)+height,ones(length(x_cir),1)];
    rotor4=[x_cir',y_cir'-l,zeros(length(x_cir),1)+height,ones(length(x_cir),1)];

    ax1=[-l,0,0,1;
    l,0,0,1;];
    ax2=[0,-l,0,1;
    0,l,0,1;];

    ver1=[0,-l,0,1;
    0,-l,height,1;];
    ver2=[0,l,0,1;
    0,l,height,1;];
    ver3=[l,0,0,1;
    l,0,height,1;];
    ver4=[-l,0,0,1;
    -l,0,height,1;];




    subplot(1,2,1)
    hold on;




    time=0:0.01:20;
    for i=1:length(time)
        des_traj(i,:)=QuadrotorReferenceTrajectory(time(i));
    end
    target=QuadrotorReferenceTrajectory(t);


    plot3(des_traj(:,1),des_traj(:,2),des_traj(:,3),'r','LineWidth',1)













    rotation=[cos(target(6))*cos(target(5)),cos(target(6))*sin(target(5))*sin(target(4))-sin(target(6))*cos(target(4)),cos(target(6))*sin(target(5))*cos(target(4))+sin(target(6))*sin(target(4));
    sin(target(6))*cos(target(5)),sin(target(6))*sin(target(5))*sin(target(4))+cos(target(6))*cos(target(4)),sin(target(6))*sin(target(5))*cos(target(4))-cos(target(6))*sin(target(4));
    -sin(target(5)),cos(target(5))*sin(target(4)),cos(target(5))*cos(target(4))];



    translation=[target(1);target(2);target(3)];
    transf=[rotation,translation;
    zeros(1,3),1];

    new_rotor1=(transf*rotor1')';
    new_rotor2=(transf*rotor2')';
    new_rotor3=(transf*rotor3')';
    new_rotor4=(transf*rotor4')';
    new_ax1=(transf*ax1')';
    new_ax2=(transf*ax2')';
    new_ver1=(transf*ver1')';
    new_ver2=(transf*ver2')';
    new_ver3=(transf*ver3')';
    new_ver4=(transf*ver4')';


    plot3(new_ax1(:,1)',new_ax1(:,2)',new_ax1(:,3)','k','LineWidth',1);
    plot3(new_ax2(:,1)',new_ax2(:,2)',new_ax2(:,3)','k','LineWidth',1)
    plot3(new_ver1(:,1)',new_ver1(:,2)',new_ver1(:,3)','k','LineWidth',1)
    plot3(new_ver2(:,1)',new_ver2(:,2)',new_ver2(:,3)','k','LineWidth',1)
    plot3(new_ver3(:,1)',new_ver3(:,2)',new_ver3(:,3)','k','LineWidth',1)
    plot3(new_ver4(:,1)',new_ver4(:,2)',new_ver4(:,3)','k','LineWidth',1)

    fill3(new_rotor1(:,1)',new_rotor1(:,2)',new_rotor1(:,3)','w')
    fill3(new_rotor2(:,1)',new_rotor2(:,2)',new_rotor2(:,3)','w')
    fill3(new_rotor3(:,1)',new_rotor3(:,2)',new_rotor3(:,3)','w')
    fill3(new_rotor4(:,1)',new_rotor4(:,2)',new_rotor4(:,3)','w')









    rotation=[cos(psi)*cos(theta),cos(psi)*sin(theta)*sin(phi)-sin(psi)*cos(phi),cos(psi)*sin(theta)*cos(phi)+sin(psi)*sin(phi);
    sin(psi)*cos(theta),sin(psi)*sin(theta)*sin(phi)+cos(psi)*cos(phi),sin(psi)*sin(theta)*cos(phi)-cos(psi)*sin(phi);
    -sin(theta),cos(theta)*sin(phi),cos(theta)*cos(phi)];


    translation=[xm;ym;zm];
    transf=[rotation,translation;
    zeros(1,3),1];

    new_rotor1=(transf*rotor1')';
    new_rotor2=(transf*rotor2')';
    new_rotor3=(transf*rotor3')';
    new_rotor4=(transf*rotor4')';
    new_ax1=(transf*ax1')';
    new_ax2=(transf*ax2')';
    new_ver1=(transf*ver1')';
    new_ver2=(transf*ver2')';
    new_ver3=(transf*ver3')';
    new_ver4=(transf*ver4')';


    plot3(new_ax1(:,1)',new_ax1(:,2)',new_ax1(:,3)','k','LineWidth',2);
    plot3(new_ax2(:,1)',new_ax2(:,2)',new_ax2(:,3)','k','LineWidth',2)
    plot3(new_ver1(:,1)',new_ver1(:,2)',new_ver1(:,3)','k','LineWidth',2)
    plot3(new_ver2(:,1)',new_ver2(:,2)',new_ver2(:,3)','k','LineWidth',2)
    plot3(new_ver3(:,1)',new_ver3(:,2)',new_ver3(:,3)','k','LineWidth',2)
    plot3(new_ver4(:,1)',new_ver4(:,2)',new_ver4(:,3)','k','LineWidth',2)

    fill3(new_rotor1(:,1)',new_rotor1(:,2)',new_rotor1(:,3)',[95,158,160]/255)
    fill3(new_rotor2(:,1)',new_rotor2(:,2)',new_rotor2(:,3)',[95,158,160]/255)
    fill3(new_rotor3(:,1)',new_rotor3(:,2)',new_rotor3(:,3)',[95,158,160]/255)
    fill3(new_rotor4(:,1)',new_rotor4(:,2)',new_rotor4(:,3)',[95,158,160]/255)


    xlabel('x')
    ylabel('y')
    zlabel('z')
    axis equal
    axis([xmin,xmax,ymin,ymax,zmin,zmax])



    view(-104,26)

    box on

    strmin=['t = ',num2str(round(t*100)/100)];
    text(5,5,5,strmin);
    set(gca,'FontSize',15,'fontWeight','bold','YTickLabel',[],...
    'XTickLabel',[],'ZTickLabel',[])
    set(findall(gcf,'type','text'),'fontSize',15,'fontWeight','bold')

    subplot(1,2,2)
    hold on;


    plot3(des_traj(:,1),des_traj(:,2),des_traj(:,3),'r','LineWidth',1)













    rotation=[cos(target(6))*cos(target(5)),cos(target(6))*sin(target(5))*sin(target(4))-sin(target(6))*cos(target(4)),cos(target(6))*sin(target(5))*cos(target(4))+sin(target(6))*sin(target(4));
    sin(target(6))*cos(target(5)),sin(target(6))*sin(target(5))*sin(target(4))+cos(target(6))*cos(target(4)),sin(target(6))*sin(target(5))*cos(target(4))-cos(target(6))*sin(target(4));
    -sin(target(5)),cos(target(5))*sin(target(4)),cos(target(5))*cos(target(4))];



    translation=[target(1);target(2);target(3)];
    transf=[rotation,translation;
    zeros(1,3),1];

    new_rotor1=(transf*rotor1')';
    new_rotor2=(transf*rotor2')';
    new_rotor3=(transf*rotor3')';
    new_rotor4=(transf*rotor4')';
    new_ax1=(transf*ax1')';
    new_ax2=(transf*ax2')';
    new_ver1=(transf*ver1')';
    new_ver2=(transf*ver2')';
    new_ver3=(transf*ver3')';
    new_ver4=(transf*ver4')';


    plot3(new_ax1(:,1)',new_ax1(:,2)',new_ax1(:,3)','k','LineWidth',1);
    plot3(new_ax2(:,1)',new_ax2(:,2)',new_ax2(:,3)','k','LineWidth',1)
    plot3(new_ver1(:,1)',new_ver1(:,2)',new_ver1(:,3)','k','LineWidth',1)
    plot3(new_ver2(:,1)',new_ver2(:,2)',new_ver2(:,3)','k','LineWidth',1)
    plot3(new_ver3(:,1)',new_ver3(:,2)',new_ver3(:,3)','k','LineWidth',1)
    plot3(new_ver4(:,1)',new_ver4(:,2)',new_ver4(:,3)','k','LineWidth',1)

    fill3(new_rotor1(:,1)',new_rotor1(:,2)',new_rotor1(:,3)','w')
    fill3(new_rotor2(:,1)',new_rotor2(:,2)',new_rotor2(:,3)','w')
    fill3(new_rotor3(:,1)',new_rotor3(:,2)',new_rotor3(:,3)','w')
    fill3(new_rotor4(:,1)',new_rotor4(:,2)',new_rotor4(:,3)','w')

















    rotation=[cos(psi)*cos(theta),cos(psi)*sin(theta)*sin(phi)-sin(psi)*cos(phi),cos(psi)*sin(theta)*cos(phi)+sin(psi)*sin(phi);
    sin(psi)*cos(theta),sin(psi)*sin(theta)*sin(phi)+cos(psi)*cos(phi),sin(psi)*sin(theta)*cos(phi)-cos(psi)*sin(phi);
    -sin(theta),cos(theta)*sin(phi),cos(theta)*cos(phi)];





    translation=[xm;ym;zm];
    transf=[rotation,translation;
    zeros(1,3),1];

    new_rotor1=(transf*rotor1')';
    new_rotor2=(transf*rotor2')';
    new_rotor3=(transf*rotor3')';
    new_rotor4=(transf*rotor4')';
    new_ax1=(transf*ax1')';
    new_ax2=(transf*ax2')';
    new_ver1=(transf*ver1')';
    new_ver2=(transf*ver2')';
    new_ver3=(transf*ver3')';
    new_ver4=(transf*ver4')';


    plot3(new_ax1(:,1)',new_ax1(:,2)',new_ax1(:,3)','k','LineWidth',2);
    plot3(new_ax2(:,1)',new_ax2(:,2)',new_ax2(:,3)','k','LineWidth',2)
    plot3(new_ver1(:,1)',new_ver1(:,2)',new_ver1(:,3)','k','LineWidth',2)
    plot3(new_ver2(:,1)',new_ver2(:,2)',new_ver2(:,3)','k','LineWidth',2)
    plot3(new_ver3(:,1)',new_ver3(:,2)',new_ver3(:,3)','k','LineWidth',2)
    plot3(new_ver4(:,1)',new_ver4(:,2)',new_ver4(:,3)','k','LineWidth',2)

    fill3(new_rotor1(:,1)',new_rotor1(:,2)',new_rotor1(:,3)',[95,158,160]/255)
    fill3(new_rotor2(:,1)',new_rotor2(:,2)',new_rotor2(:,3)',[95,158,160]/255)
    fill3(new_rotor3(:,1)',new_rotor3(:,2)',new_rotor3(:,3)',[95,158,160]/255)
    fill3(new_rotor4(:,1)',new_rotor4(:,2)',new_rotor4(:,3)',[95,158,160]/255)




    xlabel('x')
    ylabel('y')
    zlabel('z')
    axis equal
    axis([xmin,xmax,ymin,ymax,zmin,zmax])


    view(50,40)


    box on

    strmin=['t = ',num2str(round(t*100)/100)];
    text(2,5,4,strmin);
    set(gca,'FontSize',15,'fontWeight','bold','YTickLabel',[],...
    'XTickLabel',[],'ZTickLabel',[])
    set(findall(gcf,'type','text'),'fontSize',15,'fontWeight','bold')



    strmin=['Quadrotor tracking an infeasible trajectory'];





    set(gcf,'Position',[1,1,1500,750])

end
