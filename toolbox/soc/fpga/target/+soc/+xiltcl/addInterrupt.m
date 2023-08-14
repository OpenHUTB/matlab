function addInterrupt(fid,hbuild)

    intr=hbuild.Interrupt;
    if~isempty(hbuild.PS7)&&~isempty(intr)

        intrTable=struct2table(intr);
        sortedTable=sortrows(intrTable,'irq_num');
        intrSorted=table2struct(sortedTable)';
        maxIrqNum=max([intrSorted.irq_num]);

        if~soc.internal.isCustomHWBoard(hbuild.Board.Name)
            if strcmpi(hbuild.Board.BoardID,'zcu102')

                soc.xiltcl.setInstance(fid,'zynq_ultra_ps',{'PSU__USE__IRQ0','1',...
                'PSU__USE__IRQ1','1'});
                irq_str{1}='zynq_ultra_ps/pl_ps_irq0';
                irq_str{2}='zynq_ultra_ps/pl_ps_irq1';
            else

                soc.xiltcl.setInstance(fid,'processing_system7',{'PCW_USE_FABRIC_INTERRUPT','1','PCW_IRQ_F2P_INTR','1'});
                irq_str{1}='processing_system7/IRQ_F2P';
            end
        else
            cs=getActiveConfigSet(hbuild.TopSystemName);
            [~,interruptsInfo]=codertarget.interrupts.getFPGAInterupts(cs);
            if~isempty(interruptsInfo)
                for i=1:numel(interruptsInfo)
                    irq_str{i}=interruptsInfo(i).InterfacePortName;%#ok<AGROW>
                end
            else
                if iscell(hbuild.PS7.InterruptInterface)
                    irq_str=hbuild.PS7.InterruptInterface;
                else
                    irq_str{1}=hbuild.PS7.InterruptInterface;
                end
            end
        end

        if numel(irq_str)==2
            indx1=[intrSorted.irq_num]<=7;
            indx2=[intrSorted.irq_num]>7;
            maxIrqNum1=max([intrSorted(indx1).irq_num]);
            maxIrqNum2=max([intrSorted(indx2).irq_num]);
        else
            indx1=[];
            indx2=[];
            maxIrqNum1=maxIrqNum;
            maxIrqNum2=[];
        end

        if maxIrqNum~=numel(intr)-1&&~(numel(irq_str)==2&&numel(intr)==1&&maxIrqNum==8)&&...
            ~(~isempty(maxIrqNum1)&&numel(irq_str)==2&&nnz(indx1)==maxIrqNum1+1)&&...
            ~(~isempty(maxIrqNum2)&&numel(irq_str)==2&&nnz(indx2)==maxIrqNum2-7)


            soc.xiltcl.addInstance(fid,'xlconstant_0','xilinx.com:ip:xlconstant:1.1');
            soc.xiltcl.setInstance(fid,'xlconstant_0',{'CONST_WIDTH','1','CONST_VAL','0'});
        end

        indxVal=1;
        if(any([intrSorted.irq_num]<8)&&numel(irq_str)==2)||...
            (maxIrqNum>=0&&numel(irq_str)==1)
            indxVal=getIntrConnections(fid,1,maxIrqNum1+1,'interrupt_concat',intrSorted,irq_str{1},indxVal);
        end

        if maxIrqNum>7&&numel(irq_str)==2
            getIntrConnections(fid,9,maxIrqNum2+1,'interrupt_concat1',intrSorted,irq_str{2},indxVal);
        end
    end
end

function indxVal=getIntrConnections(fid,startVal,endVal,concatIPName,intr,irq_str,indxVal)
    soc.xiltcl.addInstance(fid,concatIPName,'xilinx.com:ip:xlconcat:2.1');
    soc.xiltcl.setInstance(fid,concatIPName,{'NUM_PORTS',num2str(endVal-startVal+1)});
    soc.xiltcl.addConnections(fid,{irq_str,[concatIPName,'/dout']});
    for j=startVal:endVal
        if j-1==intr(indxVal).irq_num
            soc.xiltcl.addConnections(fid,{intr(indxVal).name,[concatIPName,'/In',num2str(j-startVal)]});
            indxVal=indxVal+1;
        else

            soc.xiltcl.addConnections(fid,{'xlconstant_0/dout',[concatIPName,'/In',num2str(j-startVal)]});
        end
    end
end
