function[outNames,outSize,propertyList]=formatDimensionInput(userSpecList)









    if isempty(userSpecList)
        outNames={{},{}};
        outSize=[1,1];
        propertyList={};
        return
    end







    inputI=userSpecList{1};
    if~isscalar(inputI)&&~isempty(inputI)
        if isnumeric(inputI)

            if~isrow(inputI)
                throwAsCaller(MException('shared_adlib:validateSizes:NonRowSizeArray',...
                getString(message('MATLAB:matrix:nonRealInput'))));
            end

            checkNumericDimSpec(inputI);
            outSize=inputI;
            outNames=repmat({{}},1,numel(inputI));


            propertyList=userSpecList(2:end);
            return
        elseif iscell(inputI)&&~(iscellstr(inputI))



            nDims=numel(inputI);
            outNames=cell(1,nDims);
            outSize=zeros(1,nDims);




            try
                for k=1:nDims
                    [outSize(k),outNames{k}]=checkStringDimSpec(inputI{k},k);
                end
            catch ME

                if strcmp(ME.identifier,'shared_adlib:validateIndexNames:MustBeStringOrEmpty')
                    throwAsCaller(MException(message('shared_adlib:validateIndexNames:InvalidDimensionInput')));
                end
                throwAsCaller(ME);
            end


            propertyList=userSpecList(2:end);
            return
        end
    end




    nDims=numel(userSpecList);
    outNames=cell(1,nDims);
    outNames{1}={};
    outSize=ones(1,nDims);

    singletonCharString=false;
    dimIdx=1;
    pvPairIdx=nDims+1;
    while(dimIdx<=nDims)&&~singletonCharString
        inputI=userSpecList{dimIdx};
        singletonCharString=ischar(inputI)||(isstring(inputI)&&isscalar(inputI));
        if~singletonCharString

            if isnumeric(inputI)&&isscalar(inputI)
                checkNumericDimSpec(inputI);
                outNames{dimIdx}={};
                outSize(dimIdx)=inputI;

            elseif isvector(inputI)&&(iscellstr(inputI)||isstring(inputI))
                try
                    [outSize(dimIdx),outNames{dimIdx}]=checkStringDimSpec(inputI,dimIdx);
                catch ME

                    if strcmp(ME.identifier,'shared_adlib:validateIndexNames:MustBeStringOrEmpty')
                        throwAsCaller(MException(message('shared_adlib:validateIndexNames:InvalidDimensionInput')));
                    end
                    throwAsCaller(ME);
                end
            else
                throwAsCaller(MException(message('shared_adlib:validateIndexNames:InvalidDimensionInput')));
            end
            dimIdx=dimIdx+1;
        else
            pvPairIdx=dimIdx;
        end
    end


    outSize(dimIdx:end)=[];
    outNames(dimIdx:end)=[];

    if isempty(outSize)


        outSize=[1,1];
        outNames={{},{}};
    elseif isscalar(outSize)


        if~isnumeric(userSpecList{1})&&isrow(userSpecList{1})
            outNames={{},outNames{1}};
            outSize=[outSize~=0,outSize];
        else
            outNames={outNames{1},{}};
            outSize=[outSize,outSize~=0];
        end
    end


    propertyList=userSpecList(pvPairIdx:end);

end


function checkNumericDimSpec(thisDim)
    if~isreal(thisDim)||any(~isfinite(thisDim)|(thisDim<0)|(thisDim~=floor(thisDim)))



        throwAsCaller(MException(message('shared_adlib:validateSizes:SizeInputMustBeNonNegativeInteger')));
    end
end


function[thisSize,thisNames]=checkStringDimSpec(thisDim,dimNumber)

    thisSize=numel(thisDim);
    thisNames=thisDim;
    thisNames=optim.internal.problemdef.checkSingleDimIndexNames(...
    thisNames,thisSize,dimNumber);
end

