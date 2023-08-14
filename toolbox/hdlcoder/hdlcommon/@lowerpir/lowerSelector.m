function hNewC=lowerSelector(hN,hC)




    if strcmp(hC.getIndexMode,'Zero-based')
        zeroBasedIndex=1;
    else
        zeroBasedIndex=0;
    end

    numDims=str2double(hC.getNumberOfDimensions);
    indexOptions=zeros(1,numDims);
    indices=hC.getIndexParamArray;


    hInT=hC.PirInputSignals(1).Type;
    if hInT.isArrayType
        hInSize=hInT.Dimensions;
        if length(hInSize)<2
            if hInT.isRowVector
                hInSize=[1,hInSize];
            else
                hInSize=[hInSize,1];
            end
        end
    else
        hInSize=[1,1];
    end

    hOutT=hC.PirOutputSignals(1).Type;
    if hOutT.isArrayType
        hOutSize=hOutT.Dimensions;
        if length(hOutSize)<2&&numel(indexOptions)>1
            if hOutT.isRowVector
                hOutSize=[1,hOutSize];
            else
                hOutSize=[hOutSize,1];
            end
        end
        if length(hInSize)>2&&(length(hOutSize)<length(hInSize))
            hOutSize=[1,hOutSize];
        end
    else
        if numel(hInSize)==2
            hOutSize=[1,1];
        else
            hOutSize=[1,1,1];
        end
    end












    op_ind_i=hC.getIndexOptionArray;
    for i=1:length(hC.getIndexOptionArray)


        if strcmp(op_ind_i{i},'Select all')
            indexOptions(i)=0;
        elseif strcmp(op_ind_i{i},'Index vector (dialog)')
            if indices{i}==-1
                indexOptions(i)=0;
            else
                indexOptions(i)=1;
            end
        elseif strcmp(op_ind_i{i},'Index vector (port)')
            indexOptions(i)=2;
        elseif strcmp(op_ind_i{i},'Starting index (dialog)')
            if indices{i}==-1
                indexOptions(i)=0;
            else
                indexOptions(i)=3;
            end
        else
            indexOptions(i)=4;
        end
    end




    indexCell=cell(1,length(indexOptions));





    outLen=zeros(1,numDims);



    hInSignals=hC.PirInputSignals;
    if hInT.isArrayType&&~hInT.isRowVector&&...
        ~hInT.isColumnVector&&~hInT.isMatrix&&length(indexOptions)>1&&ishandle(hC.OrigModelHandle)









        ph=get_param(hC.OrigModelHandle,'PortHandles');
        dim_input=get_param(ph.Inport(1),'CompiledPortDimensions');




        if dim_input(2)==1
            [indices{1},indices{2}]=deal(indices{2},indices{1});
            [indexOptions(1),indexOptions(2)]=deal(indexOptions(2),indexOptions(1));
            [hOutSize(1),hOutSize(2)]=deal(hOutSize(2),hOutSize(1));

            if numel(hInSignals)==3


                [hInSignals(2),hInSignals(3)]=deal(hInSignals(3),hInSignals(2));
            end
        end
    end

    for dim=1:length(indexOptions)
        switch indexOptions(dim)
        case 0

            indexCell{dim}=(1:hInSize(dim))-zeroBasedIndex;
        case 1
            indexCell{dim}=indices{dim};
        case 2
            indexCell{dim}=[];
        case 3
            rawidx=indices{dim};

            indexCell{dim}=rawidx:(rawidx+hOutSize(dim)-1);
        otherwise
            indexCell{dim}=[];
            outLen(dim)=hOutSize(dim);
        end
    end


    hNewC=pireml.getSelectorComp(...
    hN,...
    hInSignals,...
    hC.PirOutputSignals,...
    zeroBasedIndex,...
    indexOptions,...
    indexCell,...
    outLen,...
    hC.Name);
end