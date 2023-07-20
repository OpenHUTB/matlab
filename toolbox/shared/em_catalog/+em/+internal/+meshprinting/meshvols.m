function V=meshvols(P,T)




    P1=P(T(:,1),:);
    P2=P(T(:,2),:);
    P3=P(T(:,3),:);
    P4=P(T(:,4),:);
    V=1/6*abs(dot(P2-P1,cross(P3-P1,P4-P1,2),2));

end
