function result=createEmptyReqs(count)



    if count==1
        result=rmi.reqstruct('','','','',true,'other');
    else
        isLinked=num2cell(true(1,count));
        result=rmi.reqstruct({''},{''},{''},{''},isLinked',{'other'});
    end
end

