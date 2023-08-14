classdef CuboidManager<handle























































    properties(Dependent)


NumInUse


Enabled

    end

    properties(Dependent,SetAccess=private,GetAccess=public)


CurrentROIs

    end

    properties(Access=private)



        ROI images.roi.Cuboid


Labeler


        NumInUseInternal=0;


        InteractionsAllowedInternal='all';


ContextMenu

    end

    methods

        function this=CuboidManager(labeler)



            this.Labeler=labeler;
            createContextMenu(this);



            create(this,1,100);

        end

        function add(this,data)


            this.NumInUseInternal=this.NumInUseInternal+1;
            checkIfMoreROIsRequired(this);


            idx=find(~getCurrentROIIndices(this),1);
            if isempty(idx)
                idx=1;
            end

            set(this.ROI(idx),data{:});

        end

        function remove(this,roi)


            idx=find(this.ROI==roi,1);
            set(this.ROI(idx),'Parent',gobjects(0));
            this.NumInUseInternal=this.NumInUseInternal-1;

        end

        function update(this,idx,data)


            set(this.ROI(idx),data{:});

        end

        function setprop(this,varargin)


            set(this.ROI,varargin{:});

        end

    end

    methods(Access=private)

        function create(this,first,last)




            for idx=first:last

                h=images.roi.Cuboid('Rotatable','z',...
                'SelectedColor',[1,1,0],...
                'InteractionsAllowed',this.InteractionsAllowedInternal,...
                'UIContextMenu',this.ContextMenu);

                addlistener(h,'ROIClicked',@(src,evt)onROIClicked(this.Labeler,src,evt));
                addlistener(h,'DeletingROI',@(src,~)onROIDeleted(this.Labeler,src));
                addlistener(h,'MovingROI',@(src,evt)MovingROICallback(this.Labeler,src,evt));
                addlistener(h,'ROIMoved',@(src,evt)ROIMovedCallback(this.Labeler,src,evt));

                this.ROI=[this.ROI,h];

            end

        end

        function deparent(this)


            if numel(this.ROI)>this.NumInUse
                set(this.ROI(this.NumInUse+1:end),'Parent',gobjects(0));
            end

        end

        function createContextMenu(this)





            cmenu=uicontextmenu(getFigure(this.Labeler));



            uimenu('Parent',cmenu,'Label',vision.getMessage('images:imroi:deleteCuboid'),'Callback',@(src,evt)deleteSelectedROIs(this.Labeler,src,evt));
            uimenu('Parent',cmenu,'Label',vision.getMessage('vision:labeler:ContextMenuCopy'),'Callback',@(src,evt)this.Labeler.CopyCallbackFcn);
            uimenu('Parent',cmenu,'Label',vision.getMessage('vision:labeler:ContextMenuCut'),'Callback',@(src,evt)this.Labeler.CutCallbackFcn);

            this.ContextMenu=cmenu;

        end

        function idx=getCurrentROIIndices(this)
            idx=cellfun(@(x)~isempty(x),get(this.ROI,'Parent'));
        end

        function checkIfMoreROIsRequired(this)
            if numel(this.ROI)<this.NumInUse
                create(this,numel(this.ROI)+1,this.NumInUse);
            end
        end

    end

    methods





        function set.NumInUse(this,val)



            this.NumInUseInternal=val;

            checkIfMoreROIsRequired(this);

            deparent(this);

        end

        function val=get.NumInUse(this)

            val=this.NumInUseInternal;

        end




        function set.Enabled(this,TF)





            if TF
                this.InteractionsAllowedInternal='all';
            else
                this.InteractionsAllowedInternal='none';
            end
            set(this.ROI,'InteractionsAllowed',this.InteractionsAllowedInternal);

        end

        function TF=get.Enabled(this)

            TF=strcmp(this.InteractionsAllowedInternal,'all');

        end




        function rois=get.CurrentROIs(this)
            rois=this.ROI(getCurrentROIIndices(this));
        end

    end

end