classdef ProjectHandle<handle




    methods(Hidden=true)
        function L=addlistener(obj,varargin)
            L=addlistener@handle(obj,varargin);
        end

        function L=listener(obj,varargin)
            L=listener@handle(obj,varargin);
        end

        function delete(obj)
            delete@handle(obj);
        end

        function TF=eq(obj,A,B)
            TF=eq@handle(obj,A,B);
        end

        function HM=findobj(obj,H,varargin)
            HM=findobj@handle(obj,H,varargin);
        end

        function prop=findprop(object,propname)
            prop=findprop@handle(object,propname);
        end

        function TF=ge(obj,A,B)
            TF=ge@handle(obj,A,B);
        end

        function TF=gt(obj,A,B)
            TF=gt@handle(obj,A,B);
        end






        function TF=le(obj,A,B)
            TF=le@handle(obj,A,B);
        end

        function TF=lt(obj,A,B)
            TF=lt@handle(obj,A,B);
        end

        function TF=ne(obj,A,B)
            TF=ne@handle(obj,A,B);
        end

        function notify(obj,varargin)
            notify@handle(obj,varargin);
        end

    end


end

