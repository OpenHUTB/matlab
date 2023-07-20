function createcustomclassfile(object)






    try
        if~isempty(object.packagename)
            filename=fullfile(object.customfilepath,strcat('+',object.packagename),...
            strcat('@',object.classname),strcat(object.classname,'.m'));
        else
            filename=fullfile(object.customfilepath,...
            strcat('@',object.classname),strcat(object.classname,'.m'));
        end
        file=fopen(filename,'w');

        fprintf(file,'classdef %s',object.classname);
        fprintf(file,' < %s\n\n',object.custombaseclass);
        fprintf(file,'    methods\n\n');
        fprintf(file,'        function ent = do_match(hThis, ...\n');
        fprintf(file,'                                hCSO, ... %%#ok\n');
        fprintf(file,'                                targetBitPerChar, ... %%#ok\n');
        fprintf(file,'                                targetBitPerShort, ... %%#ok\n');
        fprintf(file,'                                targetBitPerInt, ... %%#ok\n');
        fprintf(file,'                                targetBitPerLong ) %%#ok\n');
        fprintf(file,'            %% DO_MATCH - Create a custom match function. The base class\n');
        fprintf(file,'            %% checks the types of the arguments prior to calling this\n');
        fprintf(file,'            %% method. This will check additional data and perhaps modify\n');
        fprintf(file,'            %% the implementation function.\n');
        fprintf(file,'            %%\n\n');
        fprintf(file,'            ent = []; %% default the return to empty indicating the match failed.\n\n');
        fprintf(file,'            %%%%------------------------------------------------------------\n');
        fprintf(file,'            %%------------INSERT YOUR CODE HERE---------------------------\n');
        fprintf(file,'\n\n\n\n\n\n\n');
        fprintf(file,'            %%--------------------------------------------------------------\n\n');

        fprintf(file,'        end\n');
        fprintf(file,'    end\n');
        fprintf(file,'end\n');

        fclose(file);

    catch ME
        throwAsCaller(ME);
    end


