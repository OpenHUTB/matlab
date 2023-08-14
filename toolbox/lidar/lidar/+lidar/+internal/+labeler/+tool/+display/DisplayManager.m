classdef DisplayManager<vision.internal.labeler.tool.display.DisplayManager




    methods

        function this=DisplayManager(hFig,toolType,defaultName)
            this@vision.internal.labeler.tool.display.DisplayManager(hFig,toolType,defaultName);
        end


        function deleteVoxelLabelData(this,voxelID)
            for dispIdx=2:this.NumDisplays
                deleteVoxelLabelData(this.Displays{dispIdx},voxelID);
            end
        end


        function updateVoxelLabelerLookup(this,color,voxelLabelID)
            for dispIdx=2:this.NumDisplays
                updateVoxelLabelerLookup(this.Displays{dispIdx},color,voxelLabelID);
            end
        end


        function updateVoxelLabelColorInCurrentFrame(this)


            for dispIdx=2:this.NumDisplays
                updateVoxelLabelColorInCurrentFrame(this.Displays{dispIdx});
            end
        end


        function setPasteContextMenuVisibility(this)


            for dispIdx=2:this.NumDisplays
                setPasteContextMenuVisibility(this.Displays{dispIdx});
            end
        end


        function changeVisibilitySelectedVoxelROI(this,selectedLabelData,selectedItemInfo)
            for dispIdx=2:this.NumDisplays
                changeVisibilitySelectedVoxelROI(this.Displays{dispIdx},selectedLabelData,selectedItemInfo);
            end
        end


        function setClusterVisibility(this,tf)


            for dispIdx=2:this.NumDisplays
                setClusterVisibility(this.Displays{dispIdx},tf);
            end
        end
    end



    methods(Hidden)

        function drawVoxelLabels(this,locations)
            for dispIdx=2:this.NumDisplays
                drawVoxelLabels(this.Displays{dispIdx},locations);
            end
        end


        function removeVoxelLabels(this,locations)
            for dispIdx=2:this.NumDisplays
                removeVoxelLabels(this.Displays{dispIdx},locations);
            end
        end
    end
end
