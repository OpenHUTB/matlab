


function currentDateNum=getCurrentDateNum()

    temp_folder=tempname;
    mkdir(temp_folder);
    cc=dir(temp_folder);
    currentDateNum=cc(1).datenum;
    rmdir(temp_folder)

end