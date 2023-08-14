function[activeElements,activeRowPositions,activeColumnPositions]=getActiveElements(constMatrix,sharingFactor)




    sizeConstMatrix=size(constMatrix);
    if(numel(sizeConstMatrix)==2)

        sizeConstMatrix(3)=1;
    end

    activeElements=cell(1,sizeConstMatrix(3));
    activeColumnPositions=cell(1,sizeConstMatrix(1));
    activeRowPositions=cell(1,sizeConstMatrix(1));



    activePositions=zeros(sizeConstMatrix(1),sizeConstMatrix(2));
    for kk=1:sizeConstMatrix(3)
        activePositions=or(activePositions,(constMatrix(:,:,kk)~=0));
    end



    if sharingFactor>1
        activePositionsSerial=zeros(1,sizeConstMatrix(2));
        for ii=1:sizeConstMatrix(1)
            activePositionsSerial=or(activePositionsSerial,activePositions(ii,:));
        end
        activePositions=repmat(activePositionsSerial,sizeConstMatrix(1),1);
    end


    activePositionsInd=find(activePositions);


    [activePositionsI,activePositionsJ]=ind2sub([sizeConstMatrix(1),sizeConstMatrix(2)],activePositionsInd);


    for ii=1:sizeConstMatrix(1)
        activeColumnPositions{ii}=(activePositionsJ(activePositionsI==ii)).';
    end


    for ii=1:sizeConstMatrix(1)
        activeRowPositions{ii}=(find(activePositionsI==ii)).';
    end


    for kk=1:sizeConstMatrix(3)
        slice3d=constMatrix(:,:,kk);
        activeElements{kk}=slice3d(activePositionsInd);
    end

end