function viewFile(h,fileName,viewPriority)








    if nargin<3
        viewPriority=2;
    end



    if h.ViewFiles>=viewPriority
        [fPath,fName,fExt]=fileparts(fileName);
        if isempty(fPath)
            fPath=h.ClassDir;
        end
        if isempty(fExt)
            fExt='.m';
        end

        fileName=fullfile(fPath,[fName,fExt]);

        edit(fileName);
    end