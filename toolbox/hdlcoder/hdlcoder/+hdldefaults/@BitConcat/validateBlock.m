function v=validateBlock(this,hC)%#ok<INUSL>



    v=hdlvalidatestruct;

    hInSignals=hC.PirInputSignals;

    numInputs=numel(hInSignals);

    if numInputs>2


        checkFailed=false;
        dimLen=hInSignals(1).Type.getDimensions;
        for ii=2:numInputs
            if~isequal(dimLen,hInSignals(ii).Type.getDimensions)
                checkFailed=true;
                break;
            end
        end

        if checkFailed

            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:nonUniformInputsBitConcat'));
        end
    end

end