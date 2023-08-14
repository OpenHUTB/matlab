function data=getAudioData
    data=[];
    userdir=connector.internal.userdir;
    filename=[userdir,'/','audio.wav'];
    if(exist(filename))
        fid=fopen(filename,'r');
        data=fread(fid,'int8');
        fclose(fid);
    end
end
