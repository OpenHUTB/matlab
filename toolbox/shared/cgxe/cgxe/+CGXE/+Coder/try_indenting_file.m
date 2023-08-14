function try_indenting_file(fileName)



    try
        c_beautifier(fileName);
    catch ME %#ok<NASGU>
    end
