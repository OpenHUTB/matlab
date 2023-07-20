function[x_t,y_t,z_t]=fourQuadrantData_private(x,y,z)





    n_x=numel(x);
    n_y=numel(y);
    dims=size(z);

    if dims(1)~=n_x||dims(2)~=n_y||n_x<2||n_y<2



        x_t=x;
        y_t=y;
        z_t=z;

    else


        if x(1)~=0
            idx_x=n_x:-1:1;
        else

            idx_x=n_x:-1:2;
        end
        if y(1)~=0
            idx_y=n_y:-1:1;
        else

            idx_y=n_y:-1:2;
        end


        n_xy=n_x*n_y;
        n_d=prod(dims);
        n_page=n_d/n_xy;


        dims_t=dims;
        for i=1:n_page
            if(x(1)<0)&&(y(1)<0)

                x_t=x;
                y_t=y;
            elseif(x(1)<0)&&(y(1)>=0)

                x_t=x;
                y_t=[-y(idx_y),y];
                dims_t(2)=length(y_t);
            elseif(x(1)>=0)&&(y(1)<0)

                y_t=y;
                x_t=[-x(idx_x),x];
                dims_t(1)=length(x_t);
            else

                x_t=[-x(idx_x),x];
                y_t=[-y(idx_y),y];
                dims_t(1)=length(x_t);
                dims_t(2)=length(y_t);
            end
        end


        zByPage=reshape(z,n_x,n_y,n_page);
        zByPage_t=zeros(dims_t(1),dims_t(2),n_page);
        for i=1:n_page

            zThisPage=zByPage(:,:,i);
            if(x(1)<0)&&(y(1)<0)

                zByPage_t(:,:,i)=zThisPage;
            elseif(x(1)<0)&&(y(1)>=0)

                z1=zThisPage(:,idx_y);
                z2=z1(idx_x,:);
                zByPage_t(:,:,i)=[z2,zThisPage];
            elseif(x(1)>=0)&&(y(1)<0)

                z1=zThisPage(:,idx_y);
                z2=z1(idx_x,:);
                zByPage_t(:,:,i)=[z2;zThisPage];
            else


                z1=zThisPage(:,idx_y);
                z2=[z1,zThisPage];

                z3=z2(idx_x,:);
                zByPage_t(:,:,i)=[z3;z2];
            end
        end
        z_t=reshape(zByPage_t,dims_t);
    end

end