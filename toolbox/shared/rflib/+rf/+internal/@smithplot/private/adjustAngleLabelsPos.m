function adjustAngleLabelsPos(hText)















    N=numel(hText);
    centers=zeros(2,N);
    inR=0;
    for i=1:N

        ext=hText(i).Extent;
        halfLen_x=ext(3)/2;
        halfLen_y=ext(4)/2;

        centers(:,i)=[ext(1)+halfLen_x;ext(2)+halfLen_y];



        if halfLen_x>halfLen_y
            halfLen_i=halfLen_x;
        else
            halfLen_i=halfLen_y;
        end
        if halfLen_i>inR
            inR=halfLen_i;
        end
    end


    extraR=0.0;
    zc=0.294;
    for i=1:N
        ctr_i=centers(:,i);
        hText(i).Position=[(1+inR+extraR)*ctr_i/norm(ctr_i);zc];
    end

end
