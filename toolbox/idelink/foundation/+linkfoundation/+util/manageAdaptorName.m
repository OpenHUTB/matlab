function ret=manageAdaptorName(action,mdltag,name)




    mlock;
    persistent adaptorName;

    ret=[];

    idx=0;
    for i=1:length(adaptorName)
        if isequal(adaptorName(i).tag,mdltag)
            idx=i;
            break;
        end
    end

    switch action
    case 'set'
        if idx==0
            idx=length(adaptorName)+1;
            adaptorName(idx).tag=mdltag;
        end
        adaptorName(idx).name=name;

    case 'get'
        if idx>0
            ret=adaptorName(idx).name;
        end

    case 'delete'
        if idx>0
            adaptorName(idx)=[];
        end
    end
