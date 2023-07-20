classdef db_0146_b<slcheck.subcheck




    methods
        function obj=db_0146_b()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0146_b';
        end

        function result=run(this)


            result=false;

            block=get_param(this.getEntity(),'object');


            if isempty(block)||~ismember(block.BlockType,{'ForIterator','WhileIterator','ForEach'})
                return;
            end




            if any(block.Ports)
                return
            end


            preferredPosition=this.getInputParamByName(...
            DAStudio.message('ModelAdvisor:jmaab:db_0146_BlockPosition'));


            blockLocation={block.Position};


            blockLocExp=[blockLocation{:}];




            blockPos=blockLocExp(getBlockExtremes(preferredPosition));


            parent=block.Parent;
            errFlag=checkBlockLayout(parent,preferredPosition,blockPos,block);


            if errFlag
                result=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(result,'SID',block.Handle);
                result.RecAction=DAStudio.message('ModelAdvisor:jmaab:db_0146_b_rec_action',preferredPosition);
                this.setResult(result);
            end
        end
    end
end






function errFlag=checkBlockLayout(parent,position,blockPos,block)

    [start,minVal]=getIndexStartAndExtremes(position);

    allBlksInSub=find_system(parent,...
    'FindAll','on','regexp','on',...
    'SearchDepth',1,...
    'FollowLinks','on',...
    'Type','block|annotation');

    parentHdl=get_param(parent,'handle');
    allBlksInSub=setdiff(allBlksInSub,[parentHdl;block.Handle]);
    allBlkPos=get_param(allBlksInSub,'Position');
    allBlkPos=[allBlkPos{:}];




    line=find_system(parent,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','type','line');
    linePts=get_param(line,'Points');
    if~iscell(linePts)
        linePts={linePts};
    end
    pos=cellfun(@(x)[min(x(:,1)),min(x(:,2)),max(x(:,1)),max(x(:,2))],...
    linePts,'UniformOutput',false);
    allLinePos=[pos{:}];

    if minVal

        allBlkPos=min(allBlkPos(start:4:end));

        allLinePos=min(allLinePos(start:4:end));

        if isempty(allBlkPos)
            allBlkPos=realmin;
        elseif isempty(allLinePos)
            allLinePos=realmin;
        end

        errFlag=any(blockPos>allBlkPos)||...
...
        blockPos(1)>allLinePos;


    else

        allBlkPos=max(allBlkPos(start:4:end));

        allLinePos=max(allLinePos(start:4:end));

        if isempty(allBlkPos)
            allBlkPos=realmin;
        elseif isempty(allLinePos)
            allLinePos=realmin;
        end

        errFlag=any(blockPos<allBlkPos)||...
...
        blockPos(1)<allLinePos;
    end
end


function[start,minVal]=getIndexStartAndExtremes(position)


    start=1;



    minVal=1;
    switch position
    case DAStudio.message('ModelAdvisor:jmaab:db_0146_BlockPosition_Top')
        start=2;
        minVal=1;
    case DAStudio.message('ModelAdvisor:jmaab:db_0146_BlockPosition_Right')
        start=3;
        minVal=0;
    case DAStudio.message('ModelAdvisor:jmaab:db_0146_BlockPosition_Bottom')
        start=4;
        minVal=0;
    otherwise

    end
end


function blockPos=getBlockExtremes(position)






    val1=1;
    switch position
    case DAStudio.message('ModelAdvisor:jmaab:db_0146_BlockPosition_Top')
        val1=2;
    case DAStudio.message('ModelAdvisor:jmaab:db_0146_BlockPosition_Right')
        val1=3;
    case DAStudio.message('ModelAdvisor:jmaab:db_0146_BlockPosition_Bottom')
        val1=4;
    otherwise

    end
    if val1<3
        val2=val1+2;
    else
        val2=val1-2;
    end


    blockPos=[val1,val2];
end

