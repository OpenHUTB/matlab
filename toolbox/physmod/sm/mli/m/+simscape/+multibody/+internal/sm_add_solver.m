function sm_add_solver(hModel)




    load_system('nesl_utility');
    solverBlk=['nesl_utility/','Solver',char(10),'Configuration'];






    mechConfigBlks=find_system(hModel,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'ClassName','MechanismConfiguration');

    for i=1:length(mechConfigBlks)
        blkRect=Simulink.rect(get_param(mechConfigBlks(i),'Position'));
        blkSz=[blkRect.width,blkRect.height];
        [rects,orientations,coverage]=...
        l_available_rects(mechConfigBlks(i),blkSz);
        [~,minIdx]=min(coverage);
        l_add_block(solverBlk,mechConfigBlks(i),...
        rects(minIdx).double,orientations{minIdx});
    end

    function[rects,orientations,coverage]=l_available_rects(blk,sz)








        rect=Simulink.rect(get_param(blk,'Position'));
        orient=get_param(blk,'Orientation');




        [rects,orientations]=l_get_oriented_rects(rect,sz,orient);




        remove=[];
        for i=1:length(rects)
            if any(rects(i).double<0)
                remove(end+1)=i;%#ok<AGROW>
            end
        end





        rects(remove)=[];
        orientations(remove)=[];

        parent=get_param(get_param(blk,'Parent'),'Handle');
        others=find_system(parent,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'SearchDepth',1);

        others(others==parent)=[];
        poses=get_param(others,'Position');
        if~iscell(poses)
            poses={poses};
        end

        orects=repmat(Simulink.rect,length(poses),1);
        for i=1:length(poses)
            orects(i)=Simulink.rect(poses{i});
            orects(i).inset(-orects(i).width/2,-orects(i).height/2);
        end




        coverage=zeros(length(rects),1);
        for i=1:length(rects)
            maximum=0;
            for j=1:length(orects)
                intersect=orects(j)*rects(i);
                area=intersect.height*intersect.width;
                if area>maximum
                    maximum=area;
                end
            end
            coverage(i)=maximum;
        end

        function[rects,orientations]=l_get_oriented_rects(rect,sz,orientation)



            idx=[];
            rects=l_get_rects(rect,sz);
            orients={'right','left','up','down'};





            switch orientation
            case 'right'
                idx=[1,5,8,6,7];
                or=[1,1,1,1,1];
            case 'left'
                idx=[3,2,4,1,5];
                or=[2,4,3,1,1];
            case 'up'
                idx=[5,6,4,7,3];
                or=[3,1,2,4,4];
            case 'down'
                idx=[1,8,2,7,3];
                or=[4,1,2,3,3];
            end

            rects=rects(idx);
            orientations=orients(or);

            function rects=l_get_rects(rect,sz)








                hinset=round((rect.width-sz(1))/2);
                vinset=round((rect.height-sz(2))/2);

                base=rect;
                base.inset(hinset,vinset);

                hmov=round((rect.width+base.width)/2)+30;
                vmov=round((rect.height+base.height)/2)+30;

                rects=repmat(Simulink.rect,8,1);
                for i=1:8
                    rects(i)=base.copy;
                end

                rects(1).offset(0,-vmov);
                rects(2).offset(hmov,-vmov);
                rects(3).offset(hmov,0);
                rects(4).offset(hmov,vmov);
                rects(5).offset(0,vmov);
                rects(6).offset(-hmov,vmov);
                rects(7).offset(-hmov,0);
                rects(8).offset(-hmov,-vmov);

                function parent=l_get_parent(block)


                    parent=get_param(get_param(block,'Parent'),'Handle');

                    function blk=l_add_block(src,mcBlk,position,orientation)






                        parent=l_get_parent(mcBlk);
                        others=find_system(parent,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1);
                        others(others==parent)=[];
                        names=get_param(others,'Name');

                        base=get_param(src,'Name');
                        name=base;
                        i=0;
                        while any(strcmp(name,names))
                            i=i+1;
                            name=[base,num2str(i)];
                        end

                        phs1=get_param(mcBlk,'PortHandles');




                        blk=add_block(getfullname(src),[getfullname(parent),'/',name],...
                        'Position',position,...
                        'Orientation',orientation,...
                        'ShowName','off');
                        phs2=get_param(blk,'PortHandles');




                        add_line(parent,phs1.RConn,phs2.RConn,'autorouting','on');

                        set_param(mcBlk,'ShowName','off');

