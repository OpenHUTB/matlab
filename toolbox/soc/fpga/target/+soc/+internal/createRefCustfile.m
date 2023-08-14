function createRefCustfile(boardName,exportBoardFolder,exportRefFolder)
    fid=fopen('hdlcoder_ref_design_customization.m','w');
    fprintf(fid,'function [rd, boardName] = hdlcoder_ref_design_customization \n');
    fprintf(fid,'rd = { ... \n');
    fprintf(fid,'    ''%s.%s.plugin_rd'', ... \n',exportBoardFolder(2:end),exportRefFolder(2:end));
    fprintf(fid,'    }; \n');
    fprintf(fid,'boardName = ''%s'';\n',boardName);
    fprintf(fid,'end \n');
    fclose(fid);
end
