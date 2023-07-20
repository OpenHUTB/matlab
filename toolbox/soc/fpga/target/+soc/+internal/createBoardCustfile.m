function createBoardCustfile(exportBoardFolder)
    fid=fopen('hdlcoder_board_customization.m','w');
    fprintf(fid,'function r = hdlcoder_board_customization \n');
    fprintf(fid,'r = { ... \n');
    fprintf(fid,'    ''%s.plugin_board'', ... \n',exportBoardFolder(2:end));
    fprintf(fid,'    }; \n');
    fprintf(fid,'end \n');
    fclose(fid);
end
