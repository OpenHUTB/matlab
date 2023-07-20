function pathItems=getPortMapping(~,blkObj,~,outportIdx)








    pathItems={};
    if~isempty(outportIdx)>0


        if strcmp(blkObj.imagePorts,'Separate color signals')
            originalPathItems={'Output R','Output G','Output B'};
            pathItems=originalPathItems(outportIdx);
        else

            pathItems{1}='Output';
        end
    end
end
