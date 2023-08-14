function logmsg(msg)









    if mlreportgen.utils.internal.log
        stack=dbstack('-completenames');


        idx=find(cellfun(@(x)isempty(x),...
        regexp({stack.file},['\',filesep,mfilename,'\.m$'],'once'))...
        ,1);



        if isempty(idx)
            frameStr='base workspace';
        else
            file=stack(idx).file;
            line=stack(idx).line;
            relFilename=regexprep(file,[regexptranslate('escape',matlabroot),filesep],'','ignorecase');


            frameStr=sprintf('%s L.%i',relFilename,line);
            frameStr=sprintf('<a href="matlab: opentoline(''%s'',%i)">%s</a>',file,line,frameStr);

        end

        disp(['MLREPORTGEN: ',datestr(now,'yyyy-mm-dd HH:MM:SS:FFF'),' :: ',frameStr]);
        disp(msg);
    end
end