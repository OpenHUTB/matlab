function[D,Q,X2,valid]=polarAflux2DQflux_private(F,X,parks_type)%#codegen




    coder.allowpcode('plain');

    dims=size(F);
    n_1=dims(1);
    n_2=dims(2);
    n_X=dims(3);
    nPolePairs=2*pi/(X(end)-X(1));
    no=(n_X-1)/3+1;

    if(rem(no,1)>0)||(no<3)

        valid=false;
        D=zeros(n_1,n_2,n_X);
        Q=zeros(n_1,n_2,n_X);
        X2=X;
    else

        valid=true;
        E=nPolePairs*X(1:no);
        D=zeros(n_1,n_2,no);
        Q=zeros(n_1,n_2,no);
        shift_3ph=[0,-2*pi/3,2*pi/3];
        for i=1:n_1
            for j=1:n_2
                for m=1:no

                    mechanical_angle_vec=(E(m)/nPolePairs+shift_3ph/nPolePairs);

                    electrical_angle_vec=nPolePairs*mechanical_angle_vec;
                    if parks_type==1
                        abc2d=(2/3)*cos(electrical_angle_vec);
                        abc2q=(2/3)*-sin(electrical_angle_vec);
                    elseif parks_type==2
                        abc2d=(2/3)*sin(electrical_angle_vec);
                        abc2q=(2/3)*cos(electrical_angle_vec);
                    elseif parks_type==3
                        abc2d=(2/3)*cos(electrical_angle_vec);
                        abc2q=(2/3)*sin(electrical_angle_vec);
                    else
                        abc2d=(2/3)*-sin(electrical_angle_vec);
                        abc2q=(2/3)*cos(electrical_angle_vec);
                    end

                    fluxA=F(i,j,m);
                    fluxB=F(i,j,1+mod(m-(no+1),3*(no-1)+1));
                    fluxC=F(i,j,1+mod(m+(no-2),3*(no-1)+1));
                    D(i,j,m)=abc2d*[fluxA;fluxB;fluxC];
                    Q(i,j,m)=abc2q*[fluxA;fluxB;fluxC];
                end
            end
        end
        X2=E/nPolePairs;
    end

end