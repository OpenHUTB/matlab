function licStatus=serialShared()

    if bdIsLibrary(bdroot(gcb))

        licStatus=-1;
    else


        [status1,error_msg1]=builtin('license','checkout','Instr_Control_Toolbox');

        if(status1==0)


            [status2,error_msg2]=builtin('license','checkout','Motor_Control_Blockset');
            if(status2==0)
                error([error_msg1,error_msg2]);
            else
                licStatus=1;
            end
        else
            licStatus=1;
        end
    end

end

