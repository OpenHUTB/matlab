function inportOffset=fixPorts(this,hC)


    addClock=this.getImplParams('AddClockPort');
    addClken=this.getImplParams('AddClockEnablePort');
    addReset=this.getImplParams('AddResetPort');

    addClock=isempty(addClock)||strcmpi(addClock,'on');
    addClken=isempty(addClken)||strcmpi(addClken,'on');
    addReset=isempty(addReset)||strcmpi(addReset,'on');

    if hC.getIsProtectedModel
        clockName=this.getClockInputPort(hC);
        resetName=this.getResetInputPort(hC);



        modelFile=get_param(hC.SimulinkHandle,'ModelFile');
        [~,refName,~]=fileparts(modelFile);
        hDrv=hdlcurrentdriver;
        dirPath=[hDrv.hdlGetBaseCodegendir,filesep,refName];
        matFile=[dirPath,filesep,'hdlcodegenstatus.mat'];
        clear('CodeGenStatus');
        load(matFile,'CodeGenStatus');




        totalClockEnables=numel(CodeGenStatus.clockReportDatt.clockEnableData);
        if~totalClockEnables
            return;
        end

        portIdx=0;
        if addClock
            hC.setInputPortName(portIdx,hdllegalnamersvd(clockName));
            portIdx=portIdx+1;
        end

        if addClken
            if numel(CodeGenStatus.clockReportDatt.clockEnableData)>0
                for ii=1:numel(CodeGenStatus.clockReportDatt.clockEnableData)
                    clkEnData=CodeGenStatus.clockReportDatt.clockEnableData(ii);
                    clkenName=clkEnData.signalName;
                    hC.setInputPortName(portIdx,hdllegalnamersvd(clkenName));
                    portIdx=portIdx+1;
                end
            else
                clkenName=this.getClockEnableInputPort(hC);
                hC.setInputPortName(portIdx,hdllegalnamersvd(clkenName));
                portIdx=portIdx+1;
            end
        end

        if addReset
            hC.setInputPortName(portIdx,hdllegalnamersvd(resetName));
        end
    else
        clockName=this.getClockInputPort(hC);
        resetName=this.getResetInputPort(hC);
        clkenName=this.getClockEnableInputPort(hC);

        portControl=[addClock,addClken,addReset];
        inportOffset=sum(fix(portControl));
        portIdx=sum(portControl.*[4,2,1]);



        switch portIdx
        case 7
            if~isempty(clockName)
                hC.setInputPortName(0,hdllegalnamersvd(clockName));
            end
            if~isempty(clkenName)
                hC.setInputPortName(1,hdllegalnamersvd(clkenName));
            end
            if~isempty(resetName)
                hC.setInputPortName(2,hdllegalnamersvd(resetName));
            end
        case 0

        case 1
            if~isempty(resetName)
                hC.setInputPortName(0,hdllegalnamersvd(resetName));
            end
        case 2
            if~isempty(clkenName)
                hC.setInputPortName(0,hdllegalnamersvd(clkenName));
            end
        case 3
            if~isempty(clkenName)
                hC.setInputPortName(0,hdllegalnamersvd(clkenName));
            end
            if~isempty(resetName)
                hC.setInputPortName(1,hdllegalnamersvd(resetName));
            end
        case 4
            if~isempty(clockName)
                hC.setInputPortName(0,hdllegalnamersvd(clockName));
            end
        case 5
            if~isempty(clockName)
                hC.setInputPortName(0,hdllegalnamersvd(clockName));
            end
            if~isempty(resetName)
                hC.setInputPortName(1,hdllegalnamersvd(resetName));
            end
        case 6
            if~isempty(clockName)
                hC.setInputPortName(0,hdllegalnamersvd(clockName));
            end
            if~isempty(clkenName)
                hC.setInputPortName(1,hdllegalnamersvd(clkenName));
            end
        end
    end
end


