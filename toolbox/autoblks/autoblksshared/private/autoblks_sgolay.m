function[ydot,yddot]=autoblks_sgolay(y,dt,N,F)









    b=fliplr(vander(-(F-1)/2:(F-1)/2));
    B=b(:,1:N+1);
    W=eye(F,'double');
    [~,R]=qr(sqrt(W)*B,0);

    G=(B/R)*inv(R)';

    HalfWin=((F+1)/2)-1;
    yprime=zeros(length(y),1);
    ypprime=yprime;

    for n=(F+1)/2:length(y)-(F+1)/2,




        yprime(n)=dot(G(:,2),y(n-HalfWin:n+HalfWin));


        ypprime(n)=2*dot(G(:,3)',y(n-HalfWin:n+HalfWin))';
    end

    ydot=yprime./dt;
    yddot=ypprime./(dt.*dt);