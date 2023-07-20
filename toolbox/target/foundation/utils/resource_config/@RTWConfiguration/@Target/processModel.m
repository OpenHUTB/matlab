function processModel(target)















    block=target.block;



















    load_system('config_library');


    baseRCblock=find_system('config_library','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'tag','RTW CONFIGURATION BLOCK');
    if strcmp(baseRCblock,get_param(block,'AncestorBlock'))

        return;
    end

    block=getfullname(block);



    b=find_system(get_param(block,'parent'),...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on',...
    'FollowLinks','on',...
    'LinkStatus','resolved');




    tags=get_param(b,'tag');
    tags_idx=strmatch({'RTW CONFIGURATION BLOCK'},tags);
    if length(tags_idx)>=2
        block=b{tags_idx(2)};
        block=regexprep(block,sprintf('\n'),' ');
        TargetCommon.ProductInfo.error('resourceConfiguration','ResourceConfigurationBlockDuplicated',block);
    end





    c=unique(get_param(b,'referenceblock'));

    d=unique(i_bdroot(c));
    for i=1:length(d)
        load_system(i_bdroot(d{i}));
    end




    c=get_param(c,'parent');



    defaultConfigLibrary=get_param(block,'defaultConfigLibrary');
    if~isempty(defaultConfigLibrary)
        try,
            load_system(defaultConfigLibrary);
            if~isempty(defaultConfigLibrary)
                c={c{:},get_param(block,'defaultConfigLibrary')};
            end
        catch
            TargetCommon.ProductInfo.error('resourceConfiguration','LibraryMissing',defaultConfigLibrary);
        end
    end

    e=unique(c);



    lib_subsystems=setdiff(e,'config_library');



    g={};

    sub_iterator=lib_subsystems;
    while~isempty(sub_iterator)&~isequal(sub_iterator,{''})
        g_new=unique(find_system(sub_iterator,'SearchDepth',1,'tag','CONFIGURATION DATA CLASS'));
        g={g{:},g_new{:}};
        sub_iterator=setdiff(unique(get_param(sub_iterator,'parent')),{''});
    end



    implicitLibs=target.implicitLibs;
    implicitBlocks=find_system(implicitLibs,'SearchDepth',1,'tag','CONFIGURATION DATA CLASS');
    lib=length(implicitBlocks);
    lil=length(implicitLibs);
    if lib~=lil
        TargetCommon.ProductInfo.error('resourceConfiguration','ResourceConfigurationBlockDuplicatedInLibrary',lil,char(implicitLibs),lib,char(implicitBlocks));
    end
    g={g{:},implicitBlocks{:}};
    g=unique(g);



    required_class_list=get_param(g,'dClassName');
    required_resource_list=get_param(g,'rClassName');
    lib_subsystems=get_param(g,'parent');


    for i=1:length(required_class_list)




        node=target.getNodes('active',required_class_list{i});
        if isempty(node)
            node=target.getNodes('inactive',required_class_list{i});
            if isempty(node)


                try
                    data=eval([required_class_list{i},'(''new'')']);
                catch
                    TargetCommon.ProductInfo.error...
                    ('resourceConfiguration','InvalidUDDClass',required_class_list{i});
                end


                if~isempty(strrep(required_resource_list{i},' ',''))
                    try
                        resource=eval(required_resource_list{i});
                    catch
                        TargetCommon.ProductInfo.error('resourceConfiguration','InvalidUDDClass',required_resource_list{i});
                    end
                else
                    resource=[];
                end


                target.createNode('active',data,resource,lib_subsystems{i});

            else


                target.connectNodeToActiveList(node);

            end
        end
    end






    nodes=target.getNodes('active');
    current_class_list=get(nodes,'classkey');




    unrequired_class_list=setdiff(current_class_list,required_class_list);
    for i=1:length(unrequired_class_list)
        to_disconnect=target.getNodes('active',unrequired_class_list{i});
        if~isempty(to_disconnect)
            target.connectNodeToInactiveList(to_disconnect);
        end
    end



    target.validate;





    function root=i_bdroot(block)
        if iscell(block)
            l=length(block);
            root=cell(1,l);
            for i=1:l
                root{i}=i2_bdroot(block{i});
            end
        else
            root=i2_bdroot(block);
        end

        function root=i2_bdroot(block)
            mtch=findstr('/',block);
            if isempty(mtch)
                root=block;
            else
                root=block(1:(mtch(1)-1));
            end



