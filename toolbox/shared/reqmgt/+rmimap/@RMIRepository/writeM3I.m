function writeM3I(reqFileName,srcRoot)
    wf=M3I.XmiWriterFactory();
    wrt=wf.createXmiWriter();
    try
        wrt.write(reqFileName,srcRoot.asImmutable);
    catch ex
        error(message('Slvnv:rmigraph:FailedToSave',reqFileName));
    end
    delete(wrt);

end
