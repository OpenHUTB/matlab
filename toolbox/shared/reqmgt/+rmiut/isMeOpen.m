function yesno=isMeOpen()




    yesno=false;

    daRoot=rmiut.getDASRoot();
    if~isempty(daRoot)
        explorers=daRoot.find('-isa','DAStudio.Explorer');
        for i=1:length(explorers)
            if explorers(i).isVisible()
                dataRoot=explorers(i).getRoot();
                if isa(dataRoot,'Simulink.Root')
                    yesno=true;
                    return;
                end
            end
        end
    end

end

