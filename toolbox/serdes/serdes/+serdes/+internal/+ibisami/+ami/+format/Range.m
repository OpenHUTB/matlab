classdef Range<serdes.internal.ibisami.ami.format.TypMinMaxCommon




    properties(Constant)
        Name="Range";
    end

    methods
        function range=Range(varargin)
            range=range@serdes.internal.ibisami.ami.format.TypMinMaxCommon(varargin{:});
            range.AllowedTypeNames=[serdes.internal.ibisami.ami.type.Float().Name,...
            serdes.internal.ibisami.ami.type.UI().Name,...
            serdes.internal.ibisami.ami.type.Integer().Name,...
            serdes.internal.ibisami.ami.type.Tap().Name];
        end
    end
end

