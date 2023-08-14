function wrToIO(this,port,isInput)


    if hdlgetparameter('isvhdl')
        wrToIOVHDL(this,port,isInput);
    else
        wrToIOVerilog(this,port,isInput);
    end
end

function wrToIOVerilog(this,port,isInput)
    if isInput
        [SignalsRe,SignalsIm]=this.getHDLSignals('in',port);
    else
        [SignalsRe,SignalsIm]=this.getHDLSignals('out',port);
    end








    if length(port.HDLPortName)~=1
        if~port.dataIsComplex
            SignalsRe=SignalsRe(1:port.VectorPortSize);
        else
            SignalsIm=SignalsRe(port.VectorPortSize+1:2*port.VectorPortSize);
            SignalsRe=SignalsRe(1:port.VectorPortSize);
        end
    end

    writeVerilogDataIO(this,port,SignalsRe,port.data);
    if~isempty(SignalsIm)
        writeVerilogDataIO(this,port,SignalsIm,port.data_im);
    end
end


function wrToIOVHDL(this,port,isInput)
    if isInput
        [SignalsRe,SignalsIm]=this.getHDLSignals('in',port);
    else
        [SignalsRe,SignalsIm]=this.getHDLSignals('out',port);
    end

    writeVhdlDataIO(this,port,SignalsRe,port.data);
    if~isempty(SignalsIm)&&~port.dataIsConstant
        writeVhdlDataIO(this,port,SignalsIm,port.data_im);
    end
end


function writeVerilogDataIO(this,port,signals,data)
    portsltype=port.PortSLType;
    vectorSize=port.VectorPortSize;
    [iosize,iobp,iosigned]=hdlgetsizesfromtype(portsltype);


    jj=0;
    finalData=[];
    for ii=1:length(signals)
        if vectorSize>1


            if jj==vectorSize
                jj=1;
            else
                jj=jj+1;

                if jj==vectorSize
                    FlagWriteToFile=1;
                else
                    FlagWriteToFile=0;
                end
            end
            currentData=data(:,jj);

        else
            currentData=data;
            FlagWriteToFile=1;
        end

        inlen0=length(currentData);
        if iosize==0



            currentData=num2hex(currentData);
        else
            currentData=this.prepareData(currentData,inlen0,1,iosigned,iosize,iobp);
        end

        if vectorSize>1
            if isempty(finalData)
                finalData=currentData;
            else
                currDataLen=size(finalData,2);
                eachDataLen=length(currentData(1,:));
                for kk=1:size(finalData,1)
                    finalData(kk,currDataLen+1:currDataLen+1+eachDataLen)=[' ',currentData(kk,:)];%#ok %consider pre-allocation later
                end
            end
        else
            finalData=currentData;
        end

        if FlagWriteToFile==1
            dataFileName=[char(signals{ii-vectorSize+1}),'.dat'];
            writeToFile(this,dataFileName,finalData);
        end
    end
end


function writeVhdlDataIO(this,port,signals,data)
    portsltype=port.PortSLType;
    vectorSize=port.VectorPortSize;
    [iosize,iobp,iosigned]=hdlgetsizesfromtype(portsltype);


    finalData=[];
    for ii=1:vectorSize
        if vectorSize>1


            if ii==vectorSize
                FlagWriteToFile=1;
            else
                FlagWriteToFile=0;
            end
            currentData=data(:,ii);
        else
            currentData=data;
            FlagWriteToFile=1;
        end

        if iosize==0




            currentData=num2hex(currentData);

        else
            numData=length(currentData);
            currentData=this.prepareData(currentData,numData,1,iosigned,...
            iosize,iobp);
        end

        if vectorSize>1
            if isempty(finalData)
                finalData=currentData;
            else
                currDataLen=size(finalData,2);
                eachDataLen=length(currentData(1,:));
                for kk=1:size(finalData,1)
                    finalData(kk,currDataLen+1:currDataLen+1+eachDataLen)=...
                    [' ',currentData(kk,:)];%#ok<AGROW>
                end
            end
        else
            finalData=currentData;
        end

        if FlagWriteToFile==1
            dataFileName=[char(signals{ii-vectorSize+1}),'.dat'];


            fullfilename=fullfile(this.CodeGenDirectory,dataFileName);
            msg=message('HDLShared:hdlshared:gentbdatafile',...
            hdlgetfilelink(fullfilename));
            hdldisp(msg.getString,1);

            writeToFile(this,dataFileName,finalData);
        end
    end
end


function writeToFile(this,fName,finalData)
    dataFilePath=fullfile(this.CodeGenDirectory,fName);
    fid=fopen(dataFilePath,'w');
    for kk=1:size(finalData,1)
        fprintf(fid,'%s\n',finalData(kk,:));
    end
    fclose(fid);
end


