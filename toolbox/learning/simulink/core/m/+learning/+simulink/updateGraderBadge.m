function updateGraderBadge(block,pass_status)



    srcPath=learning.simulink.SimulinkAppInteractions.getSLTrainingPath();
    progroot=fullfile(srcPath,'Resources');
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


    do=diagram.resolver.resolve(block);

    if pass_status==0
        svgFile=fileread(fullfile(progroot,'red_ex.svg'));
    elseif pass_status==1
        svgFile=fileread(fullfile(progroot,'green_check.svg'));
    elseif pass_status==2
        svgFile=fileread(fullfile(progroot,'orange_question.svg'));
    else
        svgFile=fileread(fullfile(progroot,'blue_box.svg'));
    end
    b.setImageTextForInstance(do,svgFile)


    isVisible=b.isVisible(do);
    if~isVisible
        b.setVisible(do,true);
    end
end
