function[A,b]=compileLinearExprOrConstr(objects,idxLinObj,sizeOfObjects,numVars)
















    NumLinObjects=sum(sizeOfObjects(idxLinObj));
    if(NumLinObjects==0)
        A=[];
        b=[];
    else
        A=sparse(numVars,NumLinObjects);
        b=zeros(NumLinObjects,1);
        start=1;
        for i=1:numel(idxLinObj)
            eqIdx=idxLinObj(i);
            mObj=sizeOfObjects(eqIdx);
            [Atemp,...
            b(start:start+mObj-1)]=extractLinearCoefficients(...
            objects{eqIdx},...
            numVars);
            A(:,start:start+mObj-1)=Atemp;%#ok<SPRIX>
            start=start+mObj;
        end
        A=A';
    end

end