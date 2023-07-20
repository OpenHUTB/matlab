function[Z,latlim,lonlim]=dtedread(filename)






    filename=convertStringsToChars(filename);
    validateattributes(filename,{'char','string'},{'scalartext'},mfilename,'FILENAME',1);


    fileID=-1;
    if~isempty(filename)
        fileID=fopen(filename,'rb','ieee-be');
    end
    if fileID==-1
        Z=[];
        latlim=[];
        lonlim=[];
        return
    else
        clean=onCleanup(@()fclose(fileID));
    end


    [~,DSI,~]=terrain.internal.dted.readHeaders(fileID);


    latlim=[...
    terrain.internal.dted.decodeDMS(DSI.LatitudeofSWcorner),...
    terrain.internal.dted.decodeDMS(DSI.LatitudeofNWcorner)];

    lonlim=[...
    terrain.internal.dted.decodeDMS(DSI.LongitudeofSWcorner),...
    terrain.internal.dted.decodeDMS(DSI.LongitudeofSEcorner)];

    dlat=secstr2deg(DSI.Latitudeinterval);
    dlon=secstr2deg(DSI.Longitudeinterval);
    ncols=round(diff(latlim/dlat))+1;
    nrows=round(diff(lonlim/dlon))+1;


    Z=readgrid(fileID,nrows,ncols);



    function deg=secstr2deg(str)



        deg=str2double(str)/36000;



        function Z=readgrid(fileID,nrows,ncols)






            fseek(fileID,0,1);
            eof=ftell(fileID);
            fseek(fileID,0,-1);

            precision=[num2str(ncols),'*','int16'];
            nheadbytes=3428;
            nRowHeadBytes=8;
            nRowTrailBytes=4;
            dirlisting=dir(fopen(fileID));
expectedFileBytes...
            =nheadbytes+nrows*(nRowHeadBytes+2*ncols+nRowTrailBytes);
            nFileTrailBytes=max(0,dirlisting.bytes-expectedFileBytes);


            fieldlen=2;
            recordlen=nRowHeadBytes+fieldlen*ncols+nRowTrailBytes;


            expectedfilesize=nheadbytes+nrows*recordlen+nFileTrailBytes;
            if(expectedfilesize~=eof)
                error(message('shared_terrain:dted:InconsistentFileSize',...
                num2str(expectedfilesize),num2str(eof)))
            end


            byteskip=nheadbytes+nRowHeadBytes;
            fseek(fileID,byteskip,'bof');


            byteskip=nRowTrailBytes+nRowHeadBytes;
            [Z,count]=fread(fileID,nrows*ncols,precision,byteskip);

            if count~=nrows*ncols
                error(message('shared_terrain:dted:UnexpectedElementCount',nrows*ncols,count));
            end


            Z=(reshape(Z,ncols,length(Z)/ncols))';
            Z=Z';
            Z=terrain.internal.dted.correctZData(Z);
