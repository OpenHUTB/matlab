function jsonDiff=decodeAndSave(fileName1,fileName2,textFile1,textFile2)

    import com.mathworks.comparisons.review.SaveFileOnDisk
    import slxmlcomp.internal.review.doDiff

    tempDirectory=tempname;
    c=onCleanup(@()rmdir(tempDirectory,'s'));

    filePath1=fullfile(tempDirectory,'left_file',fileName1);
    filePath2=fullfile(tempDirectory,'right_file',fileName2);

    decoder1=SaveFileOnDisk(string(filePath1),string(textFile1));
    decoder2=SaveFileOnDisk(string(filePath2),string(textFile2));
    decoder1.decodeFile();
    decoder2.decodeFile();

    jsonDiff=doDiff(string(filePath1),string(filePath2));

end

