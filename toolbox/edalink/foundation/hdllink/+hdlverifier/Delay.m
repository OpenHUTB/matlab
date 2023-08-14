classdef Delay<matlab.System









    properties
        Length=1
    end

    properties(Access=private)
        UZero;
        CurIndex;
    end

    properties(DiscreteState)

        State;
    end

    methods
        function obj=Delay(varargin)

            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Access=protected)
        function setupImpl(obj,u)


            if strcmpi(class(u),'embedded.fi')
                utype=u.numerictype;
                uzero=fi(0,utype);
            else
                utype=class(u);
                uzero=eval([utype,'(0)']);
            end

            if~isreal(u)
                uzero=complex(uzero,uzero);
            end

            uzero=repmat(uzero,size(u));

            obj.UZero=uzero;
            obj.resetImpl;

        end

        function resetImpl(obj)


            obj.State=repmat(obj.UZero,[1,1,obj.Length]);
            obj.CurIndex=1;
        end

        function y=stepImpl(obj,u)


            y=obj.State(:,:,obj.CurIndex);
            obj.State(:,:,obj.CurIndex)=u;
            obj.CurIndex=obj.CurIndex+1;
            if obj.CurIndex>obj.Length
                obj.CurIndex=1;
            end




        end

        function N=getNumInputsImpl(~)

            N=1;
        end

        function N=getNumOutputsImpl(~)

            N=1;
        end
    end
end


