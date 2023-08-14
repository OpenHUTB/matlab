function[origX,origY]=update_time_data(curTmin,curTmax,newTmin,newTmax,origX,origY)










    if(newTmax~=curTmax)
        if(newTmax>curTmax)
            if(numel(origY)>1)&&(origY(end-1)==origY(end))
                origX(end)=newTmax;
            else
                origX(end+1)=newTmax;
                origY(end+1)=origY(end);
            end
        elseif(newTmax<=curTmin)
            origX(end)=newTmax;
            origY(end)=origY(1);
            if origY(1)==origY(2)
                origX(2:end-1)=[];
                origY(2:end-1)=[];
            else
                origX(1:end-1)=[];
                origY(1:end-1)=[];
            end
        else
            newY=scalar_interp(newTmax,...
            origX,origY,-1);
            delIdx=(origX>=newTmax);
            origX(delIdx)=[];
            origY(delIdx)=[];
            origX=[origX,newTmax];
            origY=[origY,newY];
        end
    end





    if(newTmin~=curTmin)
        if(newTmin<curTmin)
            if(numel(origY)>1)&&(origY(1)==origY(2))
                origX(1)=newTmin;
            else
                origX=[newTmin,origX];
                origY=[origY(1),origY];
            end
        elseif(newTmin>=curTmax)
            origX(1)=newTmin;
            origY(1)=origY(end);

            origX(2:end-1)=[];
            origY(2:end-1)=[];




        else
            newY=scalar_interp(newTmin,...
            origX,origY,1);
            delIdx=(origX<=newTmin);
            origX(delIdx)=[];
            origY(delIdx)=[];
            origX=[newTmin,origX];
            origY=[newY,origY];
        end
    end
end

