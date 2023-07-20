function cktOut=realize(cktIn,implObj)
    [cktOut,warningMsgs]=functionalClone(cktIn,@cloneRealize);%#ok<ASGLU>


    if isequal(cktIn,cktOut)
        warning(message('rf:rfcircuit:circuit:realize:NotAppliedOnCkt'));
    end

    function[elemOut,varargout]=cloneRealize(ckt,elemInd)
        warningMsg=[];
        varargout={};
        elemIn=ckt.Elements(elemInd);
        switch class(elemIn)
        case 'txlineElectricalLength'
            elemOut=elemIn.realize(implObj);
        otherwise
            warningMsg=message(['rf:rfcircuit:circuit:realize:'...
            ,'NotAppliedOnElem'],class(elemIn)).string;
            elemOut=clone(elemIn);
        end
        if nargout>1
            varargout={warningMsg};
        end
    end
end