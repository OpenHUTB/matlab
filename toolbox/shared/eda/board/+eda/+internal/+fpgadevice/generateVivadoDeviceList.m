function generateVivadoDeviceList(filename)

    if nargin==0
        filename='getXilinxVivadoDeviceList.m';
    end

    familyList=eda.internal.fpgadevice.getXilinxVivadoFPGAFamilies;

    nameMap=containers.Map();
    nameMap('Artix7')='artix7';
    nameMap('Kintex7')='kintex7';
    nameMap('Virtex7')='virtex7';
    nameMap('KintexU')='kintexu';
    nameMap('VirtexU')='virtexu';
    nameMap('Zynq')='zynq';
    nameMap('Kintex UltraScale+')='kintexuplus';
    nameMap('Virtex UltraScale+')='virtexuplus';
    nameMap('Zynq UltraScale+')='zynquplus';
    nameMap('Zynq UltraScale+ RFSoC')='zynquplusRFSOC';
    nameMap('Spartan7')='spartan7';



    for m=1:numel(familyList)
        if~nameMap.isKey(familyList{m})
            error('Family %s is not added to map table',familyList{m});
        end
    end


    l_runVivado;


    deviceMap=l_buildDeviceList(nameMap);

    l_writeFPGAPartList(deviceMap,filename);
end

function l_runVivado

    str=...
    {...
    'set Families  [split [lsort -uniq [get_property FAMILY [get_parts] ] ] ]',...
    'foreach family $Families { ',...
    ' set fid1 [open "$family.txt" "w"]',...
    ' set specialfamily {virtex7 kintex7 artix7 zynq}',...
    ' if {[lsearch $specialfamily $family] >= 0} {',...
    '   puts $fid1 "$family"',...
    '   set Devices [lsort -unique [get_property DEVICE [get_parts -filter "FAMILY==$family" ]]]',...
    '   foreach device $Devices {',...
    '     set Packages [lsort -unique [get_property PACKAGE [get_parts -filter "DEVICE==$device"]]]',...
    '     set Speeds [lsort -unique [get_property SPEED [get_parts -filter "DEVICE==$device"]]]',...
    '     puts $fid1 "$device"',...
    '     puts $fid1 "$Packages"',...
    '     puts $fid1 "$Speeds"',...
    '   }',...
    ' } else {',...
    '   set Devices [get_parts -filter "FAMILY==$family" ]',...
    '   puts $fid1 "$family"',...
    '   puts $fid1 "$Devices"',...
    ' } ',...
    ' close $fid1',...
    '}',...
    };

    fid=fopen('vivado_list_devices.tcl','w');
    for i=1:numel(str)
        fprintf(fid,'%s\n',str{i});
    end
    fclose(fid);
    vivadoStr='vivado';
    commandStr=[vivadoStr,' -mode batch -source vivado_list_devices.tcl'];
    [status,r]=system(commandStr);

    if status
        error('Vivado command failed with message %s',r);
    end
end


function deviceMap=l_buildDeviceList(nameMap)
    families=nameMap.keys;
    deviceMap=containers.Map();

    for i=1:numel(families)
        family=nameMap(families{i});
        filename=[family,'.txt'];
        fid=fopen(filename,'r');


        fgetl(fid);

        switch family
        case{'virtex7','kintex7','artix7','zynq'}
            deviceList={};
            while~feof(fid)
                device=fgetl(fid);
                package=fgetl(fid);
                speed=fgetl(fid);

                r=textscan(package,'%s','Delimiter',' ');
                package=r{1};
                r=textscan(speed,'%s','Delimiter',' ');
                speed=r{1};

                deviceList=[deviceList,{device,package,speed}];%#ok<AGROW>
            end
            deviceMap(families{i})=deviceList;
        otherwise
            device_list=fgetl(fid);
            r=textscan(device_list,'%s','Delimiter',' ');
            deviceMap(families{i})=r{1};
        end

        fclose(fid);
    end
end

function l_writeFPGAPartList(deviceMap,fileName)
    fid=fopen(fileName,'w');
    familyList=deviceMap.keys;
    onCleanupObj=onCleanup(@()fclose(fid));
    fprintf(fid,'function r = getXilinxVivadoDeviceList(varargin)\n');
    l_printCellString(fid,'familyList',familyList);
    fprintf(fid,'    if nargin == 0\n');
    fprintf(fid,'        r = familyList;\n');
    fprintf(fid,'    else\n');
    fprintf(fid,'        family = varargin{1};\n');
    fprintf(fid,'        indx = find(strcmpi(family,familyList));\n');
    fprintf(fid,'           if nargin==1\n');
    fprintf(fid,'               r = getDevice(indx);\n');
    fprintf(fid,'           else\n');
    fprintf(fid,'               r = getDevice(indx,varargin{2:end});\n');
    fprintf(fid,'           end\n');
    fprintf(fid,'    end\n');
    fprintf(fid,'end\n');
    fprintf(fid,'function r = getDevice(idx,varargin)\n');

    for m=1:numel(familyList)
        if m==1
            fprintf(fid,'    if');
        else
            fprintf(fid,'    elseif');
        end
        fprintf(fid,' idx == %d\n',m);
        d=deviceMap(familyList{m});
        if iscell(d{2})
            devices=d(1:3:end);
            package=d(2:3:end);
            speed=d(3:3:end);
            fprintf(fid,'        if nargin==1\n');
            l_printCellString(fid,'        r',devices);
            fprintf(fid,'        elseif nargin==3\n');
            for i=1:numel(devices)
                if i==1
                    keyword='if';
                else
                    keyword='elseif';
                end
                fprintf(fid,'            %s strcmpi(varargin{1},''%s'')\n',keyword,devices{i});
                fprintf(fid,'                if strcmpi(varargin{2},''package'')\n');
                l_printCellString(fid,'                    r',package{i});
                fprintf(fid,'                elseif strcmpi(varargin{2},''speed'')\n');
                l_printCellString(fid,'                    r',speed{i});
                fprintf(fid,'                end\n');
            end
            fprintf(fid,'            end\n');
            fprintf(fid,'        end\n');
        else
            fprintf(fid,'        if nargin==1\n');
            l_printCellString(fid,'        r',deviceMap(familyList{m}));
            fprintf(fid,'        else\n');
            fprintf(fid,'            r = {''''};\n');
            fprintf(fid,'        end\n');
        end
    end
    fprintf(fid,'    end\n');
    fprintf(fid,'end\n');
end


function l_printCellString(fid,varName,varValue)
    for m=1:numel(varValue)
        if m==1
            fprintf(fid,'    %s = {',varName);
        end
        fprintf(fid,'''%s'',',varValue{m});
        if m==numel(varValue)
            fprintf(fid,'};\n');
        end
    end
end
