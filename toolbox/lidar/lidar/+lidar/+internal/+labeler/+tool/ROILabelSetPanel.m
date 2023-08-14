


classdef ROILabelSetPanel<vision.internal.labeler.tool.ScrollableList

    methods

        function this=ROILabelSetPanel(parent,position)
            itemFactory=lidar.internal.labeler.tool.ROILabelItemFactory();

            this=this@vision.internal.labeler.tool.ScrollableList(...
            parent,position,itemFactory);
        end


        function appendItemAttribute(this,data,idx)
            appendAttribute(this.Items{idx},data);
        end


        function deleteItemAttribute(this,idx,name)
            deleteAttribute(this.Items{idx},name);
        end


        function modifyItemDescription(this,idx,data)
            modifyDescription(this.Items{idx},data);
        end


        function modifyItemName(this,idx,newName,changeDisplay)
            modifyName(this.Items{idx},newName,changeDisplay);
        end


        function modifyItemColor(this,idx,newLabelColor)
            modifyColor(this.Items{idx},newLabelColor);
        end


        function modifyItemMenuLabel(this,idx,flag)
            modifyMenuLabel(this.Items{idx},flag);
        end


        function modifyItemAttributeName(this,idx,data,newName)
            modifyAttributeName(this.Items{idx},data,newName);
        end


        function listItemExpanded(this,~,data)

            expand(this.Items{data.Index});

            if~isaGroupItem(this.Items{data.Index})

                for i=1:this.NumItems
                    if data.Index~=i
                        if~isaGroupItem(this.Items{i})
                            shrink(this.Items{i});
                        end
                    end
                end
            else
                notify(this,'ItemExpanded',data);
            end

            update(this);

            function TF=isaGroupItem(item)
                TF=isa(item,'vision.internal.labeler.tool.GroupItem');
            end
        end


        function listItemShrinked(this,~,data)

            shrink(this.Items{data.Index});

            if isa(this.Items{data.Index},'vision.internal.labeler.tool.GroupItem')
                notify(this,'ItemShrinked',data);
            end
            update(this);
        end
    end
end
