function generateCFG(obj,frequency,dir)

    if nargin==2
        dir=pwd;
    end

    filename=fullfile(dir,'linpar.cfg');


    fileID=fopen(filename,'w');


    fprintf(fileID,'2\n');


    fprintf(fileID,'%.8e\n',frequency);


    fprintf(fileID,'%.8e\n',obj.conductivity);


    fclose(fileID);

end

