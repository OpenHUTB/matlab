classdef BlockDelete<handle





    properties(Access=protected)
        deleteListener=[];
        validBlkHdls=[];
    end

    properties(Access=private)




        isBlockConverting=false;
    end

    methods(Access=public)
        function registerDeleteListener(this,validBlkHdls)


            this.setIsBlockConverting(false);


            this.validBlkHdls=validBlkHdls;



            if~isempty(this.deleteListener)
                for idx=1:numel(this.deleteListener)
                    delete(this.deleteListener{idx});
                end
            end


            this.deleteListener=cell(1,numel(validBlkHdls));
            for idx=1:numel(validBlkHdls)
                bObj=get_param(validBlkHdls{idx},'Object');
                this.deleteListener{idx}=...
                Simulink.listener(bObj,'DeleteEvent',@(s,e)onBlockDelete(this,validBlkHdls{idx}));
            end
        end

        function onBlockDelete(this,hdl)



            idx=[this.validBlkHdls{:}]==hdl;


            this.validBlkHdls(idx)=[];




            if isempty(this.validBlkHdls)&&~this.isBlockConverting
                delete(this);
            end
        end

        function setIsBlockConverting(this,val)

            this.isBlockConverting=val;
        end

        function val=getIsBlockConverting(this)
            val=this.isBlockConverting;
        end
    end
end































