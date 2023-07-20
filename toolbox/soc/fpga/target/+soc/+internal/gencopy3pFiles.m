function gencopy3pFiles(pluginrdInfo)

    [~,exportbrdpath]=fileparts(pluginrdInfo.exportBoardDir);
    [~,exportrdpath]=fileparts(pluginrdInfo.exportDirectory);
    genricPath=sprintf('%s.%s',exportbrdpath(2:end),exportrdpath(2:end));
    fid=fopen('copy3pFiles.m','w');
    fprintf(fid,'function copy3pFiles\n');
    fprintf(fid,'%% validate if adi 3p is registered\n');
    fprintf(fid,'adi_dir = matlab.internal.get3pInstallLocation(''analogdevices-hdl.instrset'');\n');
    fprintf(fid,'if isempty(adi_dir)\n');
    fprintf(fid,'%sadi_dir = matlab.internal.get3pInstallLocation(''analogdevices-hdl_soc.instrset'');\n',getTabStr(1));
    fprintf(fid,'end\n');

    fprintf(fid,'if ~isfolder(adi_dir)\n');
    fprintf(fid,'%serror(message(''hdlcommon:plugin:ADIHDLNotFound'',''%s'').getString);\n',getTabStr(1),genricPath);
    fprintf(fid,'end\n');

    fprintf(fid,'%% copy code\n');
    fprintf(fid,'rdFolder = fileparts(mfilename(''fullpath''));\n');
    fprintf(fid,'[srcList,dstList] = exportBoard.exportDesign.list3pFiles;\n');
    fprintf(fid,'for i = 1:numel(dstList)\n');
    fprintf(fid,'%scopyfile(fullfile(adi_dir,srcList{i}),fullfile(rdFolder,''ipcore'',dstList{i}),''f'');\n',getTabStr(1));
    fprintf(fid,'end\n');
    fclose(fid);
end
function tabs=getTabStr(num)
    tab='    ';
    tabs='';
    if eq(num,1)
        tabs=tab;
    else
        for nn=1:num
            tabs=[tabs,tab];%#ok<AGROW>
        end
    end
end