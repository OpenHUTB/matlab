classdef(Abstract,Sealed,Hidden)quat




    methods(Hidden,Static)
        function qout=conj(q)
            if isa(q,'quaternion')
                qout=quaternion(Aero.internal.shared.quaternion.conj(q.compact));
            else
                qout=Aero.internal.shared.quaternion.conj(q);
            end
        end
        function qout=divide(q,r)
            if isa(q,'quaternion')&&isa(r,'quaternion')
                qout=quaternion(Aero.internal.shared.quaternion.divide(q.compact,r.compact));
            else
                qout=Aero.internal.shared.quaternion.divide(q,r);
            end
        end
        function qout=exp(q)
            if isa(q,'quaternion')
                qout=quaternion(Aero.internal.shared.quaternion.exp(q.compact));
            else
                qout=Aero.internal.shared.quaternion.exp(q);
            end
        end
        function qout=interp(p,q,f,varargin)
            if isa(p,'quaternion')&&isa(q,'quaternion')
                qout=quaternion(Aero.internal.shared.quaternion.interp(p.compact,q.compact,f,varargin{:}));
            else
                qout=Aero.internal.shared.quaternion.interp(p,q,f,varargin{:});
            end
        end
        function qout=inv(q)
            if isa(q,'quaternion')
                qout=quaternion(Aero.internal.shared.quaternion.inv(q.compact));
            else
                qout=Aero.internal.shared.quaternion.inv(q);
            end
        end
        function qout=log(q)
            if isa(q,'quaternion')
                qout=quaternion(Aero.internal.shared.quaternion.log(q.compact));
            else
                qout=Aero.internal.shared.quaternion.log(q);
            end
        end
        function qout=mod(q)
            if isa(q,'quaternion')
                qout=Aero.internal.shared.quaternion.mod(q.compact);
            else
                qout=Aero.internal.shared.quaternion.mod(q);
            end
        end
        function qout=multiply(q,varargin)
            if isa(q,'quaternion')&&(nargin==1)
                qout=quaternion(Aero.internal.shared.quaternion.multiply(q.compact));
            elseif isa(q,'quaternion')&&isa(varargin{1},'quaternion')
                qout=quaternion(Aero.internal.shared.quaternion.multiply(q.compact,compact(varargin{1})));
            else
                qout=Aero.internal.shared.quaternion.multiply(q,varargin{:});
            end
        end
        function qout=norm(q)
            if isa(q,'quaternion')
                qout=Aero.internal.shared.quaternion.norm(q.compact);
            else
                qout=Aero.internal.shared.quaternion.norm(q);
            end
        end
        function qout=normalize(q)
            if isa(q,'quaternion')
                qout=quaternion(Aero.internal.shared.quaternion.normalize(q.compact));
            else
                qout=Aero.internal.shared.quaternion.normalize(q);
            end
        end
        function qout=power(q,pow)
            if isa(q,'quaternion')
                qout=quaternion(Aero.internal.shared.quaternion.power(q.compact,pow));
            else
                qout=Aero.internal.shared.quaternion.power(q,pow);
            end
        end
        function n=rotate(q,r)
            if isa(q,'quaternion')
                n=Aero.internal.shared.quaternion.rotate(q.compact,r);
            else
                n=Aero.internal.shared.quaternion.rotate(q,r);
            end
        end
        function dcm=toDCM(q)
            if isa(q,'quaternion')
                dcm=Aero.internal.shared.quaternion.toDCM(q.compact);
            else
                dcm=Aero.internal.shared.quaternion.toDCM(q);
            end
        end
    end
end
