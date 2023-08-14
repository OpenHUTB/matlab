function blockInfo=getBlockInfo(this,hC)
















    bfp=hC.SimulinkHandle;
    blockInfo.operationMode=get_param(bfp,'TerminationMethod');

    if(strcmpi(blockInfo.operationMode,'Continuous'))
        resetport=get_param(bfp,'ResetPort');
        if(strcmpi(resetport,'off'))
            blockInfo.enbRst=false;
        else
            blockInfo.enbRst=true;
        end
    else
        blockInfo.enbRst=true;
    end
    if(strcmpi(blockInfo.operationMode,'Truncated'))
        istport=get_param(bfp,'InitialStatePort');
        if(strcmpi(istport,'off'))
            blockInfo.enbIStPort=false;
        else
            blockInfo.enbIStPort=true;
        end
        fstport=get_param(bfp,'FinalStatePort');
        if(strcmpi(fstport,'off'))
            blockInfo.enbFStPort=false;
        else
            blockInfo.enbFStPort=true;
        end
    end
    GeneratorPolynomial=double(this.hdlslResolve('CodeGenerator',bfp));
    FeedbackPolynomial=double(this.hdlslResolve('FeedbackConnection',bfp));
    ConstraintLength=double(this.hdlslResolve('ConstraintLength',bfp));
    blockInfo.tailCount=ConstraintLength-2;

    blockInfo.clength=ConstraintLength;
    CodeGenLen=length(GeneratorPolynomial);
    blockInfo.CodeGenLen=CodeGenLen;
    Gbintmp=fi(reshape(int2bit(oct2dec(GeneratorPolynomial(:)'),ConstraintLength),ConstraintLength,[])',0,1,0);
    FeedbackPolybin=fi(reshape(int2bit(oct2dec(FeedbackPolynomial(:)'),ConstraintLength),ConstraintLength,[])',0,1,0);
    FeedbackEnable=FeedbackPolybin(1,1)==fi(1,0,1,0);
    blockInfo.feedbackenb=FeedbackEnable;
    blockInfo.fbmatrix=FeedbackPolybin;
    if FeedbackEnable
        for i=1:CodeGenLen
            if Gbintmp(i,1)==1
                Gbintmp(i,2:end)=...
                bitxor(Gbintmp(i,2:end),FeedbackPolybin(2:end));
            end
        end
    end
    blockInfo.gmatrix=(Gbintmp);
    feedbackPolybinTmp=[FeedbackPolybin(2:end),fi(0,0,1,0)];
    if(feedbackPolybinTmp(1,1)==1)
        feedbackPolybinTmp(1,2:end)=...
        bitxor(FeedbackPolybin(2:end),feedbackPolybinTmp(2:end));
    end
    blockInfo.fbmatrixp=feedbackPolybinTmp;
end
