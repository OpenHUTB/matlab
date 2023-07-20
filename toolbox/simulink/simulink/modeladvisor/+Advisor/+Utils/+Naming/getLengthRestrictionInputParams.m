function[inputParams,gridLayout]=getLengthRestrictionInputParams(checkGroup)

    switch checkGroup
    case 'JMAAB'
        paramFollowLinks=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
        paramLookUnderMasks=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
        paramConvention=Advisor.Utils.createStandardInputParameters('jmaab.StandardSelection');
        paramMinLength=Advisor.Utils.getInputParam_String('ModelAdvisor:jmaab:MinLength',[3,3],[1,2]);
        paramMaxLength=Advisor.Utils.getInputParam_String('ModelAdvisor:jmaab:MaxLength',[3,3],[3,4]);

        paramConvention.RowSpan=[2,2];
        paramLookUnderMasks.ColSpan=[3,4];

        [paramMinLength.Value,paramMaxLength.Value]=Advisor.Utils.Naming.getNameLength('JMAAB');

        inputParams={paramFollowLinks,paramLookUnderMasks,paramConvention,paramMinLength,paramMaxLength};

        gridLayout=[3,4];
    otherwise
        inputParams=[];
        gridLayout=[];
    end
end
