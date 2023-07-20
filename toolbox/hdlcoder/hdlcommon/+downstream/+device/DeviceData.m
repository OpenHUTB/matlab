




classdef DeviceData<handle



    properties











        TheDeviceData=[];


        hDevice=0;
    end

    properties(Access=protected,Hidden=true)
        xmlTab='';
    end


    methods

        function obj=DeviceData(hDevice)

            obj.hDevice=hDevice;

            obj.xmlTab='    ';

        end

        function setDeviceData(obj,deviceData)

            obj.TheDeviceData=deviceData;
        end


        function deviceData=getDeviceData(obj)%#ok<STOUT>



            error(message('hdlcommon:workflow:NeedXmlFile',obj.hDevice.PluginPath));
        end

    end


    methods(Access=public)

        function familyList=listFamily(obj)

            familyIDList=fields(obj.TheDeviceData);
            familyLength=length(familyIDList);
            familyList=cell(familyLength,1);
            for ii=1:familyLength
                familyStruct=obj.TheDeviceData.(familyIDList{ii});
                familyList{ii}=familyStruct.FamilyName;
            end
        end

        function deviceList=listDevice(obj,familyStr)

            familyData=obj.getFamilyField(familyStr);
            deviceListTemp=fields(familyData);
            deviceList=deviceListTemp(~strcmp(deviceListTemp,'FamilyName'));

            for ii=1:length(deviceList)
                deviceStr=deviceList{ii};
                if regexp(deviceStr,'^device_')
                    deviceStr=regexprep(deviceStr,'^device_','');
                end
                if regexp(deviceStr,'^underscore2hyphen_')
                    deviceStr=regexprep(deviceStr,'^underscore2hyphen_','');
                    deviceStr=strrep(deviceStr,'_','-');
                end

                deviceList{ii}=deviceStr;
            end
        end

        function packageList=listPackage(obj,familyStr,deviceStr)

            deviceData=obj.getDeviceField(familyStr,deviceStr);
            if isfield(deviceData,'package')&&~isempty(deviceData.package)
                packageList=deviceData.package;
            else
                packageList={''};
            end
        end

        function speedList=listSpeed(obj,familyStr,deviceStr)

            deviceData=obj.getDeviceField(familyStr,deviceStr);
            if isfield(deviceData,'speed')&&~isempty(deviceData.speed)
                speedList=deviceData.speed;
            else
                speedList={''};
            end
        end

        function resourceList=listResource(obj,familyStr,deviceStr)


            deviceData=obj.getDeviceField(familyStr,deviceStr);

            resourceList={deviceData.RAM,deviceData.DSP,deviceData.LUT};
        end
    end


    methods(Access=protected)

        function familyData=getFamilyField(obj,familyStr)

            familyID=obj.getFamilyID(familyStr);
            if~isfield(obj.TheDeviceData,familyID)
                error(message('hdlcommon:workflow:GetFamilyError',familyStr));
            end
            familyData=obj.TheDeviceData.(familyID);
        end

        function deviceData=getDeviceField(obj,familyStr,deviceStr)

            familyData=obj.getFamilyField(familyStr);
            if isfield(familyData,deviceStr)
                deviceData=familyData.(deviceStr);
            else

                deviceStrFix=sprintf('device_%s',deviceStr);
                if isfield(familyData,deviceStrFix)
                    deviceData=familyData.(deviceStrFix);
                else
                    deviceStrFix=sprintf('underscore2hyphen_%s',deviceStr);
                    deviceStrFix=strrep(deviceStrFix,'-','_');
                    if isfield(familyData,deviceStrFix)
                        deviceData=familyData.(deviceStrFix);
                    else
                        error(message('hdlcommon:workflow:GetDeviceError',deviceStr,familyStr));
                    end
                end
            end
        end

        function familyID=getFamilyID(~,familyName)
            familyID=regexprep(familyName,'+','__plus');
            familyID=regexprep(familyID,'[\s-]','_');
        end

    end


    methods(Access=public)

        function saveXML(obj,toolName,xmlFileName)


            if isempty(obj.TheDeviceData)
                error(message('hdlcommon:workflow:EmptyDeviceData'));
            end

            fid=fopen(xmlFileName,'w','n','ISO-8859-1');
            if fid==-1
                warning(message('hdlcommon:workflow:UnableCreateXMLFile',xmlFileName));
                return;
            end

            fprintf(fid,'<?xml version="1.0" encoding="ISO-8859-1"?>\n');
            if(strcmpi(toolName,'Xilinx ISE'))
                fprintf(fid,'<?xml-stylesheet type="text/xsl" href="../device_list_xilinx.xsl" ?>\n');
            elseif(strcmpi(toolName,'Xilinx Vivado'))
                fprintf(fid,'<?xml-stylesheet type="text/xsl" href="../device_list_xilinx_vivado.xsl" ?>\n');
            elseif(strcmpi(toolName,'Intel Quartus Pro'))
                fprintf(fid,'<?xml-stylesheet type="text/xsl" href="../device_list_intel_quartuspro.xsl" ?>\n');
            else
                fprintf(fid,'<?xml-stylesheet type="text/xsl" href="../device_list_altera.xsl" ?>\n');
            end

            fprintf(fid,'<DeviceData>\n');

            familyList=obj.listFamily;
            for ii=1:length(familyList)
                obj.printXMLFamily(fid,familyList{ii});
            end

            fprintf(fid,'</DeviceData>\n');
            fclose(fid);
        end

        function loadXML(obj,xmlFileName)


            fid=fopen(xmlFileName,'r');
            if fid==-1
                error(message('hdlcommon:workflow:UnableOpenXMLFile',xmlFileName));
            end

            lineStr=fgetl(fid);
            while ischar(lineStr)
                if regexpi(lineStr,'<DeviceData>')
                    obj.TheDeviceData='';
                elseif regexpi(lineStr,'<Family id="\w*"')
                    tokens=regexpi(lineStr,'<Family id="(\w*)" name="([\w- +]*)">','tokens','once');
                    if length(tokens)~=2
                        error(message('hdlcommon:workflow:InvalidFamlyData',xmlFileName));
                    end
                    familyID=tokens{1};
                    familyName=tokens{2};
                    familyData=obj.loadXMLFamily(fid);
                    familyData.FamilyName=familyName;
                    obj.TheDeviceData.(familyID)=familyData;
                elseif regexpi(lineStr,'</DeviceData>')
                    break;
                end
                lineStr=fgetl(fid);
            end
            fclose(fid);
        end

    end

    methods(Access=protected)

        function familyData=loadXMLFamily(obj,fid)
            lineStr=fgetl(fid);
            while ischar(lineStr)
                if regexpi(lineStr,'<Device name="[\w-]*">')
                    startPos=regexpi(lineStr,'<Device name="','end','once')+1;
                    endPos=regexpi(lineStr,'">','start','once')-1;
                    deviceStr=lineStr(startPos:endPos);
                    deviceData=obj.loadXMLDevice(fid);

                    if regexp(deviceStr,'^\d')
                        deviceStr=sprintf('device_%s',deviceStr);
                    end
                    try
                        if regexp(deviceStr,'-')
                            deviceStr=strrep(deviceStr,'-','_');
                            deviceStr=sprintf('underscore2hyphen_%s',deviceStr);
                        end

                        familyData.(deviceStr)=deviceData;
                    catch e
                        e.getReport;
                    end
                elseif regexpi(lineStr,'</Family>')
                    return;
                end
                lineStr=fgetl(fid);
            end
        end

        function deviceData=loadXMLDevice(~,fid)
            deviceData.package={};
            deviceData.speed={};
            lineStr=fgetl(fid);
            while ischar(lineStr)
                if regexpi(lineStr,'<Package>')
                    startPos=regexpi(lineStr,'<Package>','end','once')+1;
                    endPos=regexpi(lineStr,'</Package>','start','once')-1;
                    packageStr=lineStr(startPos:endPos);
                    deviceData.package{end+1}=packageStr;
                elseif regexpi(lineStr,'<Speed>')
                    startPos=regexpi(lineStr,'<Speed>','end','once')+1;
                    endPos=regexpi(lineStr,'</Speed>','start','once')-1;
                    speedStr=lineStr(startPos:endPos);
                    deviceData.speed{end+1}=speedStr;
                elseif regexpi(lineStr,'</Device>')
                    return;
                end
                lineStr=fgetl(fid);
            end
        end

        function printXMLFamily(obj,fid,familyStr)
            familyID=obj.getFamilyID(familyStr);
            fprintf(fid,'%s<Family id="%s" name="%s">\n',obj.xmlTab,familyID,familyStr);
            deviceList=obj.listDevice(familyStr);
            for ii=1:length(deviceList)
                obj.printXMLDevice(fid,familyStr,deviceList{ii});
            end
            fprintf(fid,'%s</Family>\n',obj.xmlTab);
        end

        function printXMLDevice(obj,fid,familyStr,deviceStr)
            fprintf(fid,'%s%s<Device name="%s">\n',obj.xmlTab,obj.xmlTab,deviceStr);

            packageList=obj.listPackage(familyStr,deviceStr);
            for ii=1:length(packageList)
                obj.printXMLPackage(fid,packageList{ii});
            end

            speedList=obj.listSpeed(familyStr,deviceStr);
            for ii=1:length(speedList)
                obj.printXMLSpeed(fid,speedList{ii});
            end

            deviceData=obj.getDeviceField(familyStr,deviceStr);
            if(any(isfield(deviceData,{'RAM','LUT','DSP'})))
                resourceList=obj.listResource(familyStr,deviceStr);
                obj.printXMLResource(fid,resourceList);
            end

            fprintf(fid,'%s%s</Device>\n',obj.xmlTab,obj.xmlTab);
        end

        function printXMLPackage(obj,fid,packageStr)
            if~isempty(packageStr)
                fprintf(fid,'%s%s%s<Package>%s</Package>\n',obj.xmlTab,obj.xmlTab,obj.xmlTab,packageStr);
            end
        end

        function printXMLSpeed(obj,fid,speedStr)
            if~isempty(speedStr)
                fprintf(fid,'%s%s%s<Speed>%s</Speed>\n',obj.xmlTab,obj.xmlTab,obj.xmlTab,speedStr);
            end
        end

        function printXMLResource(obj,fid,resource)
            if~isempty(resource)
                fprintf(fid,'%s%s%s<RAM>%s</RAM>\n',obj.xmlTab,obj.xmlTab,obj.xmlTab,resource{1});
                fprintf(fid,'%s%s%s<DSP>%s</DSP>\n',obj.xmlTab,obj.xmlTab,obj.xmlTab,resource{2});
                fprintf(fid,'%s%s%s<LUT>%s</LUT>\n',obj.xmlTab,obj.xmlTab,obj.xmlTab,resource{3});
            end
        end
    end

end
