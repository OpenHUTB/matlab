classdef MatrixApp<handle

    properties(Constant,Hidden)
        REL_URL='toolbox/systemcomposer/matrix/widget/web/index.html';
        DEBUG_URL='toolbox/systemcomposer/matrix/widget/web/index-debug.html';
    end


    properties(Access=private)
        URL='';
        IsDebug;
    end


    properties(SetAccess=protected)
Model
Channel
Sync
    end


    methods

        function this=MatrixApp()

            this.IsDebug=false;
            this.URL=connector.getUrl(this.REL_URL);

            this.Model=mf.zero.Model;
            this.Channel=mf.zero.io.ConnectorChannelMS('/systemcomposer_matrix_datamodel/channelOut','/systemcomposer_matrix_datamodel/channelIn');
            this.Sync=mf.zero.io.ModelSynchronizer(this.Model,this.Channel);

            this.Sync.start();
        end


        function open(this)
            web(this.URL,'-browser');
        end


        function debugMode(this,blnDebug)

            if blnDebug
                this.IsDebug=true;
                this.URL=connector.getUrl(this.DEBUG_URL);
            else
                this.IsDebug=false;
                this.URL=connector.getUrl(this.REL_URL);
            end
        end

    end



    methods(Hidden)

        function url=getURL(this)
            url=this.URL;
        end

    end
end
