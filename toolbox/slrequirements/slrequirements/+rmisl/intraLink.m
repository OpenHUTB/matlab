function count=intraLink(from_objects,to_objects)




    if ischar(from_objects)
        totalSources=1;
        [~,from_objects]=rmi.resolveobj(from_objects);
    else
        totalSources=length(from_objects);
    end


    rmiObjects=rmi.canlink(from_objects);
    if length(rmiObjects)<totalSources
        count=0;
        return;
    else
        from_objects=rmiObjects;
    end


    if length(to_objects)>1
        targetHandles=to_objects;
    else
        [~,targetHandles,~]=rmi.resolveobj(to_objects);
    end
    if selfLinkPresent(from_objects,targetHandles)
        count=0;
        return;
    end


    newLinks=rmisl.makeReqs(to_objects);

    if selfLinkPresent(from_objects,targetHandles)
        newLinks=[];
    end

    if~isempty(newLinks)

        for i=1:totalSources
            rmi.catReqs(from_objects(i),newLinks);
        end
    end
    count=length(newLinks)*totalSources;
end

function yesno=selfLinkPresent(from_objects,targetHandles)
    yesno=false;
    for i=1:length(from_objects)
        this_object=from_objects(i);
        type=strtok(class(this_object),'.');
        switch type
        case 'double'
            srcHandle=this_object;
        case 'Stateflow'
            srcHandle=this_object.Id;
        case 'Simulink'
            if rmifa.isFaultInfoObj(this_object)
                srcHandle=this_object.Uuid;
            else
                srcHandle=this_object.Handle;
            end
        otherwise
            error(message('Slvnv:reqmgt:rmi:InvalidObject',type));
        end
        if any(targetHandles==srcHandle)
            errordlg(...
            getString(message('Slvnv:reqmgt:rmi:NoSelfLinks_content')),...
            getString(message('Slvnv:reqmgt:rmi:NoSelfLinks_title')),'model');
            yesno=true;
            return;
        end
    end
end


