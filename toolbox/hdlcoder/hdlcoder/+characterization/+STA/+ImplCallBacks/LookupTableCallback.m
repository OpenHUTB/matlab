
classdef LookupTableCallback<characterization.STA.ImplementationCallback





    methods
        function self=LookupTableCallback()
            self@characterization.STA.ImplementationCallback();
        end

        function preprocessModelDependentParams(~,modelInfo)

        end


        function expr=tableDataExpr(~,N1,N2)
            expr=sprintf('reshape(repmat([1:%d],%d,1), %d, %d)',N1,N2,N2,N1);
        end


        function preprocessWidthSettings(self,modelInfo)

            dims=modelInfo.modelDependantParams('NumberOfTableDimensions');
            if(strcmp(dims{1},'1')==true)
                self.handleSingleDim(modelInfo);
            else
                self.handleDoubleDim(modelInfo);
            end
        end

        function handleDoubleDim(self,modelInfo)
            width_t=modelInfo.wmap(1);
            width=width_t{1};
            width2=width;
            N1=pow2(width);
            if(width>8)
                width2=16-width;
                if(width2==0)
                    width2=1;
                end
            end

            N2=pow2(width2);

            tdExpr=tableDataExpr(self,N1,N2);
            modelInfo.modelIndependantParams('Table')={tdExpr,characterization.ParamDesc.SIMULINK_PARAM};
            modelInfo.modelIndependantParams('BreakpointsForDimension1')={sprintf('[10:4:4*%d+9]',N2),characterization.ParamDesc.SIMULINK_PARAM};
            modelInfo.modelIndependantParams('BreakpointsForDimension2')={sprintf('[10:4:4*%d+9]',N1),characterization.ParamDesc.SIMULINK_PARAM};
            modelInfo.wmap(1)={width_t{1},'fixdt(1,24,0)'};
            modelInfo.wmap(2)={width_t{1},'fixdt(1,24,0)'};
        end


        function handleSingleDim(self,modelInfo)
            width_t=modelInfo.wmap(1);
            width=width_t{1};
            N1=pow2(width);
            tdExpr=tableDataExpr(self,N1,1);
            modelInfo.modelIndependantParams('Table')={tdExpr,characterization.ParamDesc.SIMULINK_PARAM};
            modelInfo.modelIndependantParams('BreakpointsForDimension1')={sprintf('[10:4:4*%d+9]',N1),characterization.ParamDesc.SIMULINK_PARAM};
            modelInfo.wmap(1)={width_t{1},'fixdt(1,24,0)'};
        end

    end

end
