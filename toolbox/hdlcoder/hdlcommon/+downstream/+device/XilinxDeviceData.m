


classdef XilinxDeviceData<downstream.device.DeviceData



    properties

        ToolPath='';

    end


    methods

        function obj=XilinxDeviceData(hDevice)

            obj=obj@downstream.device.DeviceData(hDevice);

        end

        function deviceData=getDeviceData(obj)











            fprintf('Updating supported device list ...');
            deviceData='';


            obj.ToolPath=obj.hDevice.hToolDriver.getToolPath;


            familyList=obj.getFPGAFamily;


            familyList=obj.filterCPLDFamily(familyList);

            for ii=1:length(familyList)
                familyStr=familyList{ii};

                [familyID,familyName,deviceList,packageList,speedList]=obj.getFPGADevice(familyStr);
                familyData='';
                for jj=1:length(deviceList)
                    deviceStr=deviceList{jj};
                    familyData.(deviceStr)=struct('package',packageList(jj),...
                    'speed',speedList(jj));
                end
                familyData.FamilyName=familyName;
                deviceData.(familyID)=familyData;
            end
            fprintf(' Done.\n');
        end

    end


    methods(Access=protected)

        function familyList=getFPGAFamily(obj)

            CmdStr=[fullfile(obj.ToolPath,'partgen'),' -arch'];
            [status,result]=system(CmdStr);
            if status
                error(message('hdlcommon:workflow:XilinxPartGenError',result));
            end
            archStr=result(regexp(result,'PartGen: Valid architectures are:','end')+1:end);


            archStr=obj.removePMSPEC(archStr);

            scanResult=textscan(archStr,'%s');
            familyList=scanResult{1};
        end

        function[familyID,familyName,deviceList,packageList,speedList]=...
            getFPGADevice(obj,familyStr)


            CmdStr=[fullfile(obj.ToolPath,'partgen'),' -arch ',familyStr];
            [status,result]=system(CmdStr);
            if status
                error(message('hdlcommon:workflow:XilinxPartGenError',result));
            end
            tempStr1=strrep(result,'(Minimum speed data available)','');
            deviceStr=tempStr1(regexpi(tempStr1,'All rights reserved.','end','once')+2:end);


            deviceStr=obj.removePMSPEC(deviceStr);

            scanResult=textscan(deviceStr,'%s');
            scanList=scanResult{1};

            familyName=deviceStr(1:regexpi(deviceStr,sprintf('\n'),'end','once')-1);
            familyID=regexprep(familyName,'[\s-]','_');

            deviceList={};
            packageList={};
            speedList={};
            for ii=1:length(scanList)
                if strcmpi(scanList{ii},'SPEEDS:')
                    deviceList{end+1}=scanList{ii-1};%#ok<AGROW>

                    packageGroup={};
                    speedGroup={};
                    jj=ii+1;
                    while jj<=length(scanList)&&~strcmpi(scanList{jj},'SPEEDS:')
                        curStr=scanList{jj};
                        if regexpi(curStr,'-\d')
                            if~any(strcmp(speedGroup,curStr))
                                speedGroup{end+1}=curStr;%#ok<AGROW>
                            end
                        else
                            packageGroup{end+1}=curStr;%#ok<AGROW>
                        end
                        jj=jj+1;
                    end

                    if jj==length(scanList)+1
                        packageList{end+1}=packageGroup;%#ok<AGROW>
                    else
                        packageList{end+1}=packageGroup(1:end-1);%#ok<AGROW>
                    end
                    speedList{end+1}=speedGroup;%#ok<AGROW>

                end
            end
        end

        function familyList=filterCPLDFamily(obj,familyList)

            CPLDList={...
            'acr2',...
            'xa9500xl',...
            'xbr',...
            'xc9500',...
            'xc9500xl',...
            'xc9500xv',...
            'xpla3',...
            };

            for ii=1:length(CPLDList)
                CPLDFamily=CPLDList{ii};
                familyList=familyList(~strcmpi(familyList,CPLDFamily));
            end

        end

        function outStr=removePMSPEC(obj,inStr)%#ok<*MANU>

            msgidx=regexp(inStr,'PMSPEC','once');
            if~isempty(msgidx)
                inStr=inStr(msgidx:end);
                tmpidx=regexp(inStr,'<[\w\\/:\-\.\s]*>','end');
                if length(tmpidx)==2
                    inStr(1:tmpidx(2)+1)=[];
                end
            end
            outStr=inStr;
        end

    end

end
