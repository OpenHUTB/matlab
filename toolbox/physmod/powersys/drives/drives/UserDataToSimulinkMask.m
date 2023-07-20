

function[]=UserDataToSimulinkMask(driveBlock,driveType)


    config=getDialogConfig(driveType);
    blockHandle=driveBlock;
    blockCache=get_param(blockHandle,'UserData');
    values=blockCache.simulink;
    nbBlocks=length(config);

    for k=1:nbBlocks

        if strcmp(config(k).maskType,'Asynchronous Machine')


            switch length(values{1})
            case 20
                nbParams=21;
            case 21
                nbParams=22;
            end

        elseif(strcmp(driveType,'AC6')||strcmp(driveType,'AC7'))&&strcmp(config(k).maskType,...
            'Permanent Magnet Synchronous Machine')


            switch length(values{1})
            case 7
                nbParams=7;
            case 14

                nbParams=15;
            end





        elseif strcmp(config(k).maskType,'Field-Oriented Controller')
            switch length(values{5})
            case 19
                nbParams=13;
            case 26
                nbParams=20;
            end
        elseif strcmp(config(k).maskType,'Direct Torque Controller')
            switch length(values{5})
            case 14
                nbParams=7;
            case 21
                nbParams=14;
            end
        elseif(strcmp(config(k).maskType,'Vector Controller (PMSM)')&&strcmp(driveType,'AC6'))
            switch length(values{5})
            case 12
                nbParams=8;
            case 19
                nbParams=15;
            end

        else


            nbParams=length(config(k).javaIdx);
        end


        matlabCell=abs(config(k).matlabCell);


        for m=1:nbParams

            if(config(k).MasksmlnkIdx(m)>0)
                set_param(blockHandle,config(k).MasksmlnkVarNames{m},values{matlabCell(m)}{config(k).matlabIdx(m)});
            end

        end

    end
end

