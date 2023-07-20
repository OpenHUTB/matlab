classdef(Sealed)LUTBlockTypeValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    methods(Access=?FunctionApproximation.internal.AbstractUtils)
        function this=LUTBlockTypeValidator()
        end
    end

    methods
        function success=validate(this,blockPath)
            success=FunctionApproximation.internal.Utils.getBlockType(blockPath)...
            ==FunctionApproximation.internal.BlockType.LUT;

            if success
                blockObject=get_param(blockPath,'Object');
                if strcmp(blockObject.UseOneInputPortForAllInputData,'on')&&(slResolve(blockObject.NumberOfTableDimensions,blockObject.Handle)>1)
                    success=false;
                    this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidBlockPath'));
                    this.Diagnostic=this.Diagnostic.addCause(MException(message('SimulinkFixedPoint:functionApproximation:useOneInputPortForAllInputData')));
                elseif strcmp(blockObject.InterpMethod,'Cubic spline')
                    success=false;
                    this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidBlockPath'));
                    this.Diagnostic=this.Diagnostic.addCause(MException(message('SimulinkFixedPoint:functionApproximation:interpMethodCubicSpline')));
                elseif~this.isAllDataFromLUTBlock(blockObject)
                    success=false;
                    this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidBlockPath'));
                    this.Diagnostic=this.Diagnostic.addCause(MException(message('SimulinkFixedPoint:functionApproximation:allDataMustBeFromLUTBlock')));
                end
            else
                this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:invalidBlockPath'));
            end
        end
    end

    methods(Static)
        function result=isAllDataFromLUTBlock(blockObject)
            result=true;

            if~strcmp(blockObject.DataSpecification,'Lookup table object')
                numDimensions=slResolve(blockObject.NumberOfTableDimensions,blockObject.Handle);

                result=strcmp(blockObject.TableSource,'Dialog');
                if result
                    prefixForParameter='BreakpointsForDimension';
                    suffixForParameter='Source';
                    for d=1:numDimensions





                        parameterName=[prefixForParameter,int2str(d),suffixForParameter];
                        if isprop(blockObject,parameterName)&&~strcmp(blockObject.(parameterName),'Dialog')
                            result=false;
                            break;
                        end
                    end
                end
            end
        end
    end
end
