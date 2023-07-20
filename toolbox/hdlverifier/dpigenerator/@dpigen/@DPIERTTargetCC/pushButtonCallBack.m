function pushButtonCallBack(hObj,~,tag)



    if strcmpi(tag,'EditDPISystemVerilogTemplate')
        curValue=hObj.getProp('DPISystemVerilogTemplate');
        cmd=['edit ',curValue];
        eval(cmd);
    elseif strcmpi(tag,'BrowseDPISystemVerilogTemplate')
        startPath=fullfile(matlabroot,'toolbox','hdlverifier','dpigenerator','rtw');
        [filename,~]=uigetfile('*.vgt','Select file template:',startPath);
        if~isequal(filename,0)
            hObj.setProp('DPISystemVerilogTemplate',filename);
        end
    end

