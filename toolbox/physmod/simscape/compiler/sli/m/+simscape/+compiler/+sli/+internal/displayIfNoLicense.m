function displayIfNoLicense(hBlk)




    if~simscape.compiler.sli.internal.checklicense(hBlk)


        objList=find_system(hBlk,'findall','on','SearchDepth',2,'FollowLinks','off',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all','type','block','mask','on');

        nObjs=size(objList);
        for idx=1:nObjs(1)
            hObj=objList(idx);


            dispScript=sprintf('color(''red'');\ndisp(''%s\\n%s'');','No','License');
            set_param(hObj,'MaskDisplay',dispScript);
            set_param(hObj,'MaskIconFrame','on');
        end
    end
end