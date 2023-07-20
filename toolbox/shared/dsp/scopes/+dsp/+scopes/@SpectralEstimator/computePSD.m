function[PSD,PSDMaxHold,PSDMinHold,Fout]=computePSD(obj,x)






    if strcmp(obj.ChannelMode,'Single')
        x=x(:,:,obj.ChannelNumber);
    end
    if obj.ReduceUpdates

        if strcmp(obj.Method,'Welch')

            [PSD,PSDMaxHold,PSDMinHold,Fout]=computePSDReducedRate(obj,x);
        else

            [PSD,PSDMaxHold,PSDMinHold,Fout]=computeFilterBankPSDReducedRate(obj,x);
        end
    else

        if strcmp(obj.Method,'Welch')

            [PSD,PSDMaxHold,PSDMinHold,Fout]=computePSDNormalRate(obj,x);
        else

            [PSD,PSDMaxHold,PSDMinHold,Fout]=computeFilterBankPSDNormalRate(obj,x);
        end
    end
end
