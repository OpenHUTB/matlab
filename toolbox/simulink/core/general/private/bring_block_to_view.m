function bring_block_to_view(bh)



    try




        open_system(get_param(bh,'Parent'),'tab');

        Simulink.scrollToVisible(bh);

        studio=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;

        if~isempty(studio(1))
            obj=diagram.resolver.resolve(bh);
            studio(1).App.hiliteAndFadeObject(obj);
        end

    catch


    end