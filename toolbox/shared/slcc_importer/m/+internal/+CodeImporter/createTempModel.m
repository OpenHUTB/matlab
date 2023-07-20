function[hMdl,tmpMdlPath]=createTempModel(obj)


    tmpLibName="tmpLibPortMapping_"+cgxe('MD5AsString',datetime,rand);
    hMdl=new_system(tmpLibName,'library');
    internal.CodeImporter.updateLibraryConfigSetSettings(obj,hMdl);



    set_param(hMdl,'SimAnalyzeCustomCode','off');




    aStr=sprintf('/* %s */',tmpLibName);
    set_param(hMdl,'SimCustomSourceCode',aStr);


    tmpMdlPath=fullfile(obj.qualifiedSettings.OutputFolder,tmpLibName+".slx");
    save_system(hMdl,tmpMdlPath);
end