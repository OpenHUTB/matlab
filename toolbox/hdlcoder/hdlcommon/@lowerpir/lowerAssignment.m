function hNewC=lowerAssignment(hN,hC)



    if strcmp(hC.getIndexMode,'Zero-based')
        zeroBasedIndex=1;
    else
        zeroBasedIndex=0;
    end


    hInT=hC.PirInputSignals(1).Type;
    if hInT.isArrayType
        hInSize=hInT.Dimensions;
    else
        hInSize=[1,1];
    end
    if length(hInSize)~=2
        if hInT.isRowVector
            hInSize=[1,hInSize];
        else
            hInSize=[hInSize,1];
        end
    end

    numDims=str2double(hC.getNumberOfDimensions);
    indexOptions=zeros(1,numDims);
    indices=hC.getIndexParamArray;
    for i=1:numel(indices)
        if ischar(indices{i})
            indices_num=str2num(indices{i});%#ok<ST2NM> using on arrays
        else
            indices_num=indices{i};
        end
        indices{i}=int32(indices_num);
    end











    for i=1:length(hC.getIndexOptionArray)

        op_ind_i=hC.getIndexOptionArray;
        op_ind_i=op_ind_i(i);
        if strcmp(op_ind_i{1},'Assign all')
            indexOptions(i)=0;
        elseif strcmp(op_ind_i{1},'Index vector (dialog)')
            if indices{i}==-1
                indexOptions(i)=0;
            else
                indexOptions(i)=1;
            end
        elseif strcmp(op_ind_i{1},'Index vector (port)')
            indexOptions(i)=2;
        elseif strcmp(op_ind_i{1},'Starting index (dialog)')
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
    assignval_size=cell2mat(hC.getOutputSizeArray);



    hInSignals=hC.PirInputSignals;
    if hInT.isArrayType&&~hInT.isRowVector&&...
        ~hInT.isColumnVector&&~hInT.is2DMatrix&&...
        length(indexOptions)>1











        if any(indexOptions==2|indexOptions==4)||...
            indexOptions(1)==0||...
            indexOptions(1)==1&&all(indices{1}==1-zeroBasedIndex)||...
            indexOptions(1)==3&&indices{1}==1-zeroBasedIndex&&assignval_size(1)==1||...
            indexOptions(2)==1&&any(indices{2}~=1-zeroBasedIndex)||...
            indexOptions(2)==3&&assignval_size(2)>1

            [indices{1},indices{2}]=deal(indices{2},indices{1});
            [indexOptions(1),indexOptions(2)]=deal(indexOptions(2),indexOptions(1));
            [assignval_size(1),assignval_size(2)]=deal(assignval_size(2),assignval_size(1));
            if numel(hInSignals)==4


                [hInSignals(3),hInSignals(4)]=deal(hInSignals(4),hInSignals(3));
            end
        end
    end


    if length(indexOptions)==1
        indices=indices{1};
        switch indexOptions
        case 3
            indices=indices:(indices+assignval_size(1)-1);
        case 4
            outLen(1)=assignval_size(1);
        end
        indexCell={indices};
    else
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

                indexCell{dim}=rawidx:(rawidx+assignval_size(dim)-1);
            otherwise
                indexCell{dim}=[];
                outLen(dim)=assignval_size(dim);
            end
        end
    end

    hNewC=pireml.getAssignmentComp(...
    hN,...
    hInSignals,...
    hC.PirOutputSignals,...
    zeroBasedIndex,...
    indexOptions,...
    indexCell,...
    outLen,...
    hC.Name);

end
