classdef SuperpixelSection<vision.internal.uitools.NewToolStripSection




    properties
SuperpixelButton
SuperpixelGridCountLabel
SuperpixelGridCountSlider
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons');
    end

    methods
        function this=SuperpixelSection()
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)
        function createSection(this)
            superpixelSectionTitle=getString(message('vision:labeler:Superpixel'));
            superpixelSectionTag='sectionSuperpixel';

            this.Section=matlab.ui.internal.toolstrip.Section(superpixelSectionTitle);
            this.Section.Tag=superpixelSectionTag;
        end

        function layoutSection(this)
            this.addSuperpixelButton();
            this.addGridCountSlider();

            colAddSession=this.addColumn();
            colAddSession.add(this.SuperpixelButton);

            colAddSession=this.addColumn('width',120,...
            'HorizontalAlignment','center');
            colAddSession.add(this.SuperpixelGridCountLabel);
            colAddSession.add(this.SuperpixelGridCountSlider);
        end


        function addSuperpixelButton(this)

            addSuperpixelTitleId='vision:labeler:Superpixel';
            addSuperpixelIcon=fullfile(this.IconPath,'Superpixel_24.png');
            addSuperpixelTag='btnAddSuperpixelLayout';
            this.SuperpixelButton=this.createToggleButton(addSuperpixelIcon,...
            addSuperpixelTitleId,addSuperpixelTag);
            toolTipID='vision:labeler:SuperpixelStateTooltip';
            this.setToolTipText(this.SuperpixelButton,toolTipID);
        end

        function addGridCountSlider(this)


            sliderTitleId='vision:labeler:SuperpixelNumberLabelTitle';
            this.SuperpixelGridCountLabel=this.createLabel(sliderTitleId);
            toolTipID='vision:labeler:SuperpixelNumberLabelTooltip';
            this.setToolTipText(this.SuperpixelGridCountLabel,toolTipID);


            sliderLabelTag='btnSuperpixelNumberSlider';



            range=[1,1000];
            startVal=400;
            this.SuperpixelGridCountSlider=this.createSlider(range,startVal,sliderLabelTag,toolTipID);
            this.SuperpixelGridCountSlider.Ticks=0;
        end
    end
end