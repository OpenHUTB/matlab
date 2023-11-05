function generateDeviceList(vendor,outputFolder)

    if nargin==1
        disp('Generating device list in the current directory');
        outputFolder=pwd;
    end
    if~exist(outputFolder,'dir')
        error('Output folder %s does not exist',outputFolder);
    end

    switch vendor
    case 'Xilinx Vivado'
        fileName=fullfile(outputFolder,'getXilinxVivadoDeviceList.m');
        eda.internal.fpgadevice.generateVivadoDeviceList(fileName);
    case 'Altera'
        fileName=fullfile(outputFolder,'getAlteraDeviceList.m');
        familyList={'Cyclone III','Cyclone IV GX','Cyclone IV E','Arria II GX','Arria V','Cyclone V','Stratix IV','Stratix V','MAX 10','Arria 10','Cyclone 10 LP','Cyclone 10 GX'};

        l_generateQuartusDeviceList(familyList,fileName);
    otherwise

    end

end


function l_generateQuartusDeviceList(familyList,fileName)
    fid=fopen(fileName,'w');
    [r,s]=system('quartus_sh -version');
    if r
        error(message('EDALink:boardmanager:SysError',s));
    end
    ver=regexp(s,'Version.+?\n','match','once');

    onCleanupObj=onCleanup(@()fclose(fid));
    fprintf(fid,'function r = getAlteraDeviceList(varargin)\n');
    fprintf(fid,'    %% Generated using Altera Quartus %s\n',ver);
    l_printCellString(fid,'familyList',familyList);
    fprintf(fid,'    if nargin == 0\n');
    fprintf(fid,'        r = familyList;\n');
    fprintf(fid,'    else\n');
    fprintf(fid,'        family = varargin{1};\n');
    fprintf(fid,'        indx = find(strcmpi(family,familyList));\n');
    fprintf(fid,'        if indx == 1 \n');
    fprintf(fid,'            r = eda.internal.fpgadevice.getAlteraCycloneIIIDeviceList; \n');
    fprintf(fid,'        else \n');
    fprintf(fid,'            r = getDevice(indx);\n');
    fprintf(fid,'        end \n');
    fprintf(fid,'    end\n');
    fprintf(fid,'end\n\n');

    fprintf(fid,'function device = getDevice(idx)\n');

    for m=2:numel(familyList)
        deviceList=l_getQuartusDeviceList(familyList{m});
        if m==2
            fprintf(fid,'if');
        else
            fprintf(fid,'elseif');

        end
        fprintf(fid,' idx == %d\n',m);
        l_printCellString(fid,'device',deviceList);
    end
    fprintf(fid,'end\n');
    fprintf(fid,'end\n');
end

function list=l_getQuartusDeviceList(family)
    cmd=sprintf('quartus_sh --tcl_eval get_part_list -family "%s" ',family);
    [r,s]=system(cmd);
    if r&&~strcmp(family,"Cyclone 10 GX")
        error(message('EDALink:boardmanager:SysError',s));
    end
    tmp=textscan(s,'%s');
    list=tmp{1};
end
function l_printCellString(fid,varName,varValue)
    for m=1:numel(varValue)
        if m==1
            fprintf(fid,'    %s = {',varName);
        end
        if m<numel(varValue)
            fprintf(fid,'''%s'',...\n',varValue{m});
        else
            fprintf(fid,'''%s''};\n',varValue{m});
        end
    end
end


