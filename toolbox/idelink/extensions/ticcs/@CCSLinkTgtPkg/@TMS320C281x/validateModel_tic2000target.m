function errormsg=validateModel_tic2000target(h,tgtInfo,modelName,IRmodelInfo,tgtPeriphs)





    errormsg=[];


    if(IRmodelInfo.numSPIs==1)&&strcmp(IRmodelInfo.SPI.enLoopback,'on')
        error(message('TICCSEXT:util:MissingRequiredBlocks'));
    end



    if(IRmodelInfo.numSPIs>1)
        if(IRmodelInfo.SPI.numRxblocks==1)
            if strcmp(tgtPeriphs.DSPBoardDSPChipSPIFIFOEnable,'off')
                if IRmodelInfo.SPI.Rx(1).dataLength>1;
                    error(message('TICCSEXT:util:FifoModeNotEnabled'));
                end
            end
        end
    end


    [ubound,modestring]=h.getMailboxUpperBound(IRmodelInfo,'eCANMode');



    if(IRmodelInfo.numCANs>0)
        mailboxesUsed=zeros(1,ubound+1);
        for i=1:IRmodelInfo.numCANs,
            mBoxNo=IRmodelInfo.CAN{i}.mailboxNo;
            if(mBoxNo<0||mBoxNo>ubound)||...
                (mBoxNo-double(uint8(mBoxNo)))
                error(message('TICCSEXT:util:InvalidMailboxNumber',num2str(mBoxNo),modestring,ubound));
            end
            if(mailboxesUsed(mBoxNo+1))
                error(message('TICCSEXT:util:CannotUseSameMailboxNumber'));
            else
                mailboxesUsed(mBoxNo+1)=1;
            end
        end
    end


