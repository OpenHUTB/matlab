classdef ModelExportData < handle

    properties ( SetAccess = private )
        Model slreportgen.webview.internal.Model
    end





    methods
        function this = ModelExportData( model )
            this.Model = model;
        end

        function write( this, writer )
            arguments
                this %#ok
                writer slreportgen.webview.JSONWriter %#ok
            end

        end
    end
end

