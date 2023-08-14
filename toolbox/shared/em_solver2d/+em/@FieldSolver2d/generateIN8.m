function fileName=generateIN8(obj)

    fileName='linpar.in8';


    fileID=fopen(fileName,'w');


    fprintf(fileID,'8\n');


    fprintf(fileID,'3\n');


    fprintf(fileID,'%d\n',obj.numSubLayer);


    fprintf(fileID,'%d\n',obj.codeSub);


    fprintf(fileID,'         0.0000000\n');


    for iSub=1:obj.numSubLayer

        fprintf(fileID,'         %.7f\n',obj.thickSub(iSub));


        fprintf(fileID,'         %.7f\n',obj.epsilonRSub(iSub));


        fprintf(fileID,'         %.7f\n',obj.lossTangentSub(iSub));


        fprintf(fileID,'%d\n',obj.numTrace(iSub));


        for iTrace=1:obj.numTrace(iSub)
            fprintf(fileID,'         %.7f\n',obj.widthTrace{iSub}(iTrace));
        end


        for iTrace=1:obj.numTrace(iSub)
            fprintf(fileID,'         %.7f\n',obj.thickTrace{iSub}(iTrace));
        end


        fprintf(fileID,'         %.7f\n',obj.offsetTrace(iSub));


        for iSep=1:obj.numTrace(iSub)-1
            fprintf(fileID,'         %.7f\n',obj.separationTrace{iSub}(iSep));
        end
    end

    if obj.codeSub~=0

        fprintf(fileID,'         %.7f\n',obj.thickCover);


        fprintf(fileID,'         %.7f\n',obj.epsilonRCover);


        fprintf(fileID,'         %.7f\n',obj.lossTangentCover);
    end


    for i=1:40
        fprintf(fileID,'0\n');
    end


    fclose(fileID);

end

