function makeConstructor(h)




    fid=h.openFile([h.ClassName,'.m']);

    fwrite(fid,sprintf(['function c=%s(varargin)\n',...
    '%%%s Report Generator component constructor\n'],...
    h.ClassName,...
    upper(h.ClassName)));

    h.writeHeader(fid);

    fprintf(fid,'%% ***************************************************** \n');
    fprintf(fid,'%% * This constructor file will change in a future     * \n');
    fprintf(fid,'%% * version of MATLAB.  Modifying this file could     * \n');
    fprintf(fid,'%% * prevent automatic conversion of this class        * \n');
    fprintf(fid,'%% * in the future.                                    * \n');
    fprintf(fid,'%% ***************************************************** \n\n');


    fwrite(fid,sprintf(['%%@CONSTRUCTOR\n',...
    'c = feval(mfilename(''class''));\n',...
    'c.init(varargin{:});\n']));

    fclose(fid);

    if h.isWriteHeader

        h.viewFile([h.ClassName,'.m']);
    else
        try
            pcode(fullfile(h.ClassDir,[h.ClassName,'.m']),'-inplace');
        catch ME
            warning('rptgen:ComponentMaker:PcodeFailure',ME.message);
        end
        delete(fullfile(h.ClassDir,[h.ClassName,'.m']));
    end



