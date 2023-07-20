


function rCalls=getRecursiveCalls(this)



    rCalls=[];
    callStack=containers.Map();
    processedFcns=containers.Map();
    visit(this);


    function visit(fcn)
        uniqueFcnKey=sprintf('%s:%s:%d',fcn.scriptPath,fcn.specializationName,fcn.tree.lefttreepos);
        if processedFcns.isKey(uniqueFcnKey)









































            return;
        end


        k=getKey(fcn);


        callStack(k)=fcn;


        calls=fcn.getCallNodes();
        for ii=1:numel(calls)
            node=calls{ii};
            callee=fcn.getCalledFcnInfo(node);
            calleeKey=getKey(callee);



            if callStack.isKey(calleeKey)

                rCall.Caller=fcn;
                rCall.Callee=callee;
                rCall.Node=node;
                rCalls=[rCalls,rCall];
            else

                visit(callee);
            end
        end


        callStack.remove(k);


        processedFcns(uniqueFcnKey)=true;
    end






















    function k=getKey(fcn)
        k=sprintf('%s:%d',fcn.scriptPath,fcn.tree.lefttreepos);
    end
end


