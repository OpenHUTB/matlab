function n=secorder(this,Hd)%#ok<INUSL>




    s=Hd.SOSMatrix;
    nsec=size(s,1);


    n=2*ones(nsec,1);

    for i=1:nsec
        if(s(i,3)==0&&s(i,6)==0)

            n(i)=1;
            if(s(i,2)==0&&s(i,5)==0)

                n(i)=0;
            end
        end
    end



