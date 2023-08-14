classdef PositionalMapService<handle




    properties(Access=private)
cache_data
bIsValid
    end

    methods(Static)

        function obj=instance()
            persistent uniqueInstance;
            if isempty(uniqueInstance)
                uniqueInstance=slcheck.services.PositionalMapService();
            end
            obj=uniqueInstance;
        end

        function posmat=getSignalLabelPositions(sigH)
            posmat=[];

            rt=SLM3I.Util.getDiagram(get_param(sigH,'parent'));

            sigm3i=SLM3I.SLDomain.handle2DiagramElement(sigH);

            if sigm3i.label.isEmpty
                return;
            end

            for i=1:sigm3i.label.size
                labelrect=round(slcheck.utils.getLabelPosition(sigm3i.label.at(i)));
                labelrect(3:4)=labelrect(3:4)+labelrect(1:2)-0.5;
                posmat=[posmat;labelrect];%#ok<AGROW>
            end
        end

    end

    methods
        function init(this,system,serviceOptions)



            this.reset();

            this.cache_data=containers.Map('KeyType','double','ValueType','any');




            subSys=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll',true,'FollowLinks',serviceOptions.FollowLinks,'LookUnderMasks',serviceOptions.LookUnderMasks,'BlockType','SubSystem');
            if strcmp(system,bdroot(system))
                subSys(end+1)=get_param(system,'handle');
            end

            for i=1:numel(subSys)


                if isfield(serviceOptions,'BlocksOnly')&&serviceOptions.BlocksOnly==true
                    type='block';
                else
                    type='block|annotation|line';
                end




                elems=find_system(subSys(i),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','LookUnderMasks','all','FindAll',true,'SearchDepth',1,'regexp',true,'type',type);
                elems=setdiff(elems,subSys(i));
                pos_matrix=[];
                for j=1:numel(elems)
                    type=get_param(elems(j),'type');
                    switch(type)
                    case{'block','annotation'}

                        pos_matrix=[pos_matrix;[elems(j),get_param(elems(j),'position')]];
                    case 'line'
                        points=get_param(elems(j),'points');
                        positions=[points,[points(2:end,:);0,0]];
                        for k=1:size(positions,1)
                            if positions(k,1)>positions(k,3)||positions(k,2)>positions(k,4)
                                p=[positions(k,3:4),positions(k,1:2)];
                                positions(k,:)=p;
                            end
                        end
                        pre_pos=positions(1:end-1,:);

                        pos_matrix=[pos_matrix;[repmat(elems(j),size(pre_pos,1),1),pre_pos]];

                        if~(isfield(serviceOptions,'IgnoreLabels')&&serviceOptions.IgnoreLabels==true)


                            pre_pos=slcheck.services.PositionalMapService.getSignalLabelPositions(elems(j));
                            pos_matrix=[pos_matrix;[repmat(elems(j),size(pre_pos,1),1),pre_pos]];
                        end
                    otherwise
                        continue;
                    end
                end
                this.cache_data(subSys(i))=pos_matrix;
            end
            this.bIsValid=true;
        end

        function reset(this)
            this.cache_data=[];
            this.bIsValid=false;
        end

        function bValid=isValid(this)
            bValid=this.bIsValid;
        end

        function posMat=getPositionalMatrixForSubsys(this,canvasH)
            if~ishandle(canvasH)
                canvasH=get_param(canvasH,'handle');
            end
            posMat=this.cache_data(canvasH);
        end

        function num=getNumElementsInRect(this,canvasH,Rect)
            num=0;

            posMat=this.cache_data(canvasH);

            for i=1:size(posMat,1)
                RComp=posMat(i,2:end);
                num=num+isRectangleOverlap(Rect,RComp);
            end
        end
    end
end

function bResult=isRectangleOverlap(R1,R2)
    bResult=~(R1(3)<R2(1)||R2(3)<R1(1)||R1(4)<R2(2)||R2(4)<R1(2));
end
