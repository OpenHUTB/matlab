

classdef ParamValueConstraint<slci.compatibility.Constraint

    properties(Access=private)




        fChecks={};


        fAllChecks={'ChkComplexParam','ChkNonFiniteParam','ChkLUTParam'};


        fPropertyName='';
    end

    methods(Access=private)

        function setPropertyName(aObj,aPropertyName)
            assert(isa(aPropertyName,'char')&&~isempty(aPropertyName),...
            'PropertyName must be non-empty string');
            aObj.fPropertyName=aPropertyName;
        end

        function out=getPropertyName(aObj)
            out=aObj.fPropertyName;
        end


        function parameterValues=getParameters(aObj)
            parameterValue=get_param(aObj.ParentBlock().getSID,...
            aObj.getPropertyName);

            if isstruct(parameterValue)
                parameterValues=struct2cell(parameterValue);
                return;
            end







            pattern1='\[([^\]])*';
            pattern2='\(([^\)])*';
            pattern3='\{([^\}])*';
            pattern=['(?<!(',pattern1,'|',pattern2,'|',pattern3,')),'];
            parameterValues=regexp(parameterValue,pattern,'split');
        end

        function message=getStrings(aObj)

            numChecks=numel(aObj.fChecks);
            messages=cell(numChecks,1);
            for k=1:numChecks
                checkName=aObj.fChecks{k};
                messages{k}=DAStudio.message(['Slci:compatibility:',checkName]);
            end


            message=[' ',messages{1}];
            if numChecks>1
                for k=2:numChecks-1
                    message=[message,' , ',messages{k}];%#ok
                end
                message=[message,' or ',messages{end}];
            end
        end

    end

    methods

        function out=getDescription(aObj)
            out=['Check the parameter value ',aObj.getPropertyName()...
            ,' value for possible violations'];
        end

        function obj=ParamValueConstraint(aPropertyName,varargin)
            obj.setEnum('ParamValue');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
            obj.setPropertyName(aPropertyName);
            if nargin>1
                obj.fChecks=varargin;

                diffChecks=setdiff(obj.fChecks,obj.fAllChecks);
                assert(isempty(diffChecks),'Invalid checks specified');
            else

                obj.fChecks=obj.fAllChecks;
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=...
            getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            if nargin==3
                failureCode=varargin{2}.getCode;
            end
            id=strrep(class(aObj),'slci.compatibility.','');

            if status
                StatusText=DAStudio.message(['Slci:compatibility:',id,'Pass']);
            else
                StatusText=DAStudio.message(['Slci:compatibility:',id,failureCode,'MAWarn']);
            end

            RecAction=DAStudio.message(['Slci:compatibility:',id,'RecAction']);
            RecAction=[RecAction,aObj.getStrings];

            SubTitle=DAStudio.message(['Slci:compatibility:',id,'SubTitle']);

            Information=DAStudio.message(['Slci:compatibility:',id,'Info']);
            Information=[Information,aObj.getStrings];
        end

        function out=check(aObj)

            out=[];
            parameters=aObj.getParameters();
            if~isempty(parameters)

                sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
                numParams=numel(parameters);
                for idx=1:numParams
                    paramstr=parameters{idx};
                    try
                        if strcmp(aObj.ParentBlock().getParam('Mask'),'on')
                            param=slResolve(paramstr,aObj.ParentBlock().getSID(),...
                            'expression','startUnderMask');
                        else
                            param=slResolve(paramstr,aObj.ParentBlock().getSID());
                        end
                    catch ex %#ok


                        continue;
                    end

                    if~isempty(param)
                        out=aObj.ChkParam(param);
                        if~isempty(out)

                            return;
                        end
                    end
                end
                delete(sess);
            end
        end

    end

    methods(Access=private)

        function out=ChkParam(aObj,param)%#ok
            numChecks=numel(aObj.fChecks);
            for k=1:numChecks
                mName=aObj.fChecks{k};
                cmd=['out = aObj.',mName,'( param );'];
                eval(cmd);
                if~isempty(out)

                    return;
                end
            end
        end

        function out=ChkComplexParam(aObj,param)
            out=[];
            if isnumeric(param)&&~isreal(param)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'ComplexParameter',...
                aObj.getPropertyName(),...
                aObj.ParentBlock().getName());
            end
        end

        function out=ChkNonFiniteParam(aObj,param)
            out=[];
            if isnumeric(param)&&...
                (any(isinf(param(:)))||...
                any(isnan(param(:))))
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'NonFiniteParameter',...
                aObj.getPropertyName(),...
                aObj.ParentBlock().getName());
            end
        end



        function out=ChkLUTParam(aObj,param)
            out=[];
            if isa(param,'Simulink.LookupTable')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'LUTParameter',...
                aObj.getPropertyName(),...
                aObj.ParentBlock().getName());
            end
        end
    end


end
