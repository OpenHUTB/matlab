function[isit,calleeTypeInfo]=isFunctionCallNode(node,fcnTypeInfo)






    isit=false;
    calleeTypeInfo=[];


    for ii=1:numel(fcnTypeInfo.callSites)
        if fcnTypeInfo.callSites{ii}{1}==node
            isit=true;
            calleeTypeInfo=fcnTypeInfo.callSites{ii}{2};
            return;
        end
    end
end
