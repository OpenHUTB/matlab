function nesl_maskinitialization(hBlock)








    if pmsl_ismodelrunning(hBlock)
        return;
    end


    simscape.compiler.sli.internal.displayIfNoLicense(hBlock);


    persistent DISPATCH;
    if isempty(DISPATCH)
        types={'solver';
        'ps_input';
        'ps_output'};
        DISPATCH=struct;
        for i=1:length(types)









            fcnname=['l_',types{i}];
            DISPATCH.(types{i})=str2func(fcnname);


            fcnname=['l_',types{i},'_eval_key'];
            DISPATCH.([types{i},'_eval_key'])=str2func(fcnname);
        end
    end


    type=get_param(hBlock,'SubClassName');
    if strcmpi(type,'eval_key')
        type=[get_param(get_param(hBlock,'Parent'),'SubClassName'),'_eval_key'];
    end
    fcn=DISPATCH.(type);
    fcn(hBlock);
end

function l_solver(hBlock)
end

function l_solver_eval_key(hBlock)

    l_delete_blocks(hBlock);
    l_delete_all_lines(hBlock);

    parent=get_param(get_param(hBlock,'Parent'),'Handle');
    [~,blockInfo,active]=nesl_blockregistry(getfullname(parent));
    if~active



        return;
    end

    l_blocksetup(getfullname(hBlock),blockInfo.connInfo);
end


function pm_unit=l_get_block_unit(block)
    pm_unit=get_param(block,'Unit');
end

function sl_unit=l_get_sl_unit(block,pm_unit)
    if~Simulink.UnitUtils.checkSimscapeUnitCompatibleWithSimulink(block,pm_unit)
        Simulink.UnitUtils.reportIncompatibleSimscapeUnit(block,pm_unit);
    end
    is_affine=strcmpi(get_param(block,'AffineConversion'),'on');


    is_relative=~is_affine;
    sl_unit=builtin('_ps2s_nonaffine_unit_conversion',pm_unit,is_relative);
end


function l_ps_input(hBlock)

    if strcmp(get_param(hBlock,'FilteringAndDerivatives'),'provide')
        num_derivs_provided=str2double(get_param(hBlock,'UdotUserProvided'));
    else


        num_derivs_provided=0;
    end
    fullname=getfullname(hBlock);

    for i=1:2
        blk=sprintf('%s/input%d',fullname,i);
        if i<=num_derivs_provided



            type='Inport';
        else



            type='Ground';
        end





        oldType=get_param(blk,'BlockType');
        if~strcmpi(oldType,type)
            position=get_param(blk,'Position');
            delete_block(blk);
            add_block(['built-in/',type],blk,...
            'Position',position);


            orientation=get_param(hBlock,'Orientation');
            pos=get_param(hBlock,'Position');


            if(strcmp(orientation,'right')||strcmp(orientation,'left'))
                if(pos(4)-pos(2)<40)
                    pos=pos+[0,-12,0,12];
                    set_param(hBlock,'Position',pos);
                end
            else
                if(pos(3)-pos(1)<40)
                    pos=pos+[-12,0,12,0];
                    set_param(hBlock,'Position',pos);
                end
            end
        end
    end











    [~,blockInfo,active]=nesl_blockregistry(fullname);
    expSize='-1';
    if active







        if any(blockInfo.data==1)
            expSize=mat2str(prod(blockInfo.data));
        else
            expSize=mat2str(blockInfo.data);
        end
    end
    for i=0:2
        blk=sprintf('%s/input%d',fullname,i);
        if strcmp(get_param(blk,'Blocktype'),'Inport')
            set_param(blk,'PortDimensions',expSize,...
            'OutDataTypeStr','double');
            slUnit=l_get_sl_unit(hBlock,l_get_block_unit(hBlock));
            switch i
            case 0
                unit=slUnit;
            case 1
                unit=[slUnit,'/s'];
            otherwise
                unit=[slUnit,'/s^',int2str(i)];
            end
            set_param(blk,'OutUnit',unit);
        end
    end
end

function l_ps_input_eval_key(hBlock)

    fullname=getfullname(hBlock);
    parent=get_param(get_param(hBlock,'Parent'),'Handle');
    [~,blockInfo,active]=nesl_blockregistry(getfullname(parent));
    if active



        l_ps_input_cleanup(hBlock);
        l_blocksetup(fullname,blockInfo.connInfo);
    else





        terminator=find_system(hBlock,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'BlockType','Terminator');
        if isempty(terminator)
            l_ps_input_cleanup(hBlock);
            for i=0:2
                term=sprintf('Terminator%d',i);
                add_block('built-in/Terminator',[fullname,'/',term],...
                'Position',[340,50*i,460,30+50*i]);
                add_line(hBlock,sprintf('input%d/1',i),[term,'/1']);
            end
        end
    end
end

function l_ps_input_cleanup(hBlock)
    l_delete_blocks(hBlock,'input0','input1','input2');
    l_delete_all_lines(hBlock);
end

function l_ps_output(hBlock)
    fullname=getfullname(hBlock);
    blk=[fullname,'/output'];
    blkUnit=l_get_block_unit(hBlock);

    if strcmp(blkUnit,pm_inherit_id())
        slUnit=blkUnit;
        [~,blockInfo,active]=nesl_blockregistry(fullname);
        if active&&isfield(blockInfo.data,'Unit')
            slUnit=l_get_sl_unit(hBlock,blockInfo.data.Unit);
        end
    else
        slUnit=l_get_sl_unit(hBlock,blkUnit);
    end

    set_param(blk,'OutUnit',slUnit);
end

function l_ps_output_eval_key(hBlock)

    fullname=getfullname(hBlock);
    parent=get_param(get_param(hBlock,'Parent'),'Handle');
    [~,blockInfo,active]=nesl_blockregistry(getfullname(parent));
    if active



        l_ps_output_cleanup(hBlock);
        l_blocksetup(fullname,blockInfo.connInfo);
    else





        ground=find_system(hBlock,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'BlockType','Ground',...
        'Name','Ground');
        if isempty(ground)
            l_ps_output_cleanup(hBlock);
            fullname=getfullname(hBlock);
            add_block('built-in/Ground',[fullname,'/Ground'],...
            'Position',[0,0,120,30]);
            add_line(hBlock,'Ground/1','output/1');
        end
    end
end

function l_ps_output_cleanup(hBlock)
    l_delete_blocks(hBlock,'output');
    l_delete_all_lines(hBlock);
end

function l_delete_blocks(hBlock,varargin)



    blocks=find_system(hBlock,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'SearchDepth',1,...
    'Type','block');




    names=get_param(blocks,'Name');
    [~,ok]=setdiff(names,varargin);
    blocks=blocks(ok);




    for j=1:length(blocks)
        if blocks(j)~=hBlock
            delete_block(blocks(j));
        end
    end
end

function l_delete_all_lines(hBlock)

    lines=find_system(hBlock,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'SearchDepth',1,...
    'FindAll','on',...
    'Type','line');
    for j=1:length(lines)
        try %#ok





            delete_line(lines(j));
        end
    end
end

function l_blocksetup(fullname,connInfo)




    incr=0;








    canvasHeight=32767;
    vertIncr=50;
    if length(connInfo.blocks)*vertIncr<canvasHeight/5
        incr=vertIncr;
    end


    width=170;


    heights=zeros(1,8);




    for i=1:length(connInfo.blocks)




        block=connInfo.blocks{i};




        offset=(block.Column-1)*width;
        height=heights(block.Column);
        position=[offset,height,offset+120,height+30];
        path=[fullname,'/',block.Name];

        newBlock=[{...
        block.Type,path...
        ,'Position',position},{block.Parameters{:}}];




        h=add_block(newBlock{:});
        nesl_addedblockregistry(block.Name,h);




        heights(block.Column)=heights(block.Column)+incr;
    end




    for i=1:length(connInfo.lines)
        line=connInfo.lines{i};
        if iscell(line{2})
            for j=1:length(line{2})
                add_line(fullname,line{1},line{2}{j});
            end
        else
            add_line(fullname,line{1},line{2});
        end
    end
end
