function[DSP,LUT,RAM]=getAvailableCount(tool,device)









    import matlab.io.xml.dom.*
    xmlFile=(fullfile(matlabroot,...
    'toolbox','hdlcoder','hdlcommon','+downstreamtools',tool,'device_list.xml'));
    xDoc=parseFile(Parser,xmlFile);



    deviceList=xDoc.getElementsByTagName('Device');


    for i=0:deviceList.getLength-1
        thisDevice=deviceList.item(i);
        deviceName=thisDevice.getAttribute("name");
        if(strcmpi(deviceName,device))


            ram=thisDevice.getElementsByTagName("RAM");

            RAM=str2double(ram.item(0).getTextContent);
            dsp=thisDevice.getElementsByTagName("DSP");

            DSP=str2double(dsp.item(0).getTextContent);
            lut=thisDevice.getElementsByTagName("LUT");

            LUT=str2double(lut.item(0).getTextContent);
            break;
        end
    end
end
