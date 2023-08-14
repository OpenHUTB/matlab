function inputNames=getBlockInputNames(hBlock,flattenCellArray)





    lineHandles=get_param(hBlock,'LineHandles');
    inports=lineHandles.Inport;
    lines=inports;



    inportNames=slmgr.getSignalName(inports);
    inputNames=cell(size(inportNames));
    for indx=1:numel(inportNames)
        inputNames{indx}=inportNames{indx};
    end


    for indx=1:numel(inportNames)
        dims=slmgr.getPortDimensions(inports(indx));
        inputNames{indx}=applyDimsToNames(inputNames{indx},dims);
    end

    if any(lines==-1)


        ports=get_param(hBlock,'PortHandles');
        for indx=find(lines==-1)
            aPort=ports.Inport(indx);



            inputNames{indx}=get_param(aPort,'SigGenPortName');
        end
    end


    if nargin>1&&flattenCellArray
        while any(cellfun(@iscell,inputNames))
            inputNames=[inputNames{:}];
        end

        inputNames=inputNames(:)';
    end
end



function elemNames=applyDimsToNames(elemNames,dims)

    if iscell(elemNames)
        for indx=1:numel(elemNames)
            elemNames{indx}=applyDimsToNames(elemNames{indx},dims{indx});
        end
    else
        nDims=prod(dims(2:end));
        if any(nDims==[0,1])
            return
        end
        origName=elemNames;
        elemNames=cell(1,nDims);
        for indx=1:nDims
            elemNames{indx}=sprintf('%s:%d',origName,indx);
        end
    end
end
