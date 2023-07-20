function y=interp2_wrapper(x1_vec,x2_vec,y_mat,xp1,xp2,interp_method,extrap_method)%#codegen






























    y_mat=y_mat';


    if length(xp1)~=length(xp2)
        pm_error('physmod:simscape:compiler:patterns:checks:LengthEqual','xp1','xp2');
    end



    monotonic_x1=all(diff(x1_vec)>0)|all(diff(x1_vec)<0);
    monotonic_x2=all(diff(x2_vec)>0)|all(diff(x2_vec)<0);


    if~monotonic_x1
        pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingOrDescendingVec','x1_vec');
    end
    if~monotonic_x2
        pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingOrDescendingVec','x2_vec');
    end


    x1_min=min(x1_vec);
    x1_max=max(x1_vec);

    xi1_idx=xp1>=x1_min&xp1<=x1_max;

    x2_min=min(x2_vec);
    x2_max=max(x2_vec);

    xi2_idx=xp2>=x2_min&xp2<=x2_max;

    xi_idx=xi1_idx&xi2_idx;

    xo_idx=~xi_idx;


    if interp_method==1
        interpolation='linear';
    elseif interp_method==2
        interpolation='makima';
    else

        pm_error('physmod:battery:shared_utils:Interpolation:UnknownOption');
    end

    y=zeros(size(xp1));

    if extrap_method==1




        if any(xi_idx)
            yi=interp2(x1_vec,x2_vec,y_mat,xp1(xi_idx),xp2(xi_idx),interpolation);
            y(xi_idx)=yi;
        end


        o_idxs=find(xo_idx);
        nx1=length(x1_vec);
        nx2=length(x2_vec);
        for i=1:length(o_idxs)
            o_idx=o_idxs(i);
            xp1_curr=xp1(o_idx);
            xp2_curr=xp2(o_idx);







            [~,i11]=min((xp1_curr-x1_vec).^2);
            [~,i21]=min((xp2_curr-x2_vec).^2);









            x11=x1_vec(i11);
            x21=x2_vec(i21);
            if i11==1
                if i21==1
                    i12=i11;
                    i22=i21+1;
                    i13=i12+1;
                    i23=i22;
                    i14=i13;
                    i24=i23-1;
                elseif i21==nx2
                    i12=i11+1;
                    i22=i21;
                    i13=i12;
                    i23=i22-1;
                    i14=i13-1;
                    i24=i23;
                else

                    if xp2_curr-x2_vec(i21)>=0
                        i12=i11;
                        i22=i21+1;
                        i13=i12+1;
                        i23=i22;
                        i14=i13;
                        i24=i23-1;
                    else
                        i12=i11+1;
                        i22=i21;
                        i13=i12;
                        i23=i22-1;
                        i14=i13-1;
                        i24=i23;
                    end
                end
            elseif i11==nx1
                if i21==1
                    i12=i11-1;
                    i22=i21;
                    i13=i12;
                    i23=i22+1;
                    i14=i13+1;
                    i24=i23;
                elseif i21==nx2
                    i12=i11;
                    i22=i21-1;
                    i13=i12-1;
                    i23=i22;
                    i14=i13;
                    i24=i23+1;
                else

                    if xp2_curr-x2_vec(i21)>=0
                        i12=i11-1;
                        i22=i21;
                        i13=i12;
                        i23=i22+1;
                        i14=i13+1;
                        i24=i23;
                    else
                        i12=i11;
                        i22=i21-1;
                        i13=i12-1;
                        i23=i22;
                        i14=i13;
                        i24=i23+1;
                    end
                end
            else
                if i21==1

                    if xp1_curr-x1_vec(i11)>=0
                        i12=i11;
                        i22=i21+1;
                        i13=i12+1;
                        i23=i22;
                        i14=i13;
                        i24=i23-1;
                    else
                        i12=i11-1;
                        i22=i21;
                        i13=i12;
                        i23=i22+1;
                        i14=i13+1;
                        i24=i23;
                    end
                elseif i21==nx2

                    if xp1_curr-x1_vec(i11)>=0
                        i12=i11+1;
                        i22=i21;
                        i13=i12;
                        i23=i22-1;
                        i14=i13-1;
                        i24=i23;
                    else
                        i12=i11;
                        i22=i21-1;
                        i13=i12-1;
                        i23=i22;
                        i14=i13;
                        i24=i23+1;
                    end



                end
            end
            x12=x1_vec(i12);
            x22=x2_vec(i22);
            x13=x1_vec(i13);
            x23=x2_vec(i23);
            x14=x1_vec(i14);
            x24=x2_vec(i24);
            x31=y_mat(i21,i11);
            x32=y_mat(i22,i12);
            x33=y_mat(i23,i13);
            x34=y_mat(i24,i14);

            X=[1,x11,x21;1,x12,x22;1,x13,x23;1,x14,x24];
            Y=[x31,x32,x33,x34]';
            A=X'*X;
            b=X'*Y;

            beta=(A\b);

            y(o_idx)=dot(beta,[1,xp1_curr,xp2_curr]);
        end
    elseif extrap_method==2

        y=interp2(x1_vec,x2_vec,y_mat,min(x1_max,max(x1_min,xp1)),...
        min(x2_max,max(x2_min,xp2)),interpolation);
    elseif extrap_method==3

        if any(xo_idx)

            pm_error('physmod:battery:shared_utils:Interpolation:ExtrapolationError','xp1,xp2');
            y=[];
        end
    else

        pm_error('physmod:battery:shared_utils:Interpolation:UnknownOption');
    end

end


