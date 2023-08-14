function simrfV2_help(blk_ptr)









    narginchk(0,1);

    if nargin<1

        curBlk=gcb;
        if~isempty(curBlk)
            blk_ptr=get_param(curBlk,'Handle');
        else
            error(message('simrf:simrfV2errors:CannotOpenFile',curBlk));
        end
    end

    if isempty(docroot)
        error(message('simrf:simrfV2errors:CannotOpenFile',docroot));
    end

    help_topic=get_param(blk_ptr,'ClassName');
    if isempty(help_topic)


        warning(message('simrf:simrfV2errors:CannotOpenFile',help_topic));
        helpview(fullfile(matlabroot,'toolbox','local','helperr.html'));
    else

        topic_id=['block_',regexprep(lower(help_topic),'[^a-z_0-9]','')];
        helpview(fullfile(docroot,'toolbox','simrf','helptargets.map'),...
        topic_id)
    end

