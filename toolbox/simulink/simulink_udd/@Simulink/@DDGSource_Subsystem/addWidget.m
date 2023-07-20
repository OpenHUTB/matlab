function items=addWidget(source,items,param,isVisible,varargin)














    refreshDialog=false;
    isEnabled=false;

    if isVisible
        isEnabled=true;

        if nargin>4
            refreshDialog=varargin{1};
        end

        if nargin>5
            isEnabled=varargin{2};
        end
    end

    block=source.getBlock;
    rowIdx=1;

    switch lower(block.IntrinsicDialogParameters.(param).Type)
    case 'boolean'
        item=create_widget(source,block,param,rowIdx,1,1);

        item.DialogRefresh=refreshDialog;
        item.Visible=isVisible;
        item.Enabled=isEnabled;
        if source.isSlimDialog




            item.Source=block;
        end
        item=updateItem(block,param,item);
    otherwise
        [prompt,value]=create_widget(source,block,param,rowIdx,1,1);

        prompt.Visible=isVisible;
        prompt.Enabled=isEnabled;
        if source.isSlimDialog


            prompt.Elide=true;
            prompt.PreferredSize=[120,-1];




            value.Source=block;
        end
        item{1}=prompt;

        value.DialogRefresh=refreshDialog;
        value.Visible=isVisible;
        value.Enabled=isEnabled;

        value=updateItem(block,param,value);
        item{2}=value;

    end

    items=appendWidget(source,items,item);

end




function ret=updateItem(block,param,item)

    ret=item;




    if isLinked(block.Handle)
        if isLinkInstance(block,param)
            ret.Enabled=true;
        else
            ret.Enabled=false;
        end
    end

end

function ret=isLinked(blkHandle)
    linkStatusForBlock=get_param(blkHandle,'StaticLinkStatus');
    switch linkStatusForBlock
    case{'resolved','implicit'}
        ret=true;
    case{'inactive','none'}
        ret=false;
    end
end

function ret=isLinkInstance(block,param)


    attribs=block.IntrinsicDialogParameters.(param).Attributes;
    ret=false;
    for idx=1:numel(attribs)
        att=attribs{idx};
        if strcmp(att,'link-instance')||strcmp(att,'always-link-instance')
            ret=true;
            return;
        end
    end

end
