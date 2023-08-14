function topicID=hdlgethelptagname(blkLibPath,blkArch,slbh)



    topicID='hdlhelp';
    blkLibPath=char(regexp(blkLibPath,'[\w]','match'))';
    blkArch=char(regexp(blkArch,'[\w]','match'))';
    if strcmp(blkLibPath,'hdlRAM')



        if nargin==3
            ramType=get_param(slbh,'RAMType');
        else
            ramType='Single port';
        end
        switch ramType
        case 'Single port'
            topicID=[topicID,...
            '_hdlsllibHDLOperationsSinglePortRAM_hdldefaultsRamBlockSingle'];
        case 'Simple dual port'
            topicID=[topicID,...
            '_hdlsllibHDLOperationsSimpleDualPortRAM_hdldefaultsRamBlockSimpDual'];
        otherwise
            topicID=[topicID,...
            '_hdlsllibHDLOperationsDualPortRAM_hdldefaultsRamBlockDual'];
        end
    else
        topicID=[topicID,'_',blkLibPath,'_',blkArch];
    end
