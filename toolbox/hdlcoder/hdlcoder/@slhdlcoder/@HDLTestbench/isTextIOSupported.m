function isSupported=isTextIOSupported(this,disp)




    if nargin<2
        disp=0;
    end
    hD=hdlcurrentdriver;
    paramIsOn=hdlgetparameter('UseFileIOInTestBench');
    emitRealMsg=false;
    emitEnumMsg=false;
    isSupported=this.useFileIO;
    if isempty(isSupported)
        isSupported=true;
        if paramIsOn

            allTypes={};
            if~isempty(this.InportSrc)
                allTypes={this.InportSrc(:).PortSLType};
            end
            if~isempty(this.OutportSnk)
                allTypes=[allTypes,this.OutportSnk(:).PortSLType];
            end

            if~targetcodegen.targetCodeGenerationUtils.isFloatingPointMode()&&(any(strcmp('double',allTypes))||any(strcmp('single',allTypes)))
                emitRealMsg=true;
                isSupported=false;
            elseif any(cellfun(@isSLEnumType,allTypes))
                emitEnumMsg=true;
                isSupported=false;
            end
        else
            isSupported=false;
        end
        this.useFileIO=isSupported;
    end

    if paramIsOn&&disp==1
        if emitRealMsg
            this.addCheckToDriver([],'Warning',...
            message('hdlcoder:engine:UseFileIOInTestBenchInvalidType'));
        end
        if emitEnumMsg
            this.addCheckToDriver([],'Warning',...
            message('hdlcoder:engine:UseFileIOEnumNotSupported'));
        end
    end
    if(hD.getParameter('generaterecordtype'))
        IO=[this.InportSrc,this.OutportSnk];
        checkTextIORecord(paramIsOn,IO,emitRealMsg,emitEnumMsg);
    end
end
function checkTextIORecord(paramIsOn,IO,emitRealMsg,emitEnumMsg)
    for ii=1:numel(IO)
        port=IO(ii);




        if(port.isRecordPort&&~port.dataIsConstant)
            if(~paramIsOn)
                error(message('hdlcoder:engine:RecordsAtDutFileIO'));
            elseif(emitRealMsg)
                error(message('hdlcoder:engine:RecordsUnsupportedFileIOReal'));
            elseif(emitEnumMsg)
                error(message('hdlcoder:engine:RecordsUnsupportedFileIOEnum'));
            end
        end
    end
end

