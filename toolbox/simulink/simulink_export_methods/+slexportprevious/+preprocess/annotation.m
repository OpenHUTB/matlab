function annotation(obj)




















    if isR2018bOrEarlier(obj.ver)
        hAnnotations=find_system(obj.modelName,...
        'LookUnderMasks','all',...
        'FindAll','on',...
        'IncludeCommented','on',...
        'MatchFilter',@Simulink.match.allVariants,...
        'Type','Annotation');

        for i=1:numel(hAnnotations)

            escapedSID=slexportprevious.utils.escapeSIDFormat(...
            get_param(hAnnotations(i),'SID'));

            obj.appendRule(sprintf(...
            '1<Connector<Target|"Annotation&:%s">:remove>',...
            escapedSID));
        end






        obj.appendRule('<Annotation<BackgroundColor|"automatic":repval "white">>');
    end

    if isR2015bOrEarlier(obj.ver)

        hAnnotations=find_system(obj.modelName,...
        'LookUnderMasks','all','FindAll','on',...
        'IncludeCommented','on','MatchFilter',@Simulink.match.allVariants,...
        'type','annotation','AnnotationType','note_annotation');


        for i=1:numel(hAnnotations)
            annotation=get_param(hAnnotations(i),'Object');

            hAlign=annotation.HorizontalAlignment;
            if(~strcmp(hAlign,'left'))
                r=annotation.Position;
                w=r(3)-r(1);
                if(strcmp(hAlign,'center'))
                    w=w/2;
                end
                annotation.Position=[r(1)+w,r(2),r(3)+w,r(4)];
            end

            vAlign=annotation.VerticalAlignment;
            if(~strcmp(vAlign,'top'))
                r=annotation.Position;
                h=r(4)-r(2);
                if(strcmp(vAlign,'middle'))
                    h=h/2;
                end
                annotation.Position=[r(1),r(2)+h,r(3),r(4)+h];
            end
        end
    end

    if isR2013bOrEarlier(obj.ver)



        hAnnotations=find_system(obj.modelName,...
        'LookUnderMasks','on',...
        'FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'type','annotation');

        if(isempty(hAnnotations))
            return;
        end


        for i=1:numel(hAnnotations)
            annotation=get_param(hAnnotations(i),'Object');

            if strcmp(annotation.isImage,'on')

                delete(annotation);
            elseif strcmp(annotation.Interpreter,'rich')


                annotation.Interpreter='off';
            end
        end
    end

    if isR2013aOrEarlier(obj.ver)



        hAnnotations=find_system(obj.modelName,...
        'LookUnderMasks','on',...
        'FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'type','annotation');

        if(isempty(hAnnotations))
            return;
        end

        for i=1:numel(hAnnotations)

            sid=slexportprevious.utils.escapeSIDFormat(...
            get_param(hAnnotations(i),'SID'));
            annotation=get_param(hAnnotations(i),'Object');
            position=annotation.position;





            obj.appendRule(sprintf(...
            '1<Annotation<SID|"%s"><Position:repval [%d, %d]>>',...
            sid,position(1),position(2)));
        end
    end








    if isR2011bOrEarlier(obj.ver)
        obj.appendRule('2<Annotation<SID:remove>>');
    end



    if(isR2014bOrEarlier(obj.ver))
        modelHandle=get_param(obj.modelName,'Handle');


        areaHandles=find_system(modelHandle,'FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'Type','annotation','annotationType','area_annotation');

        for i=1:length(areaHandles)
            areaHandle=areaHandles(i);
            areaObject=get_param(areaHandle,'Object');
            delete(areaObject);
        end
    end
end
