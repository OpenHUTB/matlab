function[RamIV,RamLoc0,isScalar]=resolveRAMIV(hC,IV)






    hD=hdlcurrentdriver;
    if hD.getParameter('isvhdl')
        isVhdl=true;
    else
        isVhdl=false;
    end


    hRamT=hC.getRamDataType;
    isComplex=hRamT.isComplexType;
    if isComplex
        hT=hRamT.BaseType;
    else
        hT=hRamT;
    end
    dataBits=hT.WordLength;
    is1BitType=hT.is1BitType;


    nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;

    slbh=hC.getGMHandle;
    if slbh>0
        portHandles=get_param(slbh,'PortHandles');

        portDataType=get_param(portHandles.Outport(1),'CompiledPortDataType');
        isPortFloatingPoint=(strcmpi('single',portDataType))||(strcmpi('double',portDataType));

        useFloatingPoint=nfpMode&&isPortFloatingPoint;

        resolvedVal=slResolve(IV,getfullname(slbh));
    else
        useFloatingPoint=nfpMode&&hC.getRamDataType.isFloatType;
        resolvedVal=eval(IV);
    end

    numElem=numel(resolvedVal);

    hasClkEnable=hC.NumberOfPirInputPorts('clock_enable');
    writeAddrIdx=3+hasClkEnable+isComplex;
    assert(numElem==1||numElem==2^(hC.PirInputSignals(writeAddrIdx).Type.WordLength));


    if isreal(resolvedVal)

        if isComplex

            resolvedVal=pirelab.getTypeInfoAsFi(hT,'Nearest','Saturate',complex(resolvedVal));
        else
            resolvedVal=pirelab.getTypeInfoAsFi(hT,'Nearest','Saturate',resolvedVal);
        end
    else



        resolvedVal=pirelab.getTypeInfoAsFi(hT,'Nearest','Saturate',resolvedVal);





    end



    isScalar=false;
    if numElem==1
        [useBinary,fmtChar]=getConstFormat(useFloatingPoint,isVhdl,resolvedVal);
        str=getStringRepresentation(resolvedVal,useFloatingPoint,isComplex,useBinary);
        RamIV='notused';
        isScalar=true;
        if isVhdl

            if is1BitType
                RamLoc0=['''',str,''''];
            else
                RamLoc0=[fmtChar,'"',str,'"'];
            end
            return;
        else
            if isComplex
                ivSize=dataBits*2;
            else
                ivSize=dataBits;
            end
            RamLoc0=sprintf('%d''%s%s',ivSize,fmtChar,str);
            return;
        end
    else

        resolvedVal=flip(resolvedVal);
        [useBinary,fmtChar]=getConstFormat(useFloatingPoint,isVhdl,resolvedVal);
    end

    if isComplex
        numDigits=ceil(dataBits/2);
    else
        numDigits=ceil(dataBits/4);
    end

    if isVhdl
        wrapMax=ceil(50/numDigits);
        wrapCnt=0;
        sep='';
        lines=ceil(numElem/(wrapMax+1));


        cSize=2+(13*numElem)+(56*lines);
        sep1=', ';
        sep2=[',',newline,repmat(' ',1,56)];
        RamIV(1:cSize)=' ';
        RamIV(1)="(";
        svnext=2;
        for ii=1:numElem
            str=getStringRepresentation(resolvedVal(ii),useFloatingPoint,isComplex,useBinary);
            if is1BitType
                fmtstr=[sep,'''',str,''''];
            else
                fmtstr=[sep,fmtChar,'"',str,'"'];
            end
            left=svnext;
            svnext=svnext+numel(fmtstr);
            RamIV(left:svnext-1)=fmtstr;
            if wrapCnt>=wrapMax
                sep=sep2;
                wrapCnt=0;
            else
                sep=sep1;
                wrapCnt=wrapCnt+1;
            end
        end
        RamIV(svnext)=')';

        RamIV=RamIV(1:svnext);
        if is1BitType
            RamLoc0=['''',str,''''];
        else
            RamLoc0=[fmtChar,'"',str,'"'];
        end
    else
        if isComplex

            dataBits=dataBits*2;
        end


        addrChars=length(int2str(numElem));

        cSize=(4+addrChars+12+length(int2str(dataBits))+dataBits/4)*numElem;
        RamIV(1:cSize)=' ';
        svnext=1;
        for ii=1:numElem
            str=getStringRepresentation(resolvedVal(ii),useFloatingPoint,isComplex,useBinary);
            fmtstr=sprintf('    ram[%d] = %d''%s%s;\n',...
            numElem-ii,dataBits,fmtChar,str);
            left=svnext;
            svnext=svnext+numel(fmtstr);
            RamIV(left:svnext-1)=fmtstr;
        end

        if svnext<cSize
            RamIV=RamIV(1:svnext);
        end
        RamLoc0=sprintf('%d''%s%s',dataBits,fmtChar,str);
    end
end

function strval=getStringRepresentation(val,usesingle,isComplex,useBinary)
    if usesingle
        cvtFcn=@num2hex;
    elseif useBinary
        cvtFcn=@bin;
    else
        cvtFcn=@hex;
    end

    strval=cvtFcn(real(val));
    if isComplex
        strval=[strval,cvtFcn(imag(val))];
    end
end

function[useBinary,fmtChar]=getConstFormat(usesingle,isVhdl,resolvedVal)
    if~usesingle&&mod(resolvedVal.WordLength,4)~=0

        useBinary=true;
        if isVhdl
            fmtChar='B';
        else
            fmtChar='b';
        end
    else
        useBinary=false;
        if isVhdl
            fmtChar='X';
        else
            fmtChar='h';
        end
    end
end


