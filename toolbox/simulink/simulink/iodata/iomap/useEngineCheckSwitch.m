function useEngineCheckSwitch(bool)





    if islogical(bool)||(isnumeric(bool)&&(bool==0||bool==1))


        if bool

            setappdata(0,'enableEngineCheckVersion1_0',true);
        else

            setappdata(0,'enableEngineCheckVersion1_0',false);
        end
    end