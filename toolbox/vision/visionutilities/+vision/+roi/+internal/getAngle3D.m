function[center,r,theta]=getAngle3D(pos)












    diffVec=diff(pos);

    center=[mean(pos(:,1)),mean(pos(:,2)),mean(pos(:,3))];


    r=hypot(hypot(diffVec(1),diffVec(2)),diffVec(3))/2;






    alpha=acosd(diffVec(1)/(2*r));
    beta=acosd(diffVec(2)/(2*r));
    gamma=acosd(diffVec(3)/(2*r));



    theta=[alpha,beta,gamma];

end