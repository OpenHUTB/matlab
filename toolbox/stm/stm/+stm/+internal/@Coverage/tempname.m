

function filename=tempname()
    [~,name,~]=fileparts(tempname);
    folder=tempname;
    mkdir(folder);
    filename=[folder,filesep,name,'.cvt'];
end