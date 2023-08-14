classdef FigureManager<handle




    properties
        PersistentFigures;
        FigureListeners;
        RootListener;
        OriginalDefaultFigureVisible;
        Root;
    end

    methods(Access=public)

        function this=FigureManager(root)
            this.Root=root;
            this.PersistentFigures=[];
            this.FigureListeners={};
        end


        function startCapture(this)
            this.snapshotPersistentFigures();
            this.OriginalDefaultFigureVisible=get(this.Root,'DefaultFigureVisible');
            set(this.Root,'DefaultFigureVisible','off');
            this.RootListener=addlistener(...
            groot,'CurrentFigure','PostSet',@this.handleCurrentFigureChange);
        end


        function stopCapture(this)
            delete(this.RootListener);
            this.closeNonPersistentFigures();
            this.deleteListeners();
            set(this.Root,'DefaultFigureVisible',this.OriginalDefaultFigureVisible);
        end



        function handleCurrentFigureChange(this,~,evtData)


            if(~isempty(evtData.AffectedObject.CurrentFigure))
                if(ismember(evtData.AffectedObject.CurrentFigure.Number,this.PersistentFigures))

                    return;
                end
                evtData.AffectedObject.CurrentFigure.Visible='off';
                listener=addlistener(evtData.AffectedObject.CurrentFigure,'Visible','PostSet',@this.handleFigureVisibilityChange);
                this.FigureListeners(length(this.FigureListeners)+1)={listener};
            end
        end



        function handleFigureVisibilityChange(~,~,evtData)
            if(strcmp(evtData.AffectedObject.Visible,'on'))
                evtData.AffectedObject.Visible='off';
            end
        end
    end

    methods(Access=private)


        function snapshotPersistentFigures(this)

            persistentFigures=allchild(this.Root);
            this.PersistentFigures=[];
            if~(isempty(persistentFigures))
                this.PersistentFigures=[persistentFigures.Number];
            end
        end



        function closeNonPersistentFigures(this)
            if(isempty(this.PersistentFigures))


                close('all','hidden');
            else

                allFigures=allchild(this.Root);
                if~(isempty(allFigures))
                    allFigureNumbers=[allFigures.Number];
                    nonPersistentFigures=setdiff(allFigureNumbers,this.PersistentFigures);
                    close(nonPersistentFigures);
                    this.PersistentFigures=[];
                end
            end
        end


        function deleteListeners(this)
            for ind=1:length(this.FigureListeners)
                delete(this.FigureListeners{ind});
            end
            this.FigureListeners={};
        end

    end
end
