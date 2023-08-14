




classdef XilinxVivadoDeviceData<downstream.device.DeviceData













    properties

        ToolPath='';
        deviceMap=[];
        nameMap=[];
        olderXilinxFamilyList={};
        olderHDLWAFamilyList=[];

    end


    methods

        function obj=XilinxVivadoDeviceData(hDevice)

            obj=obj@downstream.device.DeviceData(hDevice);


            obj.nameMap=containers.Map();
            obj.nameMap('artix7')='Artix7';
            obj.nameMap('kintex7')='Kintex7';
            obj.nameMap('virtex7')='Virtex7';
            obj.nameMap('spartan7')='Spartan7';
            obj.nameMap('kintexu')='KintexU';
            obj.nameMap('virtexu')='VirtexU';
            obj.nameMap('zynq')='Zynq';
            obj.nameMap('kintexuplus')='Kintex UltraScale+';
            obj.nameMap('virtexuplus')='Virtex UltraScale+';
            obj.nameMap('zynquplus')='Zynq UltraScale+';
            obj.nameMap('zynquplusRFSOC')='Zynq UltraScale+ RFSoC';
            obj.nameMap('virtexuplusHBM')='Virtex UltraScale+ HBM';
            obj.nameMap('virtexuplus58g')='Virtex UltraScale+ 58G';
            obj.nameMap('versal')='Versal AI Core';

            obj.deviceMap=containers.Map();




            obj.olderXilinxFamilyList={...
            'aartix7',...
            'artix7',...
            'artix7l',...
            'azynq',...
            'kintex7',...
            'kintex7l',...
            'qartix7',...
            'qkintex7',...
            'qkintex7l',...
            'qvirtex7',...
            'qzynq',...
            'virtex7',...
            'zynq'};

            obj.olderHDLWAFamilyList=containers.Map();
            obj.olderHDLWAFamilyList('Artix7')='';
            obj.olderHDLWAFamilyList('Kintex7')='';
            obj.olderHDLWAFamilyList('Virtex7')='';
            obj.olderHDLWAFamilyList('Zynq')='';

        end

        function deviceData=getDeviceData(obj)














            fprintf('Updating supported device list ...');
            deviceData='';


            obj.ToolPath=obj.hDevice.hToolDriver.getToolPath;

            obj.buildEverything();

            families=obj.deviceMap.keys();

            for fmid=1:numel(families)

                family=families{fmid};
                devices=obj.deviceMap(family).keys();
                deviceM=obj.deviceMap(family);
                familyData='';
                for devid=1:numel(devices)

                    packageMap=deviceM(devices{devid});
                    packages=packageMap.keys();
                    pkgStr=packageMap(packages{1});
                    speed=strsplit(strtrim(pkgStr{1}));


                    RAM=strtrim(pkgStr{2});
                    DSP=strtrim(pkgStr{3});
                    LUT=strtrim(pkgStr{4});
                    deviceStr=devices{devid};

                    if regexp(deviceStr,'-')
                        deviceStr=strrep(deviceStr,'-','_');
                        deviceStr=sprintf('underscore2hyphen_%s',deviceStr);
                    end

                    if obj.olderHDLWAFamilyList.isKey(family)


                        familyData.(deviceStr)=struct('package',{packages},...
                        'speed',{speed},'RAM',RAM,'DSP',DSP,'LUT',LUT);
                    else


                        familyData.(deviceStr)=struct('RAM',RAM,...
                        'DSP',DSP,'LUT',LUT);
                    end

                end
                familyData.FamilyName=family;
                familyID=regexprep(family,'[\+]','__plus');
                familyID=regexprep(familyID,'[\s-]','_');
                deviceData.(familyID)=familyData;

            end


            fprintf(' Done.\n');
        end

    end


    methods(Access=protected)



        function printDeviceDataCommandString(obj,fid)



            fprintf(fid,'set fid1 [open "vivado_device_list.txt" "w"]\n');
            fprintf(fid,'set Families  [split [lsort -uniq [get_property FAMILY [get_parts] ] ] ]\n');
            fprintf(fid,'foreach family $Families { \n');


            fprintf(fid,'  if { ');
            for ii=1:(length(obj.olderXilinxFamilyList)-1)
                fprintf(fid,'[string compare -nocase "%s" "$family"] == 0 || ',obj.olderXilinxFamilyList{ii});
            end
            fprintf(fid,'[string compare -nocase "%s" "$family"] == 0 } {\n',obj.olderXilinxFamilyList{end});


            fprintf(fid,'    set FamilyName [split [lsort -uniq [get_property ARCHITECTURE [get_parts -filter "FAMILY==$family" ] ] ] ]\n');
            fprintf(fid,'    set Devices [split [lsort -uniq [get_property DEVICE [get_parts -filter "FAMILY==$family" ] ] ] ]\n');
            fprintf(fid,'    foreach device $Devices {\n');
            fprintf(fid,'      set Packages [split [lsort -uniq [get_property PACKAGE [get_parts -filter "FAMILY==$family && DEVICE==$device" ] ] ]]\n');



            fprintf(fid,'      set RAM [lsort -uniq [get_property BLOCK_RAMS [get_parts -filter "FAMILY==$family && DEVICE==$device" ] ] ]\n');
            fprintf(fid,'      set DSP [lsort -uniq [get_property DSP [get_parts -filter "FAMILY==$family && DEVICE==$device" ] ] ]\n');
            fprintf(fid,'      set LUT [lsort -uniq [get_property LUT_ELEMENTS [get_parts -filter "FAMILY==$family && DEVICE==$device"] ] ]\n');
            fprintf(fid,'      foreach package $Packages {\n');
            fprintf(fid,'        set Speeds [lsort -uniq [get_property SPEED [get_parts -filter "FAMILY==$family && DEVICE==$device && PACKAGE==$package" ] ] ]\n');
            fprintf(fid,'        puts $fid1 "Family : $family, Architecture : $FamilyName, Device : $device, Package : $package, Speed : $Speeds, RAM : $RAM, DSP : $DSP, LUT : $LUT"\n');
            fprintf(fid,'      }\n');
            fprintf(fid,'    }\n');
            fprintf(fid,'  } else {\n');


            fprintf(fid,'    set FamilyName [split [lsort -uniq [get_property ARCHITECTURE [get_parts -filter "FAMILY==$family" ] ] ] ]\n');
            fprintf(fid,'    set Devices [split [lsort -uniq [get_parts -filter "FAMILY==$family" ] ] ]\n');
            fprintf(fid,'    foreach device $Devices {\n');

            fprintf(fid,'      set RAM [get_property BLOCK_RAMS [get_parts -regexp $device] ] \n');
            fprintf(fid,'      set DSP [get_property DSP [get_parts -regexp $device] ] \n');
            fprintf(fid,'      set LUT [get_property LUT_ELEMENTS [get_parts -regexp $device] ] \n');
            fprintf(fid,'      puts $fid1 "Family : $family, Architecture : $FamilyName, Device : $device, Package : None, Speed : None, RAM : $RAM , DSP : $DSP, LUT : $LUT"');
            fprintf(fid,'    }\n');
            fprintf(fid,'  }\n');
            fprintf(fid,'}\n');
            fprintf(fid,'close $fid1\n');

        end

        function addEntry(obj,entry)

            if~obj.nameMap.isKey(entry.family)
                error('tech mapping %s not found',entry.family);
            end

            family=obj.nameMap(entry.family);

            if~obj.deviceMap.isKey(family)
                obj.deviceMap(family)=containers.Map();
            end
            familyMap=obj.deviceMap(family);
            if~obj.deviceMap(family).isKey(entry.device)
                familyMap(entry.device)=containers.Map();
            end

            dMap=familyMap(entry.device);

            if dMap.isKey(entry.package)

                error('Entry already exist');

            end

            dMap(entry.package)={entry.speed,entry.RAM,entry.DSP,entry.LUT};%#ok<NASGU>


        end


        function executeQuery(obj)



            fid=fopen('vivado_list_devices.tcl','w');
            obj.printDeviceDataCommandString(fid);
            fclose(fid);
            vivadoStr=fullfile(obj.hDevice.hToolDriver.getToolPath,'vivado');
            commandStr=[vivadoStr,' -mode batch -source vivado_list_devices.tcl'];
            [status,~]=system(commandStr);

            if status
                error('Vivado command failed');
            end


        end

        function buildEverything(obj)
            obj.executeQuery();
            fid=fopen('vivado_device_list.txt','r');
            obj.deviceMap=containers.Map();


            pattern1='Family\s*:\s*(?<FamilyReal>\w+)\s*,\s*Architecture\s*:\s*(?<family>\w+)\s*,\s*Device\s*:\s*(?<device>[^,\s]+)\s*,\s*Package\s*:\s*(?<package>\w+)\s*,\s*Speed\s*:\s*(?<speed>.*),\s*RAM\s*:\s*(?<RAM>.*),\s*DSP\s*:\s*(?<DSP>.*),\s*LUT\s*:\s*(?<LUT>.*)';
            tline=fgets(fid);
            while ischar(tline)
                entry=regexp(tline,pattern1,'names');
                if(~isempty(entry.family))
                    obj.addEntry(entry);
                    tline=fgets(fid);
                end
            end
            fclose(fid);
        end


        function familyList=getFPGAFamily(obj)


            familyList=obj.deviceMap.keys();
        end


    end

end




