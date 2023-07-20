




function h=findChildHandle(parentH,childName)

    h=find_system(parentH,'MatchFilter',@Simulink.match.allVariants,'FollowLinks','on','SearchDepth',1,'Name',childName);

    h(h==parentH)=[];
