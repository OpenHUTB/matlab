function resetGraderBadge(model)





    srcPath=learning.simulink.SimulinkAppInteractions.getSLTrainingPath();
    progroot=fullfile(srcPath,'Resources');


    existing_graders=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'RegExp','on','ReferenceBlock','signalChecks');
    for idx=1:numel(existing_graders)
        set_param(existing_graders{idx},'pass','-1');
        try
            b=diagram.badges.get('GraderBadge','BlockNorthEast');
        catch ME
            if(strcmp(ME.identifier,'diagram_badges:badges:NonExistingBadgeKey'))

                b=diagram.badges.create('GraderBadge','BlockNorthEast');


                b.Image=fullfile(progroot,'blue_box.svg');
                b.setActionHandler(@callOpenFcn);
                b.DefaultOpacity=1;
            else
                rethrow(ME)
            end
        end
        do=diagram.resolver.resolve(existing_graders{idx});
        svgFile=fileread(fullfile(progroot,'blue_box.svg'));
        b.setImageTextForInstance(do,svgFile)


        isVisible=b.isVisible(do);
        if~isVisible
            b.setVisible(do,true);
        end
    end

end

