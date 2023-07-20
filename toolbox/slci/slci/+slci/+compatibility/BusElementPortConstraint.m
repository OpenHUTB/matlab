

classdef BusElementPortConstraint<slci.compatibility.NegativeBlockParameterConstraint



    methods


        function out=getDescription(aObj)%#ok
            out='Inport or Outport in the model is In Bus Element block';
        end

        function obj=BusElementPortConstraint(aFatal,aParameterName,aParamValue)
            obj=obj@slci.compatibility.NegativeBlockParameterConstraint(aFatal,aParameterName,aParamValue);
            obj.setEnum('BusElementPort');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end

            blkType=aObj.ParentBlock.getParam('BlockType');
            if strcmpi(blkType,'Inport')
                suggestion='Bus Selector';
                blkName='In Bus Element';
            else
                suggestion='Bus Creator';
                blkName='Out Bus Element';
            end
            Information=DAStudio.message('Slci:compatibility:BusElementPortConstraintInfo',blkType,blkName);
            SubTitle=DAStudio.message('Slci:compatibility:BusElementPortConstraintSubTitle',blkType,blkName);

            RecAction=DAStudio.message('Slci:compatibility:BusElementPortConstraintRecAction',blkType,blkName,suggestion);
            StatusText=DAStudio.message(['Slci:compatibility:BusElementPortConstraint',status],blkName);
        end

    end
end
