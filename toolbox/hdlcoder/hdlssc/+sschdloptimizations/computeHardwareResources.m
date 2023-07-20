function[numMultipliers,numAdders]=computeHardwareResources(constMatrix,sharingFactor)







    numMultipliers=0;
    numAdders=0;


    [~,~,activeColumnPositions]=sschdloptimizations.getActiveElements(constMatrix,sharingFactor);


    for ii=1:numel(activeColumnPositions)
        if~isempty(activeColumnPositions{ii})
            numMultipliers=numMultipliers+numel(activeColumnPositions{ii});
            numAdders=numAdders+numel(activeColumnPositions{ii})-1;
        end
    end


    numMultipliers=numMultipliers/sharingFactor;
    numAdders=numAdders/sharingFactor;

end