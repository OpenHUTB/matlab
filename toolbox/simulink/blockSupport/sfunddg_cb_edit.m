function do_return=sfunddg_cb_edit(sfun)






    sfun_exist=exist(sfun,'file');

    do_return=false;

    if any(sfun_exist==[0,2,3,6])


        if any(exist('sfunsrcedit_hook','file')==[2,6])
            keepLooking=sfunsrcedit_hook(sfun);
            if~keepLooking,
                do_return=true;
            end
        end

        if~do_return







            if sfun_exist==2,


                edit(which(sfun));
                do_return=true;

            elseif sfun_exist==6,





                srcCandidate=[sfun,'.m'];
                if exist(srcCandidate,'file')==2,
                    edit(which(srcCandidate));
                    do_return=true;
                end

            else




                srcFile=sfunddg_fs(sfun);
                if~isempty(srcFile)
                    edit(srcFile);
                    do_return=true;
                end
            end
        end
    end



