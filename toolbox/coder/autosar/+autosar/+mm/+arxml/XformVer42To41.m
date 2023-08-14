classdef XformVer42To41<autosar.mm.arxml.XformVer43To42





    methods
        function self=XformVer42To41(varargin)

            self@autosar.mm.arxml.XformVer43To42(varargin{:});

            self.registerPreTransform('ERROR-HANDLING',@self.skipElements);
            self.registerPostTransform('ERROR-HANDLING',@self.resetSkipElements);




            self.registerPreTransform('PORT-API-OPTIONS',@self.skipElements);
            self.registerPostTransform('PORT-API-OPTIONS',@self.resetSkipElements);
            self.registerPreTransform('PORT-API-OPTION',@self.skipElements);
            self.registerPostTransform('PORT-API-OPTION',@self.resetSkipElements);
            self.registerPreTransform('PORT-REF',@self.skipElements,ParentRoleName='PORT-API-OPTION');
            self.registerPostTransform('PORT-REF',@self.resetSkipElements,ParentRoleName='PORT-API-OPTION');

            self.registerPreTransform('BASE-COMPOSITION-REF',@self.skipElements);
            self.registerPostTransform('BASE-COMPOSITION-REF',@self.resetSkipElements);
        end
    end
end
