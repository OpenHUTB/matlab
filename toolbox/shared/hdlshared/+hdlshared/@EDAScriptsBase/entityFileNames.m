function filenames=entityFileNames(~)

    hCurrentDriver=hdlcurrentdriver;
    filenames=hCurrentDriver.cgInfo.hdlFiles;
end
