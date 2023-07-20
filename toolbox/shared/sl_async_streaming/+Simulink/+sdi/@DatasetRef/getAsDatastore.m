function[elementVal,name,retIdx]=getAsDatastore(this,arg1)


    elementVal=[];
    name='';
    retIdx=[];
    if~isscalar(this)
        Simulink.SimulationData.utError('InvalidDatasetArray');
    end
    if iscell(arg1)
        searchArg=arg1{1};
        bAlwaysReturnDS=true;
    else
        searchArg=arg1;
        bAlwaysReturnDS=false;
    end


    if isnumeric(searchArg)
        sigs={getElementAsDatastoreByIndex(this,searchArg)};
        retIdx=searchArg;


    else
        validateattributes(searchArg,{'char','string'},{},'getElement','searchArg',2);
        searchArg=char(searchArg);


        names=getElementNames(this);
        pos=strcmp(names,searchArg);
        sigs={};
        for idx=1:numel(pos)
            if pos(idx)
                sigs{end+1}=getElementAsDatastoreByIndex(this,idx);%#ok<AGROW>
                retIdx(end+1)=idx;%#ok<AGROW>
            end
        end
    end


    numElements=length(sigs);
    if numElements==1&&~bAlwaysReturnDS
        elementVal=sigs{1};
        if~isempty(elementVal)
            name=elementVal.Name;
        end
    elseif numElements>1||bAlwaysReturnDS
        elementVal=Simulink.SimulationData.Dataset;
        for idx=1:numElements
            if~isempty(sigs{idx})
                elementVal=addElement(elementVal,sigs{idx});
            else
                elementVal=addElement(elementVal,sigs{idx},'');
            end
        end
    end
end


function ret=getElementAsDatastoreByIndex(this,idx)
    ret=[];
    sigIDs=getSortedSignalIDs(this);
    if idx<=numel(sigIDs)
        ret=Simulink.sdi.DatasetRef.getDatastoreForSignal(sigIDs(idx),this.Repo);
    end
end
