


classdef IntelQuartusProDeviceData<downstream.device.DeviceData



    properties

        ToolPath='';

    end


    methods

        function obj=IntelQuartusProDeviceData(hDevice)

            obj=obj@downstream.device.DeviceData(hDevice);

        end

        function deviceData=getDeviceData(obj)










            fprintf('Updating supported device list ...');
            deviceData='';


            obj.ToolPath=obj.hDevice.hToolDriver.getToolPath;


            familyList=obj.getFPGAFamily;




            for ii=1:length(familyList)
                familyStr=familyList{ii};

                [familyID,familyName,deviceList]=obj.getFPGADevice(familyStr);
                familyData='';
                for jj=1:length(deviceList)
                    deviceStr=deviceList{jj};

                    if regexp(deviceStr,'^\d')
                        deviceStr=sprintf('device_%s',deviceStr);
                    end
                    familyData.(deviceStr)=[];
                end
                familyData.FamilyName=familyName;
                deviceData.(familyID)=familyData;
            end
            fprintf(' Done.\n');
        end

    end


    methods(Access=protected)

        function familyList=getFPGAFamily(obj)

            CmdStr=[fullfile(obj.ToolPath,'quartus_sh'),' --tcl_eval get_family_list'];
            [status,result]=system(CmdStr);

            if status
                error(message('hdlcommon:workflow:AlteraDeviceError',result));
            end


            strrep(result,newline,'');


            regexpList=regexp(result,'{([\w\s]*)}','tokens');
            nameList=cell(1,length(regexpList));
            for ii=1:length(regexpList)
                nameList{ii}=regexpList{ii}{1};
            end


            singleNameStr=regexprep(result,'{[\w\s]*}','');

            scanResult=textscan(singleNameStr,'%s');
            scanList=scanResult{1}';


            familyList=[nameList,scanList];
            familyList=sort(familyList);
        end

        function[familyID,familyName,deviceList]=getFPGADevice(obj,familyStr)


            CmdStr=[fullfile(obj.ToolPath,'quartus_sh'),...
            sprintf(' --tcl_eval get_part_list -family "%s"',familyStr)];
            [status,result]=system(CmdStr);
            if status
                error(message('hdlcommon:workflow:XilinxPartGenError',result));
            end
            idx=strfind(result,'Inconsistency');
            while(~isempty(idx))
                idx1=strfind(result(idx(1):end),char(10));
                result=[result(1:idx(1)-2),result(idx(1)+idx1(1):end)];
                idx=strfind(result,'Inconsistency');
            end

            scanResult=textscan(result,'%s');
            scanList=scanResult{1};

            familyName=familyStr;
            familyID=regexprep(familyName,'[\s-]','_');

            deviceList=scanList;
        end

    end

end


