classdef App_1<handle




    properties(Access=public)
        myModel rf.internal.apps.matchnet.Model_1
        myView rf.internal.apps.matchnet.View_1
        myController rf.internal.apps.matchnet.Controller_1
    end

    properties(SetAccess=protected,Hidden)
        toolStrip rf.internal.apps.matchnet.Toolstrip_2
    end

    methods
        function this=App_1(varargin)
            this.myModel=rf.internal.apps.matchnet.Model_1;
            this.myView=rf.internal.apps.matchnet.View_1;
            this.myController=rf.internal.apps.matchnet.Controller_1(this.myModel,this.myView);

            if nargin
                initialModel(this.myModel,varargin{1})
            end

            this.toolStrip=this.myView.myToolstrip;


            set(this.myView,'CanCloseFcn',@(h,e)appCloseRequestFcn(this));


        end

        function result=appCloseRequestFcn(this)





            if this.myView.Busy
                result=false;
            else
                if this.myModel.IsChanged
                    if this.myView.processMatchingNetworkDesignerSaving()
                        result=false;
                        return;
                    end
                end
                this.myView.Busy=true;
                if~isempty(this.toolStrip)
                    delete(this.toolStrip.galleryItems)
                    delete(this.toolStrip.ComponentGallery)
                end
                delete(this.toolStrip)
                delete(this.myController)
                delete(this.myModel)


                result=true;
            end
        end
    end
end
