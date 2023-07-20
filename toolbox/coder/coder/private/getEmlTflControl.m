function tflControl=getEmlTflControl(name)






    persistent tflControlManager;

    if strcmp(name,'reset')
        tflControlManager=struct('Name',{},'T',{});
        tflControl=[];
        return;
    end

    if isempty(tflControlManager)
        tflControlManager=struct('Name',{},'T',{});
        tflControl=RTW.TflControl;
        entry.Name=name;
        entry.T=tflControl;
        tflControlManager(1)=entry;
    else
        [~,n]=size(tflControlManager);
        found=false;







        for i=1:n
            if strcmp(tflControlManager(1,i).Name,name)
                tflControl=tflControlManager(1,i).T;
                found=true;
                break;
            end
        end

        if~found
            tflControl=RTW.TflControl;
            entry.Name=name;
            entry.T=tflControl;
            tflControlManager(n+1)=entry;
        end
    end


