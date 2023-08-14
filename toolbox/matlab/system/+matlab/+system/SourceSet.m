classdef(Sealed)SourceSet


%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>



    properties(SetAccess=private)
SystemBlockPolicy
MATLABPolicy
    end

    properties(Access=private)
        pReuseProperty=true
    end

    methods
        function policy=getPolicy(obj,platIdx)
            if platIdx
                policy=obj.SystemBlockPolicy;
            else
                policy=obj.MATLABPolicy;
            end
        end

        function ctrlPropName=getControlPropertyName(obj,platIdx)
            policy=getPolicy(obj,platIdx);
            ctrlPropName=policy.ControlPropertyName;
        end

        function obj=SourceSet(varargin)
            coder.allowpcode('plain');
            coder.extrinsic('getParsedInfo');
            if isa(varargin{1},'matlab.system.CustomPropertyOrInput')
                obj.SystemBlockPolicy=varargin{1};
                if nargin==2&&isa(varargin{2},'matlab.system.CustomPropertyOrInput')
                    error(message('MATLAB:system:badMATLABSourceSetPolicyName',class(varargin{2})));
                else
                    mlPolicyCells=...
                    matlab.system.SourceSet.getParsedInfo(false,varargin{2:end});


                    policyObj=createPoliciesFromCells(obj,coder.const(mlPolicyCells));
                    obj.MATLABPolicy=policyObj;
                end
            else
                [mlPolicyCells,~,sbPolicyCells]=...
                matlab.system.SourceSet.getParsedInfo(true,varargin{:});


                policyObj=createPoliciesFromCells(obj,coder.const(mlPolicyCells));
                obj.MATLABPolicy=policyObj;
                policyObj=createPoliciesFromCells(obj,coder.const(sbPolicyCells));
                obj.SystemBlockPolicy=policyObj;
            end
        end

        function policyObj=createPoliciesFromCells(~,policyCell)

            policyName=policyCell{end-2};
            switch policyName
            case 'Property'
                policyObj=matlab.system.internal.PropertyOnly(policyCell{end-1},...
                policyCell{end},policyCell{2});

            case 'Disabled'
                policyObj=matlab.system.internal.DisabledOnly(policyCell{end-1},...
                policyCell{end},policyCell{2});

            case 'PropertyOrInput'
                policyObj=matlab.system.internal.PropertyOrInput(policyCell{end-1},...
                policyCell{end},policyCell{2},...
                policyCell{1},policyCell{4});

            case 'PropertyOrMethod'
                policyObj=matlab.system.internal.PropertyOrMethod(policyCell{end-1},...
                policyCell{end},policyCell{1},policyCell{3});

            otherwise
                error(message('MATLAB:system:badSourceSetPolicyName',policyName));
            end
        end
    end

    methods(Hidden,Static)
        function[mlPolicyCells,sbPolicyCells]=checkAndProcessInputs(...
            mlPolicyCells,sbPolicyCells,disableValidation)

            if disableValidation
                return
            end


            if~isempty(mlPolicyCells)
                mlPolicyName=mlPolicyCells{1};
                if strcmp(mlPolicyName,'PropertyOrInput')||strcmp(mlPolicyName,'PropertyOrMethod')
                    error(message('MATLAB:system:badMATLABSourceSetPolicyName',mlPolicyName));
                end
            end


            if~isempty(sbPolicyCells)
                sbPolicyName=sbPolicyCells{1};
                if~isempty(mlPolicyCells)&&strcmp(mlPolicyName,'Property')&&strcmp(sbPolicyName,'Property')
                    error(message('MATLAB:system:doublePropertySourceSetPolicyName',mlPolicyName));
                end
            end
        end

        function[mlPolicyCells,Reuse,sbPolicyCells]=getParsedInfo(enableIdentCheck,varargin)
            if iscell(varargin{1})

                lResults=matlab.system.SourceSet.parseInputAsCellArray(varargin{:});

                fcnIsReuse=@(x)(ischar(x)||isstring(x))&&strcmp(x,'ReuseProperty');
                if any(cell2mat(cellfun(fcnIsReuse,lResults.FirstPolicy,'UniformOutput',false)))
                    error(message('MATLAB:system:sourcesetInvalidOptionalParameter','First','ReuseProperty'));
                end
                if any(cell2mat(cellfun(fcnIsReuse,lResults.SecondPolicy,'UniformOutput',false)))
                    error(message('MATLAB:system:sourcesetInvalidOptionalParameter','Second','ReuseProperty'));
                end

                [matlabPolicyCells,systemBlockPolicyCells]=matlab.system.SourceSet.assignPoliciesFromCells(lResults);

                tempStr.pReuseProperty=lResults.ReuseProperty;
                defResults.IsControlActive=false;
                defResults.ControlName=lResults.FirstPolicy{3};

                if tempStr.pReuseProperty
                    defResults.PolicyName='Property';
                else
                    defResults.PolicyName='Disabled';
                end

                [matlabPolicyCells,systemBlockPolicyCells]=...
                matlab.system.SourceSet.checkAndProcessInputs(...
                matlabPolicyCells,systemBlockPolicyCells,lResults.DisableValidation);

                if isempty(systemBlockPolicyCells)
                    mlResults=matlab.system.SourceSet.parsePolicyFromNameValueList(matlabPolicyCells{:});
                    tempStr.MATLABPolicy=matlab.system.SourceSet.createPoliciesFromResults(mlResults);
                    defResults.Client='SystemBlock';
                    tempStr.SystemBlockPolicy=matlab.system.SourceSet.createPoliciesFromResults(defResults);
                elseif isempty(matlabPolicyCells)
                    sbResults=matlab.system.SourceSet.parsePolicyFromNameValueList(systemBlockPolicyCells{:});
                    tempStr.SystemBlockPolicy=matlab.system.SourceSet.createPoliciesFromResults(sbResults);
                    defResults.Client='MATLAB';
                    tempStr.MATLABPolicy=matlab.system.SourceSet.createPoliciesFromResults(defResults);
                else
                    mlResults=matlab.system.SourceSet.parsePolicyFromNameValueList(matlabPolicyCells{:});
                    tempStr.MATLABPolicy=matlab.system.SourceSet.createPoliciesFromResults(mlResults);

                    sbResults=matlab.system.SourceSet.parsePolicyFromNameValueList(systemBlockPolicyCells{:});
                    tempStr.SystemBlockPolicy=matlab.system.SourceSet.createPoliciesFromResults(sbResults);
                end
            else

                lResults=matlab.system.SourceSet.parsePolicyFromNameValueList(varargin{:});

                tempStr.pReuseProperty=lResults.ReuseProperty;
                defResults.ControlName=lResults.ControlName;
                defResults.IsControlActive=false;

                if tempStr.pReuseProperty
                    defResults.PolicyName='Property';
                else
                    defResults.PolicyName='Disabled';
                end

                policyClient=varargin{2};
                switch policyClient
                case 'MATLAB'
                    tempStr.MATLABPolicy=matlab.system.SourceSet.createPoliciesFromResults(lResults);
                    defResults.Client='SystemBlock';
                    tempStr.SystemBlockPolicy=matlab.system.SourceSet.createPoliciesFromResults(defResults);

                case 'SystemBlock'
                    tempStr.SystemBlockPolicy=matlab.system.SourceSet.createPoliciesFromResults(lResults);
                    defResults.Client='MATLAB';
                    tempStr.MATLABPolicy=matlab.system.SourceSet.createPoliciesFromResults(defResults);

                otherwise
                    error(message('MATLAB:system:badSourceSetPolicyClient',policyClient));
                end
            end

            matlab.system.SourceSet.checkIllegalPolicies(...
            tempStr.MATLABPolicy,tempStr.SystemBlockPolicy,lResults.DisableValidation);

            if enableIdentCheck
                matlab.system.SourceSet.checkIdenticalPolicies(...
                tempStr.MATLABPolicy,tempStr.SystemBlockPolicy,lResults.DisableValidation);
            end

            Reuse=lResults.ReuseProperty;

            mlPolicyCells=convertPolicyToCells(tempStr.MATLABPolicy);
            sbPolicyCells=convertPolicyToCells(tempStr.SystemBlockPolicy);

        end

        function[mlPolicy,sbPolicy]=checkIllegalPolicies(mlPolicy,sbPolicy,disableValidation)

            if disableValidation
                return
            end


            if~isempty(mlPolicy)
                mlPolicyName=mlPolicy.Name;
                if strcmp(mlPolicyName,'PropertyOrInput')||strcmp(mlPolicyName,'PropertyOrMethod')
                    error(message('MATLAB:system:badMATLABSourceSetPolicyName',mlPolicyName));
                end
            end

        end

        function[mlPolicy,sbPolicy]=checkIdenticalPolicies(mlPolicy,sbPolicy,disableValidation)

            if disableValidation
                return
            end


            if~isempty(sbPolicy)&&~isempty(mlPolicy)
                mlPolicyName=mlPolicy.Name;
                sbPolicyName=sbPolicy.Name;
                if~isempty(mlPolicy)&&strcmp(mlPolicyName,'Property')&&strcmp(sbPolicyName,'Property')
                    error(message('MATLAB:system:doublePropertySourceSetPolicyName',mlPolicyName));
                end
            end
        end

        function policyObj=createPoliciesFromResults(parseRes)

            switch parseRes.PolicyName
            case 'Property'
                policyObj=matlab.system.internal.PropertyOnly(parseRes.Client,...
                parseRes.ControlName,parseRes.IsControlActive);

            case 'Disabled'
                policyObj=matlab.system.internal.DisabledOnly(parseRes.Client,...
                parseRes.ControlName,parseRes.IsControlActive);

            case 'PropertyOrInput'
                policyObj=matlab.system.internal.PropertyOrInput(parseRes.Client,...
                parseRes.ControlName,parseRes.InputOrdinal,...
                parseRes.InputLabel,parseRes.IsActive);

            case 'PropertyOrMethod'
                policyObj=matlab.system.internal.PropertyOrMethod(parseRes.Client,...
                parseRes.ControlName,parseRes.MethodName,parseRes.IsActive);

            otherwise
                error(message('MATLAB:system:badSourceSetPolicyName',parseRes.PolicyName));
            end
        end

        function lResults=parsePolicyFromNameValueList(varargin)

            strValidationFcn=@(x)validateattributes(x,{'char','string'},{'scalartext'});
            logicalValidationFcn=@(x)validateattributes(x,{'logical'},{'scalar'});
            posIntValidationFcn=@(x)validateattributes(x,{'numeric'},{'scalar','integer','positive'});

            p=inputParser;
            p.addRequired('PolicyName',strValidationFcn);
            p.parse(varargin{1});
            p.addRequired('Client',strValidationFcn);

            policyName=varargin{1};
            switch char(policyName)
            case{'Property','Disabled'}
                p.addOptional('ControlName','',strValidationFcn);
                p.addOptional('IsControlActive',false,logicalValidationFcn);
            case 'PropertyOrInput'
                p.addRequired('ControlName',strValidationFcn);
                p.addOptional('InputOrdinal',1,posIntValidationFcn);
                p.addOptional('InputLabel','',strValidationFcn);
                p.addOptional('IsActive',true,logicalValidationFcn);
            case 'PropertyOrMethod'
                p.addRequired('ControlName',strValidationFcn);
                p.addRequired('MethodName',strValidationFcn);
                p.addOptional('IsActive',true,logicalValidationFcn);
            otherwise
                error(message('MATLAB:system:badSourceSetPolicyName',policyName));
            end
            p.addParameter('ReuseProperty',true,logicalValidationFcn);
            p.addParameter('DisableValidation',false,logicalValidationFcn);
            p.parse(varargin{:});
            lResults=p.Results;



            switch policyName
            case{'Property','Disabled'}
                if isfield(lResults,'ControlName')&&...
                    strcmp(lResults.ControlName,'ReuseProperty')
                    error(message('MATLAB:system:srcSetReusePropArgList'));
                end
            case 'PropertyOrInput'
                if isfield(lResults,'InputLabel')&&...
                    strcmp(lResults.InputLabel,'ReuseProperty')
                    error(message('MATLAB:system:srcSetReusePropArgList'));
                end
            case 'PropertyOrMethod'
            otherwise
                error(message('MATLAB:system:badSourceSetPolicyName',policyName));
            end
        end

        function lResults=parseInputAsCellArray(varargin)
            p=inputParser;
            logicalValidationFcn=@(x)validateattributes(x,{'logical'},{'scalar'});
            cellValidationFcn=@(x)validateattributes(x,{'cell'},{'row'});


            p.addRequired('FirstPolicy',cellValidationFcn);
            p.addOptional('SecondPolicy',{},cellValidationFcn);
            p.addParameter('ReuseProperty',true,logicalValidationFcn);
            p.addParameter('DisableValidation',false,logicalValidationFcn);
            p.KeepUnmatched=true;
            p.parse(varargin{:});
            lResults=p.Results;
        end

        function[matlabPolicy,systemBlockPolicy]=assignPoliciesFromCells(lResults)

            firstPolicy=lResults.FirstPolicy;
            clientName=firstPolicy{2};
            switch clientName
            case 'MATLAB'
                if~isempty(lResults.SecondPolicy)&&~strcmp('SystemBlock',lResults.SecondPolicy{2})
                    error(message('MATLAB:system:badSourceSetSecondPolicyName',...
                    clientName,'SystemBlock'));
                end
                matlabPolicy=lResults.FirstPolicy;
                systemBlockPolicy=lResults.SecondPolicy;

            case 'SystemBlock'
                if~isempty(lResults.SecondPolicy)&&~strcmp('MATLAB',lResults.SecondPolicy{2})
                    error(message('MATLAB:system:badSourceSetSecondPolicyName',...
                    clientName,'MATLAB'));
                end
                systemBlockPolicy=lResults.FirstPolicy;
                matlabPolicy=lResults.SecondPolicy;
            otherwise
                error(message('MATLAB:system:badSourceSetPolicyClient',clientName));
            end
        end
    end
end

function cells=convertPolicyToCells(policy)
    switch class(policy)
    case 'matlab.system.internal.PropertyOrInput'
        cells={policy.InputLabel,policy.InputOrdinal,[],policy.IsTargetPropertyActive,[],'PropertyOrInput',policy.Client,policy.ControlPropertyName};
    case 'matlab.system.internal.PropertyOrMethod'
        cells={policy.MethodName,[],policy.IsTargetPropertyActive,[],'PropertyOrMethod',policy.Client,policy.ControlPropertyName};
    case 'matlab.system.internal.PropertyOnly'
        cells={[],policy.IsControlPropertyActive,[],'Property',policy.Client,policy.ControlPropertyName};
    case 'matlab.system.internal.DisabledOnly'
        cells={[],policy.IsControlPropertyActive,[],'Disabled',policy.Client,policy.ControlPropertyName};
    otherwise

        assert(false);
    end
end
