function[WAS_GOOD,valueUserEntered]=checkDimensions(userEnteredDims)




    WAS_GOOD=false;


    try

        valueUserEntered=userEnteredDims;



        userEnteredDims=str2num(strrep(userEnteredDims,';',','));


        if isempty(userEnteredDims)||~isnumeric(userEnteredDims)
            return;
        end


        if length(userEnteredDims)==1

            x=zeros([2,userEnteredDims]);

        else

            x=zeros([userEnteredDims,2]);

        end


        if~isempty(x)



            if prod(userEnteredDims)<SlIOFormatUtil.SDI_REPO_CHANNEL_UPPER_LIMIT
                WAS_GOOD=true;
            end

        end

    catch ME


    end


end

