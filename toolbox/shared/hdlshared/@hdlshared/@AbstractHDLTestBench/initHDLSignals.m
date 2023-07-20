function initHDLSignals(this,scalarizeports)


    inputSrc=this.InportSrc;
    outputSnk=this.OutportSnk;

    this.hdlSignals=struct;
    this.hdlSignals.InputSignals=cell(1,length(inputSrc));
    this.hdlSignals.OutputSignals=cell(1,length(outputSnk));

    initInSignals(this,inputSrc);
    initSignalMap(this,inputSrc,'_force',scalarizeports);
    initOutSignals(this,outputSnk);
    initSignalMap(this,outputSnk,'_expected',scalarizeports);
end


function initInSignals(this,inputSrc)
    for ii=1:length(inputSrc)
        this.hdlSignals.InputSignals{ii}=getExpandedPorts(inputSrc(ii));
    end
end


function initOutSignals(this,outputSnk)
    for ii=1:length(outputSnk)
        this.hdlSignals.OutputSignals{ii}=getExpandedPorts(outputSnk(ii));
    end
end

function initSignalMap(this,srcOrDriver,namePostfix,scalarizeports)
    for ii=1:length(srcOrDriver)
        currentSrc=srcOrDriver(ii);
        forceSignals=getForceSignals(this,currentSrc,namePostfix,scalarizeports);

        if strcmp(namePostfix,'_force')
            this.hdlSignals.ForceSignals{ii}=forceSignals;
        else
            this.hdlSignals.ExpectedSignals{ii}=forceSignals;
        end



        inputsOrOutputs=this.getHDLSignals('in',currentSrc);
        numIO=length(inputsOrOutputs);
        numForceSignals=length(forceSignals);
        newMap=cell(1,numIO);
        forceCounter=1;
        for jj=1:numIO
            newMap{jj}=forceSignals{forceCounter};
            forceCounter=forceCounter+1;
            if forceCounter>numForceSignals
                forceCounter=1;
            end
        end
        if strcmp(namePostfix,'_force')
            this.hdlSignals.ForceSignalMap{ii}=newMap;
        end
    end
end


function forceSignals=getForceSignals(this,inputSrc,namePostfix,scalarizeports)
    if iscell(inputSrc.HDLPortName{1})
        sizeOneInput=length(inputSrc.HDLPortName{1});
    else
        sizeOneInput=1;
    end

    flattenedPorts=false;
    if inputSrc.VectorPortSize>1
        if scalarizeports
            flattenedPorts=true;
        end
    end

    baseName=inputSrc.loggingPortName;
    isComplex=this.isPortComplex(inputSrc);

    if isComplex
        realPostfix=hdlgetparameter('complex_real_postfix');
        imagPostfix=hdlgetparameter('complex_imag_postfix');
        lenRealPostfix=length(realPostfix);
        if length(baseName)>lenRealPostfix&&...
            strcmp(baseName((end-lenRealPostfix)+1:end),realPostfix)
            baseName=baseName(1:end-lenRealPostfix);
        end
    end

    partIdx=0;
    forceSignals=cell(1,sizeOneInput);
    for ii=1:sizeOneInput
        forceSignals{ii}=baseName;
        if isComplex
            if ii<=sizeOneInput/2
                forceSignals{ii}=sprintf('%s%s',forceSignals{ii},realPostfix);
            else
                if partIdx>=sizeOneInput/2

                    partIdx=0;
                end
                forceSignals{ii}=sprintf('%s%s',forceSignals{ii},imagPostfix);
            end
        end
        if flattenedPorts
            forceSignals{ii}=sprintf('%s_%d',forceSignals{ii},partIdx);
        end
        forceSignals{ii}=sprintf('%s%s',forceSignals{ii},namePostfix);
        partIdx=partIdx+1;
    end
end



function expandedPorts=getExpandedPorts(src)


    count=0;
    for ii=1:length(src.HDLPortName)
        currentInput=src.HDLPortName{ii};
        if iscell(currentInput)
            count=count+length(currentInput);
        else
            count=count+1;
        end
    end

    expandedPorts=cell(1,count);
    count=1;
    for ii=1:length(src.HDLPortName)
        currentInput=src.HDLPortName{ii};
        if iscell(currentInput)
            for jj=1:length(currentInput)
                expandedPorts{count}=currentInput{jj};
                count=count+1;
            end
        else
            expandedPorts{count}=currentInput;
            count=count+1;
        end
    end
end
