function[D,IND]=inter2_point_seg(P,e,q)



















    if size(P,2)==2;
        P(:,3)=0;
    end
    if size(q,2)==2;
        q(:,3)=0;
    end

    Q=repmat(q,size(e,1),1);
    P1=P(e(:,1),:);
    P2=P(e(:,2),:);
    temp=cross(P2-P1,Q-P1,2);
    D=sqrt(dot(temp,temp,2)./dot(P2-P1,P2-P1,2));
    IND=sign(dot(Q-P1,Q-P2,2));
end