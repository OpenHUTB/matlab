function unpack(h)



    members=get(h,'Members');




    for k=1:length(members)
        elementName=members(k).name;
        assignin('caller',elementName,get(h,elementName));
    end
