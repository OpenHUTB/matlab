




classdef(Abstract)AnnotationSet<handle

    properties(Access=protected)


LabelSet

















AnnotationStructManager








    end



    methods(Access=public)

















        function configure(this)



            addlistener(this.LabelSet,'LabelAdded',@this.onLabelAdded);
            addlistener(this.LabelSet,'LabelRemoved',@this.onLabelRemoved);
            addlistener(this.LabelSet,'LabelChanged',@this.onLabelChanged);
        end

































        function removeAnnotationsBySignal(this,signalName)
            removeAnnotationStruct(this.AnnotationStructManager,signalName);
        end
    end

    methods(Access=public,Hidden)

        function importAnnotationStruct(this,annStruct)
            this.AnnotationStructManager=annStruct;
        end
    end



    methods(Abstract,Access=protected)

        onLabelAdded(this,~,data);
    end



    methods(Access=protected)


        function onLabelRemoved(this,~,data)

            removed=this.LabelSet.queryLabel(data.Label);

            removeLabel(this.AnnotationStructManager,removed.Label);
        end


        function onLabelChanged(this,~,data)


            if~isempty(data.Color)
                return;
            end
            newLabelName=data.Label;
            oldLabelName=data.OldLabel;
            if(1)
                changed=this.LabelSet.queryLabel(data.Label);
                assert(strcmp(changed.Label,newLabelName));
            end
            changeLabel(this.AnnotationStructManager,oldLabelName,newLabelName);





        end
    end

end