function[s,g,B,A]=iirparameqDesign(N,G,w0,BW)








%#codegen
    coder.allowpcode('plain');


    narginchk(1,4);

    if nargin<2
        G=3;
    end

    if nargin<3
        w0=0.5;
    end

    if nargin<4
        BW=0.2;
    end

    validateattributes(N,{'numeric'},{'real','finite','scalar','integer','even',...
    'positive'},'iirparameq','N',1);
    validateattributes(G,{'numeric'},{'real','scalar'},...
    'iirparameq','G',2);
    validateattributes(w0,{'numeric'},{'real','finite','scalar','>=',0,'<=',1},...
    'iirparameq','Wo',3);
    validateattributes(BW,{'numeric'},{'real','finite','scalar','>=',0,'<=',1},...
    'iirparameq','BW',4);


    G0=1;
    Gsq=10^(G/10);
    GBsq=(Gsq+1)/2;

    if Gsq==G0

        s=zeros(N/2,6);
        s(:,[1,4])=1;
        g=ones(N/2+1,1);
        B=zeros(ceil(N/4),5);
        B(:,1)=1;
        A=B;
        return;
    end


    [B,A]=hpeq(N/2,G0,Gsq,GBsq,w0,BW);


    [s,g]=dsp.internal.fos2sos(B,A);


    function[B,A]=hpeq(N,G0,G,GB,w0,BW)


        r=rem(N,2);L=(N-r)/2;

        WB=tan(pi.*BW/2);
        e=sqrt((G-GB)/(GB-G0));

        g=G.^(1/(2.*N));g0=G0^(1/(2.*N));


        a=e^(1/N);
        b=g0*a;


        if r==0
            offset=0;
        else
            offset=1;
        end

        Ba=zeros(L+offset,3);
        Aa=zeros(L+offset,3);

        if r~=0
            Ba(1,:)=[g*WB,b,0];
            Aa(1,:)=[WB,a,0];
        end

        if L>0
            i=(1:L)';
            ui=(2*i-1)/N;
            si=sin(pi*ui/2);
            v=ones(L,1);

            Ba(offset+i,:)=[g^2*WB^2*v,2*g*b*si*WB,b^2*v];
            Aa(offset+i,:)=[WB^2*v,2*a*si*WB,a^2*v];
        end

        [B,A]=blt(Ba,Aa,w0);


        function[B,A]=blt(Ba,Aa,w0)


            K=size(Ba,1);

            B=zeros(K,5);A=zeros(K,5);
            Bhat=zeros(K,3);Ahat=zeros(K,3);

            B0=Ba(:,1);B1=Ba(:,2);B2=Ba(:,3);
            A0=Aa(:,1);A1=Aa(:,2);A2=Aa(:,3);

            if w0==0

                c0=1;
            elseif w0==1
                c0=-1;
            elseif w0==0.5
                c0=0;
            else
                c0=cos(pi.*w0);
            end

            i1idx=find((B1~=0|A1~=0)&(B2==0&A2==0));

            if~isempty(i1idx)
                i1=i1idx(1);
                D=A0(i1)+A1(i1);
                Bhat(i1,1)=(B0(i1)+B1(i1))./D;
                Bhat(i1,2)=(B0(i1)-B1(i1))./D;
                Ahat(i1,1)=1;
                Ahat(i1,2)=(A0(i1)-A1(i1))./D;
            end

            i2idx=find(B2~=0|A2~=0);

            for k=1:length(i2idx)

                i2=i2idx(k);
                D=A0(i2)+A1(i2)+A2(i2);
                Bhat(i2,1)=(B0(i2)+B1(i2)+B2(i2))./D;
                Bhat(i2,2)=2*(B0(i2)-B2(i2))./D;
                Bhat(i2,3)=(B0(i2)-B1(i2)+B2(i2))./D;
                Ahat(i2,1)=1;
                Ahat(i2,2)=2*(A0(i2)-A2(i2))./D;
                Ahat(i2,3)=(A0(i2)-A1(i2)+A2(i2))./D;
            end


            if c0==1||c0==-1
                B(:,1:3)=Bhat;
                A(:,1:3)=Ahat;
                B(:,2)=c0*B(:,2);
                A(:,2)=c0*A(:,2);

            else
                if~isempty(i1idx)
                    i1=i1idx(1);
                    B(i1,1)=Bhat(i1,1);
                    B(i1,2)=c0*(Bhat(i1,2)-Bhat(i1,1));
                    B(i1,3)=-Bhat(i1,2);
                    A(i1,1)=1;
                    A(i1,2)=c0*(Ahat(i1,2)-1);
                    A(i1,3)=-Ahat(i1,2);
                end

                for k=1:length(i2idx)

                    i2=i2idx(k);
                    B(i2,1)=Bhat(i2,1);
                    B(i2,2)=c0*(Bhat(i2,2)-2*Bhat(i2,1));
                    B(i2,3)=(Bhat(i2,1)-Bhat(i2,2)+Bhat(i2,3))*c0^2-Bhat(i2,2);
                    B(i2,4)=c0*(Bhat(i2,2)-2*Bhat(i2,3));
                    B(i2,5)=Bhat(i2,3);


                    A(i2,1)=1;
                    A(i2,2)=c0*(Ahat(i2,2)-2);
                    A(i2,3)=(1-Ahat(i2,2)+Ahat(i2,3))*c0^2-Ahat(i2,2);
                    A(i2,4)=c0*(Ahat(i2,2)-2*Ahat(i2,3));
                    A(i2,5)=Ahat(i2,3);
                end
            end


