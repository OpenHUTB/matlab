function[obj2way,canceled]=canlink2way(objH)






    can2way=true(size(objH));
    canceled=false;


    if isa(objH,'Simulink.DDEAdapter')
        obj2way=objH;
        return;
    end


    for i=1:length(objH)
        if rmisl.isLibObject(objH(i))
            can2way(i)=false;
        end
    end


    if any(~can2way)
        obj2way=objH(can2way);
        reply=questdlg(getString(message('Slvnv:rmi:canlink2way:UnableToCreateTwowayLink_content')),...
        getString(message('Slvnv:rmi:canlink2way:UnableToCreateTwowayLink')),...
        getString(message('Slvnv:rmi:canlink2way:LinkOneWay')),'Cancel',getString(message('Slvnv:rmi:canlink2way:LinkOneWay')));
        if isempty(reply)||strcmp(reply,'Cancel')
            obj2way=[];
            canceled=true;
        end
    else
        obj2way=objH;
    end
end


