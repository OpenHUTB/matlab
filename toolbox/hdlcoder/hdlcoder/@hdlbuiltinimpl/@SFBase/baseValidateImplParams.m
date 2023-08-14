function v=baseValidateImplParams(this,hC)






    v=hdlvalidatestruct;

    if~isempty(this.implParams)&&iscell(this.implParams)
        names=this.implParamNames;

        if mod(length(this.implParams),2)~=0
            v(end+1)=hdlvalidatestruct(2,...
            message('hdlcoder:stateflow:oddnumimplparams'));
            this.implParams(end)=[];
        end


        if~isempty(this.implParams)

            props=this.implParams(1:2:end);
            notstrings=not(cellfun(@ischar,props));
            if~isempty(find(notstrings,1))
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:stateflow:nonstringproperty'));
            end
        end

        for ii=1:2:length(this.implParams)
            m=strcmpi(names,this.implParams{ii});
            if~any(m)
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:stateflow:unknownproperty',this.implParams{ii}));
            elseif sum(m)>1
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:stateflow:nonuniqueproperty'));%#ok<*AGROW>
            end
        end
    end

    useMatrixTypes=strcmpi(this.getImplParams('UseMatrixTypesInHDL'),'on');
    haveMatrixPort=checkMatrixPort(hC.PirInputSignals);
    if~haveMatrixPort
        haveMatrixPort=checkMatrixPort(hC.PirOutputSignals);
    end
    if haveMatrixPort&&~useMatrixTypes
        v(end+1)=hdlvalidatestruct(2,...
        message('hdlcoder:matrix:InconsistentMatrixSettings',hC.Name));
        newParams=[this.ImplParams,'UseMatrixTypesInHDL','on'];
        this.setImplParams(newParams);
    end
end


function haveMatrixPort=checkMatrixPort(portSigs)
    haveMatrixPort=false;
    for ii=1:numel(portSigs)
        hT=portSigs(ii).Type;
        if hT.isMatrix
            haveMatrixPort=true;
            break;
        end
    end
end