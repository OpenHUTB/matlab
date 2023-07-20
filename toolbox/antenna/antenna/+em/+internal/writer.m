function writer(fname,Horz,Vert,varargin)



    narginchk(3,4);


    fileID=fopen(fname,'w');

    if nargin==4


        DataStore=varargin{1};


        names1=fieldnames(DataStore);


        for i=1:size(names1,1)


            str=upper(names1{i});
            k=names1{i};


            switch k
            case{'gain'}
                fprintf(fileID,'%s',str);
                fprintf(fileID,' %.2f %s\r\n',DataStore.(names1{i}).value,DataStore.(names1{i}).unit);
            case{'name','make','tilt','polarization','comment'}
                fprintf(fileID,'%s',str);
                fprintf(fileID,' %s\r\n',DataStore.(names1{i}));
            case{'h_width','v_width','front_to_back'}
                fprintf(fileID,'%s',str);
                fprintf(fileID,' %.1f\r\n',DataStore.(names1{i}));
            case{'frequency'}
                fprintf(fileID,'%s',str);
                fprintf(fileID,' %.1f\r\n',(DataStore.(names1{i}))/1e6);
            otherwise
                fprintf(fileID,'%s',str);
                fprintf(fileID,' %s\r\n',DataStore.(names1{i}));
            end
        end
    end


    if nargin==3
        fprintf(fileID,'%s','FREQUENCY ');
        fprintf(fileID,'%.1f\r\n',(Horz.frequency)/1e6);
    end


    Horz.magnitude=reshape(Horz.magnitude,[length(Horz.magnitude),1]);
    Horz.angle=reshape(Horz.angle,[length(Horz.angle),1]);

    Vert.magnitude=reshape(Vert.magnitude,[length(Vert.magnitude),1]);
    Vert.angle=reshape(Vert.angle,[length(Vert.angle),1]);


    strgain=upper(Horz.slice);
    strgain1=upper(Vert.slice);


    fprintf(fileID,'%s%s%i\r\n',strgain,' ',Horz.size);
    fprintf(fileID,'%.2f %.2f\r\n',[Horz.angle';Horz.magnitude']);


    fprintf(fileID,'%s%s%i\r\n',strgain1,' ',Vert.size);
    fprintf(fileID,'%.2f %.2f\r\n',[Vert.angle';Vert.magnitude']);


    fclose(fileID);
end
