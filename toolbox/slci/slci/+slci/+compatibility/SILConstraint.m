


classdef SILConstraint<slci.compatibility.Constraint

    methods(Static)

        function out=argDimensions(info,argType,argDataId)%#ok
            str=['info.',argType,'s.',argType,'(',num2str(argDataId),').Dimensions'];
            out=eval(str);
        end


    end

    methods

        function out=verifyArgs(aObj,info,fcn,side)
            out=[];
            for i=1:info.Fcns.(fcn).(side).NumArgs
                arg=info.Fcns.(fcn).(side).Arg(i);


                if strcmp(arg.Type,'SizeArg')
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'SFunctionMayNotHaveArgThatIsSizeArg',...
                    aObj.ParentBlock().getName());
                    return
                end

                dims=slci.compatibility.SILConstraint.argDimensions(info,arg.Type,arg.DataId);

                if dims==-1
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'SFunctionMayNotHaveArgThatIsDynamicallySized',...
                    aObj.ParentBlock().getName());
                    return
                end


                if size(dims)>1
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'SFunctionMayNotHaveArgThatIsMatrix',...
                    aObj.ParentBlock().getName());
                    return
                end

            end
        end

        function out=verifyFunction(aObj,info,fcn)
            out=aObj.verifyArgs(info,fcn,'RhsArgs');
            if~isempty(out)
                return
            end
            out=aObj.verifyArgs(info,fcn,'LhsArgs');
            if~isempty(out)
                return
            end
        end


        function out=getDescription(aObj)%#ok
            out='S-Functions must be generated using the Legacy Code Tool,  may not have multiple dworks or use global variables for root input and output ports, and all arguments must be scalars, or vectors of fixed dimension';
        end

        function obj=SILConstraint()
            obj.setEnum('SIL');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            if nargin==3
                failureCode=varargin{2}.getCode;
            end
            id=strrep(class(aObj),'slci.compatibility.','');

            if status
                StatusText=DAStudio.message(['Slci:compatibility:',id,'Pass']);
            else
                StatusText=DAStudio.message(['Slci:compatibility:',failureCode,'MA']);
            end
            RecAction=DAStudio.message(['Slci:compatibility:',id,'RecAction']);
            SubTitle=DAStudio.message(['Slci:compatibility:',id,'SubTitle']);
            Information=DAStudio.message(['Slci:compatibility:',id,'Info']);
        end

        function out=check(aObj)
            out=[];%#ok
            sfunParams=aObj.ParentBlock().getParam('MaskPropertyNameString');
            if isempty(strfind(sfunParams,'XRelSourceFile'))...
                ||isempty(strfind(sfunParams,'XILSFunction'))...
                ||isempty(strfind(sfunParams,'ConfigName'))
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SFunctionMustBeLCT',...
                aObj.ParentBlock().getName());
                return
            end
            XFileSrc=aObj.ParentBlock().getParam('XRelSourceFile');
            configName=aObj.ParentBlock().getParam('ConfigName');
            if strcmp(XFileSrc,'')||~strcmp(configName,'Software-in-the-Loop (SIL)')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SFunctionMustBeLCT',...
                aObj.ParentBlock().getName());
                return
            end

            tlcFile=aObj.ParentBlock().getParam('XILSFunction');
            def=slci.internal.getSILSFunSpec(tlcFile);


            if isempty(def)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SFunctionSILSpecUnknown',...
                aObj.ParentBlock().getName());
                return
            end


            if~isempty(def.InitializeConditionsFcnSpec)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SFunctionMayNotHaveInitializeConditionsFcn',...
                aObj.ParentBlock().getName());
                return
            end




            if isfield(def,'GlobalVarSpec')
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SFunctionSILHasGlobalVarSpec',...
                aObj.ParentBlock().getName());
                return;
            end
            info=legacycode.util.lct_pGetFullInfoStructure(def,'c');


            if legacycode.lct.util.feature('newImpl')
                propName='DWorksInfo';
            else
                propName='DWorks';
            end


            if info.(propName).NumPWorks>0
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SFunctionMayNotHavePWorks',...
                aObj.ParentBlock().getName());
                return
            end


            if info.(propName).NumDWorks>1
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SFunctionMayNotHaveMultipleDWorks',...
                aObj.ParentBlock().getName());
                return
            end


            out=aObj.verifyFunction(info,'Output');
            if~isempty(out)
                return
            end
        end

    end
end


