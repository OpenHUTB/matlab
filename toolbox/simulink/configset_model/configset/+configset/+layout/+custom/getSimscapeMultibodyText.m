function out=getSimscapeMultibodyText(~,varargin)




    treeNode=simmechanics.sli.internal.getConfigParamTree;
    tNodeChildren=treeNode.getChildren;
    pageInfo=tNodeChildren{3}.Info.Annotation;


    out.Items={};
    for i=1:length(pageInfo)
        widget.Type='text';
        widget.Name=message(pageInfo{i}.TextKey).getString;
        widget.WordWrap=true;
        widget.MinimumSize=[600,20];
        if pageInfo{i}.Border
            group.Type='group';
            group.Name=message(pageInfo{i}.NameKey).getString;
            group.Items={widget};
            out.Items{i}=group;
        else
            out.Items{i}=widget;
        end
    end

